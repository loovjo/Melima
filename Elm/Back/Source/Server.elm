port module Server exposing (main)

import Time
import Json.Decode -- Necessary for ports to works as of 0.18.0
import Json.Encode exposing (encode)

import Base exposing (..)
import ServerBase exposing (..)
import JsonEncode exposing (..)
import GameLogic exposing (..)
import MsgHandler exposing (..)

main = Platform.program {init = init, update = update, subscriptions = subs}

init : ( Model, Cmd msg )
init =
    { clientIds = []
    , gameState = GameState []
    , lastTime = Nothing
    } ! []

port wsSend : (String, String) -> Cmd msg -- (msg, id)
port wsReceive : ((String, String) -> msg) -> Sub msg -- (msg, id)
port clientConnection : ((String, String) -> msg) -> Sub msg -- (id, ip)

type Msg
    = Broadcast Time.Time
    | Connection (String, String) -- (id, ip)
    | WsReceive (String, String) -- (msg, id)
    | Step Time.Time

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Broadcast timestamp ->
            model !
                List.map (\user -> 
                    let you = {ip = user.ip, id = user.id}
                        totalState = TotalState model.gameState you
                    in (wsSend (encode 0 <| encodeTotalState totalState, user.id))
                ) model.clientIds

        Connection (id, ip) ->
            { model 
            | clientIds = model.clientIds ++ [User id ip] 
            } ! []

        Step ts ->
            let timestamp = Time.inSeconds ts
                modelWithTime = { model | lastTime = Just timestamp }
            in case model.lastTime of
                Nothing -> modelWithTime ! []
                Just last ->
                    let delta = timestamp - last
                    in { modelWithTime | gameState = gameStep delta model.gameState } ! []

        WsReceive (msg, id) ->
            (always <| 
                { model | gameState = handleMsg (id, msg) model.gameState } ! []
            ) <| Debug.log "Msg, id:" <| toString (msg, id)

subs : Model -> Sub Msg
subs model = 
    Sub.batch
        [ Time.every (Time.second / 10) Broadcast
        , Time.every (Time.second / 60) Step
        , wsReceive WsReceive
        , clientConnection Connection
        ]
