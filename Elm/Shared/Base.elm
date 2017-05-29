module Base exposing (..)

(!!) : List a -> Int -> Maybe a
(!!) lst idx = List.head <| List.drop idx lst

infixr 2 !!

level1Health : Float
level1Health = 20

-- A useful command to avoid the ugly
-- [ a, b, c ] ++
--      case d of
--          Just elem -> [d]
--          Nothing -> []
-- construct that's quite common when dealing with Html things.
-- Instead you can write the above like this:
--
-- [ a, b, c ] ++ toList d

toList : Maybe a -> List a
toList hmm =
    case hmm of
        Just item -> [item]
        Nothing -> []

dist : Position -> Float
dist pos = pos.x * pos.x + pos.y * pos.y |> sqrt

type alias Position = {x : Float, y : Float}

type alias GameState =
    { players : List Player
    }

type alias Player =
    { pos : Position
    , rotation : Float -- In radians
    , turning : Float
    , vel : Float
    , name : String
    , id : String
    , health : Float
    , maxHealth : Float
    }

type alias You =
    { ip : String
    , id : String
    }

type alias TotalState = {state : GameState, you : You}
