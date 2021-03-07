module Models exposing (..)

type alias StreamSource = { source: String }

type alias StreamAddModal = { isOpened: Bool, inputText: String }

type alias InfoModal = { isOpened: Bool }

type StreamDisplayMode = Focused | Balanced

type alias StreamDisplayParams = { mode: StreamDisplayMode, order: Int }

buildStreamDisplayParams: StreamDisplayMode -> Int -> StreamDisplayParams
buildStreamDisplayParams mode order = { mode = mode, order = order }

type Msg = ActivateStream StreamSource
    | DeleteStream StreamSource
    | OpenAddStreamModal
    | CloseAddStreamModal
    | ChangeAddStreamModalText String
    | ConfirmStreamAdd
    | OpenInfoModal
    | CloseInfoModal
    | ChangeDisplayMode StreamDisplayMode