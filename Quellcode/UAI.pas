{------------------------------------------------------------------------------
Zust�ndig f�r die Bestimmung der KI Z�ge. Es wird der Bestm�gliche n�chste Zug
(Punkte und Position) ermittelt, der dann in der Main Unit dargestellt wird.

Autor: Kevin Lessing , 13.10.2017
------------------------------------------------------------------------------}
unit UAI;

interface

uses UTypes;

function getBestMove(var BestIndex: TMoveTileIndex; var BestRow: TRow; var BestCol: TCol): Boolean;

implementation

uses ULogic, UGameField;

{Ermittlung der besten Ablagem�glichkeit eines Steins auf dem aktuellen Spielfeld
IN: Tile - Der Stein f�r den die Beste Ablage ermittelt werden soll
OUT: Points - Die Punkte der besten Ablage
OUT: Row, Col - Position der besten Ablage auf dem Feld
GLOBAL: GET UGameField.isFieldEmpty - Ist das Feld leer?
        GET UGameField.checkFieldValidity - Ist eine Ablage m�glich?
        GET UGameField.calcDepositPoints - Punktberechnung f�r den Zug
RETURN: True, wenn �berhaupt eine Ablage m�glich ist}
function getBestMoveForTile(Tile: TTile; var Points: TPoints; var Row:TRow; var Col: TCol): Boolean;
var
  rowRunner: TRow;
  colRunner: TCol;
  movePossible: Boolean;
  currentPoints: TPoints;
begin
  // Initialisierungen
  movePossible:= false;
  Points:= 0;

  // Gesamtes Spielfeld durchlaufen
  for rowRunner := Low(TRow) to High(TRow) do
    for colRunner := Low(TCol) to High(TCol) do
    begin
      // Ist eine Ablage auf dem Feld m�glich?
      if  UGameField.isFieldEmpty(rowRunner, colRunner) and
          UGameField.checkFieldValidity(Tile, rowRunner, colRunner) then
      begin
        // Punkte berechnen
        currentPoints:= UGameField.calcDepositPoints(Tile, rowRunner, colRunner);
        // Sind die gerade berechneten Punkt h�her als die vorigen?
        if currentPoints > Points then
        begin
          // Neue Beste Werte zuweisen
          Points:= currentPoints;
          Row:= rowRunner;
          Col:= colRunner;
        end;
        movePossible:= true;
      end;
    end;

  getBestMoveForTile:= movePossible;
end;

{Ermittlung des Bestm�glichen n�chsten KI Zuges
f�r die noch nicht gesetzen Steine auf der Bank
OUT: BestIndex - Index des besten Steins auf der Bank
OUT: BestRow, BestCol - Reihe und Spalte des Feldes f�r den besten Zug
GLOBAL: GET ULogic.getCurrentmoveTiles - Steine der derzeitigen Bank
        GET ULogic.wasTileAlreadyMoved - Wurde der Stein schon gesetzt?
RETURN: True, wenn Zug m�glich}
function getBestMove(var BestIndex: TMoveTileIndex; var BestRow: TRow; var BestCol: TCol): Boolean;
var
  moveTiles: TMoveTiles;
  foundFirst: Boolean;
  firstIndex, indexRunner: TMoveTileIndex;
  bestPoints, newBestPoints: TPoints;
  newBestRow: TRow;
  newBestCol: TCol;
begin
  // Initialisierungen
  firstIndex:= 0;
  foundFirst:= false;
  moveTiles:= ULogic.getCurrentmoveTiles;

  // Suche den Index des ersten Steins von der Bank,
  // der noch nicht gesetzt wurde und dessen Ablage m�glich ist
  // Gleichzeitig Initialisierung der besten Werte
  while not(foundFirst) and (firstIndex < MOVE_TILE_COUNT-1) do
  begin
    if not(ULogic.wasTileAlreadyMoved(firstIndex)) then
      foundFirst:= getBestMoveForTile(moveTiles[firstIndex], bestPoints, BestRow, BestCol);
    if not(foundFirst) then
      inc(firstIndex);
  end;

  // Wenn erster Stein gefunden und dieser nicht der Letzte ist
  if foundFirst and (firstIndex < MOVE_TILE_COUNT-1) then
  begin
    // Initialisierung des besten Indizes als ersten gefundenen
    BestIndex:= firstIndex;

    // Vergleiche den ersten gefundenen Stein mit allen folgenden,
    // die noch nicht gesetzt wurden
    for indexRunner := firstIndex+1 to MOVE_TILE_COUNT-1 do
    begin
      if not(ULogic.wasTileAlreadyMoved(indexRunner)) then
      begin
        // W�hle den Stein mit der h�heren Wertigkeit, wenn dessen Ablage m�glich ist
        if (moveTiles[indexRunner].points > moveTiles[BestIndex].points) and
            getBestMoveForTile(moveTiles[indexRunner], newBestPoints, newBestRow, newBestCol) then
        begin
          // �berschreiben der Besten Werte (Wenn die Punktzahl des Steins h�her)
          BestIndex:= indexRunner;
          BestRow:= newBestRow;
          BestCol:= newBestCol;
          bestPoints:= newBestPoints;
        end
        else
        begin
          // Bei gleicher Wertigkeit w�hle gewinnbringendste Ablage
          if (moveTiles[indexRunner].points = moveTiles[BestIndex].points) then
          begin
            if getBestMoveForTile(moveTiles[indexRunner], newBestPoints, newBestRow, newBestCol) and
               (newBestPoints > bestPoints) then
            begin
              // �berschreiben der Besten Werte (Wenn die Punktzahl der Ablage h�her)
              BestIndex:= indexRunner;
              BestRow:= newBestRow;
              BestCol:= newBestCol;
              bestPoints:= newBestPoints;
            end;
          end;
        end;
      end;
    end;
  end;

  getBestMove:= foundFirst;
end;

end.
