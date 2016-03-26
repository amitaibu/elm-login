module EventCompanyFilter.Model where

type alias Model = {counter: Int , val: Maybe Int}

initialModel : Model
initialModel = {counter=0, val=Nothing}
