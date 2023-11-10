{------------------------------------------------------------------------------
Zuständig für die Verarbeitung von Richtungen. Zum einen zum Initialisieren
der offenen Richtigungen anhand eines Stein Namens. Enthält zudem auch weitere
nützliche Hilfsfunktionen für Richtungen.

Autor: Kevin Lessing , 24.09.2017
------------------------------------------------------------------------------}
unit UDirections;

interface

uses UDirectionTypes, UTypes, SysUtils;

function getDirectionsFromTileName(TileName: TTileName): TDirections;
function getOppositeDirection(Direction: TDirection): TDirection;
function getNextDirection(Tile: TTile; Origin: TDirection; var Next: TDirection): Boolean;
function getNextCoords(Direction: TDirection; var Row: TRow; var Col: TCol): Boolean;

implementation

{Berechnet die gegenüberliegende Richtung
IN:   Direction - die Richtung
RETURN: die gegenüberliegende Richtung}
function getOppositeDirection(Direction: TDirection): TDirection;
begin
  getOppositeDirection:= TDirection((ord(Direction) + 2) mod 4);
end;

{Zuordnung von SteinNamen zu zwei offenen Weg Richtungen
IN: TileName - Der Name, dessen Richtungen benötigt werden
RETURN: Menge mit den zwei offenen Richtungen für den entsprechenden TileNamen}
function getTwoWayDirections(TileName: TTileName): TDirections;
var
  resultDirections: TDirections;
  direction: TDirection;
  trueDirectionsCount: Byte;
begin
  // Initialisiere leere Richtungsmenge
  resultDirections:= [];
  trueDirectionsCount:= 0;
  direction := Low(TDirection);

  // Suche nach den beiden offenen Richtungen und setze diese
  repeat
    if StrToInt(TileName[1]) in TWO_WAYS[StrToInt(TileName[3]), direction] then
    begin
      resultDirections:= resultDirections + [direction];
      inc(trueDirectionsCount);
    end;
    if direction < High(TDirection) then
      inc(direction);
  until trueDirectionsCount = 2;

  getTwoWayDirections:= resultDirections;
end;

{Zuordnung von SteinNamen zu drei offenen Weg Richtungen
IN: TileName - Der Name, dessen Richtungen benötigt werden
RETURN: Menge mit den drei offenen Richtungen für den entsprechenden TileNamen}
function getThreeWayDirections(TileName: TTileName): TDirections;
var
  resultDirections: TDirections;
  direction: TDirection;
  falseDirectionFound: Boolean;
begin
  // Initialisiere volle Richtungsmenge
  resultDirections:= [low(TDirection)..high(TDirection)];
  falseDirectionFound:= false;
  direction := Low(TDirection);

  // Suche nach der verperrten Richtung
  repeat
    if StrToInt(TileName[1]) in THREE_WAYS[StrToInt(TileName[3]), direction] then
      falseDirectionFound:= true
    else
      inc(direction);
  until falseDirectionFound;

  // Entferne die versperrte Richtung
  resultDirections:= resultDirections - [direction];

  getThreeWayDirections:= resultDirections;
end;

{Zuordnung von TileName zur Menge der offenen Wege
IN: TileName - Der Name, dessen Richtungen benötigt werden
RETURN: Die offenen Richtungen für den entsprechenden TileNamen}
function getDirectionsFromTileName(TileName: TTileName): TDirections;
var
  resultDirections: TDirections;
begin
  case TileName[2] of
    '2': resultDirections:= getTwoWayDirections(TileName);
    '3': resultDirections:= getThreeWayDirections(TileName);
    '4': resultDirections:= [low(TDirection)..high(TDirection)];
  end;
  getDirectionsFromTileName:= resultDirections;
end;



{Ermittelt die andere Richtung einer Menge,
die sich nicht in der anderen Menge befindet
IN: NotThese - Richtungen, die aus der anderen Menge entfernt werden soll
IN: FromThese - Richtungen, aus die die andere Menge entfernt werden soll
RETURN: Die erste Richtung, die nicht in der Menge der anderen Richtungen ist}
function getOtherDirection(NotThese, FromThese: TDirections): TDirection;
var
  nextSet: TDirections;
  nextElement, resultDirection: TDirection;
begin
  // Init
  resultDirection:= low(TDirection);

  // Richtungen entfernen
  nextSet:= FromThese - NotThese;

  // Übrig gebliebene Richtung ist das Ergebnis
  for nextElement in nextSet do
    resultDirection:= nextElement;

  getOtherDirection:= resultDirection;
end;

{Ermittelt die Richtung, in die die Loop fortgesetzt wird
IN: Tile - Der Stein, dessen nächste Richtung benötigt wird
IN: Origin - Die Ursprungsrichtung, von der die Loop kommt
OUT: Next - Die nächste Richtung, in die die Loop geht
RETURN: True, wenn die Loop fortgesetzt wird}
function getNextDirection(Tile: TTile; Origin: TDirection; var Next: TDirection): Boolean;
var
  hasNext: Boolean;
  noWay, endWay: TDirection;
begin
  // Gehe davon aus, dass es keine Fortsetzung gibt (= Kreuzung oder Sackgasse)
  hasNext:= false;

  // Bei zwei Wegen wird die Loop in die andere als die Urpsrungs Richtung fortgesetzt
  if Tile.name[2] = '2' then
  begin
    hasNext:= true;
    Next:= getOtherDirection([Origin], Tile.directions);
  end
  // Bei 8 Punkte Steinen gibt es eine Sackgasse und eine Fortsetzung
  else if Tile.name[1] = '8' then
  begin
    // Ermittel zuerst die Richtung, in die kein Weg weiterführt
    noWay:= getOtherDirection(Tile.directions, [Low(TDirection)..High(TDirection)]);
    // Die Sackgasse liegt gegenüber
    endWay:= getOppositeDirection(noWay);
    // Wenn der Urprung nicht die Sackgasse ist
    // wird die Loop in die Gegenüberliegende Richtung fortgesetzt
    if not(Origin = endWay) then
    begin
      hasNext:= true;
      Next:= getOppositeDirection(Origin);
    end;
  end;

  getNextDirection:= hasNext;
end;

{Ermittelt die Koordinaten des Nachbarfeldes
IN: Direction - Die Richtung zum Nachbarfeld
IN/OUT: Row - Die Reihe des Feldes rein, Nachbarfeld Reihe raus
IN/OUT: Col - Die Spalte des Feldes rein, Nachbarfeld Spalte raus
RETURN: True, wenn Nachbarfeld vorhanden}
function getNextCoords(Direction: TDirection; var Row: TRow; var Col: TCol): Boolean;
var
  neighbourAvailable: Boolean;
begin
  neighbourAvailable:= true;
  case Direction of
    dirNorth: if Row > Low(TRow) then dec(Row) else neighbourAvailable:= false;
    dirEeast: if Col < High(TCol) then inc(Col) else neighbourAvailable:= false;
    dirSouth: if Row < High(TRow) then inc(Row) else neighbourAvailable:= false;
    dirWest:  if Col > Low(TCol) then dec(Col) else neighbourAvailable:= false;
  end;
  getNextCoords:= neighbourAvailable;
end;


end.
