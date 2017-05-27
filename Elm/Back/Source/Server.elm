port module Server exposing (main)

import Time
import Json.Decode -- Necessary for ports to works as of 0.18.0
import Json.Encode exposing (encode)

import Base exposing (..)
import JsonEncode exposing (..)

main = Platform.program {init = init, update = update, subscriptions = subs}

init : ( Model, Cmd msg )
init = { clientIds = [], gameState = GameState [Player (Position 10 10) "Loovjo" "123"] } ! []

type alias Model =
    { clientIds : List User
    , gameState : GameState }

type alias User =
    { id : String
    , ip : String}

port wsSend : (String, String) -> Cmd msg -- (msg, id)
port wsReceive : ((String, String) -> msg) -> Sub msg -- (msg, id)
port clientConnection : ((String, String) -> msg) -> Sub msg -- (id, ip)

type Msg
    = Broadcast Time.Time
    | Connection (String, String) -- (id, ip)
    | WsReceive (String, String) -- (msg, id)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Broadcast timestamp ->
            model !
                List.map (\user -> 
                    let you = You user.id <| Just user.ip
                        totalState = TotalState model.gameState you
                    in (wsSend (encode 0 <| encodeTotalState totalState, user.id))
                ) model.clientIds

        Connection (id, ip) ->
            { model 
            | clientIds = model.clientIds ++ [User id ip] 
            , gameState =
                let gameState = model.gameState 
                in  { gameState 
                    | players = gameState.players ++ [Player (Position 0 0) id id]
                    }
            } ! []

        WsReceive (msg, id) ->
            (always <| model ! []) <| Debug.log "Msg, id:" <| toString (msg, id)

subs : Model -> Sub Msg
subs model = 
    Sub.batch
        [ Time.every (Time.second / 10) Broadcast
        , wsReceive WsReceive
        , clientConnection Connection
        ]
