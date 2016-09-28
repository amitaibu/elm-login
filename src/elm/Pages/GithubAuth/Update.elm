module Pages.GithubAuth.Update exposing (..)

import Config.Model exposing (BackendConfig)
import Dict exposing (get)
import Http exposing (Error)
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE exposing (..)
import Pages.GithubAuth.Model as GithubAuth exposing (initialModel, Model)
import Task exposing (map)
import UrlParameterParser exposing (ParseResult, parseSearchString)
import WebAPI.Location exposing (location)

type alias AccessToken = String

init : (Model, Cmd Msg)
init =
  ( initialModel
  , Cmd.none
  )


type Msg
  = Activate
  | AuthorizeUser String
  | SetError String
  | SetAccessToken AccessToken
  | UpdateAccessTokenFromServer (Result Http.Error AccessToken)

type alias UpdateContext =
  { backendConfig : BackendConfig
  }

update : UpdateContext -> Msg -> Model -> (Model, Cmd Msg)
update context action model =
  case action of
    Activate ->
      (model, getCodeFromUrl)

    AuthorizeUser code ->
      let
        backendUrl =
          (.backendConfig >> .backendUrl) context
      in
        ( model
        , getJson backendUrl code
        )

    SetError msg ->
      ( { model | status = GithubAuth.Error msg }
      , Cmd.none
      )

    SetAccessToken token ->
      ( { model | accessToken = token }
      , Cmd.none
      )

    UpdateAccessTokenFromServer result ->
      case result of
        Ok token ->
          ( { model | status = GithubAuth.Fetched }
          , Task.succeed (SetAccessToken token) |> Cmd.task
          )
        Err msg ->
          ( { model | status = GithubAuth.HttpError msg }
          -- @todo: Improve.
          , Task.succeed (SetError "HTTP error") |> Cmd.task
          )

-- EFFECTS

getCodeFromUrl : Cmd Msg
getCodeFromUrl =
  let
    errAction =
      SetError "code property is missing form URL."

    getAction location =
      case (parseSearchString location.search) of
        UrlParameterParser.UrlParams dict ->
          case (Dict.get "code" dict) of
            Just val ->
              AuthorizeUser val
            Nothing ->
              errAction

        UrlParameterParser.Error _ ->
          errAction

    actionTask =
      Task.map getAction WebAPI.Location.location
  in
    Cmd.task actionTask


getJson : String -> String -> Cmd Msg
getJson backendUrl code =
  Http.post
    decodeAccessToken
    (backendUrl ++ "/auth/github")
    (Http.string <| dataToJson code )
    |> Task.toResult
    |> Task.map UpdateAccessTokenFromServer
    |> Cmd.task


dataToJson : String -> String
dataToJson code =
  JE.encode 0
    <| JE.object
        [ ("code", JE.string code) ]

decodeAccessToken : JD.Decoder AccessToken
decodeAccessToken =
  JD.at ["access_token"] <| JD.string
