import { Elm } from './App.elm'
import "../style.css";
import "./UI/SnapList"
import "@pkm/ui"

const app = Elm.App.init({
    node: document.getElementById('root')
})