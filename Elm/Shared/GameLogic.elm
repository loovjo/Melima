module GameLogic exposing (gameStep)

import Base exposing (..)


gameStep : Float -> GameState -> GameState
gameStep delta gameState =
    gameState
        |> stepPlayers delta
        |> stepEntities delta
        |> checkPlayerCollisions delta
        |> checkDeath delta


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

stepEntities : Float -> GameState -> GameState
stepEntities delta gameState =
    { gameState
    | entities = List.filterMap (entityStep delta) gameState.entities
    }

entityStep : Float -> Entity -> Maybe Entity
entityStep delta entity =
    case entity of
        ZapEntity pos rot vel ageLeft ->
            if ageLeft < 0 
                then Nothing
                else
                    let (dx, dy) = fromPolar (vel * delta, rot)
                    in
                        Just <| ZapEntity {x = pos.x + dx, y = pos.y + dy} rot vel (ageLeft - delta)

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
                        , health = player.health - dist {x = sum .x, y = sum .y} * delta * 200
                        }
                ) gameState.players
        }

checkDeath : Float -> GameState -> GameState
checkDeath delta gameState =
    { gameState
    | players = List.filter (\player -> player.health > 0) gameState.players
    }
