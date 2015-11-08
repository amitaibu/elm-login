module PageNotFound where

import Html exposing (a, div, text, Html)
import Html.Attributes exposing (href)

import Debug


-- VIEW

view : Html
view =
  div
    []
    [ a [ href "#!/"] [ text "404!"]
    ]
