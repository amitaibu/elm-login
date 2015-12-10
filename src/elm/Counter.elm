module Counter (..) where

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Effects exposing (Effects)

-- MODEL

type alias Model = Int


init : Int -> Model
init count = count



-- UPDATE

type Action = Increment


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of

    Increment ->
    ( model + 1
    , Effects.none
    )




-- VIEW

view :  Model -> Html
view  model =
  div []
    [div [ countStyle ] [ text (toString model) ]
    ]


countStyle : Attribute
countStyle =
  style
    [ ("font-size", "20px")
    , ("font-family", "monospace")
    , ("display", "inline-block")
    , ("width", "50px")
    , ("text-align", "center")
    ]
