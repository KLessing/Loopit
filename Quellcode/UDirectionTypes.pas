{------------------------------------------------------------------------------
Enthält die Typen die lediglich von der UDirections Unit verwendet werden.
Anhand der Indizes des Namens der Steine, werden hier die entsprechenden
verfügbaren Wege für die Steine gepeichert.

Autor: Kevin Lessing , 24.09.2017
------------------------------------------------------------------------------}
unit UDirectionTypes;

interface

uses UTypes;

type

  // Menge aller möglichen Werte für den ersten Index des Stein Namens
  TFirstIndexRange = 1..8;
  TFirstIndexSet = set of TFirstIndexRange;

  // Wertebereiche für den dritten Index des Namens
  // Wenn der zweite Index zwei beträgt
  TThirdIndexRangeForSecondTwo = 1..6;
  // Wenn der zweite Index drei beträgt
  TThirdIndexRangeForSecondThree = 1..4;

const

  // Offene Wege für alle Steine mit den zweiten Index 2
  // Jeder Stein hat zwei offene Wege und ist deswegen zwei mal pro dritten Index vertreten
  // Der Zugriff erfolgt über den dritten Index für den ersten Index
  TWO_WAYS : array[TThirdIndexRangeForSecondTwo, TDirection] of TFirstIndexSet =
  (
    ( // Dritter Index 1
      ([1, 3, 5, 6]),    // Weg nach Norden vorhanden für entsprechende ersten Indizes
      ([1, 4, 5, 6, 7]), // Weg nach Osten
      ([2, 3, 4]),       // Weg nach Süden
      ([2, 7])           // Weg nach Westen
    ),
    ( // Dritter Index 2
      ([4, 5, 7]),       // Weg nach Norden vorhanden für entsprechende ersten Indizes
      ([1, 2, 3, 6]),    // Weg nach Osten
      ([2, 3, 4, 5]),    // Weg nach Süden
      ([1, 6, 7])        // Weg nach Westen
    ),
    ( // Dritter Index 3
      ([2, 3, 6, 7]),    // Weg nach Norden vorhanden für entsprechende ersten Indizes
      ([1, 5, 7]),       // Weg nach Osten
      ([1, 2, 4, 5, 6]), // Weg nach Süden
      ([3, 4])           // Weg nach Westen
    ),
    ( // Dritter Index 4
      ([2, 4]),          // Weg nach Norden vorhanden für entsprechende ersten Indizes
      ([2, 3, 6, 7]),    // Weg nach Osten
      ([1, 5, 6, 7]),    // Weg nach Süden
      ([1, 3, 4, 5])     // Weg nach Westen
    ),
    ( // Dritter Index 5
      ([1, 6]),            // Weg nach Norden vorhanden für entsprechende ersten Indizes
      ([2, 4, 5]),         // Weg nach Osten
      ([1, 3, 7]),         // Weg nach Süden
      ([2, 3, 4, 5, 6, 7]) // Weg nach Westen
    ),
    ( // Dritter Index 6
      ([1, 2, 3, 4, 5, 7]), // Weg nach Norden vorhanden für entsprechende ersten Indizes
      ([3, 4]),             // Weg nach Osten
      ([6, 7]),             // Weg nach Süden
      ([1, 2, 5, 6])        // Weg nach Westen
    )
  );


  // Geschlossenen Wege für alle Steine mit den zweiten Index 3
  // Jeder Stein hat einen geschlossenen Weg und ist deswegen ein mal pro dritten Index vertreten
  // Der Zugriff erfolgt über den dritten Index für den ersten Index
  THREE_WAYS : array[TThirdIndexRangeForSecondThree, TDirection] of TFirstIndexSet =
  (
    ( // Dritter Index 1
      ([4]),            // Nach Norden versperrt für entsprechende Indizes
      ([1, 6, 8]),      // Nach Osten versperrt
      ([2, 7]),         // Nach Süden versperrt
      ([3, 5])          // Nach Westen versperrt
    ),
    ( // Dritter Index 2
      ([6]),            // Nach Norden versperrt für entsprechende Indizes
      ([3]),            // Nach Osten versperrt
      ([5]),            // Nach Süden versperrt
      ([1, 2, 4, 7, 8]) // Nach Westen versperrt
    ),
    ( // Dritter Index 3
      ([3, 8]),        // Nach Norden versperrt für entsprechende Indizes
      ([2, 5, 7]),     // Nach Osten versperrt
      ([1, 4]),        // Nach Süden versperrt
      ([6])            // Nach Westen versperrt
    ),
    ( // Dritter Index 4
      ([1, 2, 5, 7]), // Nach Norden versperrt für entsprechende Indizes
      ([4]),          // Nach Osten versperrt
      ([3, 6, 8]),    // Nach Süden versperrt
      ([])            // Nach Westen versperrt
    )
  );

implementation

end.
