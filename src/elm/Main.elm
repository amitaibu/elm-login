
import Effects exposing (Never)
import App exposing (init, update, view)
import Event exposing (Action)
import Leaflet exposing (Action, Model)
import StartApp
import Task


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [Signal.map (App.ChildEventAction << Event.ChildLeafletAction << Leaflet.ToggleMarker) selectMarker]
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

-- Interactions with Leaflet maps
port mapManager : Signal Leaflet.Model
port mapManager = Signal.map (.events >> .leaflet) app.model

port selectMarker : Signal (Maybe Int)
