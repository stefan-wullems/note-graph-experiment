module App exposing (Message, Model, Thread, main)

import Browser
import Element exposing (Element)
import Element.Background as Background
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes exposing (class)
import List.Extra as List
import Set
import Zettelkasten exposing (Zettelkasten)


testZettelkasten : Zettelkasten String String
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
        |> Zettelkasten.link "3" "14"
        |> Zettelkasten.link "2" "8"
        |> Zettelkasten.link "6" "15"


type ScrollDirectionX
    = Left
    | Right


type DirectionY
    = Top
    | Bottom


type Message
    = SetFocus String
    | ThreadThing DirectionY String


type alias Thread =
    { top : Maybe String, center : String, bottom : Maybe String }


type alias Model =
    ( Thread, Zettelkasten String String )


update : Message -> Model -> Model
update msg ( thread, zettelkasten ) =
    case msg of
        SetFocus id ->
            ( { top =
                    Zettelkasten.getBacklinks id zettelkasten
                        |> Set.toList
                        |> List.head
              , center = id
              , bottom =
                    Zettelkasten.getLinks id zettelkasten
                        |> Set.toList
                        |> List.head
              }
            , zettelkasten
            )

        ThreadThing dirY id ->
            ( case dirY of
                Top ->
                    { thread | top = Just id }

                Bottom ->
                    { thread | bottom = Just id }
            , zettelkasten
            )


viewZettel : Bool -> Zettelkasten String String -> String -> Element Message
viewZettel inThread zettelkasten id =
    Element.el
        [ Element.centerX
        , Element.centerY
        , Element.width Element.fill
        , Font.center
        , Events.onClick (SetFocus id)
        , if inThread then
            Font.color (Element.rgb255 140 140 255)

          else
            Element.mouseOver
                [ Font.color (Element.rgb255 255 255 0)
                ]
        ]
        (Element.text
            (Zettelkasten.get id zettelkasten
                |> Maybe.withDefault "ERROR"
            )
        )


viewZettelRow : (ScrollDirectionX -> Maybe Message) -> List String -> String -> Zettelkasten String String -> Element Message
viewZettelRow onScrollX ids focusId zettelkasten =
    Element.row
        [ Element.centerX
        , Element.centerY
        , Element.height Element.fill
        , Element.width Element.fill
        ]
        (List.concat
            [ [ Input.button [ Font.alignRight, Element.padding 50 ] { onPress = onScrollX Left, label = Element.text "<" } ]
            , List.map (\id -> viewZettel (id == focusId) zettelkasten id) ids
            , [ Input.button [ Font.alignLeft, Element.padding 50 ] { onPress = onScrollX Right, label = Element.text ">" } ]
            ]
        )


viewZettelkasten : Thread -> Zettelkasten String String -> Element Message
viewZettelkasten thread zettelkasten =
    let
        focusBacklinks : List String
        focusBacklinks =
            Zettelkasten.getBacklinks thread.center zettelkasten
                |> Set.toList

        focusLinks : List String
        focusLinks =
            Zettelkasten.getLinks thread.center zettelkasten
                |> Set.toList

        onScrollX : DirectionY -> List String -> String -> ScrollDirectionX -> Maybe Message
        onScrollX row links focusId dirX =
            Maybe.map (ThreadThing row) <|
                case dirX of
                    Left ->
                        List.takeWhile (\id -> id /= focusId) links
                            |> List.last

                    Right ->
                        List.dropWhile (\id -> id /= focusId) links
                            |> List.tail
                            |> Maybe.andThen List.head

        viewRow : DirectionY -> List String -> Maybe String -> Element Message
        viewRow row links focusId =
            focusId
                |> Maybe.map
                    (\focusId_ ->
                        viewZettelRow (onScrollX row links focusId_)
                            links
                            focusId_
                            zettelkasten
                    )
                |> Maybe.withDefault
                    (Element.el
                        [ Element.width Element.fill
                        , Element.height Element.fill
                        ]
                        Element.none
                    )
    in
    Element.column
        [ Element.width Element.fill
        , Element.height Element.fill
        ]
        [ viewRow Top focusBacklinks thread.top
        , viewZettel True zettelkasten thread.center
        , viewRow Bottom focusLinks thread.bottom
        ]


main : Program () Model Message
main =
    Browser.sandbox
        { init = ( { top = Just "12", center = "13", bottom = Just "14" }, testZettelkasten )
        , update = update
        , view =
            \( thread, zettelkasten ) ->
                Html.div [ class "text-3xl font-bold underline" ]
                    [ Html.text "bla"

                    -- , Element.layout
                    --     [ Background.color (Element.rgb255 20 20 20)
                    --     , Font.color (Element.rgb255 200 200 200)
                    --     ]
                    --     (viewZettelkasten thread zettelkasten)
                    ]
        }
