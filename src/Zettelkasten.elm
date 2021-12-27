module Zettelkasten exposing (Zettelkasten, empty, get, getBacklinks, getLinks, insert, isEmpty, link)

import Dict exposing (Dict)
import Set exposing (Set)


type alias Zettel comparableId content =
    { content : content
    , links : Set comparableId
    , backlinks : Set comparableId
    }


makeZettel : content -> Zettel comparableId content
makeZettel content =
    { content = content, links = Set.empty, backlinks = Set.empty }


addZettelLink : comparableId -> Zettel comparableId content -> Zettel comparableId content
addZettelLink id zettel =
    { zettel | links = Set.insert id zettel.links }


addZettelBacklink : comparableId -> Zettel comparableId content -> Zettel comparableId content
addZettelBacklink id zettel =
    { zettel | backlinks = Set.insert id zettel.backlinks }


type Zettelkasten comparableId content
    = Zettelkasten (Dict comparableId (Zettel comparableId content))


empty : Zettelkasten comparableId content
empty =
    Zettelkasten Dict.empty


isEmpty : Zettelkasten comparableId content -> Bool
isEmpty (Zettelkasten zettelkasten) =
    Dict.isEmpty zettelkasten


insert : comparableId -> content -> Zettelkasten comparableId content -> Zettelkasten comparableId content
insert id content (Zettelkasten zettelkasten) =
    Zettelkasten (Dict.insert id (makeZettel content) zettelkasten)


get : comparableId -> Zettelkasten comparableId zettel -> Maybe zettel
get id (Zettelkasten zettelkasten) =
    Dict.get id zettelkasten
        |> Maybe.map .content


link : comparableId -> comparableId -> Zettelkasten comparableId content -> Zettelkasten comparableId content
link srcId targetId (Zettelkasten zettelkasten) =
    Zettelkasten
        (zettelkasten
            |> Dict.update srcId (Maybe.map (addZettelLink targetId))
            |> Dict.update targetId (Maybe.map (addZettelBacklink srcId))
        )


getLinks : comparableId -> Zettelkasten comparableId content -> Set comparableId
getLinks id (Zettelkasten zettelkasten) =
    Dict.get id zettelkasten
        |> Maybe.map .links
        |> Maybe.withDefault Set.empty


getBacklinks : comparableId -> Zettelkasten comparableId content -> Set comparableId
getBacklinks id (Zettelkasten zettelkasten) =
    Dict.get id zettelkasten
        |> Maybe.map .backlinks
        |> Maybe.withDefault Set.empty
