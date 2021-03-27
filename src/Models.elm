module Models exposing (..)

import Json.Decode as D
import Json.Encode as E

type alias StreamSource = { source: String, platform: StreamPlatform }

type StreamPlatform = Youtube | Twitch

type alias StreamAddModal = { isOpened: Bool, inputText: String, errorText: String }

type alias InfoModal = { isOpened: Bool }

type StreamDisplayMode = Focused | Balanced

type StreamDisplayDirection = Vertical | Horizontal

type alias StreamDisplayParams = { mode: StreamDisplayMode
                                 , direction: StreamDisplayDirection
                                 , ratio: Float }

type Msg = ActivateStream StreamSource
    | DeleteStream StreamSource
    | OpenAddStreamModal
    | CloseAddStreamModal
    | ChangeAddStreamModalText String
    | ConfirmStreamAdd
    | OpenInfoModal
    | CloseInfoModal
    | ChangeDisplayMode StreamDisplayMode
    | OnResize Int Int

type alias Flags = { windowWidth: Int, windowHeight: Int, startingSources: Maybe (List StreamSource) }

platformToString: StreamPlatform -> String
platformToString platform =
    case platform of
           Youtube -> "Youtube"
           Twitch -> "Twitch"

streamListEncoder: List StreamSource -> E.Value
streamListEncoder list =
    E.list streamSourceEncoder list

streamSourceEncoder: StreamSource -> E.Value
streamSourceEncoder source =
    E.object
        [ ("source", E.string source.source)
        , ("platform", E.string (platformToString source.platform))]

flagsDecoder: D.Decoder Flags
flagsDecoder =
    D.map3 Flags
        (D.field "windowWidth" D.int)
        (D.field "windowHeight" D.int)
        (D.field "startingSources" (D.nullable (D.list streamSourceDecoder)))

streamSourceDecoder: D.Decoder StreamSource
streamSourceDecoder =
    D.map2 StreamSource
        (D.field "source" D.string)
        (D.field "platform" streamPlatformDecoder)

streamPlatformDecoder: D.Decoder StreamPlatform
streamPlatformDecoder =
    D.string
        |> D.andThen (\a -> case a of
                "Youtube" -> D.succeed Youtube
                "Twitch" -> D.succeed Twitch
                unknown -> D.fail <| "Unknown platform: " ++ unknown
        )

encodeStreamListToString: List StreamSource -> String
encodeStreamListToString list =
    (E.encode 0 (streamListEncoder list))

