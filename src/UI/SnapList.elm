module UI.SnapList exposing (SnapListConfig, viewCol, viewRow)

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
    | Column


getNode : Direction -> String
getNode direction =
    case direction of
        Row ->
            "snap-row"

        Column ->
            "snap-col"


viewSnapList : Direction -> List (Attribute msg) -> SnapListConfig item msg -> Html msg
viewSnapList direction attributes config =
    Html.node (getNode direction)
        (attributes
            ++ [ Html.Events.on "changeActiveIndex"
                    (Json.Decode.at [ "target", "activeIndex" ] Json.Decode.int
                        |> Json.Decode.andThen
                            (\index ->
                                case List.getAt (Debug.log "activeIndex" index) config.items of
                                    Just item ->
                                        Json.Decode.succeed (config.onSnap item)

                                    Nothing ->
                                        Json.Decode.fail "failed"
                            )
                    )
               , Html.Attributes.attribute "activeIndex"
                    (List.findIndex config.isActive config.items
                        |> Maybe.withDefault -1
                        |> String.fromInt
                    )
               ]
        )
        (List.concat
            [ [ Html.div [ Html.Attributes.class "w-1/2 -mr-72 shrink-0" ] [] ]
            , config.items
                |> List.map
                    (\item ->
                        Html.node "snap-item"
                            [ Html.Events.custom "snap"
                                (Json.Decode.succeed
                                    { message = config.onSnap item
                                    , stopPropagation = True
                                    , preventDefault = False
                                    }
                                )
                            , Html.Attributes.class "snap-center snap-always"
                            ]
                            [ config.viewItem item
                            ]
                    )
            , [ Html.div [ Html.Attributes.class "w-1/2 -ml-72 shrink-0" ] [] ]
            ]
        )


viewRow : List (Attribute msg) -> SnapListConfig item msg -> Html msg
viewRow =
    viewSnapList Row


viewCol : List (Attribute msg) -> SnapListConfig item msg -> Html msg
viewCol =
    viewSnapList Column
