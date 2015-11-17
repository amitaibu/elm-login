module ConfigManager where

import Effects exposing (Effects)
import Task exposing (map)
import Time exposing (Time)
import WebAPI.Location exposing (location)

type alias BackendConfig =
  { backendUrl : String
  , githubClientId : String
  , name : String
  -- Url information
  , hostname : String
  }

initialBackendConfig : BackendConfig
initialBackendConfig =
  { backendUrl = ""
  , githubClientId = ""
  , name = ""
  , hostname = ""
  }


type Status
  = Init
  | Error

type alias Model =
  { backendConfig : BackendConfig
  , status : Status
  }

initialModel : Model
initialModel =
  { backendConfig = initialBackendConfig
  , status = Init
  }

init : (Model, Effects Action)
init =
  ( initialModel
  , getConfigFromUrl
  )

localBackend : BackendConfig
localBackend =
  { backendUrl = "http://localhost/hedley-server/www"
  , githubClientId = "e5661c832ed931ae176c"
  , name = "local"
  , hostname = "localhost"
  }

prodBackend : BackendConfig
prodBackend =
  { backendUrl = "http://localhost/hedley-server/www"
  , githubClientId = "e5661c832ed931ae176c"
  , name = "prod"
  , hostname = "localhost"
  }

backends : List BackendConfig
backends =
  [ localBackend
  , prodBackend
  ]

cacheTtl : Time.Time
cacheTtl = (5 * Time.second)

-- UPDATE

type Action
  = SetConfig BackendConfig
  | SetStatus Status

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    SetConfig backendConfig ->
      ( { model | backendConfig <- backendConfig }
      , Effects.none
      )

    SetStatus status ->
      ( { model | status <- status }
      , Effects.none
      )


-- EFFECTS

getConfigFromUrl : Effects Action
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
          Nothing -> SetStatus Error

    actionTask =
      Task.map getAction WebAPI.Location.location
  in
    Effects.task actionTask
