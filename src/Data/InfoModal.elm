module Data.InfoModal exposing (..)

type alias Model = { isOpened: Bool }

setIsOpened: Bool -> Model -> Model
setIsOpened isOpened model =
    { model | isOpened = isOpened }