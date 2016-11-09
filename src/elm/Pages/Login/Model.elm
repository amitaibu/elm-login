module Pages.Login.Model exposing (emptyModel, Model)

import Http


type alias AccessToken =
    String


type alias LoginForm =
    { name : String
    , pass : String
    }


type UserMessage
    = None
    | Error String


type Status
    = Init
    | Fetching
    | Fetched
    | HttpError Http.Error


type alias Model =
    { accessToken : AccessToken
    , hasAccessTokenInStorage : Bool
    , loginForm : LoginForm
    , status : Status
    , userMessage : UserMessage
    }


emptyModel : Model
emptyModel =
    { accessToken =
        ""
        -- We start by assuming there's already an access token it the localStorage.
        -- While this property is set to True, the login form will not appear.
    , hasAccessTokenInStorage = True
    , loginForm = LoginForm "demo" "1234"
    , status = Init
    , userMessage = None
    }
