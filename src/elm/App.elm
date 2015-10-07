module App where


import Company exposing (..)
import Effects exposing (Effects, Never)
import Event exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Task exposing (..)
import User exposing (..)

import Debug

-- MODEL

type alias AccessToken = String

type alias Model =
  { user : User.Model
  , companies : List Int
  , events : Event.Model
  }

initialModel : Model
initialModel =
  { user = User.initialModel
  , companies = []
  , events = Event.initialModel
  }

init : (Model, Effects Action)
init =
  let
    eventEffects = snd Event.init
    userEffects = snd User.init
  in
    ( initialModel
    , Effects.batch
      [ Effects.map ChildEventAction eventEffects
      , Effects.map ChildUserAction userEffects
      ]
    )

-- UPDATE

type Action
  = ChildEventAction Event.Action
  | ChildUserAction User.Action
  | UpdateCompanies (List Int)

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    ChildEventAction act ->
      let
        -- Pass the access token along to child components.
        context = { accessToken = (.user >> .accessToken) model }
        (childModel, childEffects) = Event.update context act model.events
      in
        ( {model | events <- childModel }
        , Effects.map ChildEventAction childEffects
        )

    ChildUserAction act ->
      let
        (childModel, childEffects, childContext) = User.update act model.user

        effects =
          [ Effects.map ChildUserAction childEffects
          -- @todo: Where to move this so it's invoked on time?
          , Task.succeed (ChildEventAction Event.GetDataFromServer) |> Effects.task
          ]

        effects' =
          case act of
            User.UpdateDataFromServer _ ->
              (Task.succeed (UpdateCompanies childContext.companies) |> Effects.task) :: effects

            _ ->
              effects
      in
        ( { model | user <- childModel }
        , Effects.batch effects'

        )

    UpdateCompanies companies ->
      let
        d = Debug.log "UpdateCompanies" companies
      in
      ( { model | companies <- companies}
      , Effects.none
      )

-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  case model.user.name of
    Anonymous ->
      let
        childAddress =
          Signal.forwardTo address ChildUserAction
      in
        div [ style myStyle ] [ User.view childAddress model.user ]

    LoggedIn name ->
      let
        childAddress =
          Signal.forwardTo address ChildEventAction
      in
        div [ style myStyle ] [ Event.view childAddress model.events ]

rootModelView : Model -> Html
rootModelView model =
  div [] []

myStyle : List (String, String)
myStyle =
    [ ("padding", "10px")
    , ("margin", "50px")
    , ("font-size", "2em")
    ]
