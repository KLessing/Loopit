{------------------------------------------------------------------------------
Formular zum einstellen der Default Werte
(Speicherpfad, Spielernamen, KI-Wartezeit).
Das Spiel kann erst fortgesetztn werden wenn das Forumal geschlossen wurde.
Die Werte werden nur übernommen, wenn mit OK bestätigt wurde. Die Spielernamen
dürfen keine Leerzeichen und maximal 12 Zeichen beinhalten. Für die KI-Wartezeit
dürfen nur Zahlen bis zu 9999ms eingetragen werden.

Autor: Kevin Lessing , 08.10.2017
------------------------------------------------------------------------------}
unit UDefaultValues;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, UTypes;

type
  TFrmDefaultValues = class(TForm)
    EdtSaveDirectory: TEdit;
    EdtPlayerName0: TEdit;
    EdtPlayerName1: TEdit;
    EdtPlayerName2: TEdit;
    EdtPlayerName3: TEdit;
    EdtAIDelay: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    BtnOk: TButton;
    BtnCancel: TButton;
    procedure BtnOkClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    function getPlayerNames(var PlayerNames: TPlayerNames; var ErrorMessage: String): Boolean;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FrmDefaultValues: TFrmDefaultValues;

implementation

uses UFileIO, UIni;

{$R *.dfm}

{Validierung der Spielernamen der EditFelder. Sind die Namen valide, werden diese
in das entsprechende Array eingetragen sonst wird eine Fehlermeldung zurückgegeben
OUT: PlayerNames - Die Namen der Spieler, wenn diese valide sind
OUT: ErrorMessage - Fehldermeldung, wenn Spielernamen nicht valide sind
RETURN: True, wenn Spielernamen valide}
function TFrmDefaultValues.getPlayerNames(var PlayerNames: TPlayerNames; var ErrorMessage: String): Boolean;
var
  playerIndex: TPlayerCountRange;
  currentPlayerNameEdt: TEdit;
  success: Boolean;
begin
  // Initialisierungen
  ErrorMessage:= '';
  success:= true;
  playerIndex:= 0;

  // Durchlaufen der Spielernamen Felder
  while success and (playerIndex <= High(TPlayerIndex)) do
  begin
    // Entsprechendes Edit Feld suchen
    currentPlayerNameEdt:= TEdit(FindComponent('EdtPlayerName' + IntToStr(playerIndex)));
    // Validierung für Leerzeichen und Länge
    if (pos(' ', currentPlayerNameEdt.Text) = 0 ) and
       (Length(currentPlayerNameEdt.Text) <= MAX_PLAYERNAME_LENGTH) then
      // Validen Namen ins Array eintragen
      PlayerNames[playerIndex]:= currentPlayerNameEdt.Text
    else
    begin
      // Name nicht valide wenn Leerzeichen oder mehr als 12 Zeichen enthalten
      success:= false;
      ErrorMessage:= 'Spielernamen dürfen kein Leerzeichen ' +
                     'und maximal 12 Zeichen enthalten!';
    end;
    // Nächster Spielerindex
    inc(playerIndex);
  end;

  getPlayerNames:= success;
end;

{Beim Klicken auf den OK Button werden die Eingaben überprüft und gespeichert
oder es wird eine Fehlermeldung ausgegeben
GLOBAL: SET UFileIO.setIniFile - Überschreiben der Ini Datei Werte}
procedure TFrmDefaultValues.BtnOkClick(Sender: TObject);
var
  playerNames: TPlayerNames;
  errorMessage: String;
begin
  // Sind die Namen der Spieler valide?
  if getPlayerNames(playerNames, errorMessage) then
  begin
    // KI Wartezeit nicht leer?
    if (EdtAIDelay.Text <> '') then
      begin
      // Überschreibe die Werte der Ini Datei
      UFileIO.setIniFile(EdtSaveDirectory.Text,
                         playerNames,
                         StrToInt(EdtAIDelay.Text));
      // Schließe das Formular
      FrmDefaultValues.Close;
    end
    else
      // Entsprechende Fehlermeldung anzeigen
      ShowMessage('KI Wartezeit darf nicht leer sein!');
  end
  else
    // Sonst wird das Formular nicht geschlossen und
    // eine entsprechende Fehlermeldung angezeigt
    ShowMessage(errorMessage);
end;

{Beim Klicken auf den Abbrechen Button wird das Formular ohne zu speichern geschlossen}
procedure TFrmDefaultValues.BtnCancelClick(Sender: TObject);
begin
  FrmDefaultValues.Close;
end;

{Beim Anzeigen des Formulars werden die aktuellen Default Werte
aus der Ini Unit geladen und in die entsprechenden Edit Felder eingetragen
GLOBAL: GET UIni.getSaveGameDirectory - Default Path der gespeicherten Spiele
        GET UIni.getPlayerName - Default Spielername
        GET UIni.getAIDelay - Default KI Wartezeit
        GET MAX_PLAYERNAME_LENGTH - Maximal erlaubte Länge der Spielernamen}
procedure TFrmDefaultValues.FormShow(Sender: TObject);
var
  playerIndex: TPlayerIndex;
  currentPlayerNameEdt: TEdit;
begin
  // Default Path der gespeicherten Spiele in Edit Feld eintragen
  EdtSaveDirectory.Text:= UIni.getSaveGameDirectory;

  // Durchlaufen aller Spielernamen Felder
  for playerIndex := Low(TPlayerIndex) to High(TPlayerIndex) do
  begin
    // Default Spielernamen in Edit Feld eintragen
    currentPlayerNameEdt:= TEdit(FindComponent('EdtPlayerName' + IntToStr(playerIndex)));
    currentPlayerNameEdt.Text:= UIni.getPlayerName(playerIndex);

    // Maximale Länge für den Spielernamen setzen
    currentPlayerNameEdt.MaxLength:= MAX_PLAYERNAME_LENGTH;
  end;

  // Default KI Wartezeit in Edit Feld eintragen
  EdtAIDelay.Text:= IntToStr(UIni.getAIDelay);
end;

end.
