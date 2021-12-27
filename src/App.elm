module App exposing (Message, main)

import Browser
import Element exposing (Element)
import Element.Background as Background
import Element.Events as Events
import Element.Font as Font
import Set
import Zettelkasten exposing (Zettelkasten)


testZettelkasten =
    Zettelkasten.empty
        |> Zettelkasten.insert "0" "Zettelkasten"
        |> Zettelkasten.insert "1" "Goals"
        |> Zettelkasten.link "0" "1"
        |> Zettelkasten.insert "2" "Discoverability goal"
        |> Zettelkasten.link "1" "2"
        |> Zettelkasten.insert "2a" "Definition of discoverabilty goal"
        |> Zettelkasten.link "2" "2a"
        |> Zettelkasten.insert "2b" "Discovberability vs Findability of notes"
        |> Zettelkasten.link "2" "2b"
        |> Zettelkasten.insert "3" "Idea development goal"
        |> Zettelkasten.link "1" "3"
        |> Zettelkasten.insert "3a" "Definition of idea development goal"
        |> Zettelkasten.link "3" "3a"
        |> Zettelkasten.insert "5" "Composition goal"
        |> Zettelkasten.link "1" "5"
        |> Zettelkasten.insert "6" "Scalability goal"
        |> Zettelkasten.link "1" "6"
        |> Zettelkasten.insert "7" "Kinds of zettelkasten links"
        |> Zettelkasten.link "0" "7"
        |> Zettelkasten.insert "8" "Topic links"
        |> Zettelkasten.link "7" "8"
        |> Zettelkasten.insert "12" "Topic links in practice used for grouping"
        |> Zettelkasten.link "8" "12"
        |> Zettelkasten.insert "13" "Differences between topic links and indices for grouping related notes"
        |> Zettelkasten.link "12" "13"
        |> Zettelkasten.insert "15" "Manually grouping using indices becomes unwieldy"
        |> Zettelkasten.link "13" "15"
        |> Zettelkasten.insert "14" "Topic links over indices reduces choices during surfing"
        |> Zettelkasten.link "13" "14"


type Message
    = SetFocus String


viewZettel : Zettelkasten String String -> String -> Element Message
viewZettel zettelkasten id =
    Element.el
        [ Element.centerX
        , Element.centerY
        , Element.width Element.fill
        , Font.center
        , Events.onFocus (SetFocus id)
        ]
        (Element.text
            (Zettelkasten.get id zettelkasten
                |> Maybe.withDefault "ERROR"
            )
        )


viewZettelRow : List String -> Zettelkasten String String -> Element Message
viewZettelRow ids zettelkasten =
    Element.row
        [ Element.centerX
        , Element.centerY
        , Element.height Element.fill
        , Element.width Element.fill
        ]
        (List.map (viewZettel zettelkasten) ids)


viewZettelkasten : String -> Zettelkasten String String -> Element Message
viewZettelkasten focusId zettelkasten =
    let
        focusBacklinks : List String
        focusBacklinks =
            Zettelkasten.getBacklinks focusId zettelkasten
                |> Set.toList

        focusLinks : List String
        focusLinks =
            Zettelkasten.getLinks focusId zettelkasten
                |> Set.toList
    in
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        ]
        [ viewZettelRow focusBacklinks zettelkasten
        , viewZettel zettelkasten focusId
        , viewZettelRow focusLinks zettelkasten
        ]


main : Program () String Message
main =
    Browser.sandbox
        { init = "13"
        , update = \(SetFocus focus) _ -> focus
        , view =
            \focusId ->
                Element.layout
                    [ Background.color (Element.rgb255 20 20 20)
                    , Font.color (Element.rgb255 200 200 200)
                    ]
                    (viewZettelkasten focusId testZettelkasten)
        }
