module User where

import Company exposing (..)
import Config exposing (backendUrl)
import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, targetValue)
import Http
import Json.Decode as Json exposing ((:=))
import Login exposing (..)
import Storage exposing (removeItem)
import String exposing (length)
import Task

import Debug

-- MODEL

type alias Id = Int
type alias AccessToken = String

type User = Anonymous | LoggedIn String

type alias Model =
  { name : User
  , id : Id
  , isFetching : Bool
  , accessToken : AccessToken

  -- Child components
  , loginModel : Login.Model
  , companies : List Company.Model
  }


initialModel : Model
initialModel =
  Model Anonymous 0 False "" Login.initialModel [Company.initialModel]

init : (Model, Effects Action)
init =
  let
    loginEffects = snd Login.init
  in
    ( initialModel
    , Effects.map ChildLoginAction loginEffects
    )


-- UPDATE

type Action
  = NoOp (Maybe ())
  | GetDataFromServer
  | UpdateDataFromServer (Result Http.Error (Id, String, List Company.Model))
  | ChildLoginAction Login.Action
  | Logout
  -- @todo: Remove, as we don't use it
  | SetAccessToken AccessToken

  -- Page
  | Activate
  | Deactivate


type alias Context =
  { companies : List Company.Model}


update : Action -> Model -> (Model, Effects Action, Context)
update action model =
  let
    context = { companies = []}
  in
    case action of
      NoOp _ ->
        (model, Effects.none)

      GetDataFromServer ->
        let
          url : String
          url = Config.backendUrl ++ "/api/v1.0/me"
        in
          ( { model | isFetching <- True}
          , getJson url model.loginModel.accessToken
          , context
          )

      UpdateDataFromServer result ->
        let
          newModel  = { model | isFetching <- False}
        in
          case result of
            Ok (id, name, companies) ->
              ( {newModel
                  | id <- id
                  , name <- LoggedIn name
                  , companies <- companies
                }
              , Effects.none
              , context
              )
            Err msg -> (newModel, Effects.none)

      ChildLoginAction act ->
        let
          (childModel, childEffects) = Login.update act model.loginModel

          defaultEffects =
            [ Effects.map ChildLoginAction childEffects ]

          getDataFromServerEffects =
            (Task.succeed GetDataFromServer |> Effects.task) :: defaultEffects

          effects =
            case act of
              Login.UpdateAccessTokenFromServer result ->
                -- Call server only if token exists.
                if isAccessTokenInStorage result then getDataFromServerEffects else defaultEffects

              Login.UpdateAccessTokenFromStorage result ->
                -- Call server only if token exists.
                if isAccessTokenInStorage result then getDataFromServerEffects else defaultEffects


              _ ->
                defaultEffects
        in
          ( {model
              | loginModel <- childModel
              , accessToken <- childModel.accessToken
            }
          , Effects.batch effects
          , context
          )

      Logout ->
        ( model
        , removeStorageItem
        , context
        )

      SetAccessToken accessToken ->
        ( {model | accessToken <- accessToken}
        , Effects.none
        , context
        )

      Activate ->
        ( model
        , Effects.none
        , context
        )

      Deactivate ->
        ( model
        , Effects.none
        , context
        )


-- Determines if a call to the server should be done, based on having an access
-- token present.
isAccessTokenInStorage : Result err String -> Bool
isAccessTokenInStorage result =
  case result of
    -- If token is empty, no need to call the server.
    Ok token ->
      if String.isEmpty token then False else True

    Err _ ->
      False

-- Task to remove localStorage.
-- @todo: How to avoid NoOp, which isn't doing anything?
removeStorageItem : Effects Action
removeStorageItem =
  Storage.removeItem "access_token"
    |> Task.toMaybe
    |> Task.map NoOp
    |> Effects.task

-- VIEW

(=>) = (,)

view : Signal.Address Action -> Model -> Html
view address model =
  case model.name of
    Anonymous ->
      let
        childAddress =
            Signal.forwardTo address ChildLoginAction
      in
        div []
          [ Login.view childAddress model.loginModel
          ]

    LoggedIn name ->
      let
        italicName : Html
        italicName =
          em [] [text name]
      in
      div []
        [ div [] [ text "Welcome ", italicName ]
        , div [] [ text "Your companies are:"]
        , ul  [] (List.map viewCompanies model.companies)
        ]

viewCompanies : Company.Model -> Html
viewCompanies company =
  li [] [ text company.label ]

-- EFFECTS


getJson : String -> Login.AccessToken -> Effects Action
getJson url accessToken =
  let
    encodedUrl = Http.url url [ ("access_token", accessToken) ]
  in
    Http.send Http.defaultSettings
      { verb = "GET"
      , headers = []
      , url = encodedUrl
      , body = Http.empty
      }
      |> Http.fromJson decodeData
      |> Task.toResult
      |> Task.map UpdateDataFromServer
      |> Effects.task


decodeData : Json.Decoder (Id, String, List Company.Model)
decodeData =
  let
    -- Cast String to Int.
    number : Json.Decoder Int
    number =
      Json.oneOf [ Json.int, Json.customDecoder Json.string String.toInt ]

    company =
      Json.object2 Company.Model
        ("id" := number)
        ("label" := Json.string)
  in
  Json.at ["data", "0"]
    <| Json.object3 (,,)
      ("id" := number)
      ("label" := Json.string)
      ("companies" := Json.list company)
