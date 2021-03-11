module Components.InfoModal exposing (..)

import Components.CustomStream exposing (width100)
import Html exposing (Attribute, Html, a, div, img, span, text)
import Html.Attributes exposing (class, height, href, src, style, target, width)
import Html.Events exposing (onClick)
import Models exposing (InfoModal, Msg(..))
import Styles exposing (flexColumn, flexRow, toolbarIconStyle)

infoModal: Html Msg
infoModal =
    div modalStyle
    [ modalHeader
    , modalBody ]

modalHeader: Html Msg
modalHeader =
    div (flexRow ++ width100 ++ [ style "justify-content" "flex-end"])
    [ span (toolbarIconStyle ++ [ class "material-icons", onClick CloseInfoModal ]) [text "clear"] ]

modalBody: Html Msg
modalBody =
    div []
    [ span [ style "color" "white"] [ text explanationText ]
    , div (flexRow ++ width100 ++ [ style "justify-content" "center", style "margin-top" "5px"]) [githubLink] ]

githubLink: Html Msg
githubLink =
    a [ href "https://github.com/NPCRUS/multitube", target "_blank" ]
    [ img
        [ height 32,
        width 32,
        src "https://cdn.jsdelivr.net/npm/simple-icons@v4/icons/github.svg"
        , style "color" "white"] []
    ]

explanationText: String
explanationText = "Originally this website was made for watching multiple WTT(World Table Tennis) streams in parallel. " ++
    "Additionally, I wanted to be able to quickly focus on one of the games and have the rest running somewhere on background, " ++
    "so I can always see if pair of opponents has changed there and change my focus again. " ++
    "Please provide any bug reports, ideas or suggestions on github. Enjoy!"

modalStyle: List (Attribute msg)
modalStyle =
    flexColumn ++ [ style "background-color" "#FF4838"
    , style "position" "absolute"
    , style "left" "50%"
    , style "top" "50%"
    , style "transform" "translate(-50%, -50%)"
    , style "padding" "5px"
    , style "justify-content" "space-between"
    , style "max-width" "450px"]