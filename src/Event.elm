module Event where

import Config exposing (backendUrl)
import Dict exposing (empty, insert, update, get)
import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, targetValue)
import Http
import Json.Decode as Json exposing ((:=))
import String exposing (length)
import Task
import Dict exposing (Dict)

import Debug

-- MODEL

type alias Id = Int

type Status =
  Init
  | Fetching
  -- @todo: Pass timestamp for "Fetched".
  | Fetched
  | HttpError Http.Error

type alias Marker =
  { lat: Float
  , lng : Float
  }

type alias Author =
  { id : Id
  , name : String
  }

type alias Event =
  { id : Id
  , label : String
  , marker : Marker
  , author : Author
  }

type alias Model =
  { events : List Event
  , status : Status
  , selected : Maybe Int
  }


group : List Event -> Dict Int (Author, Int)
group events =
    let
        -- Event -> Dict Int (Author, Int) -> Dict Int (Author, Int)
        handleEvent event dict =
            let
                currentValue =
                    Maybe.withDefault (event.author, 0) <|
                        Dict.get event.author.id dict

                newValue =
                    case currentValue of
                        (author, count) -> (author, count + 1)


            in
                Dict.insert event.author.id newValue dict
            
    in
        List.foldl handleEvent Dict.empty events



initialModel : Model
initialModel =
  Model [] Init Nothing

init : (Model, Effects Action)
init =
  ( initialModel
  , Effects.none
  )


-- UPDATE

type Action
  = GetDataFromServer
  | UpdateDataFromServer (Result Http.Error (List Event))
  | Select Int

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    GetDataFromServer ->
      let
        url : String
        url = Config.backendUrl ++ "/api/v1.0/events"
      in
        ( { model | status <- Fetching}
          -- @todo: Remove access token hardcoding.
        , getJson url "erUOM1tKSABIGmcCKPoXhZYxO-7F4qUBGyxjRL7oUKs"
        )

    UpdateDataFromServer result ->
      case result of
        Ok events ->
          ( {model
              | events <- events
              , status <- Fetched
            }
          , Effects.none
          )
        Err msg ->
          ( {model | status <- HttpError msg}
          , Effects.none
          )

    Select id ->
      ( { model | selected <- Just id }
      , Effects.none
      )


-- VIEW

(=>) = (,)

view : Signal.Address Action -> Model -> Html
view address model =
  let
    message =
      Signal.send address GetDataFromServer
  in
  div []
    [ div [class "h2"] [ text "Event list:"]
    , ul [] (List.map (viewListEvents (address, model.selected)) model.events)
    , div [class "h2"] [ text "Event info:"]
    , viewEventInfo model
    , button [ onClick address GetDataFromServer ] [ text "Refresh" ]
    , div [] [ text <| toString (group model.events) ]
    ]


viewListEventsGroupByAuthor : Signal.Address Action -> Model -> Html
viewListEventsGroupByAuthor address model =
  let
    buildDict = Dict.empty
    buildDict event =
      case Dict.get event.author.id dict of
        Just val
          -- Update the existing record
          Dict.update event.id event.author.name buildDict
          ->
        Nothing ->
          -- New record
          Dict.insert event.id event.author.name buildDict


    viewDict item =
      li [] [ text (item.name ++ " (" ++ (toString item.count) ++ ")" ]
  in
    Dict.map viewDict dict

viewListEvents : (Signal.Address Action, Maybe Int) -> Event -> Html
viewListEvents (address, selected) event =
  let
    nonSelected = li [] [ a [ href "#", onClick address (Select event.id) ] [text event.label] ]
  in
  case selected of
    Just val ->
      if event.id == val
        then
          li [ class "selected" ] [text ("Selected: " ++ event.label)]
        else
          nonSelected

    Nothing ->
      nonSelected


viewEventInfo : Model -> Html
viewEventInfo model =
  case model.selected of
    Just val ->
      let
        -- Get the selected element.
        selectedEvent = List.filter (\event -> event.id == val) model.events

      in
        div [] (List.map (\event -> text (toString(event.id) ++ ") " ++ event.label ++ " by " ++ event.author.name)) selectedEvent)

    Nothing ->
      div [] []



-- EFFECTS


getJson : String -> String -> Effects Action
getJson url accessToken =
  let
    encodedUrl = Http.url url [ ("access_token", accessToken) ]
  in
    Http.send Http.defaultSettings
      { verb = "GET"
      , headers = []
      , url = encodedUrl
      , body = Http.empty
      }
      |> Http.fromJson decodeData
      |> Task.toResult
      |> Task.map UpdateDataFromServer
      |> Effects.task


decodeData : Json.Decoder (List Event)
decodeData =
  let
    -- Cast String to Int.
    number : Json.Decoder Int
    number =
      Json.oneOf [ Json.int, Json.customDecoder Json.string String.toInt ]


    numberFloat : Json.Decoder Float
    numberFloat =
      Json.oneOf [ Json.float, Json.customDecoder Json.string String.toFloat ]

    marker =
      Json.object2 Marker
        ("lat" := numberFloat)
        ("lng" := numberFloat)

    author =
      Json.object2 Author
        ("id" := number)
        ("label" := Json.string)
  in
  Json.at ["data"]
    <| Json.list
    <| Json.object4 Event
      ("id" := number)
      ("label" := Json.string)
      ("location" := marker)
      ("user" := author)
