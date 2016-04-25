module EventCompanyFilter.Model where

type alias Model = {
 selectedId: Maybe Int, selectionCounter: Int
}

initialModel : Model
initialModel = {selectedId = Nothing, selectionCounter = -1}
