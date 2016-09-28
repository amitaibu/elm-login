module Pages.Event.Update exposing (..)

import Config exposing (cacheTtl)
import Config.Model exposing (BackendConfig)
import Company.Model as Company exposing (Model)
import Event.Decoder exposing (decode)
import Event.Model exposing (Event)
import EventAuthorFilter.Update exposing (Msg)
import EventCompanyFilter.Update exposing (Msg)
import EventList.Update exposing (Msg)
import EventList.Utils exposing (filterEventsByString)
import Http exposing (Error)
import Leaflet.Update exposing (Msg)
import Pages.Event.Model as Event exposing (Model)
import Pages.Event.Utils exposing (filterEventsByAuthor)
import Task  exposing (andThen, succeed)
import Time exposing (Time)

type alias Id = Int
type alias CompanyId = Int
type alias Model = Event.Model

init : (Model, Cmd Msg)
init =
  ( Event.initialModel
  , Cmd.none
  )

type Msg
  = NoOp
  | GetData (Maybe CompanyId)
  | GetDataFromServer (Maybe CompanyId)
  | UpdateDataFromServer (Result Http.Error (List Event)) (Maybe CompanyId) Time.Time

  -- Child actions
  | ChildEventAuthorFilterAction EventAuthorFilter.Update.Msg
  | ChildEventCompanyFilterAction EventCompanyFilter.Update.Msg
  | ChildEventListAction EventList.Update.Msg
  | ChildLeafletAction Leaflet.Update.Msg

  -- Page
  | Activate (Maybe CompanyId)
  | Deactivate


type alias Context =
  { accessToken : String
  , backendConfig : BackendConfig
  , companies : List Company.Model
  }

update : Context -> Msg -> Model -> (Model, Cmd Msg)
update context action model =
  case action of
    ChildEventAuthorFilterAction act ->
      let
        -- The child component doesn't have effects.
        childModel =
          EventAuthorFilter.Update.update act model.eventAuthorFilter
      in
        ( { model | eventAuthorFilter = childModel }
        -- Filter out the events, before sending the events' markers.
        , Task.succeed (ChildLeafletAction <| Leaflet.Update.SetMarkers (filterEventsByAuthor model.events childModel)) |> Cmd.task
        )

    ChildEventCompanyFilterAction act ->
      let
        childModel =
          EventCompanyFilter.Update.update context.companies act model.eventCompanyFilter

        maybeCompanyId =
          -- Reach into the selected company, in order to invoke getting the
          -- data from server.
          case act of
            EventCompanyFilter.Update.SelectCompany maybeCompanyId ->
              maybeCompanyId

      in
        ( { model | eventCompanyFilter = childModel }
        , Task.succeed (GetData maybeCompanyId) |> Cmd.task
        )

    ChildEventListAction act ->
      let
        filteredEventsByAuthor =
          filterEventsByAuthor model.events model.eventAuthorFilter

        -- The child component doesn't have effects.
        childModel =
          EventList.Update.update filteredEventsByAuthor act model.eventList

        childAction =
          case act of
            EventList.Update.FilterEvents val ->
              -- Filter out the events, before sending the events' markers.
              Leaflet.Update.SetMarkers (filterEventsByString filteredEventsByAuthor val)

            EventList.Update.SelectEvent val ->
              Leaflet.Update.SelectMarker val

            EventList.Update.UnSelectEvent ->
              Leaflet.Update.UnselectMarker
      in
        ( { model | eventList = childModel }
        , Task.succeed (ChildLeafletAction <| childAction) |> Cmd.task
        )

    ChildLeafletAction act ->
      let
        childModel =
          Leaflet.Update.update act model.leaflet
      in
        ( {model | leaflet = childModel }
        , Cmd.none
        )

    GetData maybeCompanyId ->
      let
        noFx =
          (model, Cmd.none)

        getFx =
          (model, getDataFromCache model.status maybeCompanyId)
      in
        case model.status of
          Event.Fetching id ->
            if id == maybeCompanyId
              -- We are already fetching this data
              then noFx
              -- We are fetching data, but for a different company ID,
              -- so we need to re-fetch.
              else getFx

          _ ->
            getFx

    GetDataFromServer maybeCompanyId ->
      let
        backendUrl =
          (.backendConfig >> .backendUrl) context

        url =
          backendUrl ++ "/api/v1.0/events"
      in
        ( { model | status = Event.Fetching maybeCompanyId }
        , getJson url maybeCompanyId context.accessToken
        )

    NoOp ->
      (model, Cmd.none)

    UpdateDataFromServer result maybeCompanyId timestamp ->
      case result of
        Ok events ->
          let
            filteredEventsByAuthor =
              filterEventsByAuthor events model.eventAuthorFilter

            filteredEvents =
              filterEventsByString filteredEventsByAuthor model.eventList.filterString
          in
            ( { model
              | events = events
              , status = Event.Fetched maybeCompanyId timestamp
              }
            , Cmd.batch
              [ Task.succeed (ChildEventAuthorFilterAction EventAuthorFilter.Update.UnSelectAuthor) |> Cmd.task
              , Task.succeed (ChildEventListAction EventList.Update.UnSelectEvent) |> Cmd.task
              , Task.succeed (ChildEventListAction <| EventList.Update.FilterEvents "") |> Cmd.task
              ]
            )

        Err msg ->
          ( { model | status = Event.HttpError msg }
          , Cmd.none
          )

    Activate maybeCompanyId ->
      let
        childModel =
          Leaflet.Update.update Leaflet.Update.ToggleMap model.leaflet

      in
        ( { model | leaflet = childModel }
        , Cmd.batch
          [ Task.succeed (GetData maybeCompanyId) |> Cmd.task
          , Task.succeed (ChildEventCompanyFilterAction <| EventCompanyFilter.Update.SelectCompany maybeCompanyId) |> Cmd.task
          ]
        )

    Deactivate ->
      let
        childModel =
          Leaflet.Update.update Leaflet.Update.ToggleMap model.leaflet
      in
        ( { model | leaflet = childModel }
        , Cmd.none
        )


-- EFFECTS

getDataFromCache : Event.Status -> Maybe CompanyId -> Cmd Msg
getDataFromCache status maybeCompanyId =
  let
    getFx =
      Task.succeed <| GetDataFromServer maybeCompanyId

    actionTask =
      case status of
        Event.Fetched id fetchTime ->
          if id == maybeCompanyId
            then
              Task.map (\currentTime ->
                if fetchTime + Config.cacheTtl > currentTime
                  then NoOp
                  else GetDataFromServer maybeCompanyId
              ) Time.now
            else
              getFx

        _ ->
          getFx

  in
    Cmd.task actionTask


getJson : String -> Maybe CompanyId -> String -> Cmd Msg
getJson url maybeCompanyId accessToken =
  let
    params =
      [ ("access_token", accessToken) ]

    params' =
      case maybeCompanyId of
        Just id ->
          -- Filter by company
          ("filter[company]", toString id) :: params

        Nothing ->
          params


    encodedUrl =
      Http.url url params'

    httpTask =
      Task.toResult <|
        Http.get Event.Decoder.decode encodedUrl

    actionTask =
      httpTask `andThen` (\result ->
        Task.map (\timestamp ->
          UpdateDataFromServer result maybeCompanyId timestamp
        ) Time.now
      )

  in
    Cmd.task actionTask
