module Render.Render exposing (view)

import Html exposing (..)
import Svg as S
import Svg.Attributes as Sa

import Base exposing (..)
import ClientBase exposing (..)


view : Model -> Html Msg
view model =
    case model.size of
        Nothing -> div [] []
        Just size ->
            div [] <|
            [ S.svg
                [ Sa.width <| toString size.x
                , Sa.height <| toString size.y
                , Sa.style "background: #337733"
                ] <|
                List.map (renderPlayer model) model.gameState.players
            ]
renderPlayer : Model -> Player -> S.Svg Msg
renderPlayer model player =
    S.circle [ Sa.cx <| toString <| .x <| toPixels model player.pos
             , Sa.cy <| toString <| .y <| toPixels model player.pos
             , Sa.r <| toString model.zoom
             , Sa.fill "red"
             , Sa.stroke "black"
             , Sa.strokeWidth "3"] []
