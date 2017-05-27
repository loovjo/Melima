module Update.Keyboard exposing (keyDown, keyUp, keyPress)

import Base exposing (..)
import ClientBase exposing (..)

keyDown : Model -> String -> ( Model, Cmd Msg )
keyDown model button =
    if button == "SHIFT" then
        case model.lastMousePos of
            Just pos -> { model | scrollCenter = Just <| toPixels model pos } ! []
            Nothing -> model ! []
    else model ! []


keyUp : Model -> String -> ( Model, Cmd Msg )
keyUp model button = 
    if button == "SHIFT" then
       { model | scrollCenter = Nothing } ! []
    else model ! []


keyPress : Model -> String -> ( Model, Cmd Msg )
keyPress model button = model ! []
