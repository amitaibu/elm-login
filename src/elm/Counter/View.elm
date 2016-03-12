module Counter.View where

import Counter.Model as Counter exposing (Model)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)

view : Model -> Html
view model =
      span [ class "counter" ] [ text (toString model) ]
