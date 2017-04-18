module EventCompanyFilter.Model where

type alias Model =
  { state : Maybe Int,
    changes : Int
  }

initialModel : Model
initialModel =
  { state = Nothing,
    changes = -1
  }
