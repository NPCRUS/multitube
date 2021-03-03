module Styles exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)

flex: List (Attribute msg)
flex =
    [ style "display" "flex"]

flexColumn: List (Attribute msg)
flexColumn =
    flex ++ [ style "flex-direction" "column"]

flexRow: List (Attribute msg)
flexRow =
    flex ++ [ style "flex-direction" "row"]

outerBlockStyle: List (Attribute msg)
outerBlockStyle =
    flexColumn ++ [ style "height" "100%"]

toolbarBlockStyle: List (Attribute msg)
toolbarBlockStyle =
    flexRow ++ [ style "width" "100%"
    , style "background-color" "#FF4838"
    , style "height" "40px"]

activeSpaceBlockStyle: List (Attribute msg)
activeSpaceBlockStyle =
    flexColumn ++ [ style "flex-grow" "1"
    , style "width" "100%"
    , style "background-color" "#162B32"]

mainStreamStyle: List (Attribute msg)
mainStreamStyle =
    flex ++ [ style "width" "100%"
    , style "flex-grow" "1"]

unfocusedBlockStyle: List (Attribute msg)
unfocusedBlockStyle =
    flexRow ++ [ style "flex-wrap" "wrap"]
