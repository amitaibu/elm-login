module User where

import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, targetValue)
import Http
import Json.Decode as Json exposing ((:=))
import String exposing (length)
import Task


import Debug


-- MODEL

type alias Id = Int
type alias AccessToken = String

type User = Anonymous | LoggedIn String

type alias Model =
  { user : User
  , id : Id
  , isFetching : Bool
  }

init : (Model, Effects Action)
init =
  ( Model Anonymous 0 False
  , Effects.none
  )


-- UPDATE

type Action
  = GetDataFromServer
  | UpdateDataFromServer (Result Http.Error AccessToken)


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    GetDataFromServer ->
      let
        url : String
        -- @todo: Use /api/me
        url = "http://localhost/d7_dev/api/users/1"
      in
      ( { model | isFetching <- True}
      , getJson url
      )

    UpdateDataFromServer result ->
      let
        newModel  = { model | isFetching <- False}
      in
        case result of
          Ok (id, name) -> ({newModel | id <- id, user: name}, Effects.none)
          Err msg -> (newModel, Effects.none)

-- VIEW

(=>) = (,)

view : Signal.Address Action -> Model -> Html
view address model =
  div [class "container"]
    [ div [] [text ("ID: " ++ model.id)]
    ]

-- EFFECTS


getJson : String -> String -> Effects Action
getJson url accessToken =
  Http.send Http.defaultSettings
    { verb = "GET"
    , headers = [("access-token", accessToken)]
    , url = url
    , body = Http.empty
    }
    |> Http.fromJson decodeAccessToken
    |> Task.toResult
    |> Task.map UpdateDataFromServer
    |> Effects.task


decodeAccessToken : Json.Decoder (Id, String)
decodeAccessToken =
  Json.at ["data", "0"]
    <| Json.map2 Json.string
      ("id" := Json.id)
      ("label" := Json.string)
