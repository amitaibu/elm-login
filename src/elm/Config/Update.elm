module Config.Update exposing (..)

import Config exposing (backends)
import Config.Model exposing (initialModel, Model)
import Task exposing (map)
import WebAPI.Location exposing (location)

init : (Model, Cmd Msg)
init =
  ( initialModel
  , getConfigFromUrl
  )

type Msg
  = SetConfig Config.Model.BackendConfig
  | SetError

update : Msg -> Model -> (Model, Cmd Msg)
update action model =
  case action of
    SetConfig backendConfig ->
      ( { model | backendConfig = backendConfig }
      , Cmd.none
      )

    SetError ->
      ( { model | error = True }
      , Cmd.none
      )


-- EFFECTS

getConfigFromUrl : Cmd Msg
getConfigFromUrl =
  let
    getAction location =
      let
        config =
          List.filter (\backend -> backend.hostname == location.hostname) backends
          |> List.head
      in
        case config of
          Just val -> SetConfig val
          Nothing -> SetError

    actionTask =
      Task.map getAction WebAPI.Location.location
  in
    Cmd.task actionTask
