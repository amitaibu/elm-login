module Main exposing (..)

import ElmTest exposing (..)
import App.Test as App exposing (..)
import Pages.Counter.Test as Counter exposing (..)
import Pages.Login.Test as Login exposing (..)


allTests : Test
allTests =
    suite "All tests"
        [ App.all
        , Counter.all
        , Login.all
        ]


main : Program Never
main =
    runSuiteHtml allTests
