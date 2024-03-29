module Styles exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Data.DisplayParams as DisplayParams exposing (..)

flex: List (Attribute msg)
flex =
    [ style "display" "flex"]

flexColumn: List (Attribute msg)
flexColumn =
    flex ++ [ style "flex-direction" "column"]

flexRow: List (Attribute msg)
flexRow =
    flex ++ [ style "flex-direction" "row"]

justifyContentCenter: List (Attribute msg)
justifyContentCenter =
    [style "justify-content" "center"]

toCalc: Float -> String
toCalc percent =
    "calc(" ++ (String.fromFloat percent) ++ "%)"

outerBlockStyle: List (Attribute msg)
outerBlockStyle =
    flexColumn ++ [ style "height" "100%"]

toolbarBlockStyle: List (Attribute msg)
toolbarBlockStyle =
    flexRow ++ [ style "width" "100%"
    , style "background-color" "#FF4838"
    , style "height" "40px"
    , style "align-items" "center"
    , style "justify-content" "space-between"
    , style "padding" "0 5px"
    , style "box-sizing" "border-box" ]

activeSpaceBlockStyle: List (Attribute msg)
activeSpaceBlockStyle =
    flexColumn ++ [ style "flex-grow" "1"
    , style "width" "100%"
    , style "background-color" "#162B32"]

streamListBlockStyle: DisplayParams.Model ->  List (Attribute msg)
streamListBlockStyle params =
    let
        baseStyle = if(params.mode == Focused && params.direction == Horizontal) then flexColumn else flexRow
    in
        baseStyle ++ [ style "flex-wrap" "wrap"
        , style "width" "100%"
        , style "height" "100%"]

toolbarIconStyle: List (Attribute msg)
toolbarIconStyle =
    [ style "color" "rgba(255, 255, 255, 1)"
    , style "font-size" "30px"
    , style "cursor" "pointer" ]

addStreamButtonStyle: List (Attribute msg)
addStreamButtonStyle =
    [ style "font-size" "20px"
    , style "width" "250px"
    , style "align-self" "center"
    , style "background-color" "#162B32"
    , style "border-color" "white"
    , style "border-width" "thin"
    , style "border-style" "solid"
    , style "color" "white"
    , style "padding" "8px 20px"
    , style "border-radius" "5px"
    , style "cursor" "pointer"]

toolbarLeftBlockStyle: List (Attribute msg)
toolbarLeftBlockStyle =
    flexRow ++ [ style "align-items" "center"]

versionLinkStyle: List (Attribute msg)
versionLinkStyle =
    flex ++ [ style "align-self" "center"
    , style "margin-right" "5px"
    , style "color" "white"]
