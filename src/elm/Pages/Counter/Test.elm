module Pages.Counter.Test exposing (..)

import ElmTest exposing (..)
import Pages.Counter.Model as Counter exposing (emptyModel, Model)
import Pages.Counter.Update as Counter exposing (..)


decrementActionSuite : Test
decrementActionSuite =
    suite "Decrement action"
        [ test "negative count" (assertEqual -2 (updateCounter Counter.Decrement -1))
        , test "zero count" (assertEqual -1 (updateCounter Counter.Decrement 0))
        , test "positive count" (assertEqual 0 (updateCounter Counter.Decrement 1))
        ]


incrementActionSuite : Test
incrementActionSuite =
    suite "Increment action"
        [ test "negative count" (assertEqual 0 (updateCounter Counter.Increment -1))
        , test "zero count" (assertEqual 1 (updateCounter Counter.Increment 0))
        , test "positive count" (assertEqual 2 (updateCounter Counter.Increment 1))
        ]


updateCounter : Counter.Msg -> Int -> Counter.Model
updateCounter action initialModel =
    fst <| Counter.update action initialModel


all : Test
all =
    suite "Counter tests"
        [ decrementActionSuite
        , incrementActionSuite
        ]
