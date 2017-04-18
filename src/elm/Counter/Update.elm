module Counter.Update where

import Counter.Model as Counter exposing (Model)

type Action = Increment | Decrement

update : Action -> Model -> Model
update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1
