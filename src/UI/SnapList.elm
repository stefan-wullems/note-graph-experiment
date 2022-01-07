module UI.SnapList exposing (SnapListConfig, viewRow)

import Html exposing (Attribute, Html)
import Html.Attributes
import Html.Events
import Json.Decode
import List.Extra as List


type alias SnapListConfig item msg =
    { items : List item
    , viewItem : item -> Html msg
    , isActive : item -> Bool
    , onSnap : item -> msg
    }


type Direction
    = Row


getNode : Direction -> String
getNode _ =
    "snap-row"


viewSnapList : Direction -> List (Attribute msg) -> SnapListConfig item msg -> Html msg
viewSnapList direction attributes config =
    Html.node "horizontal-glider"
        (attributes
            ++ [ Html.Events.on "changeActiveIndex"
                    (Json.Decode.at [ "target", "activeIndex" ] Json.Decode.int
                        |> Json.Decode.andThen
                            (\index ->
                                case List.getAt index config.items of
                                    Just item ->
                                        Json.Decode.succeed (config.onSnap item)

                                    Nothing ->
                                        Json.Decode.fail "failed"
                            )
                    )
               , Html.Attributes.attribute "activeindex"
                    (List.findIndex config.isActive config.items
                        |> Maybe.withDefault -1
                        |> String.fromInt
                    )
               ]
        )
        (config.items
            |> List.indexedMap
                (\index item ->
                    Html.node "glider-item"
                        [ Html.Attributes.attribute "slot" ("slide" ++ String.fromInt index) ]
                        [ config.viewItem item ]
                )
        )


viewRow : List (Attribute msg) -> SnapListConfig item msg -> Html msg
viewRow =
    viewSnapList Row
