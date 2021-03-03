module Main exposing (main)

import Browser
import Components.CustomStream exposing (customStream)
import Html exposing (..)
import Models exposing (Msg(..), StreamSource)
import Styles exposing (..)

main =
    Browser.sandbox { init = init, update = update, view = view }

type alias Model = { streams: List StreamSource }

init : Model
init = { streams = [ { source = "5qap5aO4i9A" }, { source = "Ggdm7oGNA5M" }, { source = "0FKuVh336Og" } ] }

update : Msg -> Model -> Model
update msg model =
    case msg of
        ActivateStream stream -> activateStream model stream

activateStream: Model -> StreamSource -> Model
activateStream model stream =
    let
        newList = model.streams
            |> List.filter (\a -> a.source /= stream.source)
            |> (++) [ stream ]
    in
        { model | streams = newList }

focusedVideoView: (List StreamSource) -> List (Html Msg)
focusedVideoView streams =
    case (List.head streams, List.tail streams) of
        (Just head, Nothing) -> [ div mainStreamStyle [customStream head True]]
        (Just head, Just rest) -> [ div mainStreamStyle [customStream head True]
                                    , div unfocusedBlockStyle (drawTheRestOfStreams rest)]
        (_, _) -> [ div [][]]

drawTheRestOfStreams: (List StreamSource) -> List (Html Msg)
drawTheRestOfStreams streams =
    List.map (\a -> (customStream a False)) streams

view: Model -> Html Msg
view model =
    div outerBlockStyle [ div toolbarBlockStyle []
        , div activeSpaceBlockStyle (focusedVideoView model.streams)
    ]
