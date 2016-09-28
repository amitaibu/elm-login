module ArticleList.Update exposing (..)

import Article.Decoder exposing (decode)
import Article.Model as Article exposing (Model)
import ArticleList.Model exposing (initialModel, Model)
import Config exposing (cacheTtl)
import Config.Model exposing (BackendConfig)
import Http exposing (post, Error)
import Json.Decode as JD exposing ((:=))
import Task  exposing (andThen, Task)
import Time exposing (Time)

init : (ArticleList.Model.Model, Cmd Msg)
init =
  ( initialModel
  , Cmd.none
  )

type Msg
  = AppendArticle Article.Model
  | GetData
  | GetDataFromServer
  | NoOp
  | UpdateDataFromServer (Result Http.Error (List Article.Model)) Time.Time



type alias UpdateContext =
  { accessToken : String
  , backendConfig : BackendConfig
  }

update : UpdateContext -> Msg -> ArticleList.Model.Model -> (ArticleList.Model.Model, Cmd Msg)
update context action model =
  case action of
    AppendArticle article ->
      ( { model | articles = article :: model.articles }
      , Cmd.none
      )

    GetData ->
      let
        effects =
          case model.status of
            ArticleList.Model.Fetching ->
              Cmd.none

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
        ( { model | status = ArticleList.Model.Fetching }
        , getJson url context.accessToken
        )


    UpdateDataFromServer result timestamp' ->
      case result of
        Ok articles ->
          ( { model
            | articles = articles
            , status = ArticleList.Model.Fetched timestamp'
            }
          , Cmd.none
          )

        Err err ->
          ( { model | status = ArticleList.Model.HttpError err }
          , Cmd.none
          )

    NoOp ->
      (model, Cmd.none)

-- EFFECTS

getDataFromCache : ArticleList.Model.Status -> Cmd Msg
getDataFromCache status =
  let
    actionTask =
      case status of
        ArticleList.Model.Fetched fetchTime ->
          Task.map (\currentTime ->
            if fetchTime + Config.cacheTtl > currentTime
              then NoOp
              else GetDataFromServer
          ) Time.now

        _ ->
          Task.succeed GetDataFromServer

  in
    Cmd.task actionTask


getJson : String -> String -> Cmd Msg
getJson url accessToken =
  let
    params =
      [ ("access_token", accessToken)
      , ("sort", "-id")
      ]

    encodedUrl = Http.url url params

    httpTask =
      Task.toResult <|
        Http.get decodeData encodedUrl

    actionTask =
      httpTask `andThen` (\result ->
        Task.map (\timestamp' ->
          UpdateDataFromServer result timestamp'
        ) Time.now
      )

  in
    Cmd.task actionTask


decodeData : JD.Decoder (List Article.Model)
decodeData =
  JD.at ["data"] <| JD.list <| Article.Decoder.decode
