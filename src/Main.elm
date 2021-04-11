port module Main exposing (main)

import Basics as Int
import Browser
import Browser.Events as Events
import Components.CustomStream exposing (keyedStreamBlock)
import Components.InfoModal exposing (infoModal)
import Components.StreamAddModal exposing (streamAddModal)
import Html exposing (..)
import Html.Attributes exposing (class, href, style, target, title)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Json.Decode exposing (decodeValue)
import Maybe exposing (andThen)
import Data.StreamSource as StreamSource exposing (..)
import Data.StreamAddModal as StreamAddModal exposing (..)
import Data.InfoModal as InfoModal exposing (..)
import Data.DisplayParams as DisplayParams exposing (..)
import Data.Flags exposing (..)
import Msg exposing (..)
import Regex
import Styles exposing (..)
import Utils exposing (maybeFlatten2)

main =
    Browser.element { init = init
                    , view = view
                    , update = update
                    , subscriptions = subscriptions }

type alias Model = { streams: List StreamSource.Model
                    , streamAddModal: StreamAddModal.Model
                    , infoModal: InfoModal.Model
                    , displayParams: DisplayParams.Model
                    , version: String }

init : Json.Decode.Value -> (Model, Cmd Msg)
init flagsRaw =
    let
        (flags, cmd) = case decodeValue flagsDecoder flagsRaw of
            Ok decoded -> (decoded, Cmd.none)
            Err _ -> ({ windowWidth = 1920, windowHeight = 1080, startingSources = Just [], version = "DEV" }, setSources ((encodeStreamListToString [])))
        windowRatio = calcRatio flags.windowWidth flags.windowHeight
        direction = calcDirection windowRatio
        initialStreams = case flags.startingSources of
            Just streams -> streams
            Nothing -> []
    in
        ({ streams = initialStreams
            , streamAddModal = { isOpened = False, inputText = "", errorText = "" }
            , infoModal = { isOpened = False }
            , displayParams = { mode = Focused, direction = direction, ratio = windowRatio }
            , version = flags.version }
            ,cmd)


-- PORTS
port setSources: String -> Cmd msg

-- UPDATE

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ActivateStream stream -> onActivateStream model stream
        DeleteStream stream -> onDeleteStream model stream
        OpenAddStreamModal -> onOpenAddStreamModal model
        CloseAddStreamModal -> onCloseAddStreamModal model
        ChangeAddStreamModalText inputText -> onChangeAddStreamModalText model inputText
        ConfirmStreamAdd -> onConfirmStreamAdd model
        OpenInfoModal -> ({ model | infoModal = model.infoModal |> InfoModal.setIsOpened True }, Cmd.none)
        CloseInfoModal -> ({ model | infoModal = model.infoModal |> InfoModal.setIsOpened False }, Cmd.none)
        ChangeDisplayMode displayMode -> onChangeDisplayMode model displayMode
        OnResize width height -> onResize model width height

calcRatio: Int -> Int -> Float
calcRatio width height =
    (Int.toFloat width) / ( Int.toFloat height)

-- 1.035 is some magic number that so far works on both 27inch 1440p and 24inch 1080p screens when you collapse browser window into half
calcDirection: Float -> DisplayParams.Direction
calcDirection ratio =
    if(ratio > 1.035) then Horizontal else Vertical

youtubeLinkRegex: Regex.Regex
youtubeLinkRegex =
    Maybe.withDefault Regex.never <|
        Regex.fromString "\\.*?v=(\\w*)\\&?"

twitchLinkRegex: Regex.Regex
twitchLinkRegex =
    Maybe.withDefault Regex.never <|
        Regex.fromString ".*twitch\\.tv\\/(.*)"

onActivateStream: Model -> StreamSource.Model -> (Model, Cmd msg)
onActivateStream model stream =
    let
        newList = model.streams
            |> List.filter (\a -> a.token /= stream.token)
            |> (++) [ stream ]
    in
        ({ model | streams = newList }, setSources (encodeStreamListToString newList))

onDeleteStream: Model -> StreamSource.Model -> (Model, Cmd msg)
onDeleteStream model stream =
    let
        newList = List.filter (\a -> a.token /= stream.token) model.streams
    in
        ({ model | streams = newList }, setSources (encodeStreamListToString newList))

onOpenAddStreamModal: Model -> (Model, Cmd msg)
onOpenAddStreamModal model =
    ({ model |
        streamAddModal = model.streamAddModal |> StreamAddModal.setIsOpened True }
    , Cmd.none)

onCloseAddStreamModal: Model -> (Model, Cmd msg)
onCloseAddStreamModal model =
    ({ model |
        streamAddModal = model.streamAddModal
            |> StreamAddModal.setIsOpened False
            |> StreamAddModal.setInputText ""
            |> StreamAddModal.setErrorText ""}
    , Cmd.none)

onChangeAddStreamModalText: Model -> String -> (Model, Cmd msg)
onChangeAddStreamModalText model inputText =
    ({ model |
        streamAddModal = model.streamAddModal
            |> StreamAddModal.setInputText inputText}
    , Cmd.none)

onConfirmStreamAdd: Model -> (Model, Cmd msg)
onConfirmStreamAdd model =
    let
        youtubeMatchMaybe = (Regex.find youtubeLinkRegex model.streamAddModal.inputText)
            |> List.head
            |> Maybe.map .submatches
            |> andThen List.head
            |> maybeFlatten2
        twitchMatchMaybe = (Regex.find twitchLinkRegex model.streamAddModal.inputText)
            |> List.head
            |> Maybe.map .submatches
            |> andThen List.head
            |> maybeFlatten2
        maybeSource = case (twitchMatchMaybe, youtubeMatchMaybe) of
            (Just twitch, Nothing) -> Just { token = twitch, platform = Twitch }
            (Nothing, Just youtube) -> Just { token = youtube, platform = Youtube }
            (Nothing, Nothing) -> Nothing
            (Just _, Just _) -> Nothing -- wtf???
    in
        case maybeSource of
            Just streamSource ->
                let
                    newModel =
                        { model | streams = model.streams ++ [streamSource]
                        , streamAddModal = model.streamAddModal
                            |> StreamAddModal.setIsOpened False
                            |> StreamAddModal.setInputText ""
                            |> StreamAddModal.setErrorText "" }
                in
                    (newModel, setSources (encodeStreamListToString newModel.streams))
            Nothing ->
                ({ model | streamAddModal = model.streamAddModal |> StreamAddModal.setErrorText "cannot add stream" }, Cmd.none)

onChangeDisplayMode: Model -> DisplayParams.Mode -> (Model, Cmd msg)
onChangeDisplayMode model mode =
    ({ model | displayParams = model.displayParams |> DisplayParams.setMode mode }, Cmd.none)

onResize: Model -> Int -> Int -> (Model, Cmd msg)
onResize model width height =
    let
        ratio = calcRatio width height
        direction = calcDirection ratio
    in
        ({ model | displayParams = model.displayParams |> DisplayParams.setDirection direction |> DisplayParams.setRatio ratio }, Cmd.none)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [
        Events.onResize (\w h -> OnResize w h)
    ]


-- VIEW
view: Model -> Html Msg
view model =
    let
        addStreamModal = case model.streamAddModal.isOpened of
            True -> streamAddModal model.streamAddModal
            False -> div [][]
        infoModal_ = case model.infoModal.isOpened of
            True -> infoModal
            False -> div [][]
        activeBlockStyle = if(List.length model.streams) > 0 then activeSpaceBlockStyle else activeSpaceBlockStyle ++ justifyContentCenter
    in
        div outerBlockStyle [ toolbarBlock model
            , div activeBlockStyle [buildStreamList model.displayParams model.streams]
            , addStreamModal
            , infoModal_
        ]

buildStreamList: DisplayParams.Model -> (List StreamSource.Model) -> (Html Msg)
buildStreamList displayParams streams =
    if (List.length streams > 0) then
        Keyed.node "div"
            (streamListBlockStyle displayParams)
            (List.indexedMap (buildFocusedStreamBlock displayParams) streams)
    else
        button (addStreamButtonStyle ++ [ onClick OpenAddStreamModal ]) [ text "Add your first stream"]

buildFocusedStreamBlock: DisplayParams.Model -> Int -> StreamSource.Model -> (String, Html Msg)
buildFocusedStreamBlock displayParams order stream = keyedStreamBlock (displayParams, order) stream

toolbarBlock: Model -> Html Msg
toolbarBlock model =
    div toolbarBlockStyle
        [ div toolbarLeftBlockStyle
            [
                span (toolbarIconStyle ++ [ title "add new stream to the list", style "margin-right" "2px", class "material-icons", onClick OpenAddStreamModal ]) [text "add"]
                , span (toolbarIconStyle ++ [ title "switch to focused view", style "margin-right" "2px", class "material-icons", onClick (ChangeDisplayMode Focused) ]) [text "view_sidebar"]
                , span (toolbarIconStyle ++ [ title "switch to balanced view", style "margin-right" "2px", class "material-icons", onClick (ChangeDisplayMode Balanced) ]) [text "view_module"]
            ]
        , div flexRow
            [
                a  (versionLinkStyle ++ [href ("https://github.com/NPCRUS/multitube/releases/tag/" ++ model.version)
                , target "_blank"])
                    [text ("v" ++ model.version)]
                , span (toolbarIconStyle ++ [ title "info about website", class "material-icons", onClick OpenInfoModal]) [text "help_outline"] ]
            ]
