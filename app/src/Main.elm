port module Main exposing (..)

import Html exposing (Html, text, div, h1, img, h2, input, ul, li, span, br)
import Html.Attributes exposing (src, class, id)
import Html.Events exposing (onInput, onClick)
import Fuzzy
import Keyboard
import Debug
import Array
import Task
import Dom


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
    , status : String
    , title : String
    , url : String
    , width : Int
    , windowId : Int
    }



---- PORTS ----


port receiveTabs : (List Tab -> msg) -> Sub msg


port activateTab : Maybe Tab -> Cmd msg


port getTabs : String -> Cmd msg



---- MODEL ----


type alias Model =
    { tabs : List Tab, activeTab : Maybe Tab, search : String, selection : Int }


init : ( Model, Cmd Msg )
init =
    ( { tabs = [], activeTab = Nothing, search = "", selection = 0 }, Dom.focus "search-input" |> Task.attempt FocusResult )


send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ receiveTabs ReceiveTabs, Keyboard.ups KeyPress ]



---- UPDATE ----


type Msg
    = ActivateTab Tab
    | FocusResult (Result Dom.Error ())
    | NoOp
    | Change String
    | ReceiveTabs (List Tab)
    | KeyPress Keyboard.KeyCode
    | OnLoad


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FocusResult result ->
            -- handle success or failure here
            case result of
                Err (Dom.NotFound id) ->
                    -- unable to find dom 'id'
                    ( model, Cmd.none )

                Ok () ->
                    -- successfully focus the dom
                    ( model, Cmd.none )

        OnLoad ->
            ( model, Cmd.none )

        ActivateTab tab ->
            ( { model | activeTab = Just tab }, Cmd.none )

        ReceiveTabs tabs ->
            ( { model | tabs = tabs }, Cmd.none )

        Change newSearch ->
            ( { model | search = newSearch, selection = 0 }, Cmd.none )

        KeyPress code ->
            case Debug.log "code" code of
                --  ESCAPE, close the search
                27 ->
                    ( model, activateTab Maybe.Nothing )

                -- ENTER, open the first on the list
                13 ->
                    let
                        tabs =
                            sortTabs model.tabs model.search

                        tabArr =
                            Array.fromList tabs

                        smallArr =
                            Array.slice 0 6 tabArr
                    in
                        ( model, activateTab <| Array.get model.selection smallArr )

                -- ( model, activateTab <| List.head <| sortTabs model.tabs model.search )
                -- CTRL
                17 ->
                    ( model, Cmd.none )

                -- CMD
                91 ->
                    ( model, Cmd.none )

                --  I
                73 ->
                    ( model, Cmd.none )

                -- Arrow down
                40 ->
                    ( { model | selection = changeSelection (min 6 <| List.length model.tabs) model.selection Down }, Cmd.none )

                -- Arrow up
                38 ->
                    ( { model | selection = changeSelection (min 6 <| List.length model.tabs) model.selection Up }, Cmd.none )

                _ ->
                    ( model, Cmd.none )



---- UTILS ----


fuzzyMatch : String -> Tab -> Int
fuzzyMatch needle hay =
    Fuzzy.match [ Fuzzy.addPenalty 100 ] [] needle (tabToTitle (hay)) |> .score


sortTabs : List Tab -> String -> List Tab
sortTabs tabs search =
    List.sortBy (fuzzyMatch search) tabs


tabToTitle : Tab -> String
tabToTitle tab =
    tab.url


accurateResult : String -> Int -> Maybe Int
accurateResult search number =
    Maybe.Just number


type Direction
    = Up
    | Down


changeSelection : Int -> Int -> Direction -> Int
changeSelection maxLength selection direction =
    case direction of
        Up ->
            let
                newSelection =
                    selection - 1

                firstItem =
                    0
            in
                if newSelection <= firstItem then
                    firstItem
                else
                    newSelection

        Down ->
            let
                newSelection =
                    selection + 1

                lastItem =
                    maxLength - 1
            in
                if newSelection >= lastItem then
                    lastItem
                else
                    newSelection



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        tabs =
            sortTabs model.tabs model.search

        tabArr =
            Array.fromList tabs

        smallArr =
            Array.slice 0 6 tabArr

        indexTabTupleList =
            Array.toIndexedList smallArr

        -- Array.toList <| (Array.map tabItem <| (Array.slice 0 6 tabArr) <| model.selection
        -- accurateTabs =
        --     List.filterMap accurateResult <| (fuzzyMatch model.search) <| model.tabs
    in
        div [ id "popup1", class "overlay" ]
            [ div [ class "popup" ]
                [ h2 [] [ text "Search for a tab" ]
                , input [ onInput Change, id "search-input" ] []
                , ul [ class "tab-list" ] <| List.map (tabItem model.selection) indexTabTupleList
                  -- TODO limit these with accuracy instead of hard cap only
                  -- , ul [ class "tab-list" ] <| Array.toList (Array.indexedMap tabItem <| (Array.slice 0 6 tabArr) <| model.selection)
                ]
            ]


tabItem : Int -> ( Int, Tab ) -> Html Msg
tabItem selection ( index, tab ) =
    li
        [ class <|
            "tab-item"
                ++ if selection == index then
                    " tab-item-selected"
                   else
                    ""
        ]
        [ div [ class "tab-item-inner" ]
            [ img [ src tab.favIconUrl, class "tab-item-favicon" ] []
            , span [ class "tab-item-title" ] [ text tab.title ]
            , span [ class "tab-item-url" ] [ text tab.url ]
            ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
