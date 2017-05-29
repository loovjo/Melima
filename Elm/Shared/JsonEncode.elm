module JsonEncode exposing (..)

import Json.Encode exposing (..)

import Base exposing (..)

encodePosition : Position -> Value
encodePosition pos =
    object
        [ ("x", float pos.x)
        , ("y", float pos.y)
        ]

encodeTotalState : TotalState -> Value
encodeTotalState tstate =
    object
        [ ("gameState", encodeGameState tstate.state)
        , ("you", encodeYou tstate.you)
        ]

encodeYou : You -> Value
encodeYou you =
    object <|
        [ ("ip", string you.ip)
        , ("id", string you.id)
        ]

encodeGameState : GameState -> Value
encodeGameState state =
    object
        [ ("players", list <| List.map encodePlayer state.players)
        , ("entities", list <| List.map encodeEntity state.entities)
        ]

encodeEntity : Entity -> Value
encodeEntity entity =
    case entity of
        ZapEntity pos rot vel ageLeft ->
            object
                [ ("type", string "Zap")
                , ("pos", encodePosition pos)
                , ("rot", float rot)
                , ("vel", float vel)
                , ("ageLeft", float ageLeft)
                ]

encodePlayer : Player -> Value
encodePlayer player =
    object
        [ ("pos", encodePosition player.pos)
        , ("rotation", float player.rotation)
        , ("turning", float player.turning)
        , ("vel", float player.vel)
        , ("name", string player.name)
        , ("id", string player.id)
        , ("health", float player.health)
        , ("maxHealth", float player.maxHealth)
        ]
