module EventCompanyFilter.Model where

type alias Model =
    {   id : Maybe Int
    , count : Int
    }

initialModel : Model
initialModel =
  { id = Nothing
  , count = 0
  }
