module EventList.Utils (filterByAuthorAndSearchString) where

import EventAuthorFilter.Model as EventAuthorFilter exposing (Model)
import Event.Model exposing (Event)
import String exposing (length)


-- In case an author or string-filter is selected, filter the events.
filterByAuthorAndSearchString : List Event -> EventAuthorFilter.Model -> String -> List Event
filterByAuthorAndSearchString events authorFilter filterString =
  let
    events' =
      filterByAuthor events authorFilter
  in
     filterByString events' filterString

filterByAuthor : List Event -> EventAuthorFilter.Model -> List Event
filterByAuthor events authorFilter =
  case authorFilter of
    Just id ->
      List.filter (\event -> event.author.id == id) events

    Nothing ->
      events

filterByString : List Event -> String -> List Event
filterByString events filterString =
  let
    filterString' =
      String.trim filterString
  in
  if String.isEmpty filterString'
    then
      -- Return all the events.
      events

    else
      -- Filter out the events that do not contain the string.
      List.filter (\event -> String.contains (String.toLower filterString') (String.toLower event.label)) events
