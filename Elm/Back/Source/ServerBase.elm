module ServerBase exposing (..)

import Base exposing (..)

type alias Model =
    { clientIds : List User
    , gameState : GameState
    , lastTime : Maybe Float
    }

type alias User =
    { id : String
    , ip : String}

