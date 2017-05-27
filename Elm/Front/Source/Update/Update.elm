module Update.Update exposing (update)

import Char exposing (toCode, fromCode)
import String exposing (fromChar)
import Time exposing (inSeconds)

import Keyboard
import Json.Decode exposing (decodeString)

import WebSocket as Ws

import Base exposing (..)
import ClientBase exposing (..)
import JsonDecode exposing (..)

import Update.Keyboard exposing (keyDown, keyUp)
import Update.Mouse exposing (mouseDown, mouseUp, mouseMoved)

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

        KeyDown button -> keyDown model button

        KeyUp button -> keyUp model button

        KeyPress code ->
            let chr = fromCode code
            in model ! []

        MouseDown pos -> mouseDown { model | lastMousePos = Just <| decodeMouse model pos, pressing = True } <| decodeMouse model pos

        MouseUp pos -> let (result, cmd) = mouseDown model <| decodeMouse model pos
                       in ({ result | lastMousePos = Nothing, pressing = False }, cmd)

        MouseMoved pos -> let (result, cmd) = mouseMoved model <| decodeMouse model pos
                          in ({ result | lastMousePos = Just <| decodeMouse model pos }, cmd)

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

        SizeChanged newSize ->
            { model | size = Just <| Position (toFloat newSize.width) (toFloat newSize.height) } ! []

        Tick t ->
            let time = inSeconds t
                model_ = { model | lastTime = Just time }
            in case model.lastTime of
                Nothing -> model_ ! []
                Just last ->
                    let delta = time - last
                        (sDx, sDy) =
                            case (model.lastMousePos, model.scrollCenter) of
                                (Just mouseUnit, Just center) ->
                                    let mouse = Debug.log "Mouse" <| toPixels model mouseUnit
                                        diff = Position (mouse.x - center.x) (mouse.y - center.y)
                                        distDiv = dist diff |> max 20 |> min 200
                                    in (diff.x * delta / distDiv * 40, diff.y * delta / distDiv * 40)
                                _ -> (0, 0)
                        modelScroll = 
                            { model_
                            | scroll = {x = model.scroll.x + sDx, y = model.scroll.y + sDy}
                            }
                        newMouse =
                            case model.lastMousePos of
                                Just mouse -> Just <| fromPixels modelScroll <| toPixels model mouse
                                Nothing -> Nothing
                    in { modelScroll | lastMousePos = newMouse } ! []

        ServerMsg msg ->
            case decodeString decodeTotalState msg of
                Ok tState ->
                    { model | gameState = tState.state, you = Just tState.you } ! []
                Err _ ->
                    model ! []
