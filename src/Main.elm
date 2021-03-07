module Main exposing (main)

import Browser
import Components.CustomStream exposing (keyedStreamBlock)
import Components.InfoModal exposing (infoModal)
import Components.StreamAddModal exposing (streamAddModal)
import Html exposing (..)
import Html.Attributes exposing (class)
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
init = { streams = [ { source = "5qap5aO4i9A" }, { source = "9Auq9mYxFEE" } ]
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
    Keyed.node "div" streamListBlockStyle (List.indexedMap (buildFocusedStreamBlock displayMode) streams)

buildFocusedStreamBlock: StreamDisplayMode -> Int -> StreamSource -> (String, Html Msg)
buildFocusedStreamBlock displayMode order stream = keyedStreamBlock (buildStreamDisplayParams displayMode order ) stream

toolbarBlock: Html Msg
toolbarBlock =
    div toolbarBlockStyle
        [ span (toolbarIconStyle ++ [ class "material-icons", onClick OpenAddStreamModal ]) [text "add"]
        , span (toolbarIconStyle ++ [ class "material-icons", onClick OpenInfoModal]) [text "help_outline"] ]

view: Model -> Html Msg
view model =
    let
        addStreamModal = case model.streamAddModal.isOpened of
            True -> streamAddModal model.streamAddModal
            False -> div [][]
        infoModal_ = case model.infoModal.isOpened of
            True -> infoModal
            False -> div [][]
    in
        div outerBlockStyle [ toolbarBlock
            , div activeSpaceBlockStyle [buildStreamList model.displayMode model.streams]
            , addStreamModal
            , infoModal_
        ]
