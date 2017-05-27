module Update.Mouse exposing (mouseDown, mouseUp, mouseMoved)

import Base exposing (..)
import ClientBase exposing (..)

mouseDown : Model -> Position -> ( Model, Cmd Msg )
mouseDown model pos = model ! []

mouseUp : Model -> Position -> ( Model, Cmd Msg )
mouseUp model pos = model ! []

mouseMoved : Model -> Position -> ( Model, Cmd Msg )
mouseMoved model pos = model ! []
