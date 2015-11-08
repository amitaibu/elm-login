module RestrictedPage where

import Effects exposing (Effects)
import Html exposing (div, text, Html)
import RouteHash exposing (HashUpdate)

import Debug

-- MODEL

type alias Model =
  {}


initialModel : Model
initialModel =
  {}

init : (Model, Effects Action)
init =
  ( initialModel
  , Effects.none
  )


-- UPDATE

type Action
  = Activate
  | Deactivate

type User = Anonymous | LoggedIn String

type alias Context =
  { name : User }

update : Context -> Action -> Model -> (Model, Effects Action)
update context action model =
  case action of
    Activate ->
      (model, Effects.none)

    Deactivate ->
      (model, Effects.none)


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  case model.name of
    Anonymous ->
      div [] [ text "This is wrong - anon user cannot reach this!"]

    LoggedIn name ->
      div [] [ text "This is wrong - anon user cannot reach this!"]


-- ROUTER

delta2update : Model -> Model -> Maybe HashUpdate
delta2update previous current =
  Just <| RouteHash.set []

location2action : List String -> List Action
location2action list =
  []
