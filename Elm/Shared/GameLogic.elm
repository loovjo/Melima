module GameLogic exposing (gameStep)

import Base exposing (..)


gameStep : Float -> GameState -> GameState
gameStep delta gameState =
    { gameState
    | players =
        List.map (playerStep delta) gameState.players
    }

playerStep : Float -> Player -> Player
playerStep delta player =
    { player
    | pos =
        let (dx, dy) = fromPolar (player.vel * delta, player.rotation)
        in {x = player.pos.x + dx, y = player.pos.y + dy}
    }
