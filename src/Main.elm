module Main exposing (main)

import Browser
import Html


main : Program () () ()
main =
    Browser.sandbox
        { init = ()
        , update = \() _ -> ()
        , view = \_ -> Html.text "Hello world"
        }
