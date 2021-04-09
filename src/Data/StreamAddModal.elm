module Data.StreamAddModal exposing (..)

type alias Model = { isOpened: Bool, inputText: String, errorText: String }

setIsOpened: Bool -> Model -> Model
setIsOpened isOpened model =
    { model | isOpened = isOpened }

setInputText: String -> Model -> Model
setInputText inputText model =
    { model | inputText = inputText }

setErrorText: String -> Model -> Model
setErrorText errorText model =
    { model | errorText = errorText }