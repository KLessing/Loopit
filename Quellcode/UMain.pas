{------------------------------------------------------------------------------
Hauptformular. Alle Interaktionen werden von hier gesteuert.
Zust�ndig f�r das Starten und Beenden des gesamten Programmes, Interaktionen mit
allen Buttons des Formulars, anzeigen von m�glichen Sicherheitsabfragen, Nutzung
der weiteren Units, Laden der Bilder von der RessourceDatei etc.

Autor: Kevin Lessing , 20.09.2017
------------------------------------------------------------------------------}
unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Grids,
  Vcl.StdCtrls, Vcl.ImgList, Vcl.Menus, UTypes;

const
  // Eigene Windows Message f�r Aftershow
  // WM_USER ist der erste f�r User benutzbare Wert
  WM_AFTER_SHOW = WM_USER;

type
  TFrmLoopIt = class(TForm)
    DrwGrdGameField: TDrawGrid;
    PnlCurrentMove: TPanel;
    PnlCurrentPoints: TPanel;
    PnlPoints: TPanel;
    LblPlayerHeadline: TLabel;
    LblNamePlayer0: TLabel;
    LblNamePlayer1: TLabel;
    LblNamePlayer3: TLabel;
    LblNamePlayer2: TLabel;
    LblPointsHeadline: TLabel;
    LblPointsPlayer0: TLabel;
    LblPointsPlayer1: TLabel;
    LblPointsPlayer2: TLabel;
    LblPointsPlayer3: TLabel;
    LblCurrentPointsHeadline: TLabel;
    LblNameTile1: TLabel;
    LblNameTile2: TLabel;
    LblNameTile3: TLabel;
    LblMovePoints0: TLabel;
    LblMovePoints1: TLabel;
    LblMovePoints2: TLabel;
    BtnRemoveLastTile: TButton;
    BtnEndMove: TButton;
    MnMnGame: TMainMenu;
    MnItmGame: TMenuItem;
    PnlMoveTiles: TPanel;
    ImgMoveTile0: TImage;
    ImgMoveTile1: TImage;
    ImgMoveTile2: TImage;
    ImgMoveTile3: TImage;
    ImgMoveTile4: TImage;
    MnItmSave: TMenuItem;
    MnItmLoad: TMenuItem;
    MnItmNew: TMenuItem;
    MnItmEnd: TMenuItem;
    OpnDlgFile: TOpenDialog;
    MnItmSettings: TMenuItem;
    MnItmDefaultValues: TMenuItem;
    LblNameAddedPoints: TLabel;
    LblMovePointsAdded: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure MnItmLoadClick(Sender: TObject);
    procedure MnItmSaveClick(Sender: TObject);
    procedure MnItmDefaultValuesClick(Sender: TObject);
    procedure MnItmEndClick(Sender: TObject);
    procedure MnItmNewClick(Sender: TObject);

    procedure BtnRemoveLastTileClick(Sender: TObject);
    procedure BtnEndMoveClick(Sender: TObject);
    procedure TileImageClick(Sender: TObject);
    procedure DrwGrdGameFieldDrawCell(Sender: TObject; ACol, ARow: Integer;
                                      Rect: TRect; State: TGridDrawState);
    procedure DrwGrdGameFieldMouseUp(Sender: TObject; Button: TMouseButton;
                                     Shift: TShiftState; X, Y: Integer);

  private
    { Private-Deklarationen }
    procedure initializePlayers;
    procedure resetMovePoints;
    procedure loadQuery;
    procedure loadGame(LoadLoop: Boolean);
    procedure startNewGame;
    procedure newMove;
    procedure endMove;
    procedure updateMoveTileImages;
    procedure updatePointsAndPlayer(OldPlayerIndex: TPlayerIndex);
    procedure makeAIMove;
    procedure makeCurrentMove(MoveTileIndex: TMoveTileIndex; Row: TRow; Col:TCol);
    procedure WmAfterShow(var Msg: TMessage); message WM_AFTER_SHOW;
  public
    { Public-Deklarationen }
  end;

var
  FrmLoopIt: TFrmLoopIt;

implementation

uses ULogic, UGameField, UGameFieldTypes, UTileSelection,
     UPlayer, UPlayerSelection, UAI, UFileIO, UIni, UDefaultValues;

// Einbinden der Formular Defintionen
{$R *.dfm}
// Einbinden der Ressource Datei
{$R Images.RES}

{$REGION 'Unabh�ngige Hilfsfunktionen'}
{Zeichnet einen Rahmen f�r ein Canvas
IN: Canvas - Das Canvas, welches umrahmt werden soll
IN: Color - Die Farbe der Umrandung
IN: Width - Die Breite der Umrandung
IN: Height - Die H�he der Umrandung}
procedure drawBorderForCanvas(Canvas: TCanvas; Color: TColor; Width, Height: Integer);
begin
  // Farbe und Breite des Stiftes definieren
  Canvas.Pen.Color:= Color;
  Canvas.Pen.Width:= IMG_BORDER_WIDTH;

  // Umrandung zeichnen
  Canvas.MoveTo(IMG_BORDER_WIDTH, IMG_BORDER_WIDTH);
  Canvas.LineTo(Width-IMG_BORDER_WIDTH, IMG_BORDER_WIDTH);
  Canvas.LineTo(Width-IMG_BORDER_WIDTH, Height-IMG_BORDER_WIDTH);
  Canvas.LineTo(IMG_BORDER_WIDTH, Height-IMG_BORDER_WIDTH);
  Canvas.LineTo(IMG_BORDER_WIDTH, IMG_BORDER_WIDTH);
end;

{Zeigt ein Best�tigungsfenster mit einer entsprechenden Nachricht
IN: ConfirmationMessage - Die entsprechende Nachricht
RETURN: TRUE - wenn der Benutzer mit OK best�tigt hat}
function confirmationQuery(ConfirmationMessage: String): Boolean;
var
  selectedButton : Integer;
begin
  // Zeige Best�tigungsdialog mit entprechender Nachricht
  selectedButton:= messagedlg(confirmationMessage, mtConfirmation, [mbOk, mbCancel], 0);
  // True wenn ok ausgew�hlt, sonst False
  confirmationQuery:= selectedButton = mrOk;
end;

{�berpr�ft, ob das Spiel noch l�uft, indem der aktuelle Spieler �berpr�ft wird.
Wartet dann f�r die in der Ini Datei, in Millisekunden, angebene Zeit und gibt
den Status zur�ck, ob das Spiel mittlerweile abgebrochen wurde oder nicht.
IN: currentPlayer - der aktuelle Spieler mit dem gepr�ft wird
GLOBAL: GET UIni.getAIDelay - die zu wartende Dauer in Millisekunden
RETURN: TRUE - wenn das Spiel noch l�uft und nicht abgebrochen wurde}
function waitIfNotCanceled(currentPlayer: TPlayer): Boolean;
begin
  // Ist der aktuelle Spieler noch am Zug (oder wurde das Spiel abgebrochen)?
  if UPlayer.comparePlayerWithCurrent(currentPlayer) then
  begin
    // Sofortige Abarbeitung aller noch offenen �nderungen der Oberfl�che
    Application.ProcessMessages;
    // Warte f�r die angegebene Zeit
    Sleep(UIni.getAIDelay);
  end;
  // �berpr�fe nach dem Warten nochmals, ob Spiel noch l�uft
  // und gebe das Ergebnis zur�ck
  waitIfNotCanceled:= UPlayer.comparePlayerWithCurrent(currentPlayer);
end;
{$ENDREGION}

{$REGION 'Formular Methoden - Hilfsfunktionen'}
{Initialisierung der Anzeige f�r die Spielernamen und Punkte
sowie Markierung des aktiven Spielers
GLOBAL: GET UPlayer.getPlayerCount - Anzahl der Spieler im aktuellen Spiel
        GET UPlayer.getPlayer - SpielerArray(Name, Typ, Punkte)
        GET UPlayer.getCurrentPlayerIndex - Index des aktuellen Spielers}
procedure TFrmLoopIt.initializePlayers;
var
  lblName, lblPoints: TLabel;
  playerIndex: TPlayerIndex;
  player: TPlayer;
begin
  // �ber alle Spieler iterieren
  for playerIndex := Low(TPlayerIndex) to High(TPlayerIndex) do
  begin
    // Label f�r Name und Punkte zuweisen
    lblName:= TLabel(FindComponent('LblNamePlayer' + IntToStr(playerIndex)));
    lblPoints:= TLabel(FindComponent('LblPointsPlayer' + IntToStr(playerIndex)));

    // Existiert der aktuelle Spieler im Spiel?
    if playerIndex < UPlayer.getPlayerCount then
    begin
      // Spieler zuweisen
      player:= UPlayer.getPlayer(playerIndex);
      // Namen setzen, evtl. mit Zusatz KI
      lblName.Caption:= player.name;
      if player.playerType = ptAI then
        lblName.Caption:= lblName.Caption + ' (KI)';
      // Punkte setzen
      lblPoints.Caption:= IntToStr(player.points);

      // Sichtbarkeit aktivieren
      lblName.Visible:= True;
      lblPoints.Visible:= True;

      if playerIndex = UPlayer.getCurrentPlayerIndex then
      begin
        // Markierung des Aktiven Spielers
        lblName.Font.Style:= [fsUnderline];
        lblName.Font.Color:= clRed;
      end
      else
      begin
        // Markierung der Inaktiven Spieler zur�cksetzen
        // (Wichtig beim Spiel Neustart)
        lblName.Font.Style:= [];
        lblName.Font.Color:= clBlack;
      end;
    end
    else
    begin
      // Exisiert der Spieler nicht, wird die Sichtbarkeit der Label deaktiviert
      lblName.Visible:= False;
      lblPoints.Visible:= False;
    end;
  end;
end;

{Aktualisierung der Punkte des Spielers, der gerade seinen Zug beendet hat und
weitersetzen der Markierung des aktiven Spielers
IN: OldPlayerIndex - Der Spieler der vorher am Zug war, dessen Punkte aktualisiert
                     werden sollen und dessen Markierung aufgehoben werden soll
GLOBAL: GET UPlayer.getPlayer - SpielerArray(Name, Typ, Punkte)
        GET UPlayer.getCurrentPlayerIndex - Index des aktuellen Spielers}
procedure TFrmLoopIt.updatePointsAndPlayer(OldPlayerIndex: TPlayerIndex);
var
  PlayerPointsLabel, PlayerNameLabel: TLabel;
begin
  // Aktualisierung der Punkte des vorigen Spielers
  PlayerPointsLabel:= TLabel(FindComponent('LblPointsPlayer' + (IntToStr(OldPlayerIndex))));
  PlayerPointsLabel.Caption:=  IntToStr(UPlayer.getPlayer(OldPlayerIndex).points);

  // Entfernen der Markierung des vorigen Spielers
  PlayerNameLabel:= TLabel(FindComponent('LblNamePlayer' +
                                         IntToStr(OldPlayerIndex)));
  PlayerNameLabel.Font.Style:= [];
  PlayerNameLabel.Font.Color:= clBlack;

  // Setzen der Markierung des nun aktiven Spielers
  PlayerNameLabel:= TLabel(FindComponent('LblNamePlayer' +
                                         IntToStr(UPlayer.getCurrentPlayerIndex)));
  PlayerNameLabel.Font.Style:= [fsUnderline];
  PlayerNameLabel.Font.Color:= clRed;
end;

{Aktualisierung der Bilder f�r die Steine des aktuellen Zuges auf der Bank
GLOBAL: GET ULogic.isMoveTileEmpty - TRUE, wenn Stein nicht vorhanden
        GET ULogic.getMoveTileName - Name des entsprechenden Steins auf der Bank}
procedure TFrmLoopIt.updateMoveTileImages;
var
  img: TBitmap;
  imageRect: TRect;
  moveTileIndex: TMoveTileIndex;
  moveTileImage: TImage;
begin
  // Rectangle f�r alle Images anhand Breite und H�he des ersten Images zuweisen
  imageRect:= Rect(IMG_BORDER_WIDTH,
                   IMG_BORDER_WIDTH,
                   ImgMoveTile0.Width-IMG_BORDER_WIDTH,
                   ImgMoveTile0.Height-IMG_BORDER_WIDTH);

  // �ber alle Zug Steine iterieren
  for moveTileIndex := Low(TMoveTileIndex) to High(TMoveTileIndex) do
  begin
    // Entsprechende Image Komponente zuweisen
    moveTileImage:= TImage(FindComponent('ImgMoveTile' + IntToStr(moveTileIndex)));

    // Ist ein Stein an der aktuellen Stelle vorhanden?
    if not(ULogic.isMoveTileEmpty(moveTileIndex)) then
    begin
      // Sichtbarkeit der Imagekomponente aktieren
      moveTileImage.Visible:= true;
      // Wei�en Rahmen zeichnen
      // (Steht f�r nicht gesetzt und nicht ausgew�hlt)
      drawBorderForCanvas(moveTileImage.Canvas, clWhite,
                          moveTileImage.Width, moveTileImage.Height);

      // Versuchen das entsprechende Bild zu Laden und zu Zeichnen
      img := TBitmap.Create;
      try
        img.LoadFromResourceName(hinstance, 'Tile' +
                                            ULogic.getMoveTileName(moveTileIndex));
        moveTileImage.Canvas.StretchDraw(imageRect, img);
      finally
        img.Free;
      end;
    end
    else
      // Wenn kein Stein an der aktuellen Stelle vorhanden, Sichtbarkeit deaktivieren
      moveTileImage.Visible:= false;
  end;
end;

{Zur�cksetzen der Punktanzeige des aktiven Zuges}
procedure TFrmLoopIt.resetMovePoints;
var
  movePointsRunner: TMoveDetailIndex;
  currentMovePointsLabel, currentAddedPoints: TLabel;
begin
  // �ber alle Z�ge itererien und die Punktanzeige 0 setzen
  for movePointsRunner := Low(TMoveDetailIndex) to High(TMoveDetailIndex) do
  begin
    currentMovePointsLabel:= TLabel(FindComponent('LblMovePoints' +
                                                  IntToStr(movePointsRunner)));
    currentMovePointsLabel.Caption := '0';
  end;
  // Punktanzeige der addierten Punkte 0 setzen
  currentAddedPoints:= TLabel(FindComponent('LblMovePointsAdded'));
  currentAddedPoints.Caption:= '0';
end;

{Abfrage, ob ein Spiel geladen oder ein neues Spiel gestartet werden soll
in einem extra Fenster und starten der entsprechenden Operation}
procedure TFrmLoopIt.loadQuery;
var
  loadMessage: String;
  selectedButton : Integer;
begin
  // Anzeigen der entsprechenden Nachricht in einem Message Dialog
  loadMessage:= 'Spiel von einer Datei laden? Ansonsten wird ein neues Spiel gestartet.';
  selectedButton:= messagedlg(loadMessage, mtInformation, [mbYes, mbNo], 0);

  // Wurde mit ja best�tigt?
  if selectedButton = mrYes then
    // Spiel laden
    loadGame(True)
  else
    // Ansonsten (auch bei Abbruch) neues Spiel starten
    startNewGame;
end;

{Laden eines Spiels von einer Datei. Das geladene Spiel wird gestartet oder es
wird eine entprechende Fehlermeldung angezeigt
IN: LoadLoop - True, wenn bei einem Fehler oder Abbruch direkt eine neue Abfrage
               erscheinen soll, ob ein Spiel geladen oder neues Spiel gestartet
               werden soll.
GlOBAL: GET UFileIO.readFile - Spieldaten oder Fehlermeldung}
procedure TFrmLoopIt.loadGame(LoadLoop: Boolean);
var
  fileName, errorMessage: String;
  success: Boolean;
begin
  // Initialisierung: (noch) kein Erfolg
  success:= false;

  // Datei Auswahl �ffnen
  if OpnDlgFile.Execute then
  begin
    // Dateinamen zuweisen
    fileName := OpnDlgFile.fileName;

    // Lesen der Datei. Entweder wird das Spiel anhand der Datei aufgebaut oder
    // es wird eine Fehlermeldung erzeugt
    If UFileIO.readFile(fileName, errorMessage) then
    begin
      // Erfolgreich geladen
      success:= true;
      // Initialisierung der Spielernamen
      initializePlayers;
      // Starten des ersten Zuges
      newMove;
    end
    else
      // Fehlermeldung anzeigen
      showMessage(errorMessage);
  end
  else
    // Abbruch Benachrichtigung
    showMessage('Laden abgebrochen');

  // Neuer Versuch n�tig (Kein Erfolg und Schleife aktiv)?
  if not(success) and LoadLoop then
    // Neuen Versuch starten
    loadQuery;
end;

{Startet ein neues Spiel
GLOBAL: GET UPlayerSelection.FrmPlayerSelection - Fenster zur Spielerauswahl
        SET ULogic.newGame - Initialisierung des Spiels
        SET ULogic.setRdmMoveTiles - Zuf�llige Steine f�r die Bank}
procedure TFrmLoopIt.startNewGame;
begin
  // Voriges Spiel beenden
  ULogic.endGame;

  // Spielerauswahl im extra Formular
  // Sobald das Fenster per "X" oder "Spiel starten" geschlossen wird,
  // wird das Spiel gestartet
  if UPlayerSelection.FrmPlayerSelection.ShowModal = mrCancel then
  begin
    // Initialisiere neues Spiel
    ULogic.newGame;

    // Anzeige der Spielernamen im Formular
    initializePlayers;

    // Neue zuf�llige Zug Steine setzen
    ULogic.setRdmForEmptyMoveTiles;

    // Benachrichtigung, wer anfangen darf
    ShowMessage('Das Los hat entschieden: ' +
                UPlayer.getCurrentPlayer.name +
                ' beginnt!');

    // Starten des ersten Zuges
    newMove;
  end;
end;

{Startet ein neuen Zug
GLOBAL GET ULogic.isACurrentMovePossible - True wenn aktueller Zug m�glich
       GET ULogic.isMoveFromSackPossible - True, wenn �berhaupt ein Zug m�glich
       GET UPlayer.getCurrentPlayer - Aktueller Spieler
       GET UPlayer.getWinnerName - Name des Siegers}
procedure TFrmLoopIt.newMove;
begin
  // Gamefield neu zeichnen
  DrwGrdGameField.Refresh;

  // Zug Punkt Anzeige zur�cksetzen
  resetMovePoints;

  // Anzeigen der neuen Steine
  updateMoveTileImages;

  // Kann min. ein Stein der Bank auf das aktuelle Spielfeld gelegt werden?
  if ULogic.isACurrentMovePossible then
  begin
    // Wenn n�tig, KI Zug starten
    if UPlayer.getCurrentPlayer.playerType = ptAI then
      makeAIMove;
  end
  else
  begin
    // Kann min. ein Stein der sich noch im Sack befindet
    // auf das aktuelle Spielfeld gelegt werden?
    if ULogic.isMoveFromSackPossible then
    begin
      // Spieler setzt aus
      showMessage('Keine Ablage mit gezogenen Steinen m�glich. '
                  + UPlayer.getCurrentPlayer.name
                  + ' setzt aus!');
      endMove;
    end
    else
    begin
      // Spiel zu Ende
      showMessage('Keine weitere Ablage m�glich. Sieger: '
                  + UPlayer.getWinnerName);
      // Neues Spiel starten?
      if confirmationQuery('Neues Spiel starten?') then
        startNewGame;
    end;
  end;
end;

{Beenden eines Zuges
GLOBAL GET UPlayer.getCurrentPlayerIndex - Index des aktuellen Spielers
       SET ULogic.endMove - Beenden des Zuges in der Logic
       SET ULogic.setRdmMoveTiles - Zuf�llige Steine f�r die Bank}
procedure TFrmLoopIt.endMove;
var
  oldPlayerIndex: TPlayerIndex;
begin
  // Aktuellen Spieler zwischenspeichern
  oldPlayerIndex:= UPlayer.getCurrentPlayerIndex;

  // Zug beenden. Es wird unter anderem der n�chste Spieler gesetzt
  ULogic.endMove;

  // Aktualisiere Markierungen der Spieler sowie Punkte des vorigen Spielers
  updatePointsAndPlayer(oldPlayerIndex);

  // Neue zuf�llige Zug Steine setzen
  ULogic.setRdmForEmptyMoveTiles;

  // Starte n�chsten Zug
  newMove;
end;

{F�hrt den aktuellen Zug aus, indem ein Stein von der Bank
auf das Spielfeld gesetzt und entsprechend markiert wird
IN: MoveTileIndex - Index des Steins auf der Bank der gesetzt werden soll
IN: Row - Spielfeld Reihe, auf die der Stein abgelegt werden soll
IN: Col - Spielfeld Spalte, auf die der Stein abelegt werden soll
GLOBAL: GET ULogic.getMoveCount - Anzahl der aktuellen Z�ge
        GET ULogic.getCurrentMovePoints - Punkte des Zugs
        GET UPlayer.getAddedMovePoints - Addierte Punkte
        SET ULogic.setMoveTileOnField - Stein auf Feld setzen }
procedure TFrmLoopIt.makeCurrentMove(MoveTileIndex: TMoveTileIndex; Row: TRow; Col:TCol);
var
  selectedImage: TImage;
  currentPoints, currentAddedPoints: TLabel;
begin
  // Setze den Stein auf das Spielfeld in der Logik
  ULogic.setMoveTileOnField(MoveTileIndex, Row, Col);

  // Markiere den gestzen Stein auf der Bank
  selectedImage:= TImage(FindComponent('ImgMoveTile' + IntToStr(MoveTileIndex)));
  drawBorderForCanvas(selectedImage.Canvas, clRed,
                      selectedImage.Width, selectedImage.Height);

  // Aktualisiere die Punktanzeige f�r den aktuellen Zug
  currentPoints:= TLabel(FindComponent('LblMovePoints' + IntToStr(ULogic.getMoveCount-1)));
  currentPoints.Caption := IntToStr(ULogic.getCurrentMovePoints(ULogic.getMoveCount-1));
  currentAddedPoints:= TLabel(FindComponent('LblMovePointsAdded'));
  currentAddedPoints.Caption:= IntToStr(UPlayer.getAddedMovePoints(ULogic.getCurrentMoveDetails,
                                                                   ULogic.getMoveCount));

  // Aktualisiere das Spielfeld
  DrwGrdGameField.Refresh;
end;

{Ausf�hrung eines KI Zuges mit direkter Abbruchm�glichkeit
GLOBAL: GET UPlayer.getCurrentPlayer - Aktueller Spieler
        GET ULogic.getMoveCount - Anzahl Z�ge
        GET UAI.getBestMove - Bester Zug }
procedure TFrmLoopIt.makeAIMove;
var
  selectedImage: TImage;
  bestIndex: TMoveTileIndex;
  bestRow: TRow;
  bestCol: TCol;
  movePossible: Boolean;
  currentPlayer: TPlayer;
begin
  // Initialisierung
  movePossible:= true;

  // Bank Auswahl deaktivieren
  PnlCurrentMove.Enabled:= false;

  // Aktuellen Spieler abspeichern, um abzubrechen Falls Spiel neu gestartet
  // oder geladen wird w�hrend KI am Zug
  currentPlayer:= UPlayer.getCurrentPlayer;

  // F�hre Z�ge aus
  while UPlayer.comparePlayerWithCurrent(currentPlayer) and
        (ULogic.getMoveCount < MAX_MOVE_COUNT) and
        movePossible do
  begin
    // Bereche den bestm�glichsten Zug mit den aktuellen Steinen auf der Bank
    // und �berpr�fe gleichzeitig, ob ein Zug �berhaupt m�glich ist
    movePossible:= UAI.getBestMove(bestIndex, bestRow, bestCol);
    // Ist ein Zug m�glich?
    if movePossible then
    begin
      // Warte falls Spiel nicht abgebrochen
      if waitIfNotCanceled(currentPlayer) then
      begin
        // Markiere Auswahl auf der Bank
        selectedImage:= TImage(FindComponent('ImgMoveTile' + IntToStr(bestIndex)));
        drawBorderForCanvas(selectedImage.Canvas, clBlack,
                            selectedImage.Width, selectedImage.Height);
      end;
      // Warte falls Spiel nicht abgebrochen
      if waitIfNotCanceled(currentPlayer) then
      begin
        // F�hre den Zug aus
        makeCurrentMove(bestIndex, bestRow, bestCol);
      end;
    end;
  end;

  // Bank Auswahl wieder aktivieren
  PnlCurrentMove.Enabled:= true;

  // Warte falls Spiel nicht abgebrochen
  if waitIfNotCanceled(currentPlayer) then
  begin
    // Zug beenden
    endMove;
  end;
end;
{$ENDREGION}

{$REGION 'Formular Methoden - Interaktionen'}
{Verarbeitung f�r das Klicken auf das Bild eines Steins auf der Bank.
GLOBAL: SET ULogic.makeSelection - F�hre Selektion aus, wenn m�glich
        GET ULogic.makeSelection - Wurde selektiert oder deselektiert}
procedure TFrmLoopIt.TileImageClick(Sender: TObject);
var
  image: Timage;
  moveTileIndex: TmoveTileIndex;
  selection: Boolean;
begin
  // Index des geklickten Bildes ermitteln
  image:= (Sender as Timage);
  moveTileIndex:= StrToInt(image.Name[Length(image.Name)]);

  // Selektion ausf�hren, wenn m�glich
  if ULogic.trySelection(moveTileIndex, selection) then
  begin
    // Wurde selektiert oder deselektiert?
    if selection then
      // Schwarzer Rand f�r selektierte Bilder
      drawBorderForCanvas(image.Canvas, clBlack, image.Width, image.Height)
    else
      // Wieder wei�er Rand, wenn Bild deselektiert wurde
      drawBorderForCanvas(image.Canvas, clWhite, image.Width, image.Height);
  end;
end;

{Beenden eines Zuges nachdem der Finish Button geklickt wurde}
procedure TFrmLoopIt.BtnEndMoveClick(Sender: TObject);
begin
  endMove;
end;

{R�ckg�ngig machen des Letzten Zuges nachdem Reset Button gedr�ckt wurde
GLOBAL: SET ULogic.resetLastMove - Letzten Zug in der Logik r�ckg�ngig machen
        GET ULogic.getMoveCount - Anzahl der Z�ge
        GET ULogic.getCurrentMoveTileIndex - Index des zuletzt gesetzten Steins
        GET UPlayer.getAddedMovePoints - Addierte Punkte des aktuellen Zuges}
procedure TFrmLoopIt.BtnRemoveLastTileClick(Sender: TObject);
var
  lastMovePointsLabel, addedMovePointsLabel: TLabel;
  lastSelectedImage, currentSelectedImage: TImage;
begin
  // Aktuelle Selektion zur�cknehmen
  if UTileSelection.getSelectionStatus then
  begin
    UTileSelection.deselect(UTileSelection.getSelectedTileIndex);
    currentSelectedImage:= TImage(FindComponent('ImgMoveTile' +
                                                IntToStr(UTileSelection.getSelectedTileIndex)));
    drawBorderForCanvas(currentSelectedImage.Canvas, clWhite,
                        currentSelectedImage.Width, currentSelectedImage.Height);
  end;

  // Nur wenn bereits ein Zug gemacht wurde
  if ULogic.getMoveCount > 0 then
  begin
     // Letzte Rote Markierung zur�cknehmen
    lastSelectedImage:= TImage(FindComponent('ImgMoveTile' +
                                             IntToStr(ULogic.getCurrentMoveTileIndex)));
    drawBorderForCanvas(lastSelectedImage.Canvas, clWhite,
                        lastSelectedImage.Width, lastSelectedImage.Height);

    // Punktanzeige f�r den letzten Zug zur�cksetzen
    lastMovePointsLabel:= TLabel(FindComponent('LblMovePoints' +
                                               IntToStr(ULogic.getMoveCount-1)));
    lastMovePointsLabel.Caption:= '0';

    // Letzten Zug in der Logik r�ckg�ngig machen
    ULogic.resetLastMove;

    // GameField neu zeichnen
    DrwGrdGameField.refresh;

    // Addierte Punktanzeige aktualisieren
    addedMovePointsLabel:= TLabel(FindComponent('LblMovePointsAdded'));
    addedMovePointsLabel.Caption:= IntToStr(UPlayer.getAddedMovePoints(ULogic.getCurrentMoveDetails,
                                                                       ULogic.getMoveCount));
  end;
end;

{Zeichnen der Zellen des Spielfeldes
GLOBAL GET FIELD_MULTIPLIER - Multiplier f�r das Feld
       GET MULTIPLIER_COLOR - Farbe f�r den Multiplier
       GET UGameField.getTileNameFromField - Name des Steins auf dem Feld}
procedure TFrmLoopIt.DrwGrdGameFieldDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  multiplier: TFieldMultiplier;
  multiplierText: String;
  currentCellImage: TBitmap;
  moveTileIndex: TMoveTileIndex;
begin
  // Multiplier f�r das Feld zuweisen
  multiplier:= FIELD_MULTIPLIER[ARow, ACol];

  // Farbe f�r den Multiplier setzen und einf�rben
  DrwGrdGameField.Canvas.Brush.Color := MULTIPLIER_COLOR[multiplier];
  DrwGrdGameField.Canvas.FillRect(Rect);

  // Ist das Feld leer?
  if UGameField.isFieldEmpty(ARow, ACol) then
  begin
    // Handelt es sich um ein Multiplier Feld?
    if multiplier <> 1 then
    begin
      // H�he des Multipliers inkl. x als Text speichern
      multiplierText:= IntToStr(multiplier) + 'x';
      // Text in die Mitte des Feldes schreiben
      DrwGrdGameField.Canvas.TextOut(Rect.CenterPoint.X-5, Rect.CenterPoint.Y-5, multiplierText);
    end;
  end
  else
  begin
    // Versuchen das Bild des Steins von der Ressource zu laden und zu zeichen
    currentCellImage := TBitmap.Create;
    try
      // Bild von der Ressource Laden
      currentCellImage.LoadFromResourceName(hinstance, 'Tile' +
                                            UGameField.getTileNameFromField(ARow, ACol));
      // Wurde der Stein im aktuellen Zug auf das Feld gesetzt?
      if ULogic.getMoveTileIndexFromTileName(UGameField.getTileNameFromField(ARow, ACol),
                                             moveTileIndex) and
         ULogic.wasTileAlreadyMoved(moveTileIndex) then
      begin
        // Aktuelle Ablagen mit rotem Rand markieren
        drawBorderForCanvas(currentCellImage.Canvas, clRed,
                            currentCellImage.Width, currentCellImage.Height);
      end
      else
        // Sonst mit wei�em Rand �bermalen
        drawBorderForCanvas(currentCellImage.Canvas, clWhite,
                            currentCellImage.Width, currentCellImage.Height);

      // Bild zeichnen
      DrwGrdGameField.Canvas.StretchDraw(Rect, currentCellImage);
    finally
      currentCellImage.Free;
    end;
  end;
end;

{Klick Verabeitung auf eine Spielfeld Zelle
GLOBAL GET UTileSelection.getSelectedTileIndex - Index selektierter Stein auf der Bank
       GET UTileSelection.getSelectionStatus - Ist �berhaupt ein Stein selektiert?
       GET ULogic.isDepositAllowed - Ist ein Ablegen auf diesen Feld erlaubt? }
procedure TFrmLoopIt.DrwGrdGameFieldMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  intRow, intCol: LongInt; // LongInt f�r MouseToCell Parameter
  row: TRow;
  col: TCol;
  selectedIndex: TMoveTileIndex;
begin
  // Reihe und Spalte der geklickten Zelle ermitteln
  DrwGrdGameField.MouseToCell(X, Y, LongInt(intCol), LongInt(intRow));
  row:= intRow;
  col:= intCol;
  // Index des selektierten Steins ermitteln
  selectedIndex:= UTileSelection.getSelectedTileIndex;

  // Wurde Stein selektiert und ist Ablage auf der geklickten Zelle erlaubt
  if UTileSelection.getSelectionStatus and
     ULogic.isDepositAllowed(selectedIndex, row, col) then
  begin
    // F�hre den Zug aus
    makeCurrentMove(selectedIndex, row, col);
  end;
end;

{Anpassungen bei �nderung der Formulargr��e}
procedure TFrmLoopIt.FormResize(Sender: TObject);
begin
  // Buttons und Bank mittig zum Spielfeld setzen
  PnlCurrentMove.Left:= (DrwGrdGameField.Width-PnlCurrentMove.Width)div 2;

  // Neue Spalten Breite berechnen
  DrwGrdGameField.DefaultColWidth := DrwGrdGameField.Width div COL_COUNT - 1;
  // �berlauf verhinden
  if DrwGrdGameField.Width mod COL_COUNT <= 2 then
    DrwGrdGameField.DefaultColWidth:= DrwGrdGameField.DefaultColWidth - 1;

  // Neue Reihen H�he berechnen
  DrwGrdGameField.DefaultRowHeight := DrwGrdGameField.Height div ROW_COUNT - 1;
  // �berlauf verhinden
  if DrwGrdGameField.Height mod ROW_COUNT <= 2 then
    DrwGrdGameField.DefaultRowHeight:= DrwGrdGameField.DefaultRowHeight - 1;
end;

{Sicherheitsabfrage zum Schlie�en des Spiels}
procedure TFrmLoopIt.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // Abfrage im extra Fenster, ob wirklich beendet werden soll
  if confirmationQuery('Wirklich Beenden?') then
  begin
    // Spiel beenden und schlie�en
    ULogic.endGame;
    CanClose := True;
  end
  else
    // Schlie�en verhinden
    CanClose := False;
end;

{Erste Initialisierungen}
procedure TFrmLoopIt.FormCreate(Sender: TObject);
begin
  // Initialisierung f�r Zufalls Zahlen
  Randomize;

  // Default Werte aus Ini Datei Laden
  UFileIO.loadIniFile;
  OpnDlgFile.InitialDir:= UIni.getSaveGameDirectory;
end;

{Eigene Custom Message, die nach dem Anzeigen des Formulars ausgef�hrt wird
Spiel starten (Laden oder neues Spiel) NACHDEM das Formular angezeigt wird}
procedure TFrmLoopIt.WmAfterShow;
begin
  // Spiel Laden oder neues Spiel
  loadQuery;
end;

{Formular wird erst angezeigt und f�hrt dann ein PostMessage aus
um die LoadQuery zu starten NACHDEM das Spiel angezeigt wird}
procedure TFrmLoopIt.FormShow(Sender: TObject);
begin
  // Custom Message WM_AFTER_SHOW zum Formular senden
  if not PostMessage(Self.Handle, WM_AFTER_SHOW, 0, 0) then
  begin
    // Bei Fehler neues Spiel starten
    startNewGame;
  end;
end;

{Laden eines Spiels bei entsprechender Auswahl}
procedure TFrmLoopIt.MnItmLoadClick(Sender: TObject);
var
  queryMessage: string;
begin
  queryMessage:= 'Beim Laden werden ungespeicherte Fortschritte verworfen.'
                  + ' Trotzdem fortfahren?';

  // Best�tigen, ob wirklich gespeichert werden soll
  if confirmationQuery(queryMessage) then
    loadGame(True);
end;

{Neues Spiel starten bei entsprechender Auswahl}
procedure TFrmLoopIt.MnItmNewClick(Sender: TObject);
begin
  // Sicherheitsabfrage in neuem Fenster
  if confirmationQuery('Wirklich neues Spiel starten?') then
  begin
    resetMovePoints;
    ULogic.endGame;
    startNewGame;
  end;
end;

{Speichert den Spielstand in eine auszuw�hlende Datei}
procedure TFrmLoopIt.MnItmSaveClick(Sender: TObject);
var
  fileName, queryMessage: string;
begin
  queryMessage:= 'Beim Speichern wird der aktuelle Zug zur�ckgesetzt.'
                  + ' Trotzdem fortfahren?';

  // Best�tigen, ob wirklich gespeichert werden soll
  if confirmationQuery(queryMessage) then
  begin
    // Datei ausw�hlen
    if OpnDlgFile.Execute then
    begin
      // Aktuellen Zug zur�cksetzen
      ULogic.resetCurrentMoves;
      DrwGrdGameField.Refresh;
      updateMoveTileImages;
      resetMovePoints;

      // Spielstand in Datei schreiben
      fileName := OpnDlgFile.fileName;
      if UFileIO.writeFile(fileName) then
        showMessage('Speichern erfolgreich');
    end
    else
      showMessage('Speichern abgebrochen');
  end;
end;

{Spiel nach Abfrage beenden bei entsprechender Auswahl}
procedure TFrmLoopIt.MnItmEndClick(Sender: TObject);
begin
  Self.Close;
end;

{Anzeigen eines neuen Formulars f�r Default Einstellungen}
procedure TFrmLoopIt.MnItmDefaultValuesClick(Sender: TObject);
begin
  // ShowModal: Das Spiel kann erst fortgesetzt werden,
  // wenn das Einstellungs Formular geschlossen wurde
  if FrmDefaultValues.ShowModal = mrOK then
    // Neuen Pfad f�r gespeicherte Spiele setzen, wenn ok Button
    OpnDlgFile.InitialDir:= UIni.getSaveGameDirectory;
end;
{$ENDREGION}

end.
