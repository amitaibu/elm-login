module Leaflet where

import Effects exposing (Effects)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick)
import Task exposing (map)

-- MODEL

type alias Marker =
  { id : Int
  , lat : Float
  , lng : Float
  }

type alias Model =
  { markers : List Marker
  , selectedMarker : Maybe Int
  , showMap : Bool
  }


initialMarkers : List Marker
initialMarkers =
  []

initialModel : Model
initialModel =
  { markers = initialMarkers
  , selectedMarker = Nothing
  , showMap = True
  }

init : (Model, Effects Action)
init =
  ( initialModel
  , Effects.none
  )


-- UPDATE

type Action
  = ToggleMap
  | ToggleMarker (Maybe Int)
  | UnselectMarker


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    ToggleMap ->
      ( { model | showMap <- (not model.showMap) }
      , Effects.none
      )

    ToggleMarker val ->
      ( { model | selectedMarker <- val }
      , Effects.none
      )

    UnselectMarker ->
      ( { model | selectedMarker <- Nothing }
      , Effects.none
      )


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  let
    mapEl =
      if model.showMap
        then div [ style myStyle, id "map" ] []
        else span [] []
  in
  div []
    [ mapEl
    , button [ onClick address ToggleMap ] [ text "Toggle Map" ]
    , button
        [ onClick address UnselectMarker
        , disabled (model.selectedMarker == Nothing || not model.showMap)
        ]
        [ text "Unselect Marker" ]
    ]

myStyle : List (String, String)
myStyle =
    [ ("width", "600px")
    , ("height", "400px")
    ]
