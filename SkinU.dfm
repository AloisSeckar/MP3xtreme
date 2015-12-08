object SkinW: TSkinW
  Left = 715
  Top = 11
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'MP3 - Custom Visual Appearance'
  ClientHeight = 336
  ClientWidth = 322
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 5
    Top = 5
    Width = 310
    Height = 325
    Caption = 'Set Color Settings'
    Color = clGray
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    TabOrder = 0
    object Label1: TLabel
      Left = 116
      Top = 85
      Width = 160
      Height = 13
      Alignment = taRightJustify
      Caption = 'Backrground Color :'
      Constraints.MaxWidth = 160
      Constraints.MinWidth = 160
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 108
      Top = 105
      Width = 160
      Height = 13
      Alignment = taRightJustify
      Caption = 'Backrground Image :'
      Constraints.MaxWidth = 160
      Constraints.MinWidth = 160
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 223
      Top = 25
      Width = 160
      Height = 13
      Alignment = taRightJustify
      Caption = 'Current Skin :'
      Constraints.MaxWidth = 160
      Constraints.MinWidth = 160
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object BGColor: TShape
      Left = 190
      Top = 85
      Width = 60
      Height = 13
    end
    object BGImage: TImage
      Left = 190
      Top = 105
      Width = 60
      Height = 60
      Stretch = True
    end
    object Label4: TLabel
      Left = 229
      Top = 180
      Width = 160
      Height = 13
      Alignment = taRightJustify
      Caption = 'Font Color 1 :'
      Constraints.MaxWidth = 160
      Constraints.MinWidth = 160
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 229
      Top = 200
      Width = 160
      Height = 13
      Alignment = taRightJustify
      Caption = 'Font Color 2 :'
      Constraints.MaxWidth = 160
      Constraints.MinWidth = 160
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object FontColor1: TShape
      Left = 190
      Top = 180
      Width = 60
      Height = 13
    end
    object FontColor2: TShape
      Left = 190
      Top = 200
      Width = 60
      Height = 13
    end
    object Label6: TLabel
      Left = 52
      Top = 250
      Width = 160
      Height = 13
      Alignment = taRightJustify
      Caption = 'Tracklist Background :'
      Constraints.MaxWidth = 160
      Constraints.MinWidth = 160
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object TrackBGColor: TShape
      Left = 190
      Top = 250
      Width = 60
      Height = 13
    end
    object Skin: TLabel
      Left = 193
      Top = 25
      Width = 28
      Height = 13
      Caption = 'Skin'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 250
      Top = 50
      Width = 160
      Height = 13
      Alignment = taRightJustify
      Caption = 'Select Skin :'
      Constraints.MaxWidth = 160
      Constraints.MinWidth = 160
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label8: TLabel
      Left = 229
      Top = 220
      Width = 160
      Height = 13
      Alignment = taRightJustify
      Caption = 'Font Color 3 :'
      Constraints.MaxWidth = 160
      Constraints.MinWidth = 160
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object FontColor3: TShape
      Left = 190
      Top = 220
      Width = 60
      Height = 13
    end
    object SetBGColor: TButton
      Tag = 1
      Left = 255
      Top = 85
      Width = 41
      Height = 15
      Caption = '...'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = SetBGColorClick
    end
    object SetBGPicture: TButton
      Left = 255
      Top = 105
      Width = 41
      Height = 15
      Caption = '...'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = SetBGPictureClick
    end
    object SetFontColor1: TButton
      Tag = 2
      Left = 255
      Top = 180
      Width = 41
      Height = 15
      Caption = '...'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      OnClick = SetBGColorClick
    end
    object SetFontColor2: TButton
      Tag = 3
      Left = 255
      Top = 200
      Width = 41
      Height = 15
      Caption = '...'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      OnClick = SetBGColorClick
    end
    object SetTrackBGColor: TButton
      Tag = 4
      Left = 255
      Top = 250
      Width = 41
      Height = 15
      Caption = '...'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = SetBGColorClick
    end
    object CloseB: TButton
      Left = 191
      Top = 291
      Width = 75
      Height = 25
      Caption = 'Close'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = CloseBClick
    end
    object SetB: TButton
      Left = 100
      Top = 291
      Width = 75
      Height = 25
      Caption = 'Set'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      OnClick = SetBClick
    end
    object SkinSelection: TComboBox
      Left = 190
      Top = 45
      Width = 106
      Height = 21
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ItemHeight = 13
      ParentFont = False
      TabOrder = 7
      Text = 'SkinSelection'
      OnChange = SkinSelectionChange
      Items.Strings = (
        'Grayling'
        'Electric Blue'
        'Dark Deep Ocean'
        'Nymphomaniac Phantasia')
    end
    object SetFontColor3: TButton
      Tag = 5
      Left = 255
      Top = 220
      Width = 41
      Height = 15
      Caption = '...'
      Font.Charset = EASTEUROPE_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Verdana'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 8
      OnClick = SetBGColorClick
    end
  end
  object ColorDialog1: TColorDialog
    Ctl3D = True
    Left = 45
    Top = 290
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 'JPEG Image File (*.jpg;*.jpeg)|*.jpg;*.jpeg'
    Left = 15
    Top = 290
  end
end
