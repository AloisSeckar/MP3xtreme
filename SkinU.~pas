/////////////////////////////////////////////////////////////////////
//                                                                 //
//                   MP3 - Master Player 3xtreme                   //
//                     mp3 player and organizer                    //
//                                                                 //
//                  Copyright © Ellrohir 2007-2008                 //
//                                                                 //
//                                                                 //
//    Page Info                                                    //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// *  Author:         *  Ellrohir [ ellrohir@seznam.cz ]         * //
// *  Homepage:       *  http://ellrohir.xf.cz/                  * //
// *  File:           *  SkinU.pas                               * //
// *  Purpose:        *  Appearance selection and customization  * //
// *  System Version: *  1.0                                     * //
// *  Last Modified:  *  2008-03-09 1345 GMT+1                   * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
/////////////////////////////////////////////////////////////////////

unit SkinU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ExtDlgs;

type
  TSkinW = class(TForm)
    ColorDialog1: TColorDialog;
    OpenPictureDialog1: TOpenPictureDialog;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    BGColor: TShape;
    BGImage: TImage;
    Label4: TLabel;
    Label5: TLabel;
    FontColor1: TShape;
    FontColor2: TShape;
    Label6: TLabel;
    TrackBGColor: TShape;
    Skin: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    FontColor3: TShape;
    SetBGColor: TButton;
    SetBGPicture: TButton;
    SetFontColor1: TButton;
    SetFontColor2: TButton;
    SetTrackBGColor: TButton;
    CloseB: TButton;
    SetB: TButton;
    SkinSelection: TComboBox;
    SetFontColor3: TButton;
    procedure AlignLabels;
    procedure SetBGColorClick(Sender: TObject);
    procedure SetBGPictureClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CloseBClick(Sender: TObject);
    procedure SetBClick(Sender: TObject);
    procedure SkinSelectionChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SkinW: TSkinW;

implementation

uses Main, MP3Utilities, SettingsU;

{$R *.dfm}

procedure TSkinW.AlignLabels;
begin
// dunno why... (it must be when the font is alinged to right)
Label1.Left:=15;
Label2.Left:=15;
Label3.Left:=15;
Label4.Left:=15;
Label5.Left:=15;
Label6.Left:=15;
Label7.Left:=15;
Label8.Left:=15;
end;

procedure TSkinW.SetBGColorClick(Sender: TObject);
// assign selected color to specific parameter
begin
Skin.Caption:='Custom';
if ColorDialog1.Execute then case (Sender as TButton).Tag of
                             1: BGColor.Brush.Color:=ColorDialog1.Color;
                             2: FontColor1.Brush.Color:=ColorDialog1.Color;
                             3: FontColor2.Brush.Color:=ColorDialog1.Color;
                             4: TrackBGColor.Brush.Color:=ColorDialog1.Color;
                             5: FontColor3.Brush.Color:=ColorDialog1.Color;
                             end;
end;

procedure TSkinW.SetBGPictureClick(Sender: TObject);
begin
Skin.Caption:='Custom';
//OpenPictureDialog1.FileName:=
if OpenPictureDialog1.Execute then try
                                   BGImage.Picture.LoadFromFile(OpenPictureDialog1.FileName);
                                   except
                                   // nothing so far
                                   end;
end;

procedure TSkinW.FormCreate(Sender: TObject);
begin
// setting current values
if Main.Settings.Skin.SkinName<>'Custom' then begin
                                Skin.Caption:='Custom';
                                SkinSelection.Text:='Custom';
                               //CheckLastBackslash(InitDir);
                               try
                               OpenPictureDialog1.FileName:=InitDir+'Empty.jpg';
                               BGImage.Picture.LoadFromFile(InitDir+'Empty.jpg');
                               except
                                // if this failes, the whole program is about to crash
                                ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'Empty.jpg'+TranslateText('FEMissingFile2',Settings.Lang));
                                CrucialE:=true; // the program must be terminated with no asking
                                SkinW.Close;
                                Form1.Close;
                               end;
                               BGColor.Brush.Color:=clWhite;
                               FontColor1.Brush.Color:=clBlack;
                               FontColor2.Brush.Color:=clBlack;
                               FontColor3.Brush.Color:=clBlack;
                               SetTrackBGColor.Brush.Color:=clGray;
                               end
                          else begin
                               Skin.Caption:=Main.Settings.Skin.SkinName;
                               SkinSelection.Text:=Main.Settings.Skin.SkinName;
                               try
                               OpenPictureDialog1.FileName:=Main.Settings.Skin.BGImage;
                               BGImage.Picture.LoadFromFile(Settings.Skin.BGImage);
                               except
                                try
                                OpenPictureDialog1.FileName:=InitDir+'Empty.jpg';
                                BGImage.Picture.LoadFromFile(InitDir+'Empty.jpg');
                                except
                                // if this failes, the whole program is about to crash
                                ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'Empty.jpg'+TranslateText('FEMissingFile2',Settings.Lang));
                                CrucialE:=true; // the program must be terminated with no asking
                                SkinW.Close;
                                Form1.Close;
                                end;
                               end;
                               BGColor.Brush.Color:=Main.Settings.Skin.BGColor;
                               FontColor1.Brush.Color:=Main.Settings.Skin.FontColor1;
                               FontColor2.Brush.Color:=Main.Settings.Skin.FontColor2;
                               FontColor3.Brush.Color:=Main.Settings.Skin.FontColor3;
                               TrackBGColor.Brush.Color:=Main.Settings.Skin.TrackBG;
                               end;
AlignLabels;
end;

procedure TSkinW.CloseBClick(Sender: TObject);
begin
SkinW.Close;
end;

procedure TSkinW.SetBClick(Sender: TObject);
begin
// setting actual selection
Settings.Skin.BGImage:=OpenPictureDialog1.FileName;
Settings.Skin.BGColor:=BGColor.Brush.Color;
Settings.Skin.FontColor1:=FontColor1.Brush.Color;
Settings.Skin.FontColor2:=FontColor2.Brush.Color;
Settings.Skin.FontColor3:=FontColor3.Brush.Color;
Settings.Skin.TrackBG:=TrackBGColor.Brush.Color;
Form1.ChangeSkin(Skin.Caption);
RepaintForm('SkinW'); // specially repain this form
if SettingsU.Opened then RepaintForm('SettingsW'); // repaint this form if is opened under this window
AlignLabels;
end;

procedure TSkinW.SkinSelectionChange(Sender: TObject);
begin
case SkinSelection.ItemIndex of
0: begin
   Skin.Caption:='Default';
   try
    OpenPictureDialog1.FileName:=Main.InitDir+'Skins\Default\background.jpg';
    BGImage.Picture.LoadFromFile(Main.InitDir+'Skins\Default\background.jpg');
   except
    // if this failes, the whole program is about to crash
    ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'Skins\Default\background.jpg'+TranslateText('FEMissingFile2',Settings.Lang));
    CrucialE:=true; // the program must be terminated with no asking
    Form1.Close;
   end;
   BGColor.Brush.Color:=clGray;
   FontColor1.Brush.Color:=clBlack;
   FontColor2.Brush.Color:=clWhite;
   FontColor3.Brush.Color:=clGreen;
   TrackBGColor.Brush.Color:=clTeal;
   end;
1: begin
   Skin.Caption:='Electric Blue';
   try
    OpenPictureDialog1.FileName:=Main.InitDir+'Skins\Electric Blue\background.jpg';
    BGImage.Picture.LoadFromFile(InitDir+'Skins\Electric Blue\background.jpg');
   except
    try
     OpenPictureDialog1.FileName:=Main.InitDir+'Skins\Default\background.jpg';
     BGImage.Picture.LoadFromFile(Main.InitDir+'Skins\Default\background.jpg');
     ShowMessage(TranslateText('ECorruptedImageBG',Settings.Lang));
    except
     // if this failes, the whole program is about to crash
     ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'Skins\Default\background.jpg'+TranslateText('FEMissingFile2',Settings.Lang));CrucialE:=true; // the program must be terminated with no asking
     Form1.Close;
    end;
   end;
   BGColor.Brush.Color:=13100669;
   FontColor1.Brush.Color:=4227072;
   FontColor2.Brush.Color:=clBlack;
   FontColor2.Brush.Color:=32768;
   TrackBGColor.Brush.Color:=clBlack;
   end;
2: begin
   Skin.Caption:='Dark Deep Ocean';
   try
    OpenPictureDialog1.FileName:=Main.InitDir+'Skins\Dark Deep Ocean\background.jpg';
    BGImage.Picture.LoadFromFile(InitDir+'Skins\Dark Deep Ocean\background.jpg');
   except
    try
     OpenPictureDialog1.FileName:=Main.InitDir+'Skins\Default\background.jpg';
     BGImage.Picture.LoadFromFile(Main.InitDir+'Skins\Default\background.jpg');
     ShowMessage(TranslateText('ECorruptedImageBG',Settings.Lang));
    except
     // if this failes, the whole program is about to crash
     ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'Skins\Default\background.jpg'+TranslateText('FEMissingFile2',Settings.Lang));CrucialE:=true; // the program must be terminated with no asking
     Form1.Close;
    end;
   end;
   BGColor.Brush.Color:=12615808;
   FontColor1.Brush.Color:=4194304;
   FontColor2.Brush.Color:=clBlack;
   FontColor3.Brush.Color:=151;
   TrackBGColor.Brush.Color:=clBlack;
   end;
3: begin
   Skin.Caption:='Nymphomaniac Phantasia';
   try
    OpenPictureDialog1.FileName:=Main.InitDir+'Skins\Nymphomaniac Phantasia\background.jpg';
    BGImage.Picture.LoadFromFile(InitDir+'Skins\Nymphomaniac Phantasia\background.jpg');
   except
    try
     OpenPictureDialog1.FileName:=Main.InitDir+'Skins\Default\background.jpg';
     BGImage.Picture.LoadFromFile(Main.InitDir+'Skins\Default\background.jpg');
     ShowMessage(TranslateText('ECorruptedImageBG',Settings.Lang));
    except
     // if this failes, the whole program is about to crash
     ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'Skins\Default\background.jpg'+TranslateText('FEMissingFile2',Settings.Lang));CrucialE:=true; // the program must be terminated with no asking
     Form1.Close;
    end;
   end;
   BGColor.Brush.Color:=1710845;
   FontColor1.Brush.Color:=clWhite;
   FontColor2.Brush.Color:=clBlack;
   FontColor3.Brush.Color:=clBlack;
   TrackBGColor.Brush.Color:=clBlack;
   end;
end;

end;

end.
