{------------------------------------------------------------------------------
Zust�ndig f�r das Speichern und Laden der Spielst�nde und INI Dateien.

Autor: Kevin Lessing , 06.10.2017
------------------------------------------------------------------------------}
unit UFileIO;

interface

uses UTypes;

  function readFile(FileName: string; var ErrorMessage: string): Boolean;
  function writeFile(FileName: string): Boolean;

  procedure loadIniFile;
  procedure setIniFile(Directory: String;
                       Names: TPlayerNames;
                       Delay: Word);

implementation

uses ULogic, UGameField, UPlayer, UIni, UFileValidation, System.SysUtils;

{$REGION 'Hilfsfunktionen - Datenbl�cke'}
{Gibt das Spielfeld als String zur�ck
RETURN: Spielfeld als String}
function getGameFieldString: String;
var
  resultString: String;
  rowRunner: TRow;
  colRunner: TCol;
begin
  // Init
  resultString:= '';
  // Zeilen durchlaufen
  for rowRunner := Low(TRow) to High(TRow) do
  begin
    // Spalten durchlaufen
    for colRunner := Low(TCol) to High(TCol) do
    begin
      // Wenn das Feld Leer ist
      if UGameField.isFieldEmpty(rowRunner, colRunner) then
        // 0 anh�ngen
        Insert('   0', resultString, Length(resultString)+1)
      else
        // Sonst entsprechenden Stein Namen anh�ngen
        Insert(' ' + UGameField.getTileNameFromField(rowRunner, colRunner),
               resultString, Length(resultString)+1);
    end;
    // Zeilenumbruch
    Insert(sLineBreak, resultString, Length(resultString)+1);
  end;
  getGameFieldString:= resultString;
end;

{Gibt die Bank Zeile als String zur�ck
RETURN: Bank als String}
function getBankString: String;
var
  resultString: String;
  moveTileRunner: TMoveTileIndex;
begin
  // Alle Bankslot durchlaufen
  for moveTileRunner := Low(TMoveTileIndex) to High(TMoveTileIndex) do
  begin
    // Wenn der Bankslot leer ist
    if ULogic.isMoveTileEmpty(MoveTileRunner) then
      // 0 anh�ngen
      Insert('   0', resultString, Length(resultString)+1)
    else
      // Sonst entsprechenden Stein Namen anh�ngen
      Insert(' ' + ULogic.getMoveTileName(moveTileRunner),
             resultString, Length(resultString)+1);
  end;
  getBankString:= resultString + sLineBreak;
end;

{Gibt die Spielerdaten sowie den Beginner Index als String zur�ck
RETURN: Spielerdaten sowie den Beginner Index als String}
function getPlayerString: String;
var
  resultString: String;
  playerRunner: TPlayerIndex;
  player: TPlayer;
  playerTypeChar: char;
begin
  // Initialisierungen
  resultString:= '';
  playerTypeChar:= 'A';

  // Alle Spieler des Spiels durchlaufen
  for playerRunner := Low(TPlayerIndex) to UPlayer.getPlayerCount-1 do
  begin
    // Spielerdaten holen
    player:= UPlayer.getPlayer(playerRunner);

    // Spieler Typ zuweisen
    case player.playerType of
      ptHuman:  playerTypeChar:= 'H';
      ptAI: playerTypeChar:= 'A';
    end;

    // Spieler Zeile hinzuf�gen
    Insert(playerTypeChar + ' ' +
           player.name + ' ' +
           IntToStr(player.points) +
           sLineBreak, resultString, Length(resultString)+1);
  end;

  // Aktuellen Spieler in die letzte Zeile schreiben und zur�ckgeben
  getPlayerString:= resultString + IntToStr(UPlayer.getCurrentPlayerIndex);
end;
{$ENDREGION}

{Einlesen einer Spielstands Datei.
�ffnet Datei als TextFile, validiert die Daten und gibt Status zur�ck ob Einlesen
erfolgreich, ansonsten wird eine entsprechende Fehlermeldung erzeugt
IN: FileName - Name der zu lesenden Datei
OUT: ErrorMessage - Fehlermeldung (leerer String = kein Fehler)
RETURN: True, wenn Lesen der Datei erfolgreich}
function readFile(FileName: string; var ErrorMessage: string): boolean;
var
  data: textfile;
  currentRow: String;
  lineNumber: Byte;
  readSuccess, beginnerIndex: Boolean;
begin
  // Initialisierungen:
  // (Noch) kein Fehler
  ErrorMessage:= '';
  // Lesen erfolgreich bis Fehler gefunden
  readSuccess:= true;
  // Erste Zeile der Datei
  lineNumber:= 1;
  // "Leeres" Spiel
  ULogic.endGame;

  // Datei Namen Datei Typ zuweisen
  AssignFile(data, FileName);
  try
    // Datei �ffnen
    Reset(data);
    try
      // Solange kein Fehler und nicht das Ende der Datei erreicht
      while (ErrorMessage = '') and (not Eof(data)) do
      begin
        // Zeile einlesen
        readln(data, currentRow);

        // Reihe mit Steinen?
        if lineNumber <= ROW_COUNT+1 then
          // Stein Daten einlesen und verarbeiten (Spielfeld und Bank)
          ErrorMessage:= UFileValidation.processTileRow(currentRow, lineNumber)
        else
          // Spielerdaten einlesen und verarbeiten (inkl. letzter Zeile f�r Beginner)
          ErrorMessage:= UFileValidation.processPlayerRow(currentRow, lineNumber, beginnerIndex);
        // N�chste Zeile
        inc(lineNumber);
      end;

      // Weitere �berpr�fungen, wenn noch kein Fehler
      if ErrorMessage = '' then
      begin
        // Kein BeginnerIndex
        if not(beginnerIndex) then
          ErrorMessage:= 'Die letzte Zeile ben�tigt einen Beginner Index';
        // Zu wenig Angaben
        if lineNumber < 15 then
          ErrorMessage:= 'Die Datei enth�lt zu wenig Informationen';
      end;

    except
      // Fehlerreaktion (Funktionsr�ckgabewert beeinflussen)
      readSuccess := false;
    end;

  finally
    // Datei schlie�en
    closeFile(data);
  end;

  // Lesen erfolgreich wenn Datei gelesen werden konnte
  // und kein Fehler bei der Validierung aufgetreten ist
  readfile:= readSuccess and (ErrorMessage = '');
end;


{Schreiben einer Spielstands Datei.
�ffnet entsprechende Datei als TextFile, schreibt die Spielstand Daten geordnet
rein und gibt an, ob Aktion erfolgreich
IN: FileName: Namen der zu �ffnenden Datei
RETURN: True, wenn schreiben der Datei erfolgreich}
function writeFile(FileName: string): Boolean;
var
  data: Textfile;
  writeSuccess: Boolean;
begin
  // Initialisierung: Schreiben erfolgreich solange kein Fehler beim Dateizugriff
  writeSuccess:= true;

  // Datei Namen Datei Typ zuweisen
  AssignFile(data, FileName);
  try
    // Datei NEU �ffnen, Inhalt wird gel�scht
    ReWrite(data);
    try
      writeln(data, getGameFieldString +
                    getBankString +
                    getPlayerString);
    except
      // Fehlerreaktion (Funktionsr�ckgabewert beeinflussen)
      writeSuccess := false;
    end;

  finally
    // Datei schlie�en
    closeFile(data);
  end;

  writeFile:= writeSuccess;
end;

{Schreibt die �bergebenen Default Werte in die LoopIt.INI Datei und setzt diese
Werte auch gleichzeitig als Default Werte f�r das laufende Programm, damit diese
direkt �bernommen werden
IN: Directory - Pfad f�r gespeicherte Spiele
IN: Names - Spielernamen
IN: Delay - KI Zug Verz�gerung}
procedure setIniFile(Directory: String;
                     Names: TPlayerNames;
                     Delay: Word);
var
  data: TextFile;
  playerIndex: TPlayerIndex;
begin
  // Datei Namen Datei Typ zuweisen
  AssignFile(data, 'LoopIt.INI');
  try
    // Datei NEU �ffnen, Inhalt wird gel�scht
    ReWrite(data);

    // Schreiben und setzen des Default Verzeichnis f�r Spielst�nde
    writeln(data, Directory);
    UIni.setSaveGameDirectory(Directory);

    // Durchlaufen aller Spielernamen
    for playerIndex := Low(playerIndex) to High(playerIndex) do
    begin
      // Schreiben und setzen der Spielernamen
      writeln(data, Names[playerIndex]);
      UIni.setPlayerName(playerIndex, Names[playerIndex]);
    end;

    // Schreiben und setzen der KI Verz�gerung
    writeln(data, Delay);
    UIni.setAIDelay(Delay);

  finally
    // Datei schlie�en
    closeFile(data);
  end;
end;

{Laden der LoopIt.INI Datei und setzen der Werte als Default Werte f�r das
laufende Programm. Wird keine LoopIt.INI Datei gefunden, wird eine neue Datei
erstellt und mit "Default Default Werten" gef�llt.
Zu viele Angaben werden ignoriert. Wenn Spielernamen oder KI Verz�gerung nicht
valide dann werden die entsprechenden "Default Default Werte" verwendet.
Ung�ltige Default Verzeichnisse werden �bernommen, aber von Windows ignoriert,
da dann der letzte genutze Pfad benutzt wird.}
procedure loadIniFile;
var
  data: TextFile;
  directory: String;
  playerIndex: TPlayerIndex;
  playerName, delayString: String;
  delayNumber, errorCode: Integer;
begin

  // Exisiert eine Datei namens LoopIt.INI?
  if FileExists('LoopIt.INI') then
  begin
    // Datei Namen Datei Typ zuweisen
    AssignFile(data, 'LoopIt.INI');
    try
      // Datei �ffnen
      Reset(data);

      // Lesen und setzen des Default Verzeichnis f�r Spielst�nde
      readln(data, directory);
      UIni.setSaveGameDirectory(directory);

      // Durchlaufen aller Spielernamen
      for playerIndex := Low(playerIndex) to High(playerIndex) do
      begin
        // Lesen Spielernamen
        readln(data, playerName);
        // Spielername valide?
        if (Length(playerName) <= MAX_PLAYERNAME_LENGTH) and
           (pos(' ', playerName) = 0) then
          // Namen setzen
          UIni.setPlayerName(playerIndex, playerName)
        else
          // Default Namen setzen
          UIni.setPlayerName(playerIndex, DEFAULT_PLAYER_NAMES[playerIndex])
      end;

      // Lesen der KI Verz�gerung
      readln(data, delayString);
      // String in Zahl umwandeln
      val(delayString, delayNumber, errorCode);
      // Pr�fen, ob valide Zahl
      if (errorCode = 0) and
         (delayNumber >= 0) and
         (delayNumber <= MAX_AI_DELAY) then
        // KI Verz�gerung setzen
        UIni.setAIDelay(delayNumber)
      else
        // Default KI Verz�gerung setzen
        UIni.setAIDelay(DEFAULT_AI_DELAY);

    finally
      // Datei schlie�en
      closeFile(data);
    end;
  end
  else
    // Neue Datei mit "Default Default Werten" schreiben und setzen
    setIniFile(DEFAULT_SAVE_GAME_DIRECTORY,
               DEFAULT_PLAYER_NAMES,
               DEFAULT_AI_DELAY);
end;

end.
