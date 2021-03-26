module Models exposing (..)

type alias StreamSource = { source: String }

type alias StreamAddModal = { isOpened: Bool, inputText: String }

type alias InfoModal = { isOpened: Bool }

type StreamDisplayMode = Focused | Balanced

type StreamDisplayDirection = Vertical | Horizontal

type alias StreamDisplayParams = { mode: StreamDisplayMode
                                 , direction: StreamDisplayDirection
                                 , ratio: Float }

type Msg = ActivateStream StreamSource
    | DeleteStream StreamSource
    | OpenAddStreamModal
    | CloseAddStreamModal
    | ChangeAddStreamModalText String
    | ConfirmStreamAdd
    | OpenInfoModal
    | CloseInfoModal
    | ChangeDisplayMode StreamDisplayMode
    | OnResize Int Int

type alias Flags = { windowWidth: Int, windowHeight: Int }

