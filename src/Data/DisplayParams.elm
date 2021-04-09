module Data.DisplayParams exposing (..)

type Mode = Focused | Balanced

type Direction = Vertical | Horizontal

type alias Model = { mode: Mode
                           , direction: Direction
                           , ratio: Float }

setMode: Mode -> Model -> Model
setMode mode params =
    { params | mode = mode }

setDirection: Direction -> Model -> Model
setDirection direction params =
    { params | direction = direction }

setRatio: Float -> Model -> Model
setRatio ratio params =
    { params | ratio = ratio }