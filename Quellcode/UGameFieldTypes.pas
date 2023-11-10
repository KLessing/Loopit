unit UGameFieldTypes;

interface

uses
  UTypes,
  Vcl.Graphics; // Wird f�r die Farben des MULTIPLIER_COLOR Arrays ben�tigt

type
  // Spielfeld mit Steinen auf den einzelnen Feldern
  TGameField = array [TRow, TCol] of TTile;

  // Multiplier f�r die Punktberechnung eines Spielfelds
  TFieldMultiplier = 1..6;

const
  // Enth�lt den jeweiligen Multiplier f�r alle Felder des Spielfelds
  FIELD_MULTIPLIER : array [TRow, TCol] of TFieldMultiplier =
  (
    (6, 1, 1, 1, 1, 6, 1, 1, 1, 1, 6),
    (1, 1, 5, 1, 1, 1, 1, 1, 5, 1, 1),
    (1, 4, 1, 1, 1, 4, 1, 1, 1, 4, 1),
    (1, 1, 1, 3, 1, 1, 1, 3, 1, 1, 1),
    (1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1),
    (6, 1, 4, 1, 2, 1, 2, 1, 4, 1, 6),
    (1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1),
    (1, 1, 1, 3, 1, 1, 1, 3, 1, 1, 1),
    (1, 4, 1, 1, 1, 4, 1, 1, 1, 4, 1),
    (1, 1, 5, 1, 1, 1, 1, 1, 5, 1, 1),
    (6, 1, 1, 1, 1, 6, 1, 1, 1, 1, 6)
  );

  // Enth�lt die jeweilige Feld Farbe f�r die Mutliplier
  MULTIPLIER_COLOR : array [TFieldMultiplier] of TColor =
  (clBlue, clYellow, clRed, clWhite, clSkyBlue, clGreen);

implementation

end.
