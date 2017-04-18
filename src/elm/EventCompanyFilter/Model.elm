module EventCompanyFilter.Model where

--type alias Model = Maybe Int

type alias Model =
  { companyid : Maybe Int
  , counter : Int
  }

initialModel : Model
--initialModel = Nothing
initialModel =
  { companyid = Nothing
  , counter = 0
  }
