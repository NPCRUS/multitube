module Data.StreamSource exposing (..)

import Json.Decode as D
import Json.Encode as E

type Platform = Youtube | Twitch

type alias Model = { token: String, platform: Platform }

setToken: String -> Model -> Model
setToken token source =
    { source | token = token }

setPlatform: Platform -> Model -> Model
setPlatform platform source =
    { source | platform = platform }

platformToString: Platform -> String
platformToString platform =
    case platform of
           Youtube -> "Youtube"
           Twitch -> "Twitch"

streamListEncoder: List Model -> E.Value
streamListEncoder list =
    E.list streamSourceEncoder list

streamSourceEncoder: Model -> E.Value
streamSourceEncoder source =
    E.object
        [ ("source", E.string source.token)
        , ("platform", E.string (platformToString source.platform))]

streamSourceDecoder: D.Decoder Model
streamSourceDecoder =
    D.map2 Model
        (D.field "source" D.string)
        (D.field "platform" streamPlatformDecoder)

streamPlatformDecoder: D.Decoder Platform
streamPlatformDecoder =
    D.string
        |> D.andThen (\a -> case a of
                "Youtube" -> D.succeed Youtube
                "Twitch" -> D.succeed Twitch
                unknown -> D.fail <| "Unknown platform: " ++ unknown
        )

encodeStreamListToString: List Model -> String
encodeStreamListToString list =
    (E.encode 0 (streamListEncoder list))