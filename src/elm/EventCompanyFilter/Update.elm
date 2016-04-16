module EventCompanyFilter.Update where

import EventCompanyFilter.Model as EventCompanyFilter exposing (initialModel, Model)

import Company.Model as Company exposing (Model)


init : Model
init = initialModel

type Action
  = SelectCompany (Maybe Int)

type alias Model = EventCompanyFilter.Model

update : List Company.Model -> Action -> Model -> Model
update companies action model =
  case action of
    SelectCompany maybeCompanyId ->
      let
        isValidCompany val =
          companies
            |> List.filter (\company -> company.id == val)
            |> List.length


        eventCompanyFilter =
          case maybeCompanyId of
            Just val ->
              -- Make sure the given company ID is a valid one.
              if ((isValidCompany val) > 0)
                then { model | company = Just val, counter = model.counter + 1 }
                else { model | company = Nothing, counter = model.counter }
            Nothing ->
              { model | company = Nothing, counter = model.counter + 1 }
      in
        eventCompanyFilter
