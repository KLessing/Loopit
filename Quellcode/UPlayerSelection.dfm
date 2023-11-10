object FrmPlayerSelection: TFrmPlayerSelection
  Left = 0
  Top = 0
  Caption = 'LoopIt Spielerauswahl'
  ClientHeight = 300
  ClientWidth = 500
  Color = clBtnFace
  Constraints.MaxHeight = 339
  Constraints.MaxWidth = 516
  Constraints.MinHeight = 339
  Constraints.MinWidth = 516
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LblActivatePlayer: TLabel
    Left = 21
    Top = 19
    Width = 113
    Height = 16
    Caption = 'Spieler aktivieren'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LblPlayerType: TLabel
    Left = 337
    Top = 19
    Width = 68
    Height = 16
    Caption = 'Steuerung'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object LblChooseName: TLabel
    Left = 161
    Top = 19
    Width = 108
    Height = 16
    Caption = 'Name ausw'#228'hlen'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object PnlPlayer0: TPanel
    Left = 21
    Top = 48
    Width = 455
    Height = 42
    TabOrder = 0
    object ChckBxPlayerActive0: TCheckBox
      Left = 4
      Top = 16
      Width = 97
      Height = 13
      Caption = 'Spieler 1'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 0
    end
    object EdtPlayerName0: TEdit
      Left = 140
      Top = 12
      Width = 137
      Height = 21
      MaxLength = 12
      TabOrder = 1
      Text = 'Spieler1'
    end
    object RdGrpPlayerControl0: TRadioGroup
      Left = 311
      Top = 4
      Width = 138
      Height = 35
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'Mensch'
        'Computer')
      TabOrder = 2
    end
  end
  object PnlPlayer1: TPanel
    Left = 21
    Top = 98
    Width = 455
    Height = 42
    TabOrder = 1
    object EdtPlayerName1: TEdit
      Left = 140
      Top = 12
      Width = 137
      Height = 21
      MaxLength = 12
      TabOrder = 0
      Text = 'Spieler2'
    end
    object ChckBxPlayerActive1: TCheckBox
      Left = 4
      Top = 16
      Width = 97
      Height = 13
      Caption = 'Spieler 2'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 1
    end
    object RdGrpPlayerControl1: TRadioGroup
      Left = 311
      Top = 4
      Width = 138
      Height = 35
      Columns = 2
      ItemIndex = 1
      Items.Strings = (
        'Mensch'
        'Computer')
      TabOrder = 2
    end
  end
  object PnlPlayer2: TPanel
    Left = 21
    Top = 148
    Width = 455
    Height = 42
    TabOrder = 2
    object EdtPlayerName2: TEdit
      Left = 140
      Top = 12
      Width = 137
      Height = 21
      Enabled = False
      MaxLength = 12
      TabOrder = 0
      Text = 'Spieler3'
    end
    object ChckBxPlayerActive2: TCheckBox
      Left = 4
      Top = 16
      Width = 97
      Height = 17
      Caption = 'Spieler 3'
      TabOrder = 1
      OnClick = ChckBxPlayerActive2Click
    end
    object RdGrpPlayerControl2: TRadioGroup
      Left = 311
      Top = 4
      Width = 138
      Height = 35
      Columns = 2
      Enabled = False
      ItemIndex = 1
      Items.Strings = (
        'Mensch'
        'Computer')
      TabOrder = 2
    end
  end
  object PnlPlayer3: TPanel
    Left = 21
    Top = 198
    Width = 455
    Height = 42
    TabOrder = 3
    object ChckBxPlayerActive3: TCheckBox
      Left = 4
      Top = 16
      Width = 97
      Height = 17
      Caption = 'Spieler 4'
      TabOrder = 0
      OnClick = ChckBxPlayerActive3Click
    end
    object EdtPlayerName3: TEdit
      Left = 140
      Top = 12
      Width = 137
      Height = 21
      Enabled = False
      MaxLength = 12
      TabOrder = 1
      Text = 'Spieler4'
    end
    object RdGrpPlayerControl3: TRadioGroup
      Left = 311
      Top = 4
      Width = 138
      Height = 35
      Columns = 2
      Enabled = False
      ItemIndex = 1
      Items.Strings = (
        'Mensch'
        'Computer')
      TabOrder = 2
    end
  end
  object BtnStartGame: TButton
    Left = 161
    Top = 253
    Width = 137
    Height = 34
    Caption = 'Spiel starten'
    TabOrder = 4
    OnClick = BtnStartGameClick
  end
end
