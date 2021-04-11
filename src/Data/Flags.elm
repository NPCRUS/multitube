module Data.Flags exposing (..)

import Json.Decode as D
import Data.StreamSource as StreamSource exposing (..)

type alias Model = { windowWidth: Int, windowHeight: Int, startingSources: Maybe (List StreamSource.Model), version: String }

flagsDecoder: D.Decoder Model
flagsDecoder =
    D.map4 Model
        (D.field "windowWidth" D.int)
        (D.field "windowHeight" D.int)
        (D.field "startingSources" (D.nullable (D.list streamSourceDecoder)))
        (D.field "version" D.string)