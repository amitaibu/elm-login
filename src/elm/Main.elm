
import Effects exposing (Never)
import App exposing (init, update, view)
import Leaflet exposing (Model)
import StartApp
import Task


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

-- Interactions with Leaflet maps
port mapManager : Signal Leaflet.Model
port mapManager = Signal.map .leaflet app.model

port selectMarker : Signal (Maybe Int)
