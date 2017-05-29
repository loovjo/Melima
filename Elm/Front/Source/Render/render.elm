module Render.Render exposing (view)

import Html exposing (..)
import Svg as S
import Svg.Attributes as Sa
import Svg.Events as Se

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
                ++
                case model.you of
                    Just you ->
                        if (List.length <| List.filter ((==) you.id << .id) model.gameState.players) == 0
                            then
                                [ S.circle
                                    [ Sa.cx <| toString <| size.x - 50
                                    , Sa.cy <| toString <| size.y - 50
                                    , Sa.r "20"
                                    , Sa.fill "#7aad1c"
                                    , Se.onClick MakePlayerPrompt
                                    ] []
                                ]
                            else []
                    Nothing -> []
            ]
renderPlayer : Model -> Player -> List (S.Svg Msg)
renderPlayer model player =
    [ S.circle 
        [ Sa.cx <| toString <| .x <| toPixels model player.pos
        , Sa.cy <| toString <| .y <| toPixels model player.pos
        , Sa.r <| toString model.zoom
        , Sa.fill <| case model.you of
            Just you -> if you.id == player.id then "blue" else "red"
            Nothing -> "#1d54ad"
        , Sa.stroke "#000000"
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
                , Sa.stroke "#000000"
                ]
        ) []
    , S.text_
        [ Sa.x <| toString <| .x <| toPixels model player.pos
        , Sa.y <| toString <| model.zoom * 2.5 + (.y <| toPixels model player.pos)
        , Sa.fontFamily "Verdana"
        , Sa.textAnchor "middle"
        , Sa.fontSize <| toString model.zoom
        ] [S.text player.name]
    ]
