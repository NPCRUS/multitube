module Utils exposing (..)

maybeFlatten2: Maybe (Maybe a) -> Maybe a
maybeFlatten2 maybe =
    case maybe of
        Nothing -> Nothing
        Just secondMaybe -> case secondMaybe of
            Nothing -> Nothing
            Just value -> Just value
