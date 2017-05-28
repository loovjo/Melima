module MsgHandler exposing (handleMsg)

import Base exposing (..)

handleMsg : (String, String) -> GameState -> GameState
handleMsg (userId, msg) state =
    let pmsg = parse msg
    in case pmsg of
        Nothing -> state
        Just req ->
            case req of
                Make name ->
                    if String.length name > 0 then
                        { state | players = 
                            { pos = Position 0 0
                            , rotation = 0
                            , turning = 0
                            , vel = 0
                            , name = name
                            , id = userId
                            } :: state.players}
                    else state
                _ ->
                    let updateFn =
                        case req of
                            Rotate theta -> (\x -> {x | turning = theta})
                            Walk r -> (\x -> {x | vel = r})
                            _ -> identity
                    in
                        { state
                        | players = List.map (\player -> if player.id == userId then updateFn player else player) state.players
                        }


type Req
    = Make String
    | Rotate Float
    | Walk Float

parse : String -> Maybe Req
parse msg =
    let tokens = String.split " " msg
    in 
        case (List.head tokens, List.tail tokens) of
            (Just a, Just b) -> parseTokens (a, String.join " " b)
            _ -> Nothing

parseTokens : (String, String) -> Maybe Req
parseTokens (t1, t2) =
    List.head <| List.filterMap (\(tok, pars) -> if t1 == tok then pars t2 else Nothing) reqs

reqs : List (String, (String -> Maybe Req))
reqs =
    [ ("make", (Maybe.map Make) << Result.toMaybe << Ok)
    , ("rot", (Maybe.map Rotate) << Result.toMaybe << String.toFloat)
    , ("walk", (Maybe.map Walk) << Result.toMaybe << String.toFloat)
    ]

