module Config exposing (..)

import Config.Model as Config exposing (Model)
import Dict exposing (..)
import Time exposing (Time)


local : Model
local =
    { backendUrl = "https://api.github.com"
    , name = "local"
    }


production : Model
production =
    { backendUrl = "https://api.github.com"
    , name = "gh-pages"
    }


configs : Dict String Model
configs =
    Dict.fromList
        [ ( "localhost", local )
        , ( "example.com", production )
        ]


cacheTtl : Time.Time
cacheTtl =
    (5 * Time.second)
