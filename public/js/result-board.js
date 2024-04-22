import LichessPgnViewer from "./lichess-pgn-viewer.min.js";

var results = $('#results').data().results.
    map(result => result.join(''))

export function loadGame(idx) {
    $('div.lpv').replaceWith('<div id="resultBoard" class="is2d"></div>')
    document.getElementById('resultBoard')
    var lpv = LichessPgnViewer(resultBoard, {
	pgn: results[idx]
    });
    $('.lpv').focus()
}
window.loadGame = loadGame;
loadGame(0)

