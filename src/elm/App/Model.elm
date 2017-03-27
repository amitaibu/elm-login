module App.Model exposing (emptyModel, Model, Page(..))

import Config.Model exposing (Model)
import RemoteData exposing (RemoteData(..), WebData)
import User.Model exposing (..)
import Pages.Login.Model exposing (emptyModel, Model)


type Page
    = AccessDenied
    | Login
    | MyAccount
    | PageNotFound


type alias Model =
    { activePage : Page
    , config : RemoteData String Config.Model.Model
    , pageLogin : Pages.Login.Model.Model
    , user : WebData User
    }


emptyModel : Model
emptyModel =
    { activePage = Login
    , config = NotAsked
    , pageLogin = Pages.Login.Model.emptyModel
    , user = NotAsked
    }
