module EventList.Update where

import Event.Model exposing (Event)
import EventList.Model as EventList exposing (initialModel, Model)

type Action
  = FilterEvents String
  -- Select event might get values from JS (i.e. selecting a leaflet marker)
  -- so we allow passing a Maybe Int, instead of just Int.
  | SelectEvent (Maybe Int)
  | UnSelectEvent

type alias Model = EventList.Model

init : Model
init = initialModel


update : List Event -> Action -> Model -> Model
update events action model =
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
