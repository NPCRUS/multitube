module Main exposing (main)

import Browser
import Components.CustomStream exposing (keyedStreamBlock)
import Components.StreamAddModal exposing (streamAddModal)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Models exposing (Msg(..), StreamAddModal, StreamSource)
import Styles exposing (..)

main =
    Browser.sandbox { init = init, update = update, view = view }

type alias Model = { streams: List StreamSource, modal: StreamAddModal }

init : Model
init = { streams = [ { source = "IDfhf7esxZE" }, { source = "_SBFZxzs2h0" } ]
        , modal = { isOpened = False, inputText = "" } }

update : Msg -> Model -> Model
update msg model =
    case msg of
        ActivateStream stream -> activateStream model stream
        DeleteStream stream -> deleteStream model stream
        OpenAddStreamModal -> { model | modal = (updateModalIsOpened True model.modal ) }
        CloseAddStreamModal -> { model | modal = (updateModalIsOpened False model.modal ) }
        ChangeAddStreamModalText inputText -> { model | modal = (updateModalInputText inputText model.modal )}
        ConfirmStreamAdd -> addStream model

addStream: Model -> Model
addStream model =
    { model | streams = (model.streams ++ [{ source = model.modal.inputText }])
    , modal = model.modal |> updateModalIsOpened False |> updateModalInputText "" }

updateModalIsOpened: Bool -> StreamAddModal -> StreamAddModal
updateModalIsOpened isOpened modal  =
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

streamList: (List StreamSource) -> (Html Msg)
streamList streams =
    Keyed.node "div" (testBlockStyle ++ [ class "special-style"]) (List.map keyedStreamBlock streams)

toolbarBlock: Html Msg
toolbarBlock =
    div toolbarBlockStyle [ span (toolbarIconStyle ++ [ class "material-icons", onClick OpenAddStreamModal ]) [text "add_box"] ]

view: Model -> Html Msg
view model =
    let
        modal = case model.modal.isOpened of
            True -> streamAddModal model.modal
            False -> div [][]
    in
        div outerBlockStyle [ toolbarBlock
            , div activeSpaceBlockStyle [streamList model.streams]
            , modal
        ]
