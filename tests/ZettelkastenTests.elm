module ZettelkastenTests exposing (suite)

import Expect
import Set
import Test exposing (..)
import Zettelkasten


suite : Test
suite =
    describe "Zettelkasten" <|
        [ test "I can create an empty zettelkasten" <|
            \_ ->
                Expect.true "Expected zettelkasten to be empty" (Zettelkasten.isEmpty Zettelkasten.empty)
        , test "I can add notes to a zettelkasten" <|
            \_ ->
                Expect.false "Expected zettelkasten not to be empty"
                    (Zettelkasten.isEmpty
                        (Zettelkasten.empty
                            |> Zettelkasten.insert "1" ""
                        )
                    )
        , test "I can retrieve notes from a zettelkasten" <|
            \_ ->
                Zettelkasten.empty
                    |> Zettelkasten.insert "1" "bla"
                    |> Zettelkasten.get "1"
                    |> Expect.equal (Just "bla")
        , test "I can retrieve a specific note from a zettelkasten" <|
            \_ ->
                Zettelkasten.empty
                    |> Zettelkasten.insert "1" "one"
                    |> Zettelkasten.insert "2" "two"
                    |> Zettelkasten.insert "3" "three"
                    |> Zettelkasten.get "2"
                    |> Expect.equal (Just "two")
        , test "I can retrieve all links from a zettel" <|
            \_ ->
                Zettelkasten.empty
                    |> Zettelkasten.insert "1" "one"
                    |> Zettelkasten.insert "2" "two"
                    |> Zettelkasten.insert "3" "three"
                    |> Zettelkasten.link "1" "2"
                    |> Zettelkasten.link "1" "3"
                    |> Zettelkasten.getLinks "1"
                    |> Expect.all
                        [ Set.size >> Expect.equal 2
                        , Set.member "2" >> Expect.true "\"two\" is a link"
                        , Set.member "3" >> Expect.true "\"three\" is a link"
                        ]
        , test "I can retrieve all backlinks from a zettel" <|
            \_ ->
                Zettelkasten.empty
                    |> Zettelkasten.insert "1" "one"
                    |> Zettelkasten.insert "2" "two"
                    |> Zettelkasten.insert "3" "three"
                    |> Zettelkasten.link "2" "3"
                    |> Zettelkasten.link "1" "3"
                    |> Zettelkasten.getBacklinks "3"
                    |> Expect.all
                        [ Set.size >> Expect.equal 2
                        , Set.member "1" >> Expect.true "\"one\" is a backlink"
                        , Set.member "2" >> Expect.true "\"two\" is a backlink"
                        ]
        ]
