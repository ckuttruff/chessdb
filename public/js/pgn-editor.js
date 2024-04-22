const config = {
    position: 'start',
    showCoords: true,
    theme: 'brown',
    pieceStyle: 'wikipedia',
    layout: 'top',
    showFen: true,
    coordsInner: false,
    coordsFactor: '1.0', coordsFontSize: '', colorMarker: '', startPlay: '', hideMovesBefore: true,
    notation: 'short', notationLayout: 'inline'
}

var board = PGNV.pgnEdit('board', config)

$('#editboardButton').hide()
$('#boardMoves').hide()
$('#boardFen').hide()

function setFEN() {
    const fen = $('#boardFen').val().split(' ')[0]
    $('input[name="fen"]').val(fen)
}
