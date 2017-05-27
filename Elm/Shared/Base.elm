module Base exposing (..)

(!!) : List a -> Int -> Maybe a
(!!) lst idx = List.head <| List.drop idx lst

infixr 2 !!

-- A useful command to avoid the ugly
-- [ a, b, c ] ++
--      case d of
--          Just elem -> [d]
--          Nothing -> []
-- construct that's quite common when dealing with Html things.
-- Instead you can write the above like this:
--
-- [ a, b, c ] ++ toList d

(toList) : Maybe a -> List a
(toList) hmm =
    case hmm of
        Just item -> [item]
        Nothing -> []

type alias Position = {x : Float, y : Float}

type alias GameState =
    { players : List Player
    }

type alias Player =
    { pos : Position
    , name : String
    , id : String
    }

type alias You =
    { ip : String
    , youId : Maybe String
    }
