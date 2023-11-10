program LoopIt;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FrmLoopIt},
  UTypes in 'UTypes.pas',
  UTiles in 'UTiles.pas',
  UDirectionTypes in 'UDirectionTypes.pas',
  ULogic in 'ULogic.pas',
  UPlayerSelection in 'UPlayerSelection.pas' {FrmPlayerSelection},
  UDirections in 'UDirections.pas',
  UFileIO in 'UFileIO.pas',
  UIni in 'UIni.pas',
  UDefaultValues in 'UDefaultValues.pas' {FrmDefaultValues},
  UAI in 'UAI.pas',
  UPlayer in 'UPlayer.pas',
  UGameField in 'UGameField.pas',
  UTileSelection in 'UTileSelection.pas',
  UFileValidation in 'UFileValidation.pas',
  UGameFieldTypes in 'UGameFieldTypes.pas',
  UPlayerTypes in 'UPlayerTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmLoopIt, FrmLoopIt);
  Application.CreateForm(TFrmPlayerSelection, FrmPlayerSelection);
  Application.CreateForm(TFrmDefaultValues, FrmDefaultValues);
  Application.Run;
end.
