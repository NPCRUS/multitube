port module Main exposing (main)

import Basics as Int
import Browser
import Browser.Events as Events
import Components.CustomStream exposing (keyedStreamBlock)
import Components.InfoModal exposing (infoModal)
import Components.StreamAddModal exposing (streamAddModal)
import Html exposing (..)
import Html.Attributes exposing (class, style, title)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Json.Decode exposing (decodeValue)
import Maybe exposing (andThen)
import Models exposing (Flags, InfoModal, Msg(..), StreamAddModal, StreamDisplayDirection(..), StreamDisplayMode(..), StreamDisplayParams, StreamPlatform(..), StreamSource, encodeStreamListToString, flagsDecoder)
import Regex
import Styles exposing (..)

main =
    Browser.element { init = init
                    , view = view
                    , update = update
                    , subscriptions = subscriptions }

type alias Model = { streams: List StreamSource
                    , streamAddModal: StreamAddModal
                    , infoModal: InfoModal
                    , displayParams: StreamDisplayParams }

init : Json.Decode.Value -> (Model, Cmd Msg)
init flagsRaw =
    let
        (flags, cmd) = case decodeValue flagsDecoder flagsRaw of
            Ok decoded -> (decoded, Cmd.none)
            Err _ -> ({ windowWidth = 1920, windowHeight = 1080, startingSources = Just []}, setSources ((encodeStreamListToString [])))
        windowRatio = calcRatio flags.windowWidth flags.windowHeight
        direction = calcDirection windowRatio
        initialStreams = case flags.startingSources of
            Just streams -> streams
            Nothing -> []
    in
        ({ streams = initialStreams
            , streamAddModal = { isOpened = False, inputText = "" }
            , infoModal = { isOpened = False }
            , displayParams = { mode = Focused, direction = direction, ratio = windowRatio } }
            ,cmd)


-- PORTS
port setSources: String -> Cmd msg

-- UPDATE
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ActivateStream stream -> activateStream model stream
        DeleteStream stream -> deleteStream model stream
        OpenAddStreamModal -> ({ model | streamAddModal = (updateStreamModalIsOpened True model.streamAddModal ) }, Cmd.none)
        CloseAddStreamModal -> ({ model | streamAddModal = (updateStreamModalIsOpened False model.streamAddModal ) }, Cmd.none)
        ChangeAddStreamModalText inputText -> ({ model | streamAddModal = (updateModalInputText inputText model.streamAddModal )}, Cmd.none)
        ConfirmStreamAdd -> addStream model
        OpenInfoModal -> ({ model | infoModal = (updateInfoModalIsOpened True model.infoModal)}, Cmd.none)
        CloseInfoModal -> ({ model | infoModal = (updateInfoModalIsOpened False model.infoModal)}, Cmd.none)
        ChangeDisplayMode displayMode -> (updateDisplayParams model (\a -> {a | mode = displayMode}), Cmd.none)
        OnResize width height ->
            let
                ratio = calcRatio width height
                direction = calcDirection ratio
            in
                (updateDisplayParams model (\a -> {a | direction = direction, ratio = ratio}), Cmd.none)

calcRatio: Int -> Int -> Float
calcRatio width height =
    (Int.toFloat width) / ( Int.toFloat height)

-- 1.035 is some magic number that so far works on both of 27inch 1440p and 24inch 1080p screens when you collapse browser window into half
calcDirection: Float -> StreamDisplayDirection
calcDirection ratio =
    if(ratio > 1.035) then Horizontal else Vertical

youtubeLinkRegex: Regex.Regex
youtubeLinkRegex =
    Maybe.withDefault Regex.never <|
        Regex.fromString "\\?v=(\\w*)\\&?"

addStream: Model -> (Model, Cmd msg)
addStream model =
    let
        matchMaybe = (Regex.find youtubeLinkRegex model.streamAddModal.inputText)
            |> List.head
            |> Maybe.map .submatches
            |> andThen List.head
        matchString = case matchMaybe of
            Nothing -> model.streamAddModal.inputText
            Just m -> case (m) of
                Nothing -> model.streamAddModal.inputText
                Just token -> token
        newModel = updateModelAndAddStream matchString model
    in
        (newModel, setSources ((encodeStreamListToString  newModel.streams)))

updateModelAndAddStream: String -> Model -> Model
updateModelAndAddStream source model =
    { model | streams = (model.streams ++ [{ source = source, platform = Youtube }])
        , streamAddModal = model.streamAddModal |> updateStreamModalIsOpened False |> updateModalInputText "" }

updateStreamModalIsOpened: Bool -> StreamAddModal -> StreamAddModal
updateStreamModalIsOpened isOpened modal =
    { modal | isOpened = isOpened }

updateInfoModalIsOpened: Bool -> InfoModal -> InfoModal
updateInfoModalIsOpened isOpened modal =
    { modal | isOpened = isOpened }

updateModalInputText: String -> StreamAddModal -> StreamAddModal
updateModalInputText inputText modal  =
    { modal | inputText = inputText }

activateStream: Model -> StreamSource -> (Model, Cmd msg)
activateStream model stream =
    let
        newList = model.streams
            |> List.filter (\a -> a.source /= stream.source)
            |> (++) [ stream ]
    in
        ({ model | streams = newList }, setSources (encodeStreamListToString newList))

deleteStream: Model -> StreamSource -> (Model, Cmd msg)
deleteStream model stream =
    let
        newList = List.filter (\a -> a.source /= stream.source) model.streams
    in
        ({ model | streams = newList }, setSources (encodeStreamListToString newList))

updateDisplayParams: Model -> (StreamDisplayParams -> StreamDisplayParams) -> Model
updateDisplayParams model updateFunc =
    {model | displayParams = updateFunc model.displayParams }


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
        div outerBlockStyle [ toolbarBlock
            , div activeBlockStyle [buildStreamList model.displayParams model.streams]
            , addStreamModal
            , infoModal_
        ]

buildStreamList: StreamDisplayParams -> (List StreamSource) -> (Html Msg)
buildStreamList displayParams streams =
    if (List.length streams > 0) then
        Keyed.node "div"
            (streamListBlockStyle displayParams)
            (List.indexedMap (buildFocusedStreamBlock displayParams) streams)
    else
        button (addStreamButtonStyle ++ [ onClick OpenAddStreamModal ]) [ text "Add your first stream"]

buildFocusedStreamBlock: StreamDisplayParams -> Int -> StreamSource -> (String, Html Msg)
buildFocusedStreamBlock displayParams order stream = keyedStreamBlock (displayParams, order) stream

toolbarBlock: Html Msg
toolbarBlock =
    div toolbarBlockStyle
        [ div toolbarLeftBlockStyle
            [
                span (toolbarIconStyle ++ [ title "add new stream to the list", style "margin-right" "2px", class "material-icons", onClick OpenAddStreamModal ]) [text "add"]
                , span (toolbarIconStyle ++ [ title "switch to focused view", style "margin-right" "2px", class "material-icons", onClick (ChangeDisplayMode Focused) ]) [text "view_sidebar"]
                , span (toolbarIconStyle ++ [ title "switch to balanced view", style "margin-right" "2px", class "material-icons", onClick (ChangeDisplayMode Balanced) ]) [text "view_module"]
            ]
        , div []
            [
                span (toolbarIconStyle ++ [ title "info about website", class "material-icons", onClick OpenInfoModal]) [text "help_outline"] ]
            ]
