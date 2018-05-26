module TabItem exposing (..)

import Html as H
import Html.Attributes as A
import Models.Tab exposing (Tab)


emptyNode : H.Html msg
emptyNode =
    H.text ""


favicon : Maybe String -> H.Html msg
favicon url =
    case url of
        Just url ->
            H.img [ A.src url, A.class "tab-item-favicon" ] []

        Nothing ->
            emptyNode


view : Int -> ( Int, Tab ) -> H.Html msg
view selection ( index, tab ) =
    let
        className =
            "tab-item"
                ++ if selection == index then
                    " tab-item-selected"
                   else
                    ""
    in
        H.li
            [ A.class className ]
            [ H.div [ A.class "tab-item-inner" ]
                [ H.div [ A.class "tab-item-upper-row" ]
                    [ favicon tab.favIconUrl
                    , H.span [ A.class "tab-item-title" ] [ H.text tab.title ]
                    ]
                , H.div [ A.class "tab-item-lower-row" ]
                    [ H.span [ A.class "tab-item-url" ] [ H.text tab.url ]
                    ]
                ]
            ]
