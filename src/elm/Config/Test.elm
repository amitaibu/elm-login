module Config.Test exposing (..)

import ElmTest exposing (..)

import Config.Model exposing (initialBackendConfig, initialModel, Model)
import Config.Update exposing (update, Msg)

type alias Msg = Config.Update.Msg
type alias Model = Config.Model.Model

setErrorTest : Test
setErrorTest =
  test "set error action" (assertEqual True (.error <| fst(setError)))

setError : (Model, Cmd Msg)
setError =
  Config.Update.update Config.Update.SetError initialModel


all : Test
all =
  suite "Config tests"
    [ setErrorTest
    ]
