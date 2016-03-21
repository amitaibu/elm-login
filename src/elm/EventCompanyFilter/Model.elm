module EventCompanyFilter.Model where

type alias Model =
  {
    companyId : Maybe Int
  , counter : Int
  }

initialModel : Model
initialModel =
  {
    companyId = Nothing
  , counter = -1
  }
