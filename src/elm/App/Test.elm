module App.Test exposing (all)

import ElmTest exposing (..)
import RemoteData exposing (RemoteData(..))
import App.Model exposing (..)
import App.Update exposing (..)


setActivePage : Test
setActivePage =
    suite "SetActivePage msg"
        [ test "set new active page"
            (assertEqual PageNotFound (getPageAsAnonymous PageNotFound))
        , test "set Login page for anonymous user"
            (assertEqual Login (getPageAsAnonymous Login))
        , test "set My account page for anonymous user"
            (assertEqual AccessDenied (getPageAsAnonymous MyAccount))
        , test "set Login page for authenticated user"
            (assertEqual AccessDenied (getPageAsAuthenticated Login))
        , test "set My account page for authenticated user"
            (assertEqual MyAccount (getPageAsAuthenticated MyAccount))
        ]


getPageAsAnonymous : Page -> Page
getPageAsAnonymous page =
    update (SetActivePage page) emptyModel
        |> fst
        |> .activePage


getPageAsAuthenticated : Page -> Page
getPageAsAuthenticated page =
    let
        dummyUser =
            { name = Just "Foo", login = "foo", avatarUrl = "https://example.com" }

        model =
            { emptyModel | user = Success dummyUser }
    in
        update (SetActivePage page) model
            |> fst
            |> .activePage


all : Test
all =
    suite "App tests"
        [ setActivePage
        ]
