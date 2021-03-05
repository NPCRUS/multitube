module Models exposing (..)

type alias StreamSource = { source: String }

type alias StreamAddModal = { isOpened: Bool, inputText: String }

type Msg = ActivateStream StreamSource
    | DeleteStream StreamSource
    | OpenAddStreamModal
    | CloseAddStreamModal
    | ChangeAddStreamModalText String
    | ConfirmStreamAdd