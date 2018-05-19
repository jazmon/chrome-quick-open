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


type Direction
    = Up
    | Down


type alias SiteLink =
    { url : String
    , favIconUrl : String
    , title : String
    }


type alias Flags =
    { environment : String
    }



---- PORTS ----


port receiveTabs : (List Tab -> msg) -> Sub msg


port activateTab : Maybe Tab -> Cmd msg


port getTabs : String -> Cmd msg



---- MODEL ----


type alias Model =
    { tabs : List Tab, activeTab : Maybe Tab, search : String, selection : Int }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        tabs =
            if flags.environment == "development" then
                generateMockTabs 6
            else
                []
    in
        ( { tabs = tabs, activeTab = Nothing, search = "", selection = 0 }, Dom.focus "search-input" |> Task.attempt FocusResult )



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

        -- TODO only show accurate enough results
        -- accurateTabs =
        --     List.filterMap accurateResult <| (fuzzyMatch model.search) <| model.tabs
    in
        div [ id "popup1", class "overlay" ]
            [ div [ class "popup" ]
                [ h2 [ class "title" ] [ text "Search for a tab" ]
                , input [ onInput Change, id "search-input" ] []
                  -- TODO limit these with accuracy instead of hard cap only
                , ul [ class "tab-list" ] <| List.map (tabItem model.selection) indexTabTupleList
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
            [ div [ class "tab-item-upper-row" ]
                [ img [ src tab.favIconUrl, class "tab-item-favicon" ] []
                , span [ class "tab-item-title" ] [ text tab.title ]
                ]
            , div [ class "tab-item-lower-row" ]
                [ span [ class "tab-item-url" ] [ text tab.url ]
                ]
            ]
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }



---- MOCK DATA & FUNCTIONS ----


links : Array.Array SiteLink
links =
    Array.fromList
        [ { url = "https://www.google.fi", favIconUrl = "https://www.google.fi/favicon.ico", title = "Google" }
        , { url = "https://www.twitter.com", favIconUrl = "https://www.twitter.com/favicon.ico", title = "Twitter" }
        , { url = "https://futurice.com/", favIconUrl = "https://static.flockler.com/assets/futurice/images/favicon-1e8c9440235d8573ae7a278dceeb8238ca2f9dd250cc2f586c66b56095627688.png", title = "Futurice" }
        , { url = "https://huhtakangas.com/", favIconUrl = "https://huhtakangas.com/static/atte.11652db3.jpg", title = "Atte Huhtakangas' Home Page" }
        , { url = "https://www.reddit.com/", favIconUrl = "https://www.reddit.com/favicon.ico", title = "reddit: the front page of the internet" }
        , { url = "https://spiceprogram.org/", favIconUrl = "https://spiceprogram.org/assets/img/logo/chilicorn_no_text-64.png", title = "Futurice Open Source and Social Impact Program" }
        ]


createTab : Int -> Tab
createTab index =
    let
        myLink =
            Maybe.withDefault { url = "", favIconUrl = "", title = "" } <| Array.get index links
    in
        { active = False, audible = False, autoDiscardable = False, discarded = False, favIconUrl = myLink.favIconUrl, height = 100, highlighted = False, id = index, incognito = False, index = index, mutedInfo = { muted = False }, pinned = False, status = "active", title = myLink.title, url = myLink.url, width = 100, windowId = 1 }


generateMockTabs : Int -> List Tab
generateMockTabs amount =
    List.range 0 5
        |> Array.fromList
        |> Array.map createTab
        |> Array.toList
