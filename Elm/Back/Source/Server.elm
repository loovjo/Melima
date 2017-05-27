port module Server exposing (main)

import Time
import Json.Decode

main = Platform.program {init = init, update = update, subscriptions = subs}

init : ( Model, Cmd msg )
init = Model [] ! []

type alias Model =
    { clientIds : List String }

port wsSend : (String, String) -> Cmd msg
port clientConnection : (String -> msg) -> Sub msg

type Msg
    = Broadcast Time.Time
    | Connection String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Broadcast timestamp ->
            model !
                List.map (\id -> wsSend ("Hello!", id))
                model.clientIds
        Connection id ->
            { model | clientIds = Debug.log "Clients" <| model.clientIds ++ [id] } ! []

subs : Model -> Sub Msg
subs model = 
    Sub.batch
        [ Time.every (Time.second / 10) Broadcast
        , clientConnection Connection
        ]
