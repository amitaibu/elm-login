module Leaflet.View exposing (..)

import Leaflet.Model exposing (initialModel, Model)
import Leaflet.Update exposing (Msg)

import Html exposing (div, span, Html)
import Html.Attributes exposing (id, style)

view : Signal.Address Msg -> Model -> Html
view address model =
  if model.showMap
    then div [ style myStyle, id "map" ] []
    -- We use span, so the div element will be completely removed.
    else span [] []

myStyle : List (String, String)
myStyle =
    [ ("width", "600px")
    , ("height", "400px")
    ]
