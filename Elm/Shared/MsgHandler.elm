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
                        Rotate theta -> (\x -> {x | turning = theta})
                        Walk r -> (\x -> {x | vel = r})
    in
        { state
        | players = List.map (\player -> if player.id == userId then updateFn player else player) state.players
        }


type Req
    = Rotate Float
    | Walk Float

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
    [ ("rot", (Maybe.map Rotate) << Result.toMaybe << String.toFloat)
    , ("walk", (Maybe.map Walk) << Result.toMaybe << String.toFloat)
    ]

