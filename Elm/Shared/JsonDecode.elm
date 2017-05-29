module JsonDecode exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as P

import Base exposing (..)


decodePosition : Decoder Position
decodePosition =
    P.decode Position
        |> P.required "x" Decode.float
        |> P.required "y" Decode.float


decodeTotalState : Decoder TotalState
decodeTotalState =
    P.decode TotalState
        |> P.required "gameState" decodeGameState
        |> P.required "you" decodeYou

decodeYou : Decoder You
decodeYou =
    P.decode You
        |> P.required "ip" Decode.string
        |> P.required "id" Decode.string

decodeGameState : Decoder GameState
decodeGameState =
    P.decode GameState
        |> P.required "players" (Decode.list decodePlayer)

decodePlayer : Decoder Player
decodePlayer =
    P.decode Player
        |> P.required "pos" decodePosition
        |> P.required "rotation" Decode.float
        |> P.required "turning" Decode.float
        |> P.required "vel" Decode.float
        |> P.required "name" Decode.string
        |> P.required "id" Decode.string
        |> P.required "health" Decode.float
        |> P.required "maxHealth" Decode.float

