module Pages.Article.Update exposing (..)

import ArticleForm.Update exposing (Msg)
import ArticleList.Update exposing (Msg)
import Config.Model exposing (BackendConfig)
import Pages.Article.Model exposing (Model)
import Task exposing (succeed)

type Msg
  = Activate
  | ChildArticleFormAction ArticleForm.Update.Msg
  | ChildArticleListAction ArticleList.Update.Msg

type alias UpdateContext =
  { accessToken : String
  , backendConfig : BackendConfig
  }

init : (Model, Cmd Msg)
init =
  ( Pages.Article.Model.initialModel
  , Cmd.none
  )

update : UpdateContext -> Msg -> Pages.Article.Model.Model -> (Pages.Article.Model.Model, Cmd Msg)
update context action model =
  case action of
    Activate ->
        ( model
        , Task.succeed (ChildArticleListAction ArticleList.Update.GetData) |> Cmd.task
        )

    ChildArticleFormAction act ->
      let
        (childModel, childCmd, maybeArticle) = ArticleForm.Update.update context act model.articleForm

        defaultCmd =
          [ Cmd.map ChildArticleFormAction childCmd ]

        effects' =
          case maybeArticle of
            Just article ->
              (Task.succeed (ChildArticleListAction <| ArticleList.Update.AppendArticle article) |> Cmd.task)
              ::
              defaultCmd
            Nothing ->
              defaultCmd

      in

        ( { model | articleForm = childModel }
        , Cmd.batch effects'
        )

    ChildArticleListAction act ->
      let
        (childModel, childCmd) = ArticleList.Update.update context act model.articleList
      in
        ( { model | articleList = childModel }
        , Cmd.map ChildArticleListAction childCmd
        )
