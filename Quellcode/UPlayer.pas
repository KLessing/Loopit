{------------------------------------------------------------------------------
Zuständig für die Verarbeitung der Spieler. Enthält globale Variablen für die
aktuellen Spieler sowie die Anzahl der Spieler und den Index des Spielers der
am Zug ist. Zusätzlich wird hier die Punkteberechnung für die Spieler durchgeführt
und ein Gewinner ermittelt.

Autor: Kevin Lessing , 14.10.2017
------------------------------------------------------------------------------}
unit UPlayer;

interface

uses UTypes;

  { --- Getter --- }
  function getPlayer(index: TPlayerIndex): TPlayer;
  function getCurrentPlayer: TPlayer;
  function getCurrentPlayerIndex: TPlayerIndex;
  function getPlayerCount: TPlayerCountRange;
  function getWinnerName: String;
  function getAddedMovePoints(MoveDetails: TMoveDetails; MoveCount: TMoveCount): TPoints;

  { --- Setter --- }
  procedure updateCurrentPlayerPoints(MoveDetails: TMoveDetails; MoveCount: TMoveCount);
  procedure setPlayer(Name: string; PlayerType: TPlayerType; Points: TPoints);
  procedure setActivePlayer(Index: TPlayerIndex);
  procedure setNextPlayer;

  { --- Other --- }
  function comparePlayerWithCurrent(Player: TPlayer): Boolean;
  procedure destroy;

implementation

uses System.SysUtils;

var
  // Index des Spielers, der am Zug ist
  CurrentPlayerIndex: TPlayerIndex;
  // Anzahl der Spieler sowie globaler Zähler für den Speicherverbrauch
  PlayerCount: TPlayerCountRange;
  // Spieler Daten in Form eines dynamischen Arrays
  Players: TPlayers;

{$REGION 'Getter'}
{Gibt den entsprechenden Spieler zurück
IN: Index - Index des Spielers
RETURN: Spieler}
function getPlayer(index: TPlayerIndex): TPlayer;
begin
  getPlayer:= Players[index];
end;

{Gibt den aktuellen Spieler zurück
RETURN: Aktueller Spieler}
function getCurrentPlayer: TPlayer;
begin
  getCurrentPlayer:= Players[CurrentPlayerIndex];
end;

{Gibt den Index des aktuellen Spielers zurück
{RETURN: Index des aktuellen Spielers}
function getCurrentPlayerIndex: TPlayerIndex;
begin
  getCurrentPlayerIndex:= CurrentPlayerIndex;
end;

{Gibt die Anzahl der Spieler zurück
RETURN: Anzahl der Spieler}
function getPlayerCount: TPlayerCountRange;
begin
  getPlayerCount:= PlayerCount;
end;

{Ermittelt den Gewinner und gibt dessen Namen zurück
RETURN: Name des Gewinners}
function getWinnerName: String;
var
  playerIndex: TPlayerIndex;
  maxPoints: Word;
  winner: String;
begin
  // Initialisierungen
  maxPoints:= 0;
  winner:= '';

  // Durchaufen aller Spieler
  for playerIndex := 0 to PlayerCount-1  do
  begin
    // Hat der aktuelle zu prüfende Spieler mehr als vorige höchste Punktzahl?
    if Players[playerIndex].points > maxPoints then
    begin
      // Gewinner überschreiben
      maxPoints:= Players[playerIndex].points;
      winner:= Players[playerIndex].name;
    end
    else
    // Gleichstand?
    if (Players[playerIndex].points = maxPoints) and
       (maxPoints > 0) then
      // Die Spieler "teilen" sich den Sieg
      winner:= winner + ' und ' + Players[playerIndex].name;
  end;

  getWinnerName:= winner;
end;

{Addiert Ablage Punkte für einen Zug
IN: MoveDetails - Enthält Details für den Zug inkl. einzelne Punkte der Ablagen
IN: MoveCount - Anzahl der Ablagen in diesen Zug
RETURN: Addierte Punkte}
function getAddedMovePoints(MoveDetails: TMoveDetails; MoveCount: TMoveCount): TPoints;
var
  moveIndex: TMoveCount;
  resultPoints: Byte;
begin
  resultPoints:= 0;
  moveIndex:= 0;

  // Für alle Ablagen des Zuges
  while moveIndex < MoveCount do
  begin
    // Addieren der Punkte
    Inc(resultPoints, MoveDetails[moveIndex].points);
    // Nächste Ablage
    Inc(moveIndex);
  end;

  getAddedMovePoints:= resultPoints;
end;
{$ENDREGION}

{$Region 'Setter'}
{Addiert die Punkte des aktuellen Zuges zu den Gesamtpunkten des aktuellen Spielers
IN: MoveDetails - Enthält Details für den Zug inkl. einzelne Punkte der Ablagen
IN: MoveCount - Anzahl der Ablagen in diesen Zug}
procedure updateCurrentPlayerPoints(MoveDetails: TMoveDetails; MoveCount: TMoveCount);
begin
  Inc(Players[CurrentPlayerIndex].points,
      getAddedMovePoints(MoveDetails, MoveCount));
end;

{Erstellt einen Spieler und fügt diesen zum Spieler Array hinzu
IN: Name - Name des Spielers
IN: PlayerType - Typ des Spielers (Mensch oder KI)
IN: Points - Punkte des Spielers}
procedure setPlayer(Name: string; PlayerType: TPlayerType; Points: TPoints);
begin
  assert(PlayerCount < MAX_PLAYER_COUNT);
  SetLength(Players, PlayerCount+1);
  Players[PlayerCount].playerType:= PlayerType;
  Players[PlayerCount].name:= Name;
  Players[PlayerCount].points:= Points;
  inc(PlayerCount);
end;

{Setzt einen Spieler als aktiven Spieler, also der Spieler der gerade am Zug ist
IN: Index - Index des entprechenden Spielers
PRE: Index darf nicht höher sein als die Anzahl der Spieler}
procedure setActivePlayer(Index: TPlayerIndex);
begin
  assert(Index <= PlayerCount);
  CurrentPlayerIndex:= Index;
end;

{Setzt den nächste Spieler als aktiven Spieler, also den Spieler der am Zug ist}
procedure setNextPlayer;
begin
  // Wenn noch nicht der letzte Spieler am Zug war
  if CurrentPlayerIndex < PlayerCount-1 then
    // Setze den Spielerindex einen weiter
    inc(CurrentPlayerIndex)
  else
    // Sonst fange wieder von vorne an
    CurrentPlayerIndex:= 0;
end;
{$ENDREGION}

{$REGION 'Other'}
{Vergleicht einen Spieler mit den aktuellen Spieler
IN: Player - Spieler, der verglichen werden soll
RETURN: True, wenn Spieler und aktueller Spieler identisch}
function comparePlayerWithCurrent(Player: TPlayer): Boolean;
begin
  comparePlayerWithCurrent:= (CurrentPlayerIndex < PlayerCount) and
                             (Player.playerType = Players[CurrentPlayerIndex].playerType) and
                             (Player.name = Players[CurrentPlayerIndex].name) and
                             (Player.points = Players[CurrentPlayerIndex].points);
end;

{Spieler Array zurücksetzen}
procedure destroy;
begin
  PlayerCount:= 0;
  SetLength(Players, PlayerCount);
end;
{$ENDREGION}

initialization

finalization
 Assert (PlayerCount = 0, 'Speicherverwaltung in der UPlayer Unit unsauber. ' +
                          'Zählerstand: ' +
                          IntToStr(PlayerCount-1));


end.
