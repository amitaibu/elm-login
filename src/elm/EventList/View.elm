module EventList.View (view) where

import Event.Model as Event exposing (Event)
import EventAuthorFilter.Model as EventAuthorFilter exposing (Model)
import EventList.Model as EventList exposing (initialModel, Model)
import EventList.Update exposing (Action)
import EventList.Utils exposing (filterByAuthorAndSearchString)

import Html exposing (a, div, input, text, select, span, li, option, ul, Html)
import Html.Attributes exposing (class, hidden, href, id, placeholder, selected, style, value)
import Html.Events exposing (on, onClick, targetValue)

type alias Context =
  { authorFilter : EventAuthorFilter.Model
  , events : List Event
  }

type alias Model = EventList.Model

view : Context -> Signal.Address Action -> Model -> Html
view context address model =
  let
    events' =
      filterByAuthorAndSearchString context.events context.authorFilter model.filterString

  in
    div []
        [ div [class "h2"] [ text "Event list"]
        , (viewFilterString address model)
        , (viewListEvents events' address model)
        ]

viewFilterString : Signal.Address Action -> Model -> Html
viewFilterString address model =
  div []
    [ input
        [ placeholder "Filter events"
        , value model.filterString
        , on "input" targetValue (Signal.message address << EventList.Update.FilterEvents)
        ]
        []
    ]


viewListEvents : List Event -> Signal.Address Action -> Model -> Html
viewListEvents events address model =
  let
    -- filteredEvents =
    --   filterListEvents model
    filteredEvents =
      events

    hrefVoid =
      href "javascript:void(0);"

    eventSelect event =
      li []
        [ a [ hrefVoid , onClick address (EventList.Update.SelectEvent <| Just event.id) ] [ text event.label ] ]

    eventUnselect event =
      li []
        [ span []
          [ a [ href "javascript:void(0);", onClick address (EventList.Update.UnSelectEvent) ] [ text "x " ]
          , text event.label
          ]
        ]

    getListItem : Event -> Html
    getListItem event =
      case model.selectedEvent of
        Just id ->
          if event.id == id
            then eventUnselect(event)
            else eventSelect(event)

        Nothing ->
          eventSelect(event)
  in
    if List.isEmpty filteredEvents
      then
        div [] [ text "No results found"]
      else
        ul [] (List.map getListItem filteredEvents)
