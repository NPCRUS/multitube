module Msg exposing (..)

import Data.StreamSource as StreamSource exposing (..)
import Data.DisplayParams as DisplayParams exposing (..)

type Msg = ActivateStream StreamSource.Model
    | DeleteStream StreamSource.Model
    | OpenAddStreamModal
    | CloseAddStreamModal
    | ChangeAddStreamModalText String
    | ConfirmStreamAdd
    | OpenInfoModal
    | CloseInfoModal
    | ChangeDisplayMode DisplayParams.Mode
    | OnResize Int Int
    | PlaySynchronized
    | PauseSynchronized