module Components.CustomStream exposing (..)

import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (..)
import Html.Attributes as HtmlA
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy)
import Models exposing (Msg(..), StreamDisplayMode(..), StreamDisplayParams, StreamSource)
import Styles exposing (flexColumn, toolbarIconStyle)

keyedStreamBlock: StreamDisplayParams -> StreamSource -> (String, Html Msg)
keyedStreamBlock displayParams stream =
    (stream.source, lazy streamBlock (displayParams, stream))

streamBlock: (StreamDisplayParams, StreamSource) -> Html Msg
streamBlock (displayParams, stream) =
    div (outlineBlockBaseStyle ++ streamBlockStyle displayParams )
            [ makeIframe stream
             , streamToolbar displayParams stream ]

streamBlockStyle: StreamDisplayParams -> List (Attribute msg)
streamBlockStyle displayParams =
    case (displayParams.mode, displayParams.order) of
        (Focused, 0) -> [ style "height" "100%", style "width" "calc(81.5%)"]
        (Focused, _) -> [ style "height" "calc(22%)", style "width" "calc(18.5%)"]
        (Balanced, _) -> [ style "height" "50%", style "width" "50%"]

makeIframe: StreamSource -> Html Msg
makeIframe stream =
    Html.iframe
      (iframeStyle ++ [ src ("https://www.youtube-nocookie.com/embed/" ++ stream.source ++ "?autoplay=1&mute=1")
      , HtmlA.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture; fullscreen"
      , HtmlA.type_ "text/html"
      , HtmlA.attribute "allowfullscreen" "true"
      , HtmlA.attribute "frameborder" "0"]) []

streamToolbar: StreamDisplayParams -> StreamSource -> Html Msg
streamToolbar displayParams stream =
    if (displayParams.order == 0) then
        div streamToolbarStyle
            [ span (toolbarIconStyle ++ [ class "material-icons", onClick (DeleteStream stream)]) [text "clear"]]
    else
        div streamToolbarStyle
            [ span (toolbarIconStyle ++ [ class "material-icons", onClick (ActivateStream stream) ]) [text "zoom_in"]
            , span (toolbarIconStyle ++ [ class "material-icons", onClick (DeleteStream stream)]) [text "clear"]]

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