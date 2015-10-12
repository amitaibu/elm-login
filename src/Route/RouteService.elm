module Route.RouteService where

import String exposing (uncons, split)
import Http exposing (uriDecode, uriEncode)
import Signal exposing (Mailbox, send, mailbox, merge)
import Task exposing (Task)
import History


type PathAction
    = SetPath (List String)
    | ReplacePath (List String)


map : (List String -> List String) -> PathAction -> PathAction
map func action =
    case action of
        SetPath list ->
            SetPath (func list)

        ReplacePath list ->
            ReplacePath (func list)

        _ ->
            action


return : PathAction -> List String
return action =
    case action of
        SetPath list ->
            list

        ReplacePath list ->
            list


routes : Signal (List String)
routes = Signal.map hash2list History.hash


do : PathAction -> Task () ()
do action =
    case action of
        SetPath list ->
            setPath list

        ReplacePath list ->
            replacePath list


setPath : List String -> Task () ()
setPath = History.setPath << list2hash


replacePath : List String -> Task () ()
replacePath = History.replacePath << list2hash


{-| This is what we add to the URL in the location bar so we can
generate a history etc. but not switch to a different page
(from the browser's point of view).
-}
hashPrefix : String
hashPrefix = "#!/"


{-| Remove the character from the string if it is the first character -}
removeInitial : Char -> String -> String
removeInitial initial original =
    case uncons original of
        Just (first, rest) ->
            if first == initial
                then rest
                else original

        _ ->
            original


{-| Remove initial characters from the string, as many as there are.

So, for "#!/", remove # if is first, then ! if it is next, etc.
-}
removeInitialSequence : String -> String -> String
removeInitialSequence initial original =
    String.foldl removeInitial original initial


{-| Takes a string from the location's hash, and normalize it to a list of strings
that were separated by a slash. -}
hash2list : String -> List String
hash2list =
    removeInitialSequence hashPrefix >> split "/" >> List.map uriDecode


{-| The opposite of normalizeHash ... takes a list and turns it into a hash -}
list2hash : List String -> String
list2hash list =
    hashPrefix ++ String.join "/" (List.map uriEncode list)
        
