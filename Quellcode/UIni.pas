{------------------------------------------------------------------------------
Zuständig für die Verwaltung der Default Werte. Die Werte werden in dieser
Unit als globale Werte gespeichert. Sie werden nach dem Laden der Ini Datei
gesetzt und zusätzlich verändert, wenn die Werte in den Einstellung angepasst
werden, damit diese auch direkt im aktuellen Spiel zum Einsatz kommen.
Wird keine Ini Datei gefunden, werden die Default Ini Werte, die hier als
Konstante Werte deklariert sind, gesetzt und in eine neue Ini Datei geschrieben.
(In der UFileIO werden die Daten beim Laden UND Schreiben gesetzt)

Autor: Kevin Lessing , 08.10.2017
------------------------------------------------------------------------------}
unit UIni;

interface

uses UTypes;

const
  // Default INI Werte
  DEFAULT_SAVE_GAME_DIRECTORY = 'C:\';
  DEFAULT_AI_DELAY = 2000;
  DEFAULT_PLAYER_NAMES: TPlayerNames =
  (
    'Spieler1',
    'Spieler2',
    'Spieler3',
    'Spieler4'
  );

  { --- Getter --- }
  function getSaveGameDirectory: String;
  function getPlayerName(Index: TPlayerIndex): String;
  function getAIDelay: Word;

  { --- Setter --- }
  procedure setSaveGameDirectory(Dir: String);
  procedure setPlayerName(Index: TPlayerIndex; Name: String);
  procedure setAIDelay(Delay: Word);


implementation

var

  // Aktuelle INI Werte
  SaveGameDirectory: String;
  PlayerNames: TPlayerNames;
  AIDelay: Word;

{$REGION 'Getter'}
{Gibt den Speicherpfad zurück
RETURN: Speicherpfad}
function getSaveGameDirectory: String;
begin
  getSaveGameDirectory:= SaveGameDirectory;
end;

{Gibt einen Spielernamen zurück
IN: Index - Index des Spielernamens
RETURN: Spielernamen an der entpsrechenden Stelle}
function getPlayerName(Index: TPlayerIndex): String;
begin
  getPlayerName:= PlayerNames[Index];
end;

{Gibt die KI-Wartezeit zurück
RETURN: KI-Wartezeit}
function getAIDelay: Word;
begin
  getAIDelay:= AIDelay;
end;
{$ENDREGION}

{$REGION 'Setter'}
{Setzen des Speicherpfades
IN: Dir - Speicherpfad}
procedure setSaveGameDirectory(Dir: String);
begin
  SaveGameDirectory:= Dir;
end;

{Setzen eines Spielernamens
IN: Index - Index des Spielernamens
IN: Name - Entprechender Name}
procedure setPlayerName(Index: TPlayerIndex; Name: String);
begin
  PlayerNames[Index]:= Name;
end;

{Setzen der KI-Wartezeit
IN: Delay - entprechende Wartezeit in ms}
procedure setAIDelay(Delay: Word);
begin
  AIDelay:= Delay;
end;
{$ENDREGION}

end.
