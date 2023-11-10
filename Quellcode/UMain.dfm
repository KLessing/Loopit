object FrmLoopIt: TFrmLoopIt
  Left = 480
  Top = 166
  Caption = 'LoopIt'
  ClientHeight = 445
  ClientWidth = 675
  Color = clBtnFace
  Constraints.MinHeight = 504
  Constraints.MinWidth = 691
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MnMnGame
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    675
    445)
  PixelsPerInch = 96
  TextHeight = 13
  object PnlCurrentMove: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 365
    Width = 542
    Height = 80
    Anchors = [akBottom]
    Locked = True
    TabOrder = 0
    object PnlMoveTiles: TPanel
      Left = 91
      Top = 8
      Width = 360
      Height = 64
      Locked = True
      TabOrder = 0
      object ImgMoveTile0: TImage
        Left = 8
        Top = 8
        Width = 56
        Height = 48
        OnClick = TileImageClick
      end
      object ImgMoveTile1: TImage
        Left = 80
        Top = 8
        Width = 56
        Height = 48
        OnClick = TileImageClick
      end
      object ImgMoveTile2: TImage
        Left = 152
        Top = 8
        Width = 56
        Height = 48
        OnClick = TileImageClick
      end
      object ImgMoveTile3: TImage
        Left = 224
        Top = 8
        Width = 56
        Height = 48
        OnClick = TileImageClick
      end
      object ImgMoveTile4: TImage
        Left = 294
        Top = 8
        Width = 56
        Height = 48
        OnClick = TileImageClick
      end
    end
    object BtnEndMove: TButton
      Left = 470
      Top = 16
      Width = 56
      Height = 48
      Caption = 'Finish'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = BtnEndMoveClick
    end
    object BtnRemoveLastTile: TButton
      Left = 16
      Top = 16
      Width = 56
      Height = 48
      Caption = 'Reset'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = BtnRemoveLastTileClick
    end
  end
  object PnlCurrentPoints: TPanel
    Left = 542
    Top = 184
    Width = 133
    Height = 183
    Anchors = [akTop, akRight]
    TabOrder = 1
    object LblCurrentPointsHeadline: TLabel
      Left = 8
      Top = 8
      Width = 118
      Height = 13
      Caption = 'Punkte aktueller Zug'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblNameTile1: TLabel
      Left = 10
      Top = 37
      Width = 33
      Height = 13
      Caption = 'Stein 1'
    end
    object LblNameTile2: TLabel
      Left = 10
      Top = 66
      Width = 33
      Height = 13
      Caption = 'Stein 2'
    end
    object LblNameTile3: TLabel
      Left = 10
      Top = 95
      Width = 33
      Height = 13
      Caption = 'Stein 3'
    end
    object LblMovePoints0: TLabel
      Left = 105
      Top = 37
      Width = 6
      Height = 13
      Caption = '0'
    end
    object LblMovePoints1: TLabel
      Left = 105
      Top = 66
      Width = 6
      Height = 13
      Caption = '0'
    end
    object LblMovePoints2: TLabel
      Left = 105
      Top = 95
      Width = 6
      Height = 13
      Caption = '0'
    end
    object LblNameAddedPoints: TLabel
      Left = 10
      Top = 124
      Width = 36
      Height = 13
      Caption = 'Gesamt'
    end
    object LblMovePointsAdded: TLabel
      Left = 105
      Top = 124
      Width = 6
      Height = 13
      Caption = '0'
    end
  end
  object PnlPoints: TPanel
    Left = 542
    Top = 0
    Width = 133
    Height = 183
    Anchors = [akTop, akRight]
    TabOrder = 2
    object LblPlayerHeadline: TLabel
      Left = 8
      Top = 8
      Width = 39
      Height = 13
      Caption = 'Spieler'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblNamePlayer0: TLabel
      Left = 8
      Top = 37
      Width = 41
      Height = 13
      Caption = 'Spieler 1'
      Color = clBtnFace
      ParentColor = False
      Visible = False
    end
    object LblNamePlayer1: TLabel
      Left = 8
      Top = 69
      Width = 41
      Height = 13
      Caption = 'Spieler 2'
      Visible = False
    end
    object LblNamePlayer3: TLabel
      Left = 8
      Top = 133
      Width = 41
      Height = 13
      Caption = 'Spieler 4'
      Visible = False
    end
    object LblNamePlayer2: TLabel
      Left = 8
      Top = 101
      Width = 41
      Height = 13
      Caption = 'Spieler 3'
      Visible = False
    end
    object LblPointsHeadline: TLabel
      Left = 89
      Top = 8
      Width = 40
      Height = 13
      Caption = 'Punkte'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblPointsPlayer0: TLabel
      Left = 105
      Top = 37
      Width = 6
      Height = 13
      Caption = '0'
      Visible = False
    end
    object LblPointsPlayer1: TLabel
      Left = 105
      Top = 69
      Width = 6
      Height = 13
      Caption = '0'
      Visible = False
    end
    object LblPointsPlayer2: TLabel
      Left = 105
      Top = 101
      Width = 6
      Height = 13
      Caption = '0'
      Visible = False
    end
    object LblPointsPlayer3: TLabel
      Left = 105
      Top = 133
      Width = 6
      Height = 13
      Caption = '0'
      Visible = False
    end
  end
  object DrwGrdGameField: TDrawGrid
    Left = 0
    Top = 0
    Width = 542
    Height = 367
    Align = alCustom
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clBlue
    ColCount = 11
    DefaultColWidth = 48
    DefaultRowHeight = 32
    RowCount = 11
    TabOrder = 3
    OnDrawCell = DrwGrdGameFieldDrawCell
    OnMouseUp = DrwGrdGameFieldMouseUp
  end
  object MnMnGame: TMainMenu
    Left = 632
    Top = 400
    object MnItmGame: TMenuItem
      Caption = 'Spiel'
      object MnItmNew: TMenuItem
        Caption = 'Neu'
        OnClick = MnItmNewClick
      end
      object MnItmSave: TMenuItem
        Caption = 'Speichern'
        OnClick = MnItmSaveClick
      end
      object MnItmLoad: TMenuItem
        Caption = 'Laden'
        OnClick = MnItmLoadClick
      end
      object MnItmEnd: TMenuItem
        Caption = 'Beenden'
        OnClick = MnItmEndClick
      end
    end
    object MnItmSettings: TMenuItem
      Caption = 'Einstellungen'
      object MnItmDefaultValues: TMenuItem
        Caption = 'Default Werte'
        OnClick = MnItmDefaultValuesClick
      end
    end
  end
  object OpnDlgFile: TOpenDialog
    DefaultExt = '.lit'
    Filter = 'LoopIt Datei (*.lit)|*.lit'
    Left = 584
    Top = 400
  end
end
