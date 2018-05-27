port module Main exposing (..)

import Html as H
import Html.Attributes as A
import Fuzzy
import Keyboard
import Array
import Task
import Dom
import Models.Tab exposing (Tab)
import TabItem
import MockData
import Search
import List.Extra


---- TYPES ----


type TabsType
    = Recent
    | All


type Direction
    = Up
    | Down


type alias Flags =
    { environment : String
    }



---- PORTS ----


port receiveTabs : (List Tab -> msg) -> Sub msg


port activateTab : Maybe Tab -> Cmd msg


port getTabs : String -> Cmd msg



---- MODEL ----


type alias Model =
    { tabs : List Tab
    , activeTab : Maybe Tab
    , search : String
    , selection : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        tabs =
            if flags.environment == "development" then
                MockData.generateMockTabs 6
            else
                []
    in
        ( { tabs = tabs
          , activeTab = Nothing
          , search = ""
          , selection = 0
          }
        , Dom.focus "search-input" |> Task.attempt FocusResult
        )



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
            case code of
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
    let
        fuzzySorted =
            List.sortBy (fuzzyMatch search) tabs

        normalizedSearch =
            String.toLower search

        matchesInTitle =
            List.filter (\s -> String.contains normalizedSearch <| String.toLower s.title) tabs

        matchesInUrl =
            List.filter (\s -> String.contains normalizedSearch <| String.toLower s.url) tabs

        uniqueMatches =
            List.Extra.uniqueBy (\t -> t.id) (matchesInTitle ++ matchesInUrl)

        uniqMatchesLength =
            List.length uniqueMatches
    in
        if uniqMatchesLength <= 6 then
            uniqueMatches ++ (Tuple.first <| List.Extra.splitAt (6 - uniqMatchesLength) fuzzySorted)
        else
            uniqueMatches


tabToTitle : Tab -> String
tabToTitle tab =
    tab.url


accurateResult : String -> Int -> Maybe Int
accurateResult search number =
    Maybe.Just number


changeSelection : Int -> Int -> Direction -> Int
changeSelection maxLength selection direction =
    let
        change =
            if direction == Up then
                -1
            else
                1

        next =
            selection + change

        limit =
            if direction == Up then
                0
            else
                maxLength - 1

        over =
            if direction == Up then
                (<=)
            else
                (>=)
    in
        if over next limit then
            limit
        else
            next


getTabTuples : List Tab -> String -> List ( Int, Tab )
getTabTuples origTabs search =
    let
        tabs =
            sortTabs origTabs search

        tabArr =
            Array.fromList tabs

        smallArr =
            Array.slice 0 6 tabArr

        indexTabTupleList =
            Array.toIndexedList smallArr
    in
        indexTabTupleList



---- VIEW ----


view : Model -> H.Html Msg
view model =
    let
        tabs =
            getTabTuples model.tabs model.search
    in
        H.div [ A.id "popup1", A.class "overlay" ]
            [ H.div [ A.class "popup" ]
                [ H.h2 [ A.class "title" ] [ H.text "Search for a tab" ]
                , Search.view Change
                , tabs
                    |> List.map (TabItem.view model.selection)
                    |> H.ul [ A.class "tab-list" ]
                ]
            ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    H.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
