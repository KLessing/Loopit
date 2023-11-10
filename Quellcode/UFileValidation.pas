{------------------------------------------------------------------------------
Zuständig für die Validierung und Verarbeitung der einzelnen Reihen der
geladenen Spiel Dateien.

Autor: Kevin Lessing , 16.11.2017
------------------------------------------------------------------------------}
unit UFileValidation;

interface

  function processTileRow(CurrentRow: String; LineNumber: Byte): String;
  function processPlayerRow(CurrentRow: String; LineNumber: Byte; var BeginnerIndex: Boolean): String;

implementation

uses UTypes, ULogic, UGameField, UPlayer, UTiles, System.SysUtils;

{Extrahiert die nächste Spalte aus einer Reihe
IN/OUT: Row - Reihe rein, Reihe ohne erste Spalte raus
OUT: Col - Erste Spalte aus der Reihe
RETURN: True, wenn Vorgang erfolgreich (sonst Reihe bereits leer)}
function extractNextCol(var Row: string; var Col: string): Boolean;
var
  success: Boolean;
begin
  // Initialisierungen:
  // Erfolgreich, bis Gegenteil eingetreten
  success:= true;
  // Getrimmte Reihe (Vordere und Hintere Leerzeichen abgeschnitten)
  Row:= trim(Row);

  // solange noch ein Leerzeichen enthalten gibt es min 2 Cols
  if pos(' ', Row) > 0 then
    Col:= Copy(Row, 1, pos(' ', Row)-1)
  // wenn kein Leerzeichen mehr enthalten
  else
    // entweder letzte Col
    if Length(Row) > 0 then
      Col:= Row
    // oder keine Col mehr
    else
      success:= false;

  // Col aus Row entfernen
  Delete(Row, 1, Length(Col));

  extractNextCol:= success;
end;

{Extrahiert den Namen des nächsten Steins aus einer Reihe und validiert diesen.
Bei einem Fehler wird eine aussagekräftige Fehlermeldung zurückgegeben.
IN/OUT: CurrentRow - Reihe rein, Reihe ohne erste Spalte raus
OUT: TileName - Nächster valide Stein Name der Reihe bei Erfolg
IN: LineNumber, ColNumber - Datei Position für aussagekräftige Fehlermeldung
RETURN: Fehlermeldung (Kein Fehler = Leerer String}
function getTileFromRow(var CurrentRow, TileName: String; LineNumber, ColNumber: Byte): String;
var
  errorMessage: String;
  tileIndex: TTileIndex;
begin
  // Initialisierung: (Noch) kein Fehler
  errorMessage:= '';

  // gibt es eine nächste Col?
    if extractNextCol(CurrentRow, TileName) then
    begin
      // bei 0 keine Verarbeitung erforderlich da GameField 0 initialisiert
      // Extra if, da hier keine Fehlermeldung gemacht werden soll
      if (TileName[1] <> '0') then
      begin
        // ist der Name des Steins valide?
        if (Length(TileName) = 3) and
            UTiles.getIndexFromName(TileName, tileIndex) then
        begin
          // Wurde der Stein bereits gesetzt?
          if not(ULogic.isTileInSack(tileIndex)) then
            errorMessage:= 'Mehrfach vorkommender identischer Stein '
                            + TileName;
        end
        else
          errorMessage:= 'Ungültiger Stein ' + TileName
                          + ' in Zeile '      + IntToStr(LineNumber)
                          + ', Spalte '      + IntToStr(colNumber);
      end;
    end
    else
      errorMessage:= 'Zu wenig Angaben in Zeile ' + IntToStr(LineNumber);

  getTileFromRow:= errorMessage;
end;

{Verarbeitung für einen Stein Namen. Setzt den entsprechenden Stein aufs Spielfeld oder auf die Bank.
Anonsten wird eine Fehlermeldung zurückgegeben
IN: TileName - Name des Steins, der verarbeitet werden soll
IN/OUT: HasZero - True, wenn eine 0 auf der Bank enthalten ist
IN: LineNumber, ColNumber: LesePosition in der Datei
RETURN: True, wenn Verarbeitung erfolgreich, sonst Fehlermeldung}
function processTileName(TileName: TTileName; var HasZero: Boolean; LineNumber, ColNumber: Byte): String;
var
  tile: TTile;
  errorMessage: String;
begin
  // Initialisierung: (noch) kein Fehler
  errorMessage:= '';

  // Hole den entsprechenden Stein für den Namen
  tile:= UTiles.getTileFromName(TileName);

  // Spielfeld Reihe?
  if LineNumber <= ROW_COUNT then
  begin
    // Wenn Feld nicht leer
    if TileName <> '0' then
      // Stein auf GameField setzen (-1, da GameField 0 indiziert)
      ULogic.setFieldTile(LineNumber-1, colNumber-1, tile);
  end
  // Sonst Bank Reihe
  else
  begin
    // Ist ein Stein für diesen Bank Platz vorhanden? (Also nicht 0/leer)
    if TileName <> '0' then
    begin
      // War vorher schon eine 0 enthalten?
      if not(HasZero) then
        // Stein auf Bank setzen (-1, da Bank 0 indiziert)
        ULogic.setMoveTile(colNumber-1, tile)
      else
        errorMessage:= 'Nach einem leeren Bank Platz dürfen keine vollen Bank Plätze mehr kommen';

    end
    else
      HasZero:= true;
  end;

  processTileName:= errorMessage;
end;

{Verarbeitung einer Reihe, die ausschließlich Steine enthält (GameField oder Bank)
und gibt eine entsprechende Fehlermeldung zurück.
IN: CurrentRow - Reihe, die ausschließlich Steine enthält
IN: LineNumber - Zeile in der Datei
RETURN: Fehlermeldung (Leerer String = Kein Fehler)}
function processTileRow(CurrentRow: String; LineNumber: Byte): String;
var
  colNumber, maxColNumber: Byte;
  errorMessage, currentTileName, reducedRow: String;
  hasZero: Boolean;
begin
  // Initialisierungen:
  // (Noch) kein Fehler
  errorMessage:= '';
  // Erste Spalte
  colNumber:= 1;
  // Annahme, dass die Zeile keine 0 enthält
  // (wichtig für Bank Zeile, da nach einem leeren Bank Platz keine vollen mehr)
  hasZero:= false;
  // starten mit kompletter Zeile, die immer kleiner wird,
  // da die jeweilige Col aus der Row entfernt wird
  reducedRow:= CurrentRow;

  // Länge definieren: Spielfeld oder Bank (Erste 11 Zeilen Spielfeld)
  if LineNumber <= ROW_COUNT then
    maxColNumber:= COL_COUNT
  else
    maxColNumber:= MOVE_TILE_COUNT;

  // Solange nicht das Ende der entsprechenden Zeile erreicht ist und kein Fehler
  while (colNumber <= maxColNumber) and (errorMessage = '') do
  begin
    // Versuche den nächsten Steinnamen aus der Zeile zu extrahieren
    errorMessage:= getTileFromRow(reducedRow, currentTileName, LineNumber, colNumber);

    // Wenn kein Fehler aufgetreten ist
    if errorMessage = '' then
      // Verarbeitung des entsprechenden Steins
      errorMessage:= processTileName(currentTileName, hasZero, LineNumber, colNumber);

    // Nächste Spalte bzw. Stein Name
    inc(colNumber);
  end;

  // Weitere Überprüfungen, wenn bisher kein Fehler aufgetreten ist
  if errorMessage = '' then
  begin
    // Fehler falls noch Daten übrig in Zeile
    if Length(reducedRow) > 0 then
      errorMessage:= 'Zu viele Angaben in Zeile ' + IntToStr(LineNumber)
    else
      // Nach einlesen des gesamten Gamefields auf Validität prüfen
      if LineNumber = ROW_COUNT then
      begin
        if not(UGameField.isGameFieldValid) then
          errorMessage:= 'Das geladene Spielfeld ist nicht valide!';
      end
      else
        // Bank mit rdm Tiles füllen falls keine geladen wurden
        if (LineNumber > ROW_COUNT) and hasZero then
          Ulogic.setRdmForEmptyMoveTiles;
  end;

  processTileRow:= errorMessage;
end;

{Verarbeitung einer Reihe mit Spieler Daten oder Beginner Index
IN: CurrentRow - Reihe mit Spieler Daten (oder Beginner Index)
IN: LineNumber - Zeile in der Datei
OUT: BeginnerIndex - True, wenn es sich bei der Reihe um den BeginnerIndex handelt
RETURN: Fehlermeldung (Leerer String = Kein Fehler)
Anmerkung: playerPoints als Integer um negative Werte beim umwandeln abzufangen}
function processPlayerRow(CurrentRow: String; LineNumber: Byte; var BeginnerIndex: Boolean): String;
var
  playerIndex: Byte;
  errorCode, playerPoints: Integer;
  playerType: TPlayerType;
  errorMessage, typeOrIndex, name, points: String;
begin
  // Initialisierung
  BeginnerIndex:= False;
  playerType:= ptAI;;
  playerIndex:= 0;

  // Erste Spalte wird IMMER ausgelesen
  if extractNextCol(CurrentRow, typeOrIndex) then
    // Erst Prüfen ob Zahl
    val(typeOrIndex, playerIndex, errorCode);

    // Direkt Fehler für Player UND PlayerIndex abfangen
    if (Length(typeOrIndex) = 1) and
       (((upCase(typeOrIndex[1]) = 'A') or (upCase(typeOrIndex[1]) = 'H')) or
       ((errorCode = 0) and (playerIndex < UPlayer.getPlayerCount))) then
    begin

      // wenn PlayerType dann weiter für Name und Punkte
      if (upCase(typeOrIndex[1]) = 'A') or (upCase(typeOrIndex[1]) = 'H') then
      begin
        // PlayerType bestimmen
        case upCase(typeOrIndex[1]) of
          'A': playerType:= ptAI;
          'H': playerType:= ptHuman;
        end;

        // Name und Punkte einlesen wenn in Zeile vorhanden
        if extractNextCol(CurrentRow, name) and
           extractNextCol(CurrentRow, points) then
        begin
          // Punkte von String in Zahl umwandeln wenn möglich
          val(points, playerPoints, errorCode);

          // Sind Punkte eine positive Zahl?
          if (errorCode = 0) and
             (playerPoints >= 0) then
          begin
            // Länge des Spielernamens valide?
            if (Length(name) <= MAX_PLAYERNAME_LENGTH) then
            begin
              if (UPlayer.getPlayerCount < MAX_PLAYER_COUNT) then
                UPlayer.setPlayer(name, playerType, playerPoints)
              else
                errorMessage:= 'Zu viele Spieler';
            end
            else
              errorMessage:= 'Spielername in Zeile ' + IntToStr(lineNumber) +
                             ' zu lang! Maximal ' + IntToStr(MAX_PLAYERNAME_LENGTH) +
                             ' Zeichen erlaubt';
          end
          else
            errorMessage:= 'Ungültige Punktangabe in Zeile ' + IntToStr(lineNumber);
        end
        else
            errorMessage:= 'Zu wenig Angaben in Zeile ' + IntToStr(lineNumber)
      end
      else
      begin
        // sonst aktiven Spieler setzen
        UPlayer.setActivePlayer(playerIndex);
        // und zurückgeben, dass es sich um den Beginner Index handelt
        BeginnerIndex:= True;
      end;
    end
    else
      errorMessage:= 'Ungültiger Angabe ' + typeOrIndex
                      + ' in Zeile '      + IntToStr(lineNumber);

    // Fehler falls noch Daten übrig in Zeile
    if (errorMessage = '') and
       (Length(CurrentRow) > 0) then
      errorMessage:= 'Zu viele Angaben in Zeile ' + IntToStr(LineNumber);

    // Spieleranzahl überprüfen
    if  (errorMessage = '') and
        (lineNumber >= 14) and
        (UPlayer.getPlayerCount < 2) then
      errorMessage:= 'Zu wenig Spieler';

  processPlayerRow:= errorMessage;
end;

end.
