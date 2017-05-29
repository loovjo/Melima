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
                ++ List.concatMap (renderEntity model) model.gameState.entities
                ++ case model.you of
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
    let (cx, cy) = (.x <| toPixels model player.pos, .y <| toPixels model player.pos)
    in
        [ S.circle 
            [ Sa.cx <| toString cx
            , Sa.cy <| toString cy
            , Sa.r <| toString model.zoom
            , Sa.fill <| case model.you of
                Just you -> if you.id == player.id then "blue" else "red"
                Nothing -> "#1d54ad"
            , Sa.stroke "#000000"
            , Sa.strokeWidth "3"
            ] []
        , S.line -- Health
            [ Sa.x1 <| toString <| cx - 5 * model.zoom - 2
            , Sa.y1 <| toString <| cy - 2 * model.zoom
            , Sa.x2 <| toString <| cx + 5 * model.zoom + 2
            , Sa.y2 <| toString <| cy - 2 * model.zoom
            , Sa.strokeWidth "7"
            , Sa.stroke "#000000"
            ] []
        , S.line -- Health
            [ Sa.x1 <| toString <| cx - 5 * model.zoom
            , Sa.y1 <| toString <| cy - 2 * model.zoom
            , Sa.x2 <| toString <| cx - 5 * model.zoom + model.zoom * 10 * player.health / player.maxHealth
            , Sa.y2 <| toString <| cy - 2 * model.zoom
            , Sa.strokeWidth "3"
            , Sa.stroke "#FF0000"
            ] []
        , S.line
            (
                let (dx, dy) = fromPolar (model.zoom, player.rotation)
                in
                    [ Sa.x1 <| toString cx
                    , Sa.y1 <| toString cy
                    , Sa.x2 <| toString <| dx + cx
                    , Sa.y2 <| toString <| dy + cy
                    , Sa.strokeWidth "3"
                    , Sa.stroke "#000000"
                    ]
            ) []
        , S.text_
            [ Sa.x <| toString cx
            , Sa.y <| toString <| model.zoom * 2.5 + cy
            , Sa.fontFamily "Verdana"
            , Sa.textAnchor "middle"
            , Sa.fontSize <| toString model.zoom
            ] [S.text player.name]
        ]

renderEntity : Model -> Entity -> List (S.Svg Msg)
renderEntity model entity =
    case entity of
        ZapEntity pos rot vel ageLeft ->
            let (dx, dy) = fromPolar (model.zoom, rot)
                (x, y) = (.x <| toPixels model pos, .y <| toPixels model pos)
            in [ S.line
                [ Sa.x1 <| toString x
                , Sa.y1 <| toString y
                , Sa.x2 <| toString <| x + dx
                , Sa.y2 <| toString <| y + dy
                , Sa.strokeWidth "3"
                , Sa.stroke "#00FFFF"
                ] []
            ]

