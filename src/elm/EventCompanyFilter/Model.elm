module EventCompanyFilter.Model where

type alias Model = { company: Maybe Int, counter: Int }

initialModel : Model
initialModel = { company = Nothing, counter = -1 }
