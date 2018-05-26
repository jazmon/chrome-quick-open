module Models.Tab exposing (..)

import Json.Decode as Json
import Json.Decode.Pipeline as P
import Json.Encode as JS


type alias MutedInfo =
    { muted : Bool }


mudedInfoDecoder : Json.Decoder MutedInfo
mudedInfoDecoder =
    P.decode MutedInfo
        |> P.required "muted" Json.bool


type alias Tab =
    { active : Bool
    , audible :
        Bool
    , autoDiscardable : Bool
    , discarded : Bool
    , favIconUrl : Maybe String
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


maybeString : Json.Decoder (Maybe String)
maybeString =
    Json.string
        |> Json.map
            (\str ->
                if String.length str == 0 then
                    Nothing
                else
                    Just str
            )


tabDecoder : Json.Decoder Tab
tabDecoder =
    P.decode Tab
        |> P.required "active" Json.bool
        |> P.required "audible" Json.bool
        |> P.required "autoDiscardable" Json.bool
        |> P.required "discarded" Json.bool
        |> P.required "favIconUrl" maybeString
        |> P.required "height" Json.int
        |> P.required "highlighted" Json.bool
        |> P.required "id" Json.int
        |> P.required "incognito" Json.bool
        |> P.required "index" Json.int
        |> P.required "mutedInfo" mudedInfoDecoder
        |> P.required "pinned" Json.bool
        |> P.required "status" Json.string
        |> P.required "title" Json.string
        |> P.required "url" Json.string
        |> P.required "width" Json.int
        |> P.required "windowId" Json.int


encode : Tab -> JS.Value
encode tab =
    JS.object <|
        [ ( "active", JS.bool tab.active )
        , ( "audible", JS.bool tab.audible )
        , ( "autoDiscardable", JS.bool tab.autoDiscardable )
        , ( "discarded", JS.bool tab.discarded )
        , ( "favIconUrl"
          , tab.favIconUrl
                |> Maybe.map (JS.string)
                |> Maybe.withDefault JS.null
          )
        , ( "height", JS.int tab.height )
        , ( "highlighted", JS.bool tab.highlighted )
        , ( "id", JS.int tab.id )
        , ( "incognito", JS.bool tab.incognito )
        , ( "index", JS.int tab.index )
        , ( "mutedInfo", JS.object [ ( "muted", JS.bool tab.mutedInfo.muted ) ] )
        , ( "pinned", JS.bool tab.pinned )
        , ( "status", JS.string tab.status )
        , ( "title", JS.string tab.title )
        , ( "url", JS.string tab.url )
        , ( "width", JS.int tab.width )
        , ( "windowId", JS.int tab.windowId )
        ]
