module GameLogic exposing (gameStep)

import Base exposing (..)


gameStep : Float -> GameState -> GameState
gameStep delta gameState =
    stepPlayers delta gameState
    |> checkPlayerCollisions delta


stepPlayers : Float -> GameState -> GameState
stepPlayers delta gameState =
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
    , rotation = player.rotation + player.turning * delta
    }

checkPlayerCollisions : Float -> GameState -> GameState
checkPlayerCollisions delta gameState =
    let intersectingPlayers =
        List.concatMap
            (\player1 ->
                List.filterMap (\player2 ->
                    let pDelta = {x = player1.pos.x - player2.pos.x, y = player1.pos.y - player2.pos.y}
                    in
                        if dist pDelta < 2 && player1.id /= player2.id
                           then Just (player1, player2)
                           else Nothing
                ) gameState.players
            ) gameState.players
    in
        { gameState
        | players =
            List.map 
                (\player ->
                    let intersectionsPoses =
                        List.filterMap (\(me, other) -> 
                            if me == player 
                                then 
                                    let delta = {x = me.pos.x - other.pos.x, y = me.pos.y - other.pos.y}
                                    in Just {x = delta.x * (dist delta - 2), y = delta.y * (dist delta - 2)}
                               else Nothing
                        ) intersectingPlayers
                        sum axis = (List.sum <| List.map axis intersectionsPoses) / 3
                    in 
                        { player 
                        | pos = {x = player.pos.x - sum .x, y = player.pos.y - sum .y}
                        }
                ) gameState.players
        }
