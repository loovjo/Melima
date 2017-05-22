module Main exposing (..)

import Char exposing (toCode, fromCode)
import String exposing (fromChar)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Lazy exposing (..)
import Json.Decode exposing (decodeString)
import Keyboard

import WebSocket

import Base exposing (..)
import JsonDecode exposing (..)


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

        , err = Nothing
        , webSocketUrl = flags.webSocketUrl
        }
        , Cmd.none
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyDown_ code ->
            case keyboardMap !! code of
                Just key -> update (KeyDown key) model
                Nothing -> model ! []

        KeyUp_ code ->
            case keyboardMap !! code of
                Just key -> update (KeyUp key) model
                Nothing -> model ! []

        KeyDown text ->
            model ! []

        KeyUp text ->
            model ! []

        KeyPress code ->
            let chr = fromCode code
            in model ! []

        WsMsg json ->
            case decodeString decodeTotalState json of
                Ok {state, you} ->
                    { model
                    | gameState = state
                    , you = Just you
                    , err = Nothing
                    } ! []
                Err err ->
                    { model | err = Just err } ! []

view : Model -> Html Msg
view model =
    div [] <|
        [ pre [] [text <| toString model.gameState]
        ] ++ (toList <| Maybe.map (\a -> pre [] [text <| a.ip ++ " " ++ toString a.player]) model.you)
          ++ (toList <| Maybe.map (\a -> pre [] [text a]) model.err)

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
    [ Keyboard.downs KeyDown_
    , Keyboard.ups KeyUp_
    , Keyboard.presses KeyPress
    , WebSocket.listen model.webSocketUrl WsMsg
    ]