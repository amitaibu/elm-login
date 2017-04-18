module EventCompanyFilter.Update where

import EventCompanyFilter.Model as EventCompanyFilter exposing (initialModel, Model)

import Company.Model as Company exposing (Model)


init : Model
init = initialModel

type Action
  = SelectCompany (Maybe Int)
  | ResetCounter -- added this to support counter resetting on page init

type alias Model = EventCompanyFilter.Model

update : List Company.Model -> Action -> Model -> Model
update companies action model =
  case action of
    ResetCounter -> -- need this to support a differentiation between a page init (that I don't want the counter to count) and a user selection. There's probably a better way to do this
      {model | selectionCounter = -1}

    SelectCompany maybeCompanyId ->
      let
        isValidCompany val =
          companies
            |> List.filter (\company -> company.id == val)
            |> List.length

        increase intNumber  =  
          intNumber+1
           
        eventCompanyFilter =
          case maybeCompanyId of
            Just val ->
              -- Make sure the given company ID is a valid one.
              if ((isValidCompany val) > 0)
                then {model | selectedId = Just val, selectionCounter = increase model.selectionCounter}
                else {model | selectedId = Nothing} -- don't update counter. (set it to -1?)
            Nothing ->
              {model | selectedId = Nothing, selectionCounter = increase model.selectionCounter} 
      in
        eventCompanyFilter
