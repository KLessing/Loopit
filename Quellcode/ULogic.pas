{------------------------------------------------------------------------------
Zust�ndig f�r die Logik des Programms. Enth�lt haupts�chlich Funktionen zum
aktuellen Zug, verkn�pft mit den Spielfeld, Spieler, Selektion und Stein Units.

Autor: Kevin Lessing , 27.09.2017
------------------------------------------------------------------------------}
unit ULogic;

interface

uses UTypes;

  { --- Getter --- }
  function getMoveCount: TMoveCount;
  function getCurrentMovePoints(Index: TMoveDetailIndex): Word;
  function getCurrentMoveTileIndex: TMoveTileIndex;
  function getCurrentMoveTiles: TMoveTiles;
  function getCurrentMoveDetails: TMoveDetails;
  function getMoveTile(MoveTileIndex: TMoveTileIndex): TTile;
  function getMoveTileName(MoveTileIndex: TMoveTileIndex): TTileName;
  function getMoveTileIndexFromTileName(TileName: TTileName; var MoveTileIndex: TMoveTileIndex): Boolean;

  { --- Setter --- }
  procedure setMoveTileOnField(MoveTileIndex: TMoveTileIndex; Row: TRow; Col: TCol);
  procedure setMoveTile(MoveTileIndex: TMoveTileIndex; Tile: TTile);
  procedure setFieldTile(Row: TRow; Col: TCol; Tile: TTile);
  procedure setRdmForEmptyMoveTiles;

  { --- Querys --- }
  function isTileInSack(TileIndex: TTileIndex): Boolean;
  function isMoveTileEmpty(Index: TMoveTileIndex): Boolean;
  function wasTileAlreadyMoved(MoveTileIndex: TMoveTileIndex): Boolean;
  function isDepositAllowed(MoveTileIndex: TMoveTileIndex; Row: TRow; Col: TCol): Boolean;
  function isACurrentMovePossible: Boolean;
  function isMoveFromSackPossible: Boolean;

  { --- Other --- }
  function trySelection(MoveTileIndex: TMoveTileIndex; var Selection: Boolean): Boolean;
  procedure resetLastMove;
  procedure resetCurrentMoves;
  procedure endMove;
  procedure endGame;
  procedure newGame;

implementation

uses UGameField, UPlayer, UTileSelection, UTiles, System.SysUtils;

var
  // Der Sack mit den Steinen ist eine Menge mit den Indizes aller Steine
  TileSack: TTileIndexSack;

  // Die Steine des derzeitigen Zuges, die sich auf der Bank befinden
  CurrentMoveTiles: TMoveTiles;

  // Anzahl der Ablagen des aktuellen Zuges sowie globaler Z�hler f�r den
  // Speicherverbauch des dynamischen Arrays
  MoveCount: TMoveCount;
  // Dynamisches Array zur Verwaltung der Details des aktuellen Zuges
  CurrentMoveDetails: TMoveDetails;

{$REGION 'Debug'}
{Schreibt die Indizes der noch im Sack enthaltenen Steine in die Konsole}
procedure debugTileSack;
var
  index: TTileIndex;
begin
  for index in TileSack do
    writeln(index);
end;

{Schreibt die gesetzten Bank Indizes des aktuellen Zuges in die Konsole}
procedure debugCurrentMoveDetails;
var
  index: TMoveDetailIndex;
begin
  index:= 0;
  while index < MoveCount do
  begin
    writeln(index, ': ', CurrentMoveDetails[index].moveTileIndex);
    inc(index);
  end;
end;
{$ENDREGION}

{$REGION 'Getter'}
{Gibt den Index des zuletzt gesetzten Steins auf der Bank zur�ck
PRE: Es muss bereits eine Ablage im aktuellen Zug stattgefunden haben
RETURN: Index des zuletzt gesetzten Steins auf der Bank}
function getCurrentMoveTileIndex: TMoveTileIndex;
begin
  assert(MoveCount > 0);
  getCurrentMoveTileIndex:= CurrentMoveDetails[MoveCount-1].moveTileIndex;
end;

{Gibt das gesamte Array der Steine zur�ck,
die sich derzeit auf der Bank befinden}
function getCurrentMoveTiles: TMoveTiles;
begin
  getCurrentMoveTiles:= CurrentMoveTiles;
end;

{Gibt das gesamte Array der Details des aktuellen Zugs zur�ck}
function getCurrentMoveDetails: TMoveDetails;
begin
  getCurrentMoveDetails:= CurrentMoveDetails;
end;

{Gibt einen bestimmten auf der Bank befindlichen Stein zur�ck
IN: MoveTileIndex: Bank Index des Steins}
function getMoveTile(MoveTileIndex: TMoveTileIndex): TTile;
begin
  getMoveTile:= CurrentMoveTiles[MoveTileIndex];
end;

{Gibt die Anzahl der Ablagen des aktuellen Zuges zur�ck}
function getMoveCount: TMoveCount;
begin
  getMoveCount:= MoveCount;
end;

{Gibt die Punkte einer bestimmten Ablage des aktuellen Zuges zur�ck
IN: Index - Index der Ablage, dessen Punkte zru�ckgegeben werden sollen
PRE: Index muss kleiner sein als die Anzahl der bereits get�tigten Ablagen}
function getCurrentMovePoints(Index: TMoveDetailIndex): Word;
begin
  assert(Index < MoveCount);
  getCurrentMovePoints:= CurrentMoveDetails[Index].points;
end;

{Gibt den Namen eines bestimmten auf der Bank befindlichen Steins zur�ck
IN: MoveTileIndex - Bank Index des Steins}
function getMoveTileName(MoveTileIndex: TMoveTileIndex): TTileName;
begin
  getMoveTileName:= CurrentMoveTiles[MoveTileIndex].name;
end;

{Sucht einen Stein Namen auf der Bank und gibt den Index des Steins f�r die Bank
zur�ck und ob der Stein �berhaupt auf der Bank enthalten ist
IN: TileName - Name des gesuchten Steins
OUT: MoveTileIndex - Bank Index des Steins
Return: True, wenn der Stein auf der Bank enthalten ist}
function getMoveTileIndexFromTileName(TileName: TTileName; var MoveTileIndex: TMoveTileIndex): Boolean;
var
  indexRunner: TMoveTileIndex;
  found: Boolean;
begin
  // Initialisierung
  found:= false;
  // Bank Pl�tze durchlaufen
  for indexRunner := Low(TMoveTileIndex) to High(TMoveTileIndex) do
    // Namen vergleichen
    if CurrentMoveTiles[indexRunner].name = TileName then
    begin
      // Wenn gefunden dann setzen
      MoveTileIndex:= indexRunner;
      found:= true;
    end;
  getMoveTileIndexFromTileName:= found;
end;
{$ENDREGION}

{$REGION 'Setter'}
{Setzen der Details einer Ablage in einem Zug
IN: TileIndex - Bank Index des Steins auf der Bank der gesetzt wurde
IN: Points - Punkte die durch diese Ablage erzielt wurden
IN: Row, Col - Position der Ablage auf dem Spielfeld
PRE: Die maximale Anzahl von Z�gen darf noch nicht erreicht sein}
procedure setCurrentMoveDetail(TileIndex: TMoveTileIndex; Points: Byte; Row: TRow; Col: TCol);
begin
  assert(MoveCount < MAX_MOVE_COUNT);

  // L�nge des Dynamischen Arrays erh�hen
  SetLength(CurrentMoveDetails, MoveCount+1);

  // Zuweisungen
  CurrentMoveDetails[MoveCount].moveTileIndex:= TileIndex;
  CurrentMoveDetails[MoveCount].points:= Points;
  CurrentMoveDetails[MoveCount].row:= Row;
  CurrentMoveDetails[MoveCount].col:= Col;

  // Anzahl der get�tigten Z�ge erh�hen
  inc(MoveCount);
end;

{Setzt einen Stein von der Bank auf das Spielfeld
IN: MoveTileIndex - Bank Index des Steins
IN: Row, Col - Ablageposition auf dem Spielfeld}
procedure setMoveTileOnField(MoveTileIndex: TMoveTileIndex; Row: TRow; Col: TCol);
begin
  // Setze Stein aufs Spielfeld
  UGameField.setTileOnField(CurrentMoveTiles[MoveTileIndex], Row, Col);

  // Speicher Details des Zuges
  SetLength(CurrentMoveDetails, MoveCount+1);
  setCurrentMoveDetail(MoveTileIndex,
                       UGameField.calcDepositPoints(CurrentMoveTiles[MoveTileIndex], Row, Col),
                       Row, Col);

  // Deaktiviere Selektions Sperre
  UTileSelection.deactivateSelectionLock;
end;

{Setzt einen Stein auf das Feld und entfernt diesen aus dem Sack
IN: Row, Col - Ablageposition auf dem Spielfeld
IN: Tile - Stein der aufs Spielfeld gesetzt werden soll}
procedure setFieldTile(Row: TRow; Col: TCol; Tile: TTile);
begin
  UGameField.setTileOnField(Tile, Row, Col);
  TileSack:= TileSack - [Tile.index];
end;

{Setzt einen Stein auf die Bank und entfern diesen aus dem Sack
IN: MoveTileIndex - Index auf der Bank auf den der Stein gesetzt werden soll
IN: Tile - Entprechender Stein der auf die Bank gesetzt werden soll}
procedure setMoveTile(MoveTileIndex: TMoveTileIndex; Tile: TTile);
begin
  CurrentMoveTiles[MoveTileIndex]:= Tile;
  TileSack:= TileSack - [Tile.index];
end;

{F�llt leere Bankpl�tze mit zuf�lligen Steinen aus dem Sack, wenn noch Steine
im Sack vorhanden sind. Die Steine werden dabei aus dem Sack entfernt.}
procedure setRdmForEmptyMoveTiles;
var
  index: TMoveTileIndex;
begin
  // Durchlaufen aller Bank Pl�tze
  for index := Low(TMoveTileIndex) to High(TMoveTileIndex) do
  begin
    // Ist der Bank Platz leer und sind noch Steine im Sack?
    if (CurrentMoveTiles[index].index = 0) and
       not(UTiles.isTileSackEmpty(TileSack)) then
      // Zuf�lligen Stein auf den Bank Platz setzen
      setMoveTile(index, UTiles.getRdmTileFromSack(TileSack));
  end;
end;
{$ENDREGION}

{$REGION 'Querys'}
{Gibt zur�ck, ob ein Index auf der Bank leer ist,
also auf den leeren Stein Index verweist.
IN: Index, der �berpr�ft werden soll
RETURN: True, wenn Bank Platz leer}
function isMoveTileEmpty(Index: TMoveTileIndex): Boolean;
begin
  isMoveTileEmpty:= CurrentMoveTiles[Index].index = 0;
end;

{Gibt zur�ck, ob sich ein bestimmter Stein Index noch im Sack befindet
IN: TileIndex: Index des zu �berpr�fenden Steins
RETURN: True, wenn Stein noch im Sack}
function isTileInSack(TileIndex: TTileIndex): Boolean;
begin
  isTileInSack:= TileIndex in TileSack;
end;

{�berpr�ft alle Felder des Spielfeldes, ob ein bestimmter Stein
auf mindestens einem Feld abgelegt werden kann
IN: Tile: Der Stein der �berpr�ft werden soll
RETURN: True, wenn Steinablage m�glich}
function isMoveWithTilePossible(Tile: TTile): Boolean;
var
  possibleMoveFound: Boolean;
  rowRunner: Low(TRow)..High(TRow)+1;
  colRunner: Low(TCol)..High(TCol)+1;
begin
  // Initialisierungen
  possibleMoveFound:= false;
  rowRunner:= 0;

  // Durchlaufen aller Reihen bis gefunden oder Ende
  while not(possibleMoveFound) and (rowRunner < ROW_COUNT) do
  begin
    // Spalte wieder auf Anfang setzen
    colRunner:= 0;
    // Durchlaufen aller Spalten bis gefunden oder Ende
    while not(possibleMoveFound) and (colRunner < COL_COUNT) do
    begin
      possibleMoveFound:= UGameField.isFieldEmpty(rowRunner, colRunner) and
                          UGameField.checkFieldValidity(Tile, rowRunner, colRunner);
      inc(colRunner);
    end;
    inc(rowRunner);
  end;

  isMoveWithTilePossible:= possibleMoveFound;
end;

{�berpr�ft f�r jeden Stein auf der Bank, jedes Feld, ob eine Ablage m�glich ist
RETURN: True, wenn Ablage m�glich}
function isACurrentMovePossible: Boolean;
var
  possibleMoveFound: Boolean;
  moveTileRunner: 0..MOVE_TILE_COUNT;
begin
  // Initialisierungen
  possibleMoveFound:= false;
  moveTileRunner:= 0;

  // Durchlaufen aller Pl�tze auf der Bank bis gefunden oder Ende
  while not(possibleMoveFound) and (moveTileRunner < MOVE_TILE_COUNT) do
  begin
    // Alle Felder f�r den jeweiligen Stein pr�fen
    possibleMoveFound:= isMoveWithTilePossible(CurrentMoveTiles[moveTileRunner]);
    // N�chster Stein
    inc(moveTileRunner);
  end;

  isACurrentMovePossible:= possibleMoveFound;
end;

{�berpr�ft f�r jeden Stein, der sich noch im Sack befindet, jedes Feld, ob eine
Ablage m�glich ist. (Muss nur gepr�ft werden, wenn kein aktueller Zug m�glich ist)
RETURN: True, wenn Ablage m�glich}
function isMoveFromSackPossible: Boolean;
var
  possibleMoveFound: Boolean;
  indexRunner: TTileIndex;
begin
  // Initialisierungen
  possibleMoveFound:= false;
  indexRunner:= 0;

  // Durchlaufen aller Steine bis gefunden oder Ende
  while not(possibleMoveFound) and (indexRunner < TILE_COUNT) do
  begin
    // Befindet sich der aktuelle Stein noch im Sack?
    if indexRunner in TileSack then
      // Alle Felder f�r den jeweiligen Stein pr�fen
      possibleMoveFound:= isMoveWithTilePossible(UTiles.getTileFromIndex(indexRunner));
    // N�chster Stein
    inc(indexRunner);
  end;

  isMoveFromSackPossible:= possibleMoveFound;
end;

{�berpr�ft, ob ein bestimmter Stein auf der Bank im aktuellen Zug auf das
Spielfeld abgelegt wurde
IN: MoveTileIndex - Index des Steins auf der Bank, der �berpr�ft werden soll
Return: True, wenn der Stein im aktuellen Zug abgelegt wurde}
function wasTileAlreadyMoved(MoveTileIndex: TMoveTileIndex): Boolean;
var
  moveDetailIndex: TMoveCount;
  found: Boolean;
begin
  // Initialisierungen
  found:= false;
  moveDetailIndex:= 0;

  // Durchlaufen aller Details des aktuellen Zuges bis gefunden oder Ende
  while not(found) and (moveDetailIndex < MoveCount) do
  begin
    // �berpr�fen ob der Stein abgelegt wurde
    //(ob er sich in den Zug Details befindet)
    found:= CurrentMoveDetails[moveDetailIndex].moveTileIndex = MoveTileIndex;
    // Details der n�chsten Ablage des Zuges
    inc(moveDetailIndex);
  end;

  wasTileAlreadyMoved:= found;
end;

{�berpr�ft, ob das Ablegen eines Steines auf einer bestimmten Spielfeld Position
erlaubt ist.
IN: MoveTileIndex - Bank Index des Steins
IN: Row, Col - Ablageposition, die �berpr�ft werden soll
Return: True, wenn die Ablage des Steins an der Position erlaubt ist}
function isDepositAllowed(MoveTileIndex: TMoveTileIndex; Row: TRow; Col: TCol): Boolean;
begin
  isDepositAllowed:= // Maximale Ablage Anzahl erreicht?
                     (MoveCount < MAX_MOVE_COUNT) and
                     // Wurde der Stein im aktuellen Zug schon abgelegt?
                     not(wasTileAlreadyMoved(MoveTileIndex)) and
                     // Ist das Feld leer?
                     UGameField.isFieldEmpty(Row, Col) and
                     // Ist eine Ablage auf dem Feld erlaubt?
                     UGameField.checkFieldValidity(CurrentMoveTiles[MoveTileIndex], Row, Col);
end;
{$ENDREGION}

{$REGION 'Other'}
{Selektiert oder deselektiert einen Stein auf der Bank, wenn m�glich.
Gibt zur�ck, ob Selektion bzw Deselektion m�glich war und was ausgef�hrt wurde.
IN: MoveTileIndex - Index des zu (de)selektierenden Steins auf der Bank
OUT: Selection - True, wenn selektiert wurde
                 False, wenn deselektiert wurde
RETURN: TRUE, wenn Selektion bzw. Deselektion erfolgen konnte}
function trySelection(MoveTileIndex: TMoveTileIndex; var Selection: Boolean): Boolean;
var
  success: Boolean;
begin
  // Keine Selektion m�glich, wenn der Stein bereits gesetzt wurde
  // oder die maximale Anzahl an Z�gen bereits erreicht wurde
  if not(wasTileAlreadyMoved(MoveTileIndex)) and
     (getMoveCount < MAX_MOVE_COUNT) then
  begin
    // Selektion durchf�hren
    Selection:= UTileSelection.makeSelection(MoveTileIndex);
    success:= true;
  end
  else
    success:= false;

  trySelection:= success;
end;

{Packt die Steine, die sich auf der Bank befinden und nicht im aktuellen Zug
gesetzt wurden, zur�ck in den Sack.}
procedure returnNotUsedTilesToSack;
var
  settedTiles: TTileIndexSack;
  moveIndexRunner: TMoveDetailIndex;
  tileIndexRunner: TMoveTileIndex;
  moveTileIndex: TMoveTileIndex;
begin
  // Gesetzte Tiles leer initialisieren
  settedTiles:= [];

  // Menge aus gesetzen Tiles herausfiltern
  // Wenn �berhaupt eine Ablage erfolgt ist
  if MoveCount > 0 then
    // Durchlaufen aller Ablage Details des Zuges
    for moveIndexRunner := 0 to MoveCount-1 do
    begin
      // Bank Index des Steins der entprechenden Ablage
      moveTileIndex:= CurrentMoveDetails[moveIndexRunner].moveTileIndex;
      // Menge der gesetzten Steine hinzuf�gen
      settedTiles:= settedTiles +
                    [CurrentMoveTiles[moveTileIndex].index];
    end;

  // Alle Steine, die nicht gesetzt wurden in TileSack zur�ck:
  // Durchlaufen aller Steine auf der Bank
  for tileIndexRunner := Low(TMoveTileIndex) to High(TMoveTileIndex) do
    // Wenn der Stein nicht gesetzt wurde und der Platz auf der Bank nicht leer ist
    if not(CurrentMoveTiles[tileIndexRunner].index in settedTiles) and
       (CurrentMoveTiles[tileIndexRunner].index <> 0)  then
      // Stein zur�ck in den Sack
      TileSack := TileSack + [CurrentMoveTiles[tileIndexRunner].index];
end;

{Zur�cksetzen der letzten Ablage
PRE: Es muss eine Ablage erfolgt sein}
procedure resetLastMove;
begin
  assert(MoveCount > 0);

  // Stein vom Spielfeld entfernen
  UGameField.removeTileFromField(CurrentMoveDetails[MoveCount-1].row,
                                 CurrentMoveDetails[MoveCount-1].col);
  // Anzahl der gemachten Ablagen f�r den Zug verringern
  dec(MoveCount);
  // L�nge des dynamischen Zug Details Arrays anpassen
  // (Und Details des letzten Zuges dabei verwerfen)
  SetLength(CurrentMoveDetails, MoveCount);
end;

{Zur�cksetzen des gesamten Zuges. (Alle Steine, die in diesem Zug gelegt wurden,
werden vom Spielfeld genommen)}
procedure resetCurrentMoves;
begin
  // Alle Ablagen zur�cksetzen
  while MoveCount > 0 do
    resetLastMove;
end;

{Zur�cksetzen der Details des letzten Zuges}
procedure resetMoveDetails;
var
  moveTileIndex: TMoveTileIndex;
begin
  // Zug Anzahl zur�cksetzen
  MoveCount:= 0;

  // Steine von der Bank zur�cksetzen
  for moveTileIndex := Low(TMoveTileIndex) to High(TMoveTileIndex) do
    FillChar(CurrentMoveTiles[moveTileIndex], SizeOf(TTile), 0);

  // Details des Zuges zur�cksetzen
  SetLength(CurrentMoveDetails, MoveCount);
end;

{Beenden eines Zuges}
procedure endMove;
begin
  // Aktualisieren der Punkte Anzahl des letzen Spielers
  UPlayer.updateCurrentPlayerPoints(CurrentMoveDetails, MoveCount);
  // Nicht genutzte Steine in den Sack zur�ck
  returnNotUsedTilesToSack;
  // Zug Details zur�cksetzen
  resetMoveDetails;
  // N�chster Spieler ist am Zug
  UPlayer.setNextPlayer;
end;

{Beenden des gesamten Spiels
Leere Initialiserungen
inkl. Speicherfreigabe}
procedure endGame;
begin
  // Spieler zur�cksetzen
  UPlayer.destroy;

  // Spielfeld zur�cksetzen
  UGameField.clearGameField;

  // Zug Details zur�cksetzen
  resetMoveDetails;

  // Sack mit allen Steinen f�llen (0 ist f�r empty reserviert, also kein Stein)
  TileSack:= [1..TILE_COUNT];

  // Keine aktive Selektion
  UTileSelection.deactivateSelectionLock;
end;

{Vorbereitungen f�r ein neues Spiels
Auslosung des Beginners und des Steins in der Mitte}
procedure newGame;
var
  firstTile: TTile;
  firstPlayerIndex: TPlayerIndex;
begin
  // Hole zuf�lligen ersten Stein aus dem Sack
  firstTile:= UTiles.getRdmTileFromSack(TileSack);
  TileSack:= TileSack - [firstTile.index];
  // Setze den Stein in die Mitte des Spielfeldes
  UGameField.setTileOnField(firstTile, 5, 5);

  // Setze den zuf�lligen ersten Spieler
  firstPlayerIndex:= random(UPlayer.getPlayerCount);
  UPlayer.setActivePlayer(firstPlayerIndex);
end;
{$ENDREGION}

initialization

finalization
 Assert (MoveCount = 0, 'Speicherverwaltung in der ULogic Unit unsauber. ' +
                        'Z�hlerstand: ' +
                        IntToStr(MoveCount));


end.
