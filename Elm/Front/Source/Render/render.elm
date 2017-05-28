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
                , Sa.height <| toString <| size.y
                , Sa.style "background: #337733"
                ] <|
                List.concatMap (renderPlayer model) model.gameState.players
            ]
renderPlayer : Model -> Player -> List (S.Svg Msg)
renderPlayer model player =
    [ S.circle 
        [ Sa.cx <| toString <| .x <| toPixels model player.pos
        , Sa.cy <| toString <| .y <| toPixels model player.pos
        , Sa.r <| toString model.zoom
        , Sa.fill "red"
        , Sa.stroke "black"
        , Sa.strokeWidth "3"
        ] []
    , S.line
        (
            let (dx, dy) = fromPolar (model.zoom, player.rotation)
            in
                [ Sa.x1 <| toString <| .x <| toPixels model player.pos
                , Sa.y1 <| toString <| .y <| toPixels model player.pos
                , Sa.x2 <| toString <| dx + (.x <| toPixels model player.pos)
                , Sa.y2 <| toString <| dy + (.y <| toPixels model player.pos)
                , Sa.strokeWidth "3"
                , Sa.stroke "black"
                ]
        ) []
    , S.text_
        [ Sa.x <| toString <| .x <| toPixels model player.pos
        , Sa.y <| toString <| model.zoom * 2.5 + (.y <| toPixels model player.pos)
        , Sa.fontFamily "Verdana"
        , Sa.textAnchor "middle"
        ] [S.text player.name]
    ]
