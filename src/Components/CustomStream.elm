module Components.CustomStream exposing (..)

import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (..)
import Html.Attributes as HtmlA
import Html.Events exposing (onClick)
import Html.Lazy exposing (lazy)
import Data.StreamSource as StreamSource exposing (..)
import Data.DisplayParams as DisplayParams exposing (..)
import Msg exposing (..)
import Styles exposing (flexColumn, toCalc, toolbarIconStyle)

keyedStreamBlock: (DisplayParams.Model, Int) -> StreamSource.Model -> (String, Html Msg)
keyedStreamBlock (displayParams, order) stream =
    (stream.token, lazy streamBlock (displayParams, order, stream))

streamBlock: (DisplayParams.Model, Int, StreamSource.Model) -> Html Msg
streamBlock (displayParams, order, stream) =
    div (outlineBlockBaseStyle ++ streamBlockStyle displayParams order )
            [ makeIframe stream
             , streamToolbar order stream ]

streamBlockStyle: DisplayParams.Model -> Int -> List (Attribute msg)
streamBlockStyle displayParams order =
    let
        firstWidth = if(displayParams.direction == Horizontal) then
                toCalc 81.5
            else
                toCalc 100
        othersWidth = if(displayParams.direction == Horizontal) then
                toCalc (18.5)
            else
                toCalc 50
        firstHeight = if(displayParams.direction == Vertical) then
                toCalc 57
            else
                toCalc 100
        otherHeight = if(displayParams.direction == Vertical) then
                toCalc 43
            else
                toCalc 22
    in
        case (displayParams.mode, order) of
            (Focused, 0) -> [ style "height" firstHeight, style "width" firstWidth]
            (Focused, _) -> [ style "height" otherHeight, style "width" othersWidth]
            (Balanced, _) -> [ style "height" "50%", style "width" "50%"]

makeIframe: StreamSource.Model -> Html Msg
makeIframe stream =
    if(stream.platform == Youtube) then
        youtubeIframe stream
    else
        twitchIframe stream

youtubeIframe: StreamSource.Model -> Html msg
youtubeIframe stream =
    Html.iframe
          (iframeStyle ++ [ src ("https://www.youtube-nocookie.com/embed/" ++ stream.token ++ "?autoplay=1&mute=1")
          , HtmlA.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture; fullscreen"
          , HtmlA.type_ "text/html"
          , HtmlA.attribute "allowfullscreen" "true"
          , HtmlA.attribute "frameborder" "0"]) []

twitchIframe: StreamSource.Model -> Html msg
twitchIframe stream =
    let
        attr = "&muted=true&parent=localhost&parent=multitube.dev"
    in
        Html.iframe
            (iframeStyle ++ [ (src ("https://player.twitch.tv/?channel=" ++ stream.token ++ attr))
             , style "border-width" "0"
             , HtmlA.attribute "width" "100%"
             , HtmlA.attribute "height" "100%"
             , HtmlA.attribute "allowfullscreen" "true"]) []

streamToolbar: Int -> StreamSource.Model -> Html Msg
streamToolbar order stream =
    if (order == 0) then
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