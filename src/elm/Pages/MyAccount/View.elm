module Pages.MyAccount.View exposing (view)

import RemoteData exposing (RemoteData(..), WebData)
import Html exposing (a, div, h2, i, p, text, img, Html)
import Html.Attributes exposing (class, href, src)
import User.Model exposing (..)


-- VIEW


view : WebData User -> Html a
view user =
    let
        ( name, login, avatar ) =
            case user of
                Success val ->
                    let
                        name' =
                            case val.name of
                                Just name ->
                                    name

                                Nothing ->
                                    val.login
                    in
                        ( name', val.login, img [ src val.avatarUrl ] [] )

                _ ->
                    ( "", "", div [] [] )
    in
        div [ class "ui centered card" ]
            [ div [ class "image" ] [ avatar ]
            , div [ class "content" ]
                [ div [ class "header" ] [ text <| "Welcome " ++ name ]
                , div [ class "meta" ] [ text <| "@" ++ login ]
                ]
            ]
