{------------------------------------------------------------------------------
Zuständig für die Verarbeitung des SpielFeldes. Enthält eine globale Variable
für das aktuelle Spielfeld und Funktionen zum bearbeiten oder lesen der Daten.
Zudem findet hier die Berechnung der Punkte für einen Zug statt und die Über-
prüfung, ob eine Ablage erlaubt ist, bzw. ob das gesamte Spielfeld valide

Autor: Kevin Lessing , 14.10.2017
------------------------------------------------------------------------------}
unit UGameField;

interface

uses UTypes, UGameFieldTypes, UDirections;

  function getTileNameFromField(Row: TRow; Col: TCol): TTileName;
  procedure setTileOnField(Tile: TTile; Row: TRow; Col: TCol);
  procedure removeTileFromField(Row: TRow; Col: TCol);
  function isGameFieldValid: Boolean;
  function isFieldEmpty(Row: TRow; Col: TCol): Boolean;
  function checkFieldValidity(Tile: TTile; Row: TRow; Col: TCol): Boolean;
  function calcDepositPoints(Tile: TTile; Row: TRow; Col: TCol): TPoints;
  procedure clearGameField;

implementation

var
  // Globale Variable für das aktuelle Spielfeld
  GameField: TGameField;

{Gibt den Namen des Steins eines Feldes zurück
IN: Row, Col - Reihe und Spalte des Feldes
RETURN: Name des Steins}
function getTileNameFromField(Row: TRow; Col: TCol): TTileName;
begin
  getTileNameFromField:= GameField[Row, Col].name;
end;

{Setzt einen Stein auf ein Feld
IN: Tile - Entsprechender Stein
IN: Row, Col - Reihe und Spalte des Feldes}
procedure setTileOnField(Tile: TTile; Row: TRow; Col: TCol);
begin
  GameField[Row, Col]:= Tile;
end;

{Entfernt ein Stein von einem Feld bzw. initialisiert das Feld leer
IN: Row, Col - Reihe und Spalte des Feldes}
procedure removeTileFromField(Row: TRow; Col: TCol);
begin
  FillChar(GameField[Row, Col],
           SizeOf(TTile),
           0);
end;

{Gibt an ob das entsprechende Feld leer ist
IN: Row, Col - Reihe und Spalte des Feldes
RETURN: True, wenn Feld leer}
function isFieldEmpty(Row: TRow; Col: TCol): Boolean;
begin
  isFieldEmpty:= GameField[Row, Col].index = 0;
end;

{Überprüft, ob die Loop beim oder vom Nachbarfeld unterbrochen wird
IN: Direction - Die Richtung, die auf Kompatibilität geprüft werden soll
IN: Row, Col - Reihe und Spalte des Feldes
IN: ReverseCheck - True, wenn geprüft werden soll, ob die Loop DES Nachbarn unterbrochen wird
                   False, wenn geprüft werden soll, ob die Loop VOM Nachbarn unterbrochen wird
OUT: NeighbourLoop - Wird die Loop des Nachbarn weitergeführt? (Muss min ein mal vorhanden stein)
RETURN: True, wenn die Loop unterbrochen wurde}
function checkInterruption(Direction: TDirection; Row: TRow; Col: TCol; ReverseCheck: Boolean; var NeighbourLoop: Boolean): Boolean;
var
  isBorder, interrupt: Boolean;
  oppositeDir: TDirection;
  neighbourRow: TRow;
  neighbourCol: TCol;
begin
  // Initialisierungen
  neighbourRow:= Row;
  neighbourCol:= Col;

  // Gegenüberliegende Richtung ermitteln
  oppositeDir:= UDirections.getOppositeDirection(Direction);

  // Nachbarfeld ermitteln, wenn es sich nicht um ein Feld am Rand handelt
  isBorder:= not(UDirections.getNextCoords(Direction, neighbourRow, neighbourCol));

  // Prüfen, ob die Loop des Nachbarfeldes in die Richtung des zu überprüfenden Feldes zeigt
  NeighbourLoop:= oppositeDir in GameField[neighbourRow, neighbourCol].directions;

  // Wird Loop des Nachbarn überprüft? (oder Loop ZUM Nachbarn)
  if ReverseCheck then
    // Am Rand kann keine Loop des Nachbarn unterbrochen werden (da keiner existiert)
    // sonst wenn Nachbar Loop in Richtung des zu überprüfenden Steins vorhanden ist,
    // wird diese unterbrochen
    interrupt:= not(isBorder) and NeighbourLoop
  else
    // Loop darf nicht übern Rand laufen
    // sonst wenn das Nachbarfeld nicht leer ist und die Loop des Nachbarn
    // nicht mit der Richtung des zu überprüfenden Steins anschließt
    interrupt:= isBorder
                or (not(isFieldEmpty(neighbourRow, neighbourCol))
                    and not(NeighbourLoop));

  checkInterruption:= interrupt;
end;

{Überprüft die Validität eines Steins auf einem Feld
Vorbedingung: falls der Stein anschließend abgelegt wird, muss das Feld leer sein
IN: Tile - Entsprechender Stein
IN: Row, Col - Reihe und Spalte des Feldes
RETURN: True, wenn Stein auf Feld valide}
function checkFieldValidity(Tile: TTile; Row: TRow; Col: TCol): Boolean;
var
  dir: TDirection;
  checkContinuedLoop, checkReverse,
  continuedLoop, interrupted: Boolean;
begin
  // Initialisierungen
  continuedLoop:= false;
  interrupted:= false;

  // Überprüfe alle Himmelsrichtungen
  for dir := Low(TDirection) to High(TDirection) do
  begin
    // Wenn Loop enhalten ist, dann Nachbar prüfen ob er diese unterbricht
    // ansonsten umgekehrt, wenn keine Loop enthalten ist,
    // prüfen ob die Loop vom Nachbarn unterbrochen wird
    if dir in Tile.directions then
      checkReverse:= false
    else
      checkReverse:= true;

    // Unterbrechung überprüfen
    interrupted:= interrupted or
                  checkInterruption(dir, Row, Col, checkReverse, checkContinuedLoop);
    // Es muss mindestens eine Nachbar Loop fortgesetzt werden
    continuedLoop:= continuedLoop or checkContinuedLoop;
  end;

  checkFieldValidity:= not(interrupted) and continuedLoop;
end;

{Rekursive Fortsetzung der Punktberechnung
IN: Origin - Urpsrungsrichtung zum vorher berechneten Stein
IN/OUT: AlreadySet - Menge der Indizes, der bereits gezählten Steine
IN: Row, Col - Reihe und Spalte des zu berechnenden Feldes
GLOBAL: GET UDirections.getNextDirection - Richtung zum Nachbarn
        GET UDirections.getNextCoords - Reihe und Spalte des Nachbarn
RETURN: Addierte Punkte für die Richtung bis zum Ende (Kreuzung, Sackgasse, Border)}
function continuePointCalc(Origin: TDirection; var AlreadySet: TTileIndexSack; Row: TRow; Col: TCol): Word;
var
  nextRow: TRow;
  nextCol: Tcol;
  dirToNext, nextOrigin: TDirection;
begin
  // Initialisierungen
  nextRow:= Row;
  nextCol:= Col;

  // Stein des Feldes zur Menge der berechneten Steine hinzufügen
  AlreadySet:= AlreadySet + [GameField[Row, Col].index];

  // Nachbarfeld nicht leer und noch nicht berechnet
  if UDirections.getNextDirection(GameField[Row, Col], Origin, dirToNext) and
     UDirections.getNextCoords(dirToNext, nextRow, nextCol) and
     not(isFieldEmpty(nextRow, nextCol)) and
     not(GameField[nextRow, nextCol].index in AlreadySet) then
  begin
    // Der Urpsrung des Nachbarn ist die Gegenüberliegende Richtung, die zum Nachbarn zeigt
    nextOrigin:= UDirections.getOppositeDirection(dirToNext);
    // Punktberechnung fortsetzen und addieren
    continuePointCalc:= GameField[Row, Col].points +
                            continuePointCalc(nextOrigin, AlreadySet, nextRow, nextCol);
  end
  else
    // Ende der Berechnung für diese Richtung, nur noch Punkte zurück geben
    continuePointCalc:= GameField[Row, Col].points;
end;

{Starten der Punktberechnung und Weiterführung in alle Richtung
IN: Tile - Entsprechender Stein
IN: Row, Col - Reihe und Spalte des Feldes
GLOBAL: GET FIELD_MULTIPLIER - Multiplier für das Feld
        GET UDirections.getNextCoords - Reihe und Spalte des Nachbarn
        GET UDirections.getOppositeDirection - Gegenüberliegende Richtung
RETURN: Anzahl der Gesamtpunkte des Zuges}
function calcDepositPoints(Tile: TTile; Row: TRow; Col: TCol): TPoints;
var
  alreadySet: TTileIndexSack;
  pointRes: Byte;
  dirRunner, origin: TDirection;
  nextRow: TRow;
  nextCol: TCol;
begin
  // Punkte des Steins mit dem Multiplier des Feldes multiplizieren
  pointRes:= Tile.points *
             FIELD_MULTIPLIER[Row, Col];

  // Merken, dass der Stein schon gezählt wurde
  alreadySet:= [GameField[Row, Col].index];

  // Weiterführen der Punktberechnung in alle Richtungen der Loop
  for dirRunner in Tile.directions do
  begin
    // Initialisierung um die Nachbar Koordinaten zu bekommen
    nextRow:= Row;
    nextCol:= Col;
    // Wenn Nachbar nicht leer und noch nicht gezählt wurde
    if UDirections.getNextCoords(dirRunner, nextRow, nextCol) and
       not(isFieldEmpty(nextRow, nextCol)) and
       not(GameField[nextRow, nextCol].index in AlreadySet) then
    begin
      // Der Urpsrung des Nachbarn ist die Gegenüberliegende Richtung, die zum Nachbarn zeigt
      origin:= UDirections.getOppositeDirection(dirRunner);
      // Berechnung fortsetzen
      pointRes:= pointRes +
                 continuePointCalc(origin, alreadySet, nextRow, nextCol);
    end;
  end;

  calcDepositPoints:= pointRes;
end;

{Überprüft, ob nur das mittlere Feld gesetzt ist und alle anderen Felder Leer sind
RETURN: True, wenn nur mittleres Feld gesetzt}
function isOnlyMiddleFieldSet: Boolean;
var
  row: 0..ROW_COUNT;
  col: 0..COL_COUNT;
  allOtherEmpty: Boolean;
begin
  // Initialisierungen
  allOtherEmpty:= false;
  row:= 0;

  // Erst prüfen, ob das mittlere Feld gesetzt ist
  if not(isFieldEmpty(5, 5)) then
    allOtherEmpty:= true;

  // Dann prüfen, ob alle anderen Felder (außer das Mittlere) leer sind
  while allOtherEmpty and (row < ROW_COUNT) do
  begin
    col:= 0;
    while allOtherEmpty and (col < COL_COUNT) do
    begin
      if not(isFieldEmpty(row, col)) and
         (not((row = 5) and (col = 5))) then
        allOtherEmpty:= false;
      inc(col);
    end;
    inc(row);
  end;

  isOnlyMiddleFieldSet:= allOtherEmpty;
end;

{Überprüft, ob das gesamte Spielfeld valide ist
RETURN: True, wenn Spielfeld valide}
function isGameFieldValid: Boolean;
var
  row: 0..ROW_COUNT;
  col: 0..COL_COUNT;
  valid: Boolean;
begin
  // Initialisierungen
  row:= 0;
  valid:= true;

  // wenn nur das mittlere Feld gesetzt ist,
  // ist das Gamefield valide und keine weitere Überprüfung notwendig
  // sont muss jedes Feld auf validität überprüft werden. (Auch das mittlere)
  if not(isOnlyMiddleFieldSet) then
  begin
    while valid and (row < ROW_COUNT) do
    begin
      col:= 0;
      while valid and (col < COL_COUNT) do
      begin
        if not(isFieldEmpty(row, col)) then
          valid:= checkFieldValidity(GameField[row, col], row, col);
        inc(col);
      end;
      inc(row);
    end;
  end;

  isGameFieldValid:= valid;
end;

{Entfernt alle Steine vom Spielfeld}
procedure clearGameField;
var
  row: TRow;
  col: TCol;
begin
  for row := Low(TRow) to High(TRow) do
    for col := Low(TCol) to High(TCol) do
      removeTileFromField(row, col);
end;


end.
