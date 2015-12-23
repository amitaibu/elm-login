module EventList.Update where

import Event.Model as Event exposing (Event)
import EventList.Model as EventList exposing (initialModel, Model)
import String exposing (length)

init : Model
init = initialModel

type Action
  = FilterEvents String
  -- Select event might get values from JS (i.e. selecting a leaflet marker)
  -- so we allow passing a Maybe Int, instead of just Int.
  | SelectEvent (Maybe Int)
  | UnSelectEvent


update : Action -> Model -> Model
update action model =
  case action of
    FilterEvents val ->
      let
        model' = { model | filterString = val }

        selectedEvent' =
          case model.selectedEvent of
            Just val ->
              -- Determine if the selected event is visible and not filtered
              -- out.
              -- let
              --   isSelectedEvent =
              --     filterListEvents model'
              --       |> List.filter (\event -> event.id == val)
              --       |> List.length
              -- in
              --   if isSelectedEvent > 0
              --     then model.selectedEvent
              --     else Nothing
              Just val

            Nothing ->
              Nothing
      in
        { model' | selectedEvent = selectedEvent' }

    SelectEvent val ->
      { model | selectedEvent = val }

    UnSelectEvent ->
      { model | selectedEvent = Nothing }

-- -- Build the Leaflet's markers data from the events
-- leafletMarkers : Model -> List Leaflet.Model.Marker
-- leafletMarkers model =
--   filterListEvents model
--     |> List.map (\event -> Leaflet.Model.Marker event.id event.marker.lat event.marker.lng)
--

-- -- In case an author or string-filter is selected, filter the events.
-- filterListEvents : Model -> List Event
-- filterListEvents model =
--   let
--     authorFilter : List Event -> List Event
--     authorFilter events =
--       case model.eventAuthorFilter of
--         Just id ->
--           List.filter (\event -> event.author.id == id) events
--
--         Nothing ->
--           events
--
--     stringFilter : List Event -> List Event
--     stringFilter events =
--       if String.length (String.trim model.filterString) > 0
--         then
--           List.filter (\event -> String.contains (String.trim (String.toLower model.filterString)) (String.toLower event.label)) events
--
--         else
--           events
--
--   in
--     authorFilter model.events
--      |> stringFilter
