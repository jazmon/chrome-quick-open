module Search exposing (..)

import Html as H
import Html.Attributes as A
import Html.Events as E


view : (String -> msg) -> H.Html msg
view onInput =
    H.input [ E.onInput onInput, A.id "search-input" ] []
