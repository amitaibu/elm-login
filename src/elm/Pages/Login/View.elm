module Pages.Login.View exposing (view)

import RemoteData exposing (RemoteData(..), WebData)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import User.Model exposing (..)
import Pages.Login.Model exposing (..)
import Pages.Login.Update exposing (..)


view : WebData User -> Model -> Html Msg
view user model =
    let
        spinner =
            i [ class "notched circle loading icon" ] []

        ( isLoading, isError ) =
            case user of
                Loading ->
                    ( True, False )

                Failure _ ->
                    ( False, True )

                _ ->
                    ( False, False )

        inputClasses =
            classList
                [ ( "ui action input", True )
                , ( "error", isError )
                ]
    in
        Html.form
            [ onSubmit TryLogin
            , action "javascript:void(0);"
            , class "ui stacked segment"
            ]
            [ div [ inputClasses ]
                [ input
                    [ type' "text"
                    , placeholder "Github name"
                    , onInput SetLogin
                    , value model.login
                    ]
                    []
                  -- Submit button
                , button
                    [ onClick TryLogin
                    , disabled (isLoading || isError)
                    , class "ui primary button"
                    ]
                    [ span [ hidden <| not isLoading ] [ spinner ]
                    , span [ hidden isLoading ] [ text "Login" ]
                    ]
                ]
            ]
