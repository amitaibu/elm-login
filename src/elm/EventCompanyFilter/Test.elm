module EventCompanyFilter.Test where

import ElmTest exposing (..)

import Company.Model as Company exposing (Model)
import EventCompanyFilter.Model as EventCompanyFilter exposing (initialModel, Model)
import EventCompanyFilter.Update exposing (Action)

type alias Model = EventCompanyFilter.Model

selectCompanySuite : Test
selectCompanySuite =
  suite "SelectCompany action"
    [ test "no company" (assertEqual Nothing (selectCompany Nothing).selectedId) -- just making sure the tests pass.
    , test "valid company" (assertEqual (Just 1) (selectCompany <| Just 1).selectedId)
    , test "invalid company" (assertEqual Nothing (selectCompany <| Just 100).selectedId)
    ]

selectCompany : Maybe Int -> Model
selectCompany val =
  EventCompanyFilter.Update.update companies (EventCompanyFilter.Update.SelectCompany val) initialModel

companies : List Company.Model
companies =
  [ Company.Model 1 "foo"
  , Company.Model 2 "bar"
  , Company.Model 3 "baz"
  ]

all : Test
all =
  suite "EventCompanyFilter"
    [ selectCompanySuite
    ]
