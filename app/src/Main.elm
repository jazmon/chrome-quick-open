port module Main exposing (..)

import Html exposing (Html, text, div, h1, img, h2, input, ul, li)
import Html.Attributes exposing (src, class, id)
import Html.Events exposing (onInput, onClick)
import Fuzzy
import Keyboard


---- TYPES ----


type TabsType
    = Recent
    | All


type alias MutedInfo =
    { muted : Bool }


type alias Tab =
    { active : Bool
    , audible : Bool
    , autoDiscardable : Bool
    , discarded : Bool
    , favIconUrl : String
    , height : Int
    , highlighted : Bool
    , id : Int
    , incognito : Bool
    , index : Int
    , mutedInfo : MutedInfo
    , pinned : Bool
    , status :
        String
        -- CHECK IF THIS CAN BE TYPED BETTER
    , title : String
    , url : String
    , width : Int
    , windowId : Int
    }



---- PORTS ----


port receiveTabs : (List Tab -> msg) -> Sub msg



-- Port to close the search with a tab or just close


port activateTab : Maybe Tab -> Cmd msg



-- port closeSearch : Maybe Tab -> Cmd msg


port getTabs : String -> Cmd msg



---- MODEL ----


type alias Model =
    { tabs : List Tab, activeTab : Maybe Tab, search : String }


init : ( Model, Cmd Msg )
init =
    ( { tabs = [], activeTab = Nothing, search = "" }, Cmd.none )



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ receiveTabs ReceiveTabs, Keyboard.ups KeyPress ]



-- Sub.batch
--     [ Main.port.tabs ]
---- UPDATE ----


type Msg
    = ActivateTab Tab
    | Change String
    | ReceiveTabs (List Tab)
    | KeyPress Keyboard.KeyCode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ActivateTab tab ->
            ( { model | activeTab = Just tab }, Cmd.none )

        ReceiveTabs tabs ->
            ( { model | tabs = tabs }, Cmd.none )

        Change newSearch ->
            ( { model | search = newSearch }, Cmd.none )

        KeyPress code ->
            case code of
                --  ESCAPE, close the search
                27 ->
                    ( model, activateTab Maybe.Nothing )

                -- ENTER, open the first on the list
                13 ->
                    ( model, activateTab <| List.head model.tabs )

                _ ->
                    ( model, Cmd.none )



-- ( model, Cmd.none )
---- VIEW ----


view : Model -> Html Msg
view model =
    let
        myMatch needle hay =
            Fuzzy.match [] [] needle (tabToTitle (hay)) |> .score

        tabTitles =
            List.sortBy (myMatch model.search) model.tabs
    in
        div [ id "popup1", class "overlay" ]
            [ div [ class "popup" ]
                [ h2 [] [ text "Search for a tab" ]
                , input [ onInput Change ] []
                  -- TODO limit these with accuracy instead of hard cap only
                , ul [] (List.map tabItem <| List.take 6 tabTitles)
                ]
            ]


tabItem : Tab -> Html Msg
tabItem tab =
    li [] [ text tab.title ]


tabToTitle : Tab -> String
tabToTitle tab =
    tab.title



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
