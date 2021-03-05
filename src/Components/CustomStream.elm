module Components.CustomStream exposing (..)

import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (..)
import Html.Attributes as HtmlA
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy)
import Models exposing (Msg(..), StreamSource)
import Styles exposing (flexColumn, toolbarIconStyle)

keyedStreamBlock: StreamSource -> (String, Html Msg)
keyedStreamBlock stream =
    (stream.source, lazy streamBlock stream)

streamBlock: StreamSource -> Html Msg
streamBlock stream =
    div outlineBlockBaseStyle
            [ makeIframe stream
             , streamToolbar stream ]

makeIframe: StreamSource -> Html Msg
makeIframe stream =
    Html.iframe
      (iframeStyle ++ [ src ("https://www.youtube-nocookie.com/embed/" ++ stream.source ++ "?autoplay=1&mute=1")
      , HtmlA.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture; fullscreen"
      , HtmlA.type_ "text/html"
      , HtmlA.attribute "allowfullscreen" "true"
      , HtmlA.attribute "frameborder" "0"]) []

streamToolbar: StreamSource -> Html Msg
streamToolbar stream =
    div streamToolbarStyle
    [ span (toolbarIconStyle ++ [ class "material-icons", onClick (ActivateStream stream) ]) [text "zoom_in"]
    , span (toolbarIconStyle ++ [ class "material-icons", onClick (DeleteStream stream)]) [text "cancel"]]

iframeStyle: List (Attribute msg)
iframeStyle =
    [ style "width" "100%"
    , style "height" "100%"]

width100: List (Attribute msg)
width100 = [ style "width" "100%"]

outlineBlockBaseStyle: List (Attribute msg)
outlineBlockBaseStyle =
    [ style "display" "flex"
    , style "position" "relative"]

streamToolbarStyle: List (Attribute msg)
streamToolbarStyle =
    flexColumn ++ [ style "position" "absolute"
    , style "left" "0"
    , style "width" "auto"]