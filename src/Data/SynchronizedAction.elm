module Data.SynchronizedAction exposing (..)

import Data.StreamSource as StreamSource
import Json.Encode as E

type ActionType = Play | Pause

type alias SynchronizedAction = { action: ActionType, streams: List StreamSource.Model }

actionTypeToString: ActionType -> String
actionTypeToString actionType =
    case actionType of
        Play -> "Play"
        Pause -> "Pause"

synchronizedActionEncoder: SynchronizedAction -> String
synchronizedActionEncoder action =
    E.object
            [ ("action", E.string (actionTypeToString action.action))
            , ("streams", (StreamSource.streamListEncoder action.streams))]
    |> (E.encode 0)