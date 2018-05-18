import './main.css';
import {
  Main
} from './Main.elm';

// Main.embed(document.getElementById('__QUICK_OPEN_ROOT'));

global.Main = window.Main = Main;
