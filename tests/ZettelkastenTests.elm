module ZettelkastenTests exposing (suite)

import Expect
import Test exposing (Test)
import Zettelkasten


suite : Test
suite =
    Test.describe "Zettelkasten" <|
        [ Test.test "I can create an empty zettelkasten" <|
            \_ ->
                Expect.true "Expected zettelkasten to be empty" (Zettelkasten.isEmpty Zettelkasten.empty)
        , Test.test "I can add notes to a zettelkasten" <|
            \_ ->
                Expect.false "Expected zettelkasten not to be empty"
                    (Zettelkasten.isEmpty
                        (Zettelkasten.empty
                            |> Zettelkasten.insert "1" ""
                        )
                    )
        , Test.test "I can retrieve notes from a zettelkasten" <|
            \_ ->
                Zettelkasten.empty
                    |> Zettelkasten.insert "1" "bla"
                    |> Zettelkasten.get "1"
                    |> Expect.equal (Just "bla")
        , Test.test "I can retrieve a specific note from a zettelkasten" <|
            \_ ->
                Zettelkasten.empty
                    |> Zettelkasten.insert "1" "one"
                    |> Zettelkasten.insert "2" "two"
                    |> Zettelkasten.insert "3" "three"
                    |> Zettelkasten.get "2"
                    |> Expect.equal (Just "two")
        , Test.test "I can retrieve all links from a zettel" <|
            \_ ->
                Zettelkasten.empty
                    |> Zettelkasten.insert "1" "one"
                    |> Zettelkasten.insert "2" "two"
                    |> Zettelkasten.insert "3" "three"
                    |> Zettelkasten.link "1" "2"
                    |> Zettelkasten.link "1" "3"
                    |> Zettelkasten.getLinks "1"
                    |> Expect.all
                        [ List.length >> Expect.equal 2
                        , List.member "2" >> Expect.true "\"two\" is a link"
                        , List.member "3" >> Expect.true "\"three\" is a link"
                        ]
        , Test.test "I can retrieve all backlinks from a zettel" <|
            \_ ->
                Zettelkasten.empty
                    |> Zettelkasten.insert "1" "one"
                    |> Zettelkasten.insert "2" "two"
                    |> Zettelkasten.insert "3" "three"
                    |> Zettelkasten.link "2" "3"
                    |> Zettelkasten.link "1" "3"
                    |> Zettelkasten.getBacklinks "3"
                    |> Expect.all
                        [ List.length >> Expect.equal 2
                        , List.member "1" >> Expect.true "\"one\" is a backlink"
                        , List.member "2" >> Expect.true "\"two\" is a backlink"
                        ]
        ]
