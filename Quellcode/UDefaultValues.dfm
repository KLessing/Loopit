object FrmDefaultValues: TFrmDefaultValues
  Left = 0
  Top = 0
  Caption = 'Default Werte'
  ClientHeight = 307
  ClientWidth = 294
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 35
    Width = 95
    Height = 13
    Caption = 'Default Verzeichnis:'
  end
  object Label2: TLabel
    Left = 24
    Top = 82
    Width = 68
    Height = 13
    Caption = 'Spielername1:'
  end
  object Label3: TLabel
    Left = 24
    Top = 109
    Width = 68
    Height = 13
    Caption = 'Spielername2:'
  end
  object Label4: TLabel
    Left = 24
    Top = 136
    Width = 68
    Height = 13
    Caption = 'Spielername3:'
  end
  object Label5: TLabel
    Left = 24
    Top = 163
    Width = 68
    Height = 13
    Caption = 'Spielername4:'
  end
  object Label6: TLabel
    Left = 24
    Top = 208
    Width = 99
    Height = 13
    Caption = 'KI Wartezeit (in ms):'
  end
  object EdtSaveDirectory: TEdit
    Left = 149
    Top = 32
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object EdtPlayerName0: TEdit
    Left = 149
    Top = 79
    Width = 121
    Height = 21
    MaxLength = 12
    TabOrder = 1
  end
  object EdtPlayerName1: TEdit
    Left = 149
    Top = 106
    Width = 121
    Height = 21
    MaxLength = 12
    TabOrder = 2
  end
  object EdtPlayerName2: TEdit
    Left = 149
    Top = 133
    Width = 121
    Height = 21
    MaxLength = 12
    TabOrder = 3
  end
  object EdtPlayerName3: TEdit
    Left = 149
    Top = 160
    Width = 121
    Height = 21
    MaxLength = 12
    TabOrder = 4
  end
  object EdtAIDelay: TEdit
    Left = 149
    Top = 205
    Width = 121
    Height = 21
    MaxLength = 4
    NumbersOnly = True
    TabOrder = 5
  end
  object BtnOk: TButton
    Left = 48
    Top = 251
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 6
    OnClick = BtnOkClick
  end
  object BtnCancel: TButton
    Left = 171
    Top = 251
    Width = 75
    Height = 25
    Caption = 'Abbrechen'
    TabOrder = 7
    OnClick = BtnCancelClick
  end
end
