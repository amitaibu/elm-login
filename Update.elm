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

        id =
          case maybeCompanyId of
            Just val ->
              -- Make sure the given company ID is a valid one.
              if ((isValidCompany val) > 0)
                then Just val
                else Nothing
            Nothing ->
              Nothing

        countChange =
            if not (( maybeCompanyId == Nothing ) && model.count == 0)
            then
                model.count + 1
            else
                0
      in
       { model
       | id = id
       , count = countChange
       }
