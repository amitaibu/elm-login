module App.Update exposing (init, update, Msg(..))

import App.Model exposing (..)
import Config.Model as Config
import Pages.Login.Update exposing (Msg)
import RemoteData exposing (RemoteData(..), WebData)
import User.Model exposing (..)


type Msg
    = Logout
    | PageLogin Pages.Login.Update.Msg
    | SetActivePage Page
    | SetConfig Config.Model
    | SetConfigError


init : ( Model, Cmd Msg )
init =
    emptyModel ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        backendUrl =
            case model.config of
                Success config ->
                    config.backendUrl

                _ ->
                    ""
    in
        case msg of
            Logout ->
                init

            PageLogin msg ->
                let
                    ( val, cmds, user ) =
                        Pages.Login.Update.update backendUrl model.user msg model.pageLogin

                    model' =
                        { model
                            | pageLogin = val
                            , user = user
                        }

                    model'' =
                        case user of
                            -- If user was successfuly fetched, reditect to my
                            -- account page.
                            Success _ ->
                                update (SetActivePage MyAccount) model'
                                    |> fst

                            _ ->
                                model'
                in
                    ( model'', Cmd.map PageLogin cmds )

            SetActivePage page ->
                { model | activePage = setActivePageAccess model.user page } ! []

            SetConfig config ->
                { model | config = Success config } ! []

            SetConfigError ->
                { model | config = Failure "No config found" } ! []


{-| Determine is a page can be accessed by a user (anonymous or authenticated),
and if not return a access denied page.

If the user is authenticated, don't allow them to revisit Login page. Do the
opposite for anonumous user - don't allow them to visit the MyAccount page.
-}
setActivePageAccess : WebData User -> Page -> Page
setActivePageAccess user page =
    case user of
        Success _ ->
            if page == Login then
                AccessDenied
            else
                page

        _ ->
            if page == MyAccount then
                AccessDenied
            else
                page
