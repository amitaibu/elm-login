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
        counter = model.counter
        isValidCompany val =
          companies
            |> List.filter (\company -> company.id == val)
            |> List.length



        eventCompanyFilter =
          case maybeCompanyId of
            Just val ->
              -- Make sure the given company ID is a valid one.
              if ((isValidCompany val) > 0)
                --then Just val
                then { model | companyid = Just val, counter = counter + 1 }
                else { model | companyid = Nothing }
            Nothing ->
              { model | companyid = Nothing }
      in
        eventCompanyFilter
