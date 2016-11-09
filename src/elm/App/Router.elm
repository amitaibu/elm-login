module App.Router exposing (delta2url, location2messages)

import App.Model exposing (..)
import App.Update exposing (..)
import Config exposing (configs)
import Dict exposing (..)
import Navigation exposing (Location)
import RouteUrl exposing (HistoryEntry(..), UrlChange)


delta2url : Model -> Model -> Maybe UrlChange
delta2url previous current =
    case current.activePage of
        AccessDenied ->
            Nothing

        Counter ->
            Just <| UrlChange NewEntry "/#counter"

        Login ->
            Just <| UrlChange NewEntry "/#login"

        MyAccount ->
            Just <| UrlChange NewEntry "/#my-account"

        PageNotFound ->
            Just <| UrlChange NewEntry "/#404"


location2messages : Location -> List Msg
location2messages location =
    let
        cmd =
            case location.hash of
                "" ->
                    []

                "#counter" ->
                    [ SetActivePage Counter ]

                "#login" ->
                    [ SetActivePage Login ]

                "#my-account" ->
                    [ SetActivePage MyAccount ]

                "#404" ->
                    [ SetActivePage PageNotFound ]

                _ ->
                    [ SetActivePage PageNotFound ]
    in
        getConfigFromLocation location :: cmd



-- @todo: We calcualte the config over and over again. It's not expensive
-- but redundent.


getConfigFromLocation : Location -> Msg
getConfigFromLocation location =
    case (Dict.get location.hostname configs) of
        Just val ->
            SetConfig val

        Nothing ->
            SetConfigError
