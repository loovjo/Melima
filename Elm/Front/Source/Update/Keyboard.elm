module Update.Keyboard exposing (keyDown, keyUp, keyPress)

import Base exposing (..)
import ClientBase exposing (..)

keyDown : Model -> String -> ( Model, Cmd Msg )
keyDown model button = model ! []


keyUp : Model -> String -> ( Model, Cmd Msg )
keyUp model button = model ! []


keyPress : Model -> String -> ( Model, Cmd Msg )
keyPress model button = model ! []
