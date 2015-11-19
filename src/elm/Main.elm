import App exposing (init, update, view)
import StartApp as StartApp
import Effects exposing (Never)
import Event exposing (Action)
import Leaflet exposing (Action, Model)
import RouteHash
import Task exposing (Task)


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs =
        [ messages.signal
        , Signal.map (App.ChildEventAction << Event.SelectEvent) selectEvent
        ]
    }

main =
  app.html

messages : Signal.Mailbox App.Action
messages =
    Signal.mailbox App.NoOp

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks

port routeTasks : Signal (Task () ())
port routeTasks =
  RouteHash.start
    { prefix = RouteHash.defaultPrefix
    , address = messages.address
    , models = app.model
    , delta2update = App.delta2update
    , location2action = App.location2action
    }

-- Interactions with Leaflet maps

type alias LeafletPort =
  { leaflet : Leaflet.Model
  , events : List Int
  }

port mapManager : Signal LeafletPort
port mapManager =
  let
    getLeaflet model =
      (.events >> .leaflet) model

    getEvents model =
      (.events >> .events) model

    getLeafletPort model =
      { leaflet = getLeaflet model
      , events = List.map .id <| getEvents model
      }

  in
    Signal.map getLeafletPort app.model

port selectEvent : Signal (Maybe Int)

-- Dropzone

port activePage : Signal String
port activePage =
  let
    pageAsString model =
      case model.activePage of
        App.Article -> "Article"
        App.Event _ -> "Event"
        App.GithubAuth -> "GithubAuth"
        App.Login -> "Login"
        App.PageNotFound -> "PageNotFound"
        App.User -> "User"

  in
  Signal.map pageAsString app.model
