module Main exposing (main)

import Browser
import Components.CustomStream exposing (customStream, keyedCustomStream)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy)
import Models exposing (Msg(..), StreamSource)
import Styles exposing (..)

main =
    Browser.sandbox { init = init, update = update, view = view }

type alias Model = { streams: List StreamSource }

init : Model
init = { streams = [ { source = "2tWkQbbmlwQ" }, { source = "vfVo_YQBEQA" }, { source = "qJdhYmWdXQQ" }, { source = "9Auq9mYxFEE" } ] }

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

testVideoView: (List StreamSource) -> (Html Msg)
testVideoView streams =
    Keyed.node "div" (testBlockStyle ++ [ class "special-style"]) (List.map keyedCustomStream streams)

view: Model -> Html Msg
view model =
    div outerBlockStyle [ div toolbarBlockStyle []
        , div activeSpaceBlockStyle [testVideoView model.streams]
    ]
