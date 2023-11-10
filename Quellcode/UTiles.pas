{------------------------------------------------------------------------------
Zusändig für das Erstellen von Steinen mit entsprechenden Punkten und Richtungen.
Enthält zudem Hilfsfunktionen für den Steine Sack.
Alle Stein Namen sind in einem Konstanten Array definiert um den Namen einen
Index zuzuordnen, wobei der "0te" Index für "empty" steht.

Autor: Kevin Lessing , 24.09.2017
------------------------------------------------------------------------------}

unit UTiles;

interface

uses UDirections, UTypes, SysUtils;

  function getTileFromName(TileName: TTileName): TTile;
  function getTileFromIndex(Index: TTileIndex): TTile;
  function getIndexFromName(TileName: TTileName; var TileIndex: TTileIndex): Boolean;
  function getRdmTileFromSack(TileSack: TTileIndexSack): TTile;

  function isTileSackEmpty(TileSack: TTileIndexSack): Boolean;

implementation

const
  // Konstantes Array, das einem Index einen Namen zuordnet (0 = empty)
  ALL_TILES: array[TTileIndex] of TTileName =
  (
    '0',
    '121', '122', '123', '124', '125', '126',
    '131', '132', '133', '134', '141',
    '221', '222', '223', '224', '225', '226',
    '231', '232', '233', '234', '241',
    '321', '322', '323', '324', '325', '326',
    '331', '332', '333', '334', '341',
    '421', '422', '423', '424', '425', '426',
    '431', '432', '433', '434', '441',
    '521', '522', '523', '524', '525', '526',
    '531', '532', '533', '534', '541',
    '621', '622', '623', '624', '625', '626',
    '631', '632', '633', '634', '641',
    '721', '722', '723', '724', '725', '726',
    '731', '732', '733', '734', '741',
    '831', '832', '833', '834'
  );

{Gibt die Punkte eines Steins anhand des Namens zurück
IN: TileName - Name des Steins
RETURN: Punkte des Steins}
function getPoints(TileName: TTileName): TTilePoints;
begin
  getPoints:= TTilePoints(StrToInt(TileName[1]))
end;

{Gibt den Stein für einen bestimmten Stein Namen zurück
PRE: Name sollte vorhanden sein, sonst wird ein leerer Datensatz zurückgegeben
RETURN: Der Stein mit dem entsprechenden Namen}
function createTile(TileName: TTileName): TTile;
var
  resultTile: TTile;
begin
  // Leer Initialisieren
  FillChar(resultTile, SizeOf(TTile), 0);

  // Nur wenn der Name vorhanden entsprechende Daten zuweisen
  if getIndexFromName(TileName, resultTile.index) then
  begin
    resultTile.name:= TileName;
    resultTile.directions:= UDirections.getDirectionsFromTileName(TileName);
    resultTile.points:= getPoints(TileName);
  end;

  createTile:= resultTile;
end;

{Gibt den Index für einen Stein anhand des Namens zurück
IN: TileName - Name dessen Index benötigt wird
OUT: TileIndex - Index für den Namen
RETURN: True, wenn der Name überhaupt existiert}
function getIndexFromName(TileName: TTileName; var TileIndex: TTileIndex): Boolean;
var
  found: boolean;
begin
  // Initialisierungen
  found:= false;
  TileIndex:= 0;

  // Durchlaufen des Namens Arrays bis Name gefunden oder Ende
  while not(found) and (TileIndex <= TILE_COUNT) do
    if (AnsiCompareStr(ALL_TILES[TileIndex], TileName) = 0) then
      found:= true
    else
      inc(TileIndex);

  getIndexFromName:= found;
end;

{Gibt ein Stein anhand seines Namens zurück
IN: TileName - Name des Steins
RETURN: Entsprechender Stein}
function getTileFromName(TileName: TTileName): TTile;
begin
  getTileFromName:= createTile(TileName);
end;

{Gibt einen Stein anhand seines Indizes zurück
IN: Index - Index des Steins
RETURN: Entsprechender Stein}
function getTileFromIndex(Index: TTileIndex): TTile;
begin
  getTileFromIndex:= createTile(ALL_TILES[Index]);
end;

{Gibt an ob ein Stein Sack leer ist
IN: TileSack - Der Sack der überprüft werden soll
RETURN: True, wenn der Sack leer ist}
function isTileSackEmpty(TileSack: TTileIndexSack): Boolean;
begin
  isTileSackEmpty:= TileSack = [];
end;

{Gibt einen zufälligen Stein, der sich noch im angegebenen Sack befindet, zurück
IN: TileSack - Der Sack aus dem der zufällige Stein gesucht werden soll
RETURN: Den zufälligen Stein aus dem Sack}
function getRdmTileFromSack(TileSack: TTileIndexSack): TTile;
var
  randomTileIndex: TTileIndex;
begin
  // Suche zufälligen Index bis einer gefunden wurde,
  // der sich noch im Sack befindet
  repeat
    randomTileIndex:= random(TILE_COUNT)+1;
  until (randomTileIndex in TileSack);

  getRdmTileFromSack:= getTileFromIndex(randomTileIndex);
end;



end.
