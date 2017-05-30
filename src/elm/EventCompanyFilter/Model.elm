module EventCompanyFilter.Model where

type alias Model =
    { counter : Int
    , companyId : Maybe Int
    }

initialModel : Model
initialModel =
    { counter = 0
    , companyId = Nothing
    }
