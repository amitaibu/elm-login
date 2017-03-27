module User.Model exposing (..)


type alias User =
    { avatarUrl : String
    , login :
        String
        -- In GitHub user might not have a name, just the login handler, so this
        -- is a "Maybe" value.
    , name : Maybe String
    }
