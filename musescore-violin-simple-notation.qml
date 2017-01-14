import QtQuick 2.0
import MuseScore 1.0

// TODO: I'm not quite happy with the placement/location.
// TODO: I'm not quite happy without additional hand positions.

MuseScore {
	menuPath: 'Plugins.SimpleViolinNotation'

	property variant pitchMapping: {
		// G
		55: {name: 'G' , snare: 'G', finger: '0'},
		56: {name: 'G♯', snare: 'G', finger: '1♭'},
		57: {name: 'A' , snare: 'G', finger: '1'},
		58: {name: 'A♯', snare: 'G', finger: '2♭'},
		59: {name: 'B' , snare: 'G', finger: '2'},
		60: {name: 'C' , snare: 'G', finger: '3'},
		61: {name: 'C♯', snare: 'G', finger: '3♯'},
		// D
		62: {name: 'D' , snare: 'D', finger: '0', substitute: {snare: 'G', finger: '4'}},
		63: {name: 'D♯', snare: 'D', finger: '1♭'},
		64: {name: 'E' , snare: 'D', finger: '1'},
		65: {name: 'F' , snare: 'D', finger: '2♭'},
		66: {name: 'F♯', snare: 'D', finger: '2'},
		67: {name: 'G' , snare: 'D', finger: '3'},
		68: {name: 'G♯', snare: 'D', finger: '3♯'},
		// A
		69: {name: 'A' , snare: 'A', finger: '0', substitute: {snare: 'D', finger: '4'}},
		70: {name: 'A♯', snare: 'A', finger: '1♭'},
		71: {name: 'B' , snare: 'A', finger: '1'},
		72: {name: 'C' , snare: 'A', finger: '2♭'},
		73: {name: 'C♯', snare: 'A', finger: '2'},
		74: {name: 'D' , snare: 'A', finger: '3'},
		75: {name: 'D♯', snare: 'A', finger: '3♯'},
		// E
		76: {name: 'E' , snare: 'E', finger: '0', substitute: {snare: 'A', finger: '4'}},
		77: {name: 'F' , snare: 'E', finger: '1♭'},
		78: {name: 'F♯', snare: 'E', finger: '1'},
		79: {name: 'G' , snare: 'E', finger: '2♭'},
		80: {name: 'G♯', snare: 'E', finger: '2'},
		81: {name: 'A' , snare: 'E', finger: '3'},
		82: {name: 'A♯', snare: 'E', finger: '3♯'},
		83: {name: 'B' , snare: 'E', finger: '4'}
	}
	
	function createNoteMap() {
		var result = [];
		iterateNotes(function (cursor, notePitch) {
			result.push(pitchMapping[notePitch]);
		});
		return result;
	}
	
	function createText(cursor, text, yPos) {
		var element = newElement(Element.STAFF_TEXT);
		element.pos.y = yPos;
		element.text = text;
		cursor.add(element);
	}
	
	function iterateNotes(callback) {
		var cursor = curScore.newCursor();
		var noteIndex = 0;
		for (var staffIdx = 0; staffIdx < curScore.nstaves; staffIdx++) {
			for (var voice = 0; voice < 4; voice++) {
				cursor.rewind(0);
				cursor.staffIdx = staffIdx;
				cursor.voice = voice;
				while (cursor.segment) {
					if (cursor.element && cursor.element.notes && cursor.element.notes.length !== 0 && cursor.element.type === Element.CHORD) {
						callback(cursor, cursor.element.notes[0].pitch, noteIndex);
						noteIndex++;
					}
					cursor.next();
				}
			}
		}
	}
	
	function fillText(noteMap) {
		var previousSnare;
		iterateNotes(function (cursor, notePitch, noteIndex) {
			// Initialize the current note.
			var currentNote = noteMap[noteIndex];
			if (currentNote == null) return;

			// Annotate with the substitude finger position when applicable.
			if (currentNote.substitute && currentNote.substitute.snare === previousSnare) {
				var nextNote = noteMap[noteIndex + 1];
				if (nextNote && currentNote.substitute.snare === previousSnare && currentNote.snare !== nextNote.snare) {
					createText(cursor, currentNote.substitute.finger, 12);
					return;
				}
			}
			
			// Annotate with the new snare when applicable.
			if (currentNote.snare !== previousSnare) {
				createText(cursor, currentNote.snare, 14);
				previousSnare = currentNote.snare;
			}
				
			// Annotate the finger position.
			createText(cursor, currentNote.finger, 12);
		});
	}

	onRun: {
		fillText(createNoteMap());
		Qt.quit();
	}
}
