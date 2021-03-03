module Models exposing (..)

type alias StreamSource = { source: String }

type Msg = ActivateStream StreamSource