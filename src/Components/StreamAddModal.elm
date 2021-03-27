module Components.StreamAddModal exposing (..)

import Components.CustomStream exposing (width100)
import Html exposing (Attribute, Html, button, div, input, span, text)
import Html.Attributes exposing (class, style, value)
import Html.Events exposing (onClick, onInput)
import Models exposing (Msg(..), StreamAddModal)
import Styles exposing (flexColumn, flexRow, toolbarIconStyle)

streamAddModal: StreamAddModal -> Html Msg
streamAddModal modal =
    div modalStyle
    [ modalHeader
    , modalBody modal.inputText
    , modalErrorText modal.errorText
    , modalSubmitSection ]

modalHeader: Html Msg
modalHeader =
    div (flexRow ++ width100 ++ [ style "justify-content" "flex-end"])
    [ span (toolbarIconStyle ++ [ class "material-icons", onClick CloseAddStreamModal ]) [text "clear"] ]

modalBody: String -> Html Msg
modalBody inputText =
    let
        infoText = "Input link to youtube stream/video or twitch stream"
    in
        div (flexColumn ++ width100 ++ [style "justify-content" "center"])
        [ span [ style "color" "white", style "font-size" "18px"] [ text infoText ]
        , input [ value inputText, onInput ChangeAddStreamModalText ] []]

modalErrorText: String -> Html Msg
modalErrorText errorText =
    div [] [ text errorText ]

modalSubmitSection: Html Msg
modalSubmitSection =
    div (flexRow ++ width100 ++ [ style "justify-content" "center"])
    [ button (confirmButtonStyle ++ [ onClick ConfirmStreamAdd ]) [ text "Confirm"] ]

confirmButtonStyle: List (Attribute msg)
confirmButtonStyle =
    [ style "font-size" "20px"
    , style "background-color" "#FF4838"
    , style "border-color" "white"
    , style "border-width" "thin"
    , style "border-style" "solid"
    , style "color" "white"
    , style "padding" "8px"
    , style "border-radius" "5px"
    , style "cursor" "pointer"]

modalStyle: List (Attribute msg)
modalStyle =
    flexColumn ++ [ style "width" "450px"
    , style "height" "200px"
    , style "background-color" "#FF4838"
    , style "position" "absolute"
    , style "left" "50%"
    , style "top" "50%"
    , style "transform" "translate(-50%, -50%)"
    , style "padding" "5px"
    , style "justify-content" "space-between"]