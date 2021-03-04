module Components.CustomStream exposing (..)

import Html exposing (Attribute, Html, button, div, span, text)
import Html.Attributes exposing (..)
import Html.Attributes as HtmlA
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy)
import Models exposing (Msg(..), StreamSource)
import Styles exposing (flex)

keyedCustomStream: StreamSource -> (String, Html Msg)
keyedCustomStream stream =
    (stream.source, lazy testCustomStream stream)

testCustomStream: StreamSource -> Html Msg
testCustomStream stream =
    div outlineBlockBaseStyle
            [ makeIframe stream
             , streamToolbar stream ]

customStream: (StreamSource, Bool) -> Html Msg
customStream (stream, isActive) =
    let
        outlineBlockStyle = case isActive of
            True -> outlineBlockBaseStyle ++ width100
            False -> outlineBlockBaseStyle
    in
        div outlineBlockStyle
        [ makeIframe stream
         , streamToolbar stream ]

makeIframe: StreamSource -> Html Msg
makeIframe stream =
    Html.iframe
      (iframeStyle ++ [ src ("https://www.youtube-nocookie.com/embed/" ++ stream.source)
      , HtmlA.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture; fullscreen"
      , HtmlA.type_ "text/html"
      , HtmlA.attribute "allowfullscreen" "true"
      , HtmlA.attribute "frameborder" "0"]) []

streamToolbar: StreamSource -> Html Msg
streamToolbar stream =
    div streamToolbarStyle
    [ span (toolbarIconStyle ++ [ class "material-icons", onClick (ActivateStream stream) ]) [text "zoom_in"] ]

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
    [ style "position" "absolute"
    , style "left" "0"
    , style "margin-top" "60px"]

toolbarIconStyle: List (Attribute msg)
toolbarIconStyle =
    [ style "color" "rgba(255, 255, 255, 1)"
    , style "font-size" "36px"
    , style "cursor" "pointer"]