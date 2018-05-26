module MockData exposing (..)

import Array
import Models.Tab exposing (Tab)


type alias SiteLink =
    { url : String
    , favIconUrl : Maybe String
    , title : String
    }


links : Array.Array SiteLink
links =
    Array.fromList
        [ { url = "https://www.google.fi"
          , favIconUrl = Just "https://www.google.fi/favicon.ico"
          , title = "Google"
          }
        , { url = "https://www.twitter.com"
          , favIconUrl = Just "https://www.twitter.com/favicon.ico"
          , title = "Twitter"
          }
        , { url = "https://futurice.com/"
          , favIconUrl = Nothing
          , title = "Futurice"
          }
        , { url = "https://huhtakangas.com/"
          , favIconUrl = Just "https://huhtakangas.com/static/atte.11652db3.jpg"
          , title = "Atte Huhtakangas' Home Page"
          }
        , { url = "https://www.reddit.com/"
          , favIconUrl = Just "https://www.reddit.com/favicon.ico"
          , title = "reddit: the front page of the internet"
          }
        , { url = "https://spiceprogram.org/"
          , favIconUrl = Just "https://spiceprogram.org/assets/img/logo/chilicorn_no_text-64.png"
          , title = "Futurice Open Source and Social Impact Program"
          }
        ]


createTab : Int -> Tab
createTab index =
    let
        myLink =
            Maybe.withDefault { url = "", favIconUrl = Nothing, title = "" } <| Array.get index links
    in
        { active = False
        , audible = False
        , autoDiscardable = False
        , discarded = False
        , favIconUrl = myLink.favIconUrl
        , height = 100
        , highlighted = False
        , id = index
        , incognito = False
        , index = index
        , mutedInfo = { muted = False }
        , pinned = False
        , status = "active"
        , title = myLink.title
        , url = myLink.url
        , width = 100
        , windowId = 1
        }


generateMockTabs : Int -> List Tab
generateMockTabs amount =
    List.range 0 5
        |> Array.fromList
        |> Array.map createTab
        |> Array.toList
