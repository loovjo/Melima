module MsgHandler exposing (handleMsg)

import Base exposing (..)

handleMsg : (String, String) -> GameState -> GameState
handleMsg (userId, msg) state =
    let updateFn =
            let pmsg = parse msg
            in case pmsg of
                Nothing -> identity
                Just req ->
                    case req of
                        RotateR dtheta -> (\x -> {x | rotation = x.rotation + dtheta})
                        RotateL dtheta -> (\x -> {x | rotation = x.rotation - dtheta})
    in
        { state
        | players = List.map (\player -> if player.id == userId then updateFn player else player) state.players
        }


type Req
    = RotateL Float
    | RotateR Float

parse : String -> Maybe Req
parse msg =
    let tokens = String.split " " msg
    in 
        case (tokens !! 0, tokens !! 1) of
            (Just a, Just b) -> parseTokens (a, b)
            _ -> Nothing

parseTokens : (String, String) -> Maybe Req
parseTokens (t1, t2) =
    List.head <| List.filterMap (\(tok, pars) -> if t1 == tok then pars t2 else Nothing) reqs

reqs : List (String, (String -> Maybe Req))
reqs =
    [ ("rotr", (Maybe.map RotateR) << Result.toMaybe << String.toFloat)
    , ("rotl", (Maybe.map RotateL) << Result.toMaybe << String.toFloat)
    ]

