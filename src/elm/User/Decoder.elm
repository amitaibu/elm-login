module User.Decoder exposing (decodeFromGithub)

import Json.Decode exposing ((:=))
import Json.Decode.Extra exposing ((|:))
import User.Model exposing (..)


decodeFromGithub : Json.Decode.Decoder User
decodeFromGithub =
    Json.Decode.succeed User
        |: ("avatar_url" := Json.Decode.string)
        |: ("login" := Json.Decode.string)
        |: ("name" := Json.Decode.maybe Json.Decode.string)
