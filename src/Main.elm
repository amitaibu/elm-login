module Main where

import App exposing (init, update, view)
import Html exposing (Html)
import Effects exposing (Never)
import StartApp
import Task


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


main : Signal Html
main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

-- Interactions with localStorage to save the access token.

port getStorage : Maybe String


signalAccessToken : Signal App.Model -> Signal String
signalAccessToken model =
  Signal.map (.user >> .accessToken) model

port setStorage : Signal String
port setStorage =
  signalAccessToken app.model
