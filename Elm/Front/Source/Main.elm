module Main exposing (..)

import Char exposing (toCode, fromCode)
import String exposing (fromChar)
import Task
import Time

import Html exposing (..)
import Keyboard
import Mouse exposing (downs, ups, moves)

import Window exposing (Size)
import WebSocket

import Base exposing (..)
import ClientBase exposing (..)
import Update.Update exposing (update)
import Render.Render exposing (view)

import WebSocket as Ws


main =
    Html.programWithFlags { init = init, view = view, update = update, subscriptions = subscriptions }

type alias Flags =
    { webSocketUrl : String
    }

init : Flags -> ( Model, Cmd Msg )
init flags =
    (
        { gameState = GameState []
        , you = Nothing
        , lastTime = Nothing

        , size = Nothing
        , currentCombo = []

        , showDebug = False
        , err = Nothing
        , webSocketUrl = flags.webSocketUrl

        , scroll = Position 3 3
        , zoom = 10

        , sideScroll = 100
        , scrollSpeed = 100

        , lastMousePos = Nothing
        , pressing = False
        }
        , Cmd.batch
            [ Task.perform SizeChanged <| Window.size
            ]
    )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
    [ Keyboard.downs KeyDown_
    , Keyboard.ups KeyUp_
    , Keyboard.presses KeyPress
    , WebSocket.listen model.webSocketUrl WsMsg
    , Window.resizes SizeChanged
    , Time.every (Time.second / fps) Tick
    , downs MouseDown
    , ups MouseUp
    , moves MouseMoved
    , Ws.listen model.webSocketUrl ServerMsg
    ]