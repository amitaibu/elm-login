module Pages.Login.Model exposing (emptyModel, Model)


type alias Model =
    { login : String
    }


emptyModel : Model
emptyModel =
    { login = ""
    }
