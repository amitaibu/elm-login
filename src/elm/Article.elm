module Article where

import Config exposing (cacheTtl)
import ConfigType exposing (BackendConfig)
import Effects exposing (Effects)
import Html exposing (div, text, Html)
import Html.Attributes exposing (class)
import Http exposing (post)
import Json.Decode as JD exposing ((:=))
import String exposing (toInt, toFloat)
import Task  exposing (andThen, Task)
import TaskTutorial exposing (getCurrentTime)
import Time exposing (Time)

import Debug

-- MODEL

type alias Id = Int

type Status =
  Init
  | Fetching
  | Fetched Time.Time
  | HttpError Http.Error


type alias Author =
  { id : Id
  , name : String
  }

type alias Article =
  { id : Id
  , label : String
  , body : String
  , author : Author
  }

type alias Model =
  { articles : List Article
  , status : Status
  }

initialModel : Model
initialModel =
  { articles = []
  , status = Init
  }

init : (Model, Effects Action)
init =
  ( initialModel
  , Effects.none
  )


-- UPDATE

type Action
  = Activate
  | GetData
  | GetDataFromServer
  | NoOp
  | UpdateDataFromServer (Result Http.Error (List Article)) Time.Time

type alias UpdateContext =
  { accessToken : String
  , backendConfig : BackendConfig
  }

update : UpdateContext -> Action -> Model -> (Model, Effects Action)
update context action model =
  case action of
    NoOp ->
      (model, Effects.none)

    GetData ->
      let
        noFx =
          (model, Effects.none)

        getFx =
          (model, getDataFromCache model.status)
      in
      case model.status of
        Fetching ->
          noFx

        _ ->
          getFx

    GetDataFromServer ->
      let
        backendUrl =
          (.backendConfig >> .backendUrl) context

        url =
          backendUrl ++ "/api/v1.0/articles"
      in
        ( { model | status <- Fetching }
        , getJson url context.accessToken
        )

    UpdateDataFromServer result timestamp' ->
      case result of
        Ok articles ->
          ( { model
            | articles <- articles
            , status <- Fetched timestamp'
            }
          , Effects.none
          )

        Err msg ->
          ( { model | status <- HttpError msg }
          , Effects.none
          )

    Activate ->
        ( model
        , Task.succeed Activate |> Effects.task
        )

-- VIEW

view :Signal.Address Action -> Model -> Html
view address model =
  div [] [ text "Articles"]

-- EFFECTS

getDataFromCache : Status -> Effects Action
getDataFromCache status =
  let
    actionTask =
      case status of
        Fetched fetchTime ->
          Task.map (\currentTime ->
            if fetchTime + Config.cacheTtl > currentTime
              then NoOp
              else GetDataFromServer
          ) getCurrentTime

        _ ->
          Task.succeed GetDataFromServer

  in
    Effects.task actionTask


getJson : String -> String -> Effects Action
getJson url accessToken =
  let
    params =
      [ ("access_token", accessToken) ]

    encodedUrl = Http.url url params

    httpTask =
      Task.toResult <|
        Http.get decodeData encodedUrl

    actionTask =
      httpTask `andThen` (\result ->
        Task.map (\timestamp' ->
          UpdateDataFromServer result timestamp'
        ) getCurrentTime
      )

  in
    Effects.task actionTask


decodeData : JD (List Aricle)
decodeData =
  let
    -- Cast String to Int.
    number : JD.Decoder Int
    number =
      JD.oneOf [ JD.int, JD.customDecoder JD.string String.toInt ]


    numberFloat : JD.Decoder Float
    numberFloat =
      JD.oneOf [ JD.float, JD.customDecoder JD.string String.toFloat ]

    author =
      JD.object2 Author
        ("id" := number)
        ("label" := JD.string)
  in
    JD.at ["data"]
      <| JD.list
      <| JD.object4 Article
        ("id" := number)
        ("label" := JD.string)
        ("body" := JD.string)
        ("user" := author)
