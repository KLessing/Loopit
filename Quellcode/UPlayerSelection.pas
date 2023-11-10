{------------------------------------------------------------------------------
Formular zum auswählen und konfigurieren der Spieler für ein Spiel.
Wird nur aufgerufen bevor ein neues Spiel gestartet wird.
Es müssen min. zwei Spieler vorhanden sein und min. einer der Spieler muss
manuell von einem Menschen gesteuert werden. Die Spielernamen dürfen nicht mehr
als 12 Zeichen beinhalten. Die Default Spielernamen werden von der Ini Datei
übernommen. Schließen des Formulars führt ebenfalls zur Validierung und
Übernahme der Daten, wenn diese valide sind.

Autor: Kevin Lessing , 20.09.2017
------------------------------------------------------------------------------}
unit UPlayerSelection;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFrmPlayerSelection = class(TForm)
    ChckBxPlayerActive0: TCheckBox;
    EdtPlayerName0: TEdit;
    LblActivatePlayer: TLabel;
    LblPlayerType: TLabel;
    LblChooseName: TLabel;
    ChckBxPlayerActive1: TCheckBox;
    EdtPlayerName1: TEdit;
    EdtPlayerName2: TEdit;
    ChckBxPlayerActive2: TCheckBox;
    EdtPlayerName3: TEdit;
    ChckBxPlayerActive3: TCheckBox;
    PnlPlayer0: TPanel;
    PnlPlayer1: TPanel;
    PnlPlayer2: TPanel;
    PnlPlayer3: TPanel;
    BtnStartGame: TButton;
    RdGrpPlayerControl0: TRadioGroup;
    RdGrpPlayerControl1: TRadioGroup;
    RdGrpPlayerControl2: TRadioGroup;
    RdGrpPlayerControl3: TRadioGroup;
    procedure ChckBxPlayerActive2Click(Sender: TObject);
    procedure ChckBxPlayerActive3Click(Sender: TObject);
    procedure BtnStartGameClick(Sender: TObject);
    procedure ChckBxPlayerActive0Click(Sender: TObject);
    procedure ChckBxPlayerActive1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private-Deklarationen }
    procedure selectPlayers;
    function validityCheck(var ErrorMessage: String): Boolean;
  public
    { Public-Deklarationen }
  end;

var
  FrmPlayerSelection: TFrmPlayerSelection;

implementation

{$R *.dfm}

uses UPlayer, UIni, UTypes;

{$REGION 'Hilfsfunktionen'}
{Validierungs Überprüfung der Spielernamen und ob menschlicher Spieler vorhanden.
Spielername darf nicht leer sein und keine Leerzeichen beinhalten.
(Länge wird direkt im Edit Feld auf 12 Zeichen beschränkt)
OUT: ErrorMessage: Die entsprechende Fehlermeldung (Leerer String, wenn kein Fehler)
RETURN: True, wenn alle Spielernamen valide}
function TFrmPlayerSelection.validityCheck(var ErrorMessage: String): Boolean;
var
  humanAvailable: Boolean;
  playerIndex: TPlayerCountRange;
  currentPlayerEdt: TEdit;
  currentPlayerRdGrp: TRadioGroup;
  currentChkBx: TCheckBox;
begin
  // Initialisierungen:
  // (Noch) kein Fehler gefunden
  ErrorMessage:= '';
  // Kein menschlicher Spieler vorhanden bis gefunden
  humanAvailable:= false;
  // Erster Spieler
  playerIndex:= 0;

  // Durchlaufen aller Spieler bis Fehler gefunden oder Ende
  while (ErrorMessage = '') and (playerIndex <= high(TPlayerIndex)) do
  begin
    // Checkbox des Enable Status des Spielers holen (Spieler aktiviert/deaktiviert)
    currentChkBx:= TCheckBox(FindComponent('ChckBxPlayerActive' + IntToStr(playerIndex)));

    // Ist der Spieler aktiviert?
    if currentChkBx.Checked then
    begin
      // Edit Feld des Namens vom aktiven Spieler holen
      currentPlayerEdt:= TEdit(FindComponent('EdtPlayerName' + IntToStr(playerIndex)));
      // Auf Leeren String, maximale Länge und Leerzeichen prüfen
      if (Length(currentPlayerEdt.Text) = 0) or
         (Length(currentPlayerEdt.Text) > MAX_PLAYERNAME_LENGTH) or
         (pos(' ', currentPlayerEdt.Text) > 0) then
        // Entsprechende Fehlermeldung setzen, wenn Überprüfung Fehlgeschlagen
        ErrorMessage:= 'Aktive Spieler benötigen einen beliebigen Namen. ' +
                       'Dieser darf keine Leerzeichen ' +
                       'und maximal 12 Zeichen beinhalten.';

      // Radio Group für die Steuerung des Spielers holen (Player oder AI)
      currentPlayerRdGrp:= TRadioGroup(FindComponent('RdGrpPlayerControl' + IntToStr(playerIndex)));
      // Soll der Spieler durch einen Mensch gesteuert werden?
      if currentPlayerRdGrp.ItemIndex = 0 then
        // Menschlicher Spieler gefunden
        HumanAvailable:= true;
    end;
    // Nächster Spieler
    inc(playerIndex);
  end;

  // Wurde kein menschlicher Spieler gefunden?
  if not(humanAvailable) then
    // Entsprechende Fehlermeldung setzen
    ErrorMessage:= 'Es wird mindestens ein menschlicher Spieler benötigt';

  // Valide wenn keine Error Message vorhanden
  validityCheck:= ErrorMessage = '';
end;

{Setzen der Spielerkonfiguration des Formulars für das Spiel
GLOBAL: SET UPlayer.setPlayer - setzen des Spielers für das Spiel}
procedure TFrmPlayerSelection.selectPlayers;
var
  playerIndex: TPlayerIndex;
  currentChkBx: TCheckBox;
  currentEdt: TEdit;
  currentRdGrp: TRadioGroup;
begin
  // Durchlaufen aller Spieler
  for playerIndex := 0 to high(TPlayerIndex) do
  begin
    // Checkbox des Enable Status des Spielers holen (Spieler aktiviert/deaktiviert)
    currentChkBx:= TCheckBox(FindComponent('ChckBxPlayerActive' + IntToStr(playerIndex)));

    // Ist der Spieler aktiviert?
    if currentChkBx.Checked then
    begin
      // Edit Feld des Namens vom aktiven Spieler holen
      currentEdt:= TEdit(FindComponent('EdtPlayerName' + IntToStr(playerIndex)));
      // Radio Group für die Steuerung des Spielers holen (Player oder AI)
      currentRdGrp:= TRadioGroup(FindComponent('RdGrpPlayerControl' + IntToStr(playerIndex)));

      // Setzen des Spielers
      UPlayer.setPlayer(currentEdt.Text, TPlayerType(currentRdGrp.ItemIndex), 0);
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Formular Interaktionen'}
{Setzen der Default Werte und anzeigen des Formular
GLOBAL: GET UIni.getPlayerName - Entsprechende Spielernamen
        GET MAX_PLAYERNAME_LENGTH - Maximal zulässige Anzahl an Zeichen im Spielernamen}
procedure TFrmPlayerSelection.FormShow(Sender: TObject);
var
  playerIndex: TPlayerIndex;
  currentPlayerEdt: TEdit;
begin
  // Alle Spieler durchlaufen
  for playerIndex := 0 to high(TPlayerIndex) do
  begin
    // Default Namen ins entsprechende Edit Feld setzen
    currentPlayerEdt:= TEdit(FindComponent('EdtPlayerName' + IntToStr(playerIndex)));
    currentPlayerEdt.Text:= UIni.getPlayerName(playerIndex);

    // Maximal Namenslänge definieren
    currentPlayerEdt.MaxLength:= MAX_PLAYERNAME_LENGTH;
  end;
end;

{Übernehmen der Spielerwerte und schließen des Formulars.
NUR wenn Werte valide. Ansonsten wird eine Fehlermeldung angezeigt}
procedure TFrmPlayerSelection.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  errorMessage: String;
begin
  // Daten Valide?
  if validityCheck(errorMessage) then
    // Daten übernehmen
    selectPlayers
  else
  begin
    // Sonst schließen verhindern
    CanClose:= false;
    // Und entsprechende Fehlermeldung anzeigen
    showMessage(errorMessage);
  end;
end;

{Der Start Button führt die normale Close Routine des Formulars aus}
procedure TFrmPlayerSelection.BtnStartGameClick(Sender: TObject);
begin
  FrmPlayerSelection.Close;
end;
{$ENDREGION}

{$REGION 'Enable State Switch'}
{Zuständig für die Aktivierung und Deaktivierung der jeweiligen Eingabemöglichkeiten.
Der "Enable" Status wird umgekehrt. (Z.b. wird von Enable auf Disable gesetzt)
IN: Edit - Das zu switchende Edit Feld
IN: RdGrp - Die zu switchende Radio Group}
procedure switchEnableState(Edit: TEdit; RdGrp: TRadioGroup);
begin
  Edit.Enabled:= not(Edit.Enabled);
  RdGrp.Enabled:= not(RdGrp.Enabled);
end;

{Umkehren des Enable States für den ersten Spieler}
procedure TFrmPlayerSelection.ChckBxPlayerActive0Click(Sender: TObject);
begin
  switchEnableState(EdtPlayerName0, RdGrpPlayerControl0);
end;

{Umkehren des Enable States für den zweiten Spieler}
procedure TFrmPlayerSelection.ChckBxPlayerActive1Click(Sender: TObject);
begin
  switchEnableState(EdtPlayerName1, RdGrpPlayerControl1);
end;

{Umkehren des Enable States für den dritten Spieler}
procedure TFrmPlayerSelection.ChckBxPlayerActive2Click(Sender: TObject);
begin
  switchEnableState(EdtPlayerName2, RdGrpPlayerControl2);
end;

{Umkehren des Enable States für den vierten Spieler}
procedure TFrmPlayerSelection.ChckBxPlayerActive3Click(Sender: TObject);
begin
  switchEnableState(EdtPlayerName3, RdGrpPlayerControl3);
end;
{$ENDREGION}

end.
