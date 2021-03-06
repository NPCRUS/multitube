module Models exposing (..)

type alias StreamSource = { source: String }

type alias StreamAddModal = { isOpened: Bool, inputText: String }

type alias InfoModal = { isOpened: Bool }

type Msg = ActivateStream StreamSource
    | DeleteStream StreamSource
    | OpenAddStreamModal
    | CloseAddStreamModal
    | ChangeAddStreamModalText String
    | ConfirmStreamAdd
    | OpenInfoModal
    | CloseInfoModal