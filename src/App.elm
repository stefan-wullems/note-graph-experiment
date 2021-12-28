module App exposing (Message, Model, Thread, main)

import Browser
import Html exposing (Html)
import Html.Attributes as Attribute exposing (class)
import Html.Events as Events
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


viewZettel : Bool -> Zettelkasten String String -> String -> Html Message
viewZettel inThread zettelkasten id =
    Html.li [ class "snap-center w-96 text-center", Attribute.classList [ ( "text-sky-400", inThread ) ], Events.onClick (SetFocus id) ]
        [ Html.text
            (Zettelkasten.get id zettelkasten
                |> Maybe.withDefault "ERROR"
            )
        ]


viewZettelRow : (ScrollDirectionX -> Maybe Message) -> List String -> String -> Zettelkasten String String -> Html Message
viewZettelRow onScrollX ids focusId zettelkasten =
    Html.div
        [ Attribute.class "flex flex-row grow" ]
        [ Html.button
            [ Attribute.class "w-96"
            , onScrollX Left
                |> Maybe.map Events.onClick
                |> Maybe.withDefault (Attribute.disabled True)
            ]
            [ Html.text "<" ]
        , Html.ul
            [ Attribute.class "snap-x grow overflow-x-auto grid grid-flow-col"
            ]
            (List.map (\id -> viewZettel (id == focusId) zettelkasten id) (List.concat [ ids, ids, ids ]))
        , Html.button
            [ Attribute.class "w-96"
            , onScrollX Right
                |> Maybe.map Events.onClick
                |> Maybe.withDefault (Attribute.disabled True)
            ]
            [ Html.text ">" ]
        ]


viewZettelkasten : Thread -> Zettelkasten String String -> Html Message
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

        viewRow : DirectionY -> List String -> Maybe String -> Html Message
        viewRow row links focusId =
            focusId
                |> Maybe.map
                    (\focusId_ ->
                        viewZettelRow (onScrollX row links focusId_)
                            links
                            focusId_
                            zettelkasten
                    )
                |> Maybe.withDefault (Html.text "")
    in
    Html.ul
        [ Attribute.class "flex flex-col justify-items-center gap-5 bg-zinc-700 h-full text-zinc-100" ]
        [ viewRow Top focusBacklinks thread.top
        , Html.ul
            [ Attribute.class "snap-x grow overflow-x-auto grid grid-flow-col"
            ]
            [ viewZettel True zettelkasten thread.center ]
        , viewRow Bottom focusLinks thread.bottom
        ]


main : Program () Model Message
main =
    Browser.sandbox
        { init = ( { top = Just "12", center = "13", bottom = Just "14" }, testZettelkasten )
        , update = update
        , view =
            \( thread, zettelkasten ) ->
                viewZettelkasten thread zettelkasten
        }
