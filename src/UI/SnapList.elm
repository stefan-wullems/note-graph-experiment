module UI.SnapList exposing (SnapListConfig, viewCol, viewRow)

import Html exposing (Attribute, Html)
import Html.Events as Events
import Json.Decode as JsonDecode


type alias SnapListConfig item msg =
    { items : List item
    , viewItem : item -> Html msg
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
        attributes
        (config.items
            |> List.map
                (\item ->
                    Html.node "snap-item"
                        [ Events.custom "snap"
                            (JsonDecode.succeed
                                { message = config.onSnap item
                                , stopPropagation = True
                                , preventDefault = False
                                }
                            )
                        ]
                        [ config.viewItem item
                        ]
                )
        )


viewRow : List (Attribute msg) -> SnapListConfig item msg -> Html msg
viewRow =
    viewSnapList Row


viewCol : List (Attribute msg) -> SnapListConfig item msg -> Html msg
viewCol =
    viewSnapList Column
