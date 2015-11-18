module Article where

import Config exposing (cacheTtl)
import ConfigType exposing (BackendConfig)
import Effects exposing (Effects)
import Html exposing (div, li, text, ul, Html)
import Html.Attributes exposing (class, style)
import Http exposing (post)
import Json.Decode as JD exposing ((:=))
import String exposing (toInt, toFloat)
import Task  exposing (andThen, Task)
import TaskTutorial exposing (getCurrentTime)
import Time exposing (Time)
import Utils.Http exposing (getErrorMessageFromHttpResponse)


import Debug

-- MODEL

type alias Id = Int

type Status =
  Init
  | Fetching
  | Fetched Time.Time
  | HttpError Http.Error

type UserMessage
  = None
  | Error String


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

type alias ArticleForm =
  { label : String
  , body : String
  }

initialArticleForm : ArticleForm
initialArticleForm =
  { label = ""
  , body = ""
  }

type alias Model =
  { articleForm : ArticleForm
  , articles : List Article
  , status : Status
  , userMessage : UserMessage
  }

initialModel : Model
initialModel =
  { articleForm = initialArticleForm
  , articles = []
  , status = Init
  , userMessage = None
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
  | SetUserMessage UserMessage
  | UpdateDataFromServer (Result Http.Error (List Article)) Time.Time

type alias UpdateContext =
  { accessToken : String
  , backendConfig : BackendConfig
  }

update : UpdateContext -> Action -> Model -> (Model, Effects Action)
update context action model =
  case action of
    Activate ->
      ( model
      , Task.succeed GetData |> Effects.task
      )

    GetData ->
      let
        effects =
          case model.status of
            Fetching ->
              Effects.none

            _ ->
              getDataFromCache model.status
      in
        ( model
        , effects
        )


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


    NoOp ->
      (model, Effects.none)

    SetUserMessage userMessage ->
      ( { model | userMessage <- userMessage }
      , Effects.none
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

        Err err ->
          let
            message =
              getErrorMessageFromHttpResponse err
          in
            ( { model | status <- HttpError err }
            , Task.succeed (SetUserMessage <| Error message) |> Effects.task
            )

-- VIEW

view :Signal.Address Action -> Model -> Html
view address model =
  div [class "container"]
    [ viewUserMessage model.userMessage
    , div [] [ text "Recent articles"]
    , ul  [] (List.map viewArticles model.articles)
    ]

viewUserMessage : UserMessage -> Html
viewUserMessage userMessage =
  case userMessage of
    None ->
      div [] []
    Error message ->
      div [ style [("text-align", "center")]] [ text message ]

viewArticles : Article -> Html
viewArticles article =
  li [] [ text article.label ]

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


decodeData : JD.Decoder (List Article)
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
