import QtQuick 2.0
import MuseScore 1.0

// TODO: I'm not quite happy with the placement/location. It's also quite... static.
// TODO: I'm not quite happy with the colors.
// TODO: I'm not quite happy with the notation (no high/low).
// TODO: There are notes that just aren't recognized yet.

MuseScore {
	menuPath: 'Plugins.SimpleViolinNotation'

	property variant colors: [
		'#FF0000', '#FF0000', '#FF0000', '#FF0000', '#FF0000', '#FF0000', '#FF0000',
		'#0000FF', '#0000FF', '#0000FF', '#0000FF', '#0000FF', '#0000FF', '#0000FF',
		'#006600', '#006600', '#006600', '#006600', '#006600', '#006600', '#006600', 
		'#666600', '#666600', '#666600', '#666600', '#666600', '#666600', '#666600', '#666600'
	]

	property variant fingers: [ 
		'0', '1', '1', '2', '2', '3', '3',
		'0', '1', '1', '2', '2', '3', '3',
		'0', '1', '1', '2', '2', '3', '3', 
		'0', '1', '1', '2', '2', '3', '3', '4'
	]
	
	property variant snares: [ 
		'G', 'G', 'G', 'G', 'G', 'G', 'G',
		'D', 'D', 'D', 'D', 'D', 'D', 'D',
		'A', 'A', 'A', 'A', 'A', 'A', 'A',
		'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E'
	]
	
	function fillText(notes, element) {
		if (notes.length === 1) {
			var index = notes[0].pitch - 55;
			if (index >= 0 && index < fingers.length){
				element.color = colors[index];
				element.text = fingers[index] + '\n' + snares[index];
			} else {
				console.log('Unknown index: ' + index);
				element.text = '?';
			}
		}
	}

	onRun: {
		var cursor = curScore.newCursor();
		for (var staffIdx = 0; staffIdx < curScore.nstaves; staffIdx++) {
			for (var voice = 0; voice < 4; voice++) {
				cursor.rewind(0);
				cursor.staffIdx = staffIdx;
				cursor.voice = voice;
				while (cursor.segment) {
					if (cursor.element && cursor.element.type == Element.CHORD) {
						var element = newElement(Element.STAFF_TEXT);
						var notes = cursor.element.notes;
						fillText(notes, element);
						element.pos.y = 12;
						cursor.add(element);
					}
					cursor.next();
				}
			}
		}
		Qt.quit();
	}
}
