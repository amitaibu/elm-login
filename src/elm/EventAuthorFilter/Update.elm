module EventAuthorFilter.Update exposing (..)

import EventAuthorFilter.Model as EventAuthorFilter exposing (initialModel, Model)

init : EventAuthorFilter.Model
init = initialModel

type Msg
  = SelectAuthor Int
  | UnSelectAuthor

update : Msg -> Model -> Model
update action model =
  case action of
    SelectAuthor id ->
      Just id

    UnSelectAuthor ->
      Nothing
