module Update.Keyboard exposing (keyDown, keyUp, keyPress)

import Base exposing (..)
import ClientBase exposing (..)
import WebSocket as Ws

keyDown : Model -> String -> ( Model, Cmd Msg )
keyDown model button =
    if button == "SHIFT" then
        case model.lastMousePos of
            Just pos -> { model | scrollCenter = Just <| toPixels model pos } ! []
            Nothing -> model ! []
    else if button == "A" then
        model ! [wsSend "rot -6"]
    else if button == "D" then
        model ! [wsSend "rot 6"]
    else if button == "W" then
        model ! [wsSend "walk 10"]
    else if button == "S" then
        model ! [wsSend "walk -7"]
    else if button == "I" then
        { model | zoom = model.zoom / 1.2 } ! []
    else if button == "O" then
        { model | zoom = model.zoom * 1.2 } ! []
    else if button == "0" then
        { model | zoom = 10, scroll = Position 0 0 } ! []
    else if button == "Z" then
        model ! [wsSend "zap 30"]
    else model ! []


keyUp : Model -> String -> ( Model, Cmd Msg )
keyUp model button = 
    if button == "SHIFT" then
       { model | scrollCenter = Nothing } ! []
    else if button == "A" || button == "D" then
        model ! [wsSend "rot 0"]
    else if button == "W" || button == "S" then
        model ! [wsSend "walk 0"]
    else model ! []


keyPress : Model -> String -> ( Model, Cmd Msg )
keyPress model button = model ! []
