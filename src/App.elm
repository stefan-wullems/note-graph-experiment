module App exposing (Message, Model, Thread, main)

import Browser
import Html exposing (Html)
import Html.Attributes
import Html.Events as Events
import UI.SnapList as SnapList
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
                    thread.top
                        |> Maybe.andThen
                            (\top ->
                                let
                                    backlinks : List String
                                    backlinks =
                                        Zettelkasten.getBacklinks id zettelkasten
                                in
                                if List.member top backlinks then
                                    Just top

                                else
                                    List.head backlinks
                            )
              , center = id
              , bottom =
                    thread.bottom
                        |> Maybe.andThen
                            (\bottom ->
                                let
                                    links : List String
                                    links =
                                        Zettelkasten.getLinks id zettelkasten
                                in
                                if List.member bottom links then
                                    Just bottom

                                else
                                    List.head links
                            )
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


viewZettel : Zettelkasten String String -> String -> Html Message
viewZettel zettelkasten id =
    Html.div
        [ Html.Attributes.class "w-96 text-center shrink-0 bg-orange-50 rounded-lg z-10"
        , Events.onClick (SetFocus id)
        ]
        [ Html.div [ Html.Attributes.class "px-3 py-4 sm:px-6" ]
            [ Html.h3 [ Html.Attributes.class "text-lg leading-6 text-gray-900" ]
                [ Html.text (id ++ "     ")
                , Html.text
                    (Zettelkasten.get id zettelkasten
                        |> Maybe.withDefault "ERROR"
                    )
                ]
            ]
        ]


{-| SnapList is currently uncontrolled.
We only need to make it controlled when we want to support initialization with specific threads.
This is likely only neccesary when we want the page to be in sync with the url.
-}
viewZettelRow : (String -> Message) -> Maybe String -> List String -> Zettelkasten String String -> Html Message
viewZettelRow onSnap selectedId ids zettelkasten =
    Html.div
        [ Html.Attributes.class "flex flex-row grow" ]
        [ SnapList.viewRow
            [ Html.Attributes.class "grow"
            ]
            { onSnap = onSnap, items = ids, isActive = \id -> Just id == selectedId, viewItem = viewZettel zettelkasten }
        ]


viewZettelkasten : Thread -> Zettelkasten String String -> Html Message
viewZettelkasten thread zettelkasten =
    let
        focusBacklinks : List String
        focusBacklinks =
            Zettelkasten.getBacklinks thread.center zettelkasten

        focusLinks : List String
        focusLinks =
            Zettelkasten.getLinks thread.center zettelkasten

        parentLinks : List String
        parentLinks =
            thread.top
                |> Maybe.map
                    (\id -> Zettelkasten.getLinks id zettelkasten)
                |> Maybe.withDefault [ thread.center ]
    in
    Html.ul
        [ Html.Attributes.class "flex flex-col justify-items-center gap-24 bg-zinc-700 h-full " ]
        [ viewZettelRow (ThreadThing Top) thread.top focusBacklinks zettelkasten
        , viewZettelRow SetFocus (Just thread.center) parentLinks zettelkasten
        , viewZettelRow (ThreadThing Bottom) thread.bottom focusLinks zettelkasten
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
