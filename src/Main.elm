module Main exposing (main)

import Browser
import Components.CustomStream exposing (keyedStreamBlock)
import Components.InfoModal exposing (infoModal)
import Components.StreamAddModal exposing (streamAddModal)
import Html exposing (..)
import Html.Attributes exposing (class, style, title)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Maybe exposing (andThen)
import Models exposing (InfoModal, Msg(..), StreamAddModal, StreamDisplayMode(..), StreamSource, buildStreamDisplayParams)
import Regex
import Styles exposing (..)

main =
    Browser.sandbox { init = init, update = update, view = view }

type alias Model = { streams: List StreamSource, streamAddModal: StreamAddModal, infoModal: InfoModal, displayMode: StreamDisplayMode }

init : Model
init = { streams = [ ]
        , streamAddModal = { isOpened = False, inputText = "" }
        , infoModal = { isOpened = False }
        , displayMode = Focused }

update : Msg -> Model -> Model
update msg model =
    case msg of
        ActivateStream stream -> activateStream model stream
        DeleteStream stream -> deleteStream model stream
        OpenAddStreamModal -> { model | streamAddModal = (updateStreamModalIsOpened True model.streamAddModal ) }
        CloseAddStreamModal -> { model | streamAddModal = (updateStreamModalIsOpened False model.streamAddModal ) }
        ChangeAddStreamModalText inputText -> { model | streamAddModal = (updateModalInputText inputText model.streamAddModal )}
        ConfirmStreamAdd -> addStream model
        OpenInfoModal -> { model | infoModal = (updateInfoModalIsOpened True model.infoModal)}
        CloseInfoModal -> { model | infoModal = (updateInfoModalIsOpened False model.infoModal)}
        ChangeDisplayMode displayMode -> { model | displayMode = displayMode }

testRegex: Regex.Regex
testRegex =
    Maybe.withDefault Regex.never <|
        Regex.fromString "\\?v=(\\w*)\\&?"

addStream: Model -> Model
addStream model =
    let
        matchMaybe = (Regex.find testRegex model.streamAddModal.inputText)
            |> List.head
            |> Maybe.map .submatches
            |> andThen List.head
        matchString = case matchMaybe of
            Nothing -> model.streamAddModal.inputText
            Just m -> case (m) of
                Nothing -> model.streamAddModal.inputText
                Just token -> token
    in
        updateModelAndAddStream matchString model

updateModelAndAddStream: String -> Model -> Model
updateModelAndAddStream source model =
    { model | streams = (model.streams ++ [{ source = source }])
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

activateStream: Model -> StreamSource -> Model
activateStream model stream =
    let
        newList = model.streams
            |> List.filter (\a -> a.source /= stream.source)
            |> (++) [ stream ]
    in
        { model | streams = newList }

deleteStream: Model -> StreamSource -> Model
deleteStream model stream =
    let
        newList = List.filter (\a -> a.source /= stream.source) model.streams
    in
        { model | streams = newList }

buildStreamList: StreamDisplayMode -> (List StreamSource) -> (Html Msg)
buildStreamList displayMode streams =
    if (List.length streams > 0) then
        Keyed.node "div"
            (streamListBlockStyle displayMode)
            (List.indexedMap (buildFocusedStreamBlock displayMode) streams)
    else
        button (addStreamButtonStyle ++ [ onClick OpenAddStreamModal ]) [ text "Add your first stream"]

buildFocusedStreamBlock: StreamDisplayMode -> Int -> StreamSource -> (String, Html Msg)
buildFocusedStreamBlock displayMode order stream = keyedStreamBlock (buildStreamDisplayParams displayMode order ) stream

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
            , div activeBlockStyle [buildStreamList model.displayMode model.streams]
            , addStreamModal
            , infoModal_
        ]
