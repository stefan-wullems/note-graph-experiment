import { Elm } from './App.elm'
import "../style.css";
import "./UI/SnapList"
import "./webcomponents/index"

const app = Elm.App.init({
    node: document.getElementById('root')
})