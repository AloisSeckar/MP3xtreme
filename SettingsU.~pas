/////////////////////////////////////////////////////////////////////
//                                                                 //
//                   MP3 - Master Player 3xtreme                   //
//                     mp3 player and organizer                    //
//                                                                 //
//                 Copyright © Ellrohir 2007-2008                  //
//                                                                 //
//                                                                 //
//    Page Info                                                    //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// *  Author:         *  Ellrohir [ ellrohir@seznam.cz ]         * //
// *  Homepage:       *  http://ellrohir.xf.cz/                  * //
// *  File:           *  SettingsU.pas                           * //
// *  Purpose:        *  Various program settings customization  * //
// *  System Version: *  1.0                                     * //
// *  Last Modified:  *  2008-03-09 1815 GMT+1                   * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
/////////////////////////////////////////////////////////////////////

unit SettingsU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls;

type
  TSettingsW = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    BGOpt1: TRadioButton;
    BGOpt3: TRadioButton;
    BGOpt2: TRadioButton;
    GroupBox3: TGroupBox;
    ARewind: TCheckBox;
    OkB: TButton;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    OkB2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MP3Res: TComboBox;
    MP3Skin: TComboBox;
    MP3Lang: TComboBox;
    OptID3v1: TRadioButton;
    OptID3v2: TRadioButton;
    Label4: TLabel;
    ConvertTags: TCheckBox;
    GroupBox7: TGroupBox;
    CloseB: TButton;
    GroupBox8: TGroupBox;
    StartOpt1: TRadioButton;
    StartOpt2: TRadioButton;
    GroupBox9: TGroupBox;
    FileOpt1: TRadioButton;
    FileOpt2: TRadioButton;
    GroupBox10: TGroupBox;
    SizeOpt1: TRadioButton;
    SizeOpt2: TRadioButton;
    SizeOpt3: TRadioButton;
    GroupBox11: TGroupBox;
    WDirPath: TEdit;
    OwnSkin: TButton;
    BGOpt4: TRadioButton;
    KillTags: TCheckBox;
    GroupBox12: TGroupBox;
    ASetOpt1: TRadioButton;
    ASetOpt2: TRadioButton;
    BGImage: TImage;
    ACTrOpt1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure OkBClick(Sender: TObject);
    procedure OkB2Click(Sender: TObject);
    procedure CloseBClick(Sender: TObject);
    procedure OwnSkinClick(Sender: TObject);
    procedure MP3SkinChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SettingsW: TSettingsW;
  Opened: boolean;

implementation

uses Main, SkinU, PlayerU, MP3Utilities;

{$R *.dfm}

procedure TSettingsW.FormCreate(Sender: TObject);
// inicializations according to the current settings
begin
Opened:=true;
if Main.Settings.Skin.SkinName='Default' then MP3Skin.ItemIndex:=0
                                         else MP3Skin.ItemIndex:=1;
case Main.Settings.ResH of
600: MP3Res.ItemIndex:=0;
756: MP3Res.ItemIndex:=1;
800: MP3Res.ItemIndex:=2;
end;
case Main.Settings.FSiz of
1: SizeOpt1.Checked:=true;
1000: SizeOpt2.Checked:=true;
1000000: SizeOpt3.Checked:=true;
end;
if Main.Settings.Lang='ENG' then MP3Lang.ItemIndex:=0 else
if Main.Settings.Lang='CZE' then MP3Lang.ItemIndex:=1;
if Main.Settings.Bckg='Ameoba' then BGOpt1.Checked:=true else
if Main.Settings.Bckg='Flowers' then BGOpt2.Checked:=true else
if Main.Settings.Bckg='Universe' then BGOpt3.Checked:=true else
if Main.Settings.Bckg='Lights' then BGOpt4.Checked:=true;
if Main.Settings.ARwd then ARewind.Checked:=true;
if Main.Settings.ID3V then OptID3v2.Checked:=true
                      else OptID3v1.Checked:=true;
if Main.Settings.ALod then StartOpt2.Checked:=true
                      else StartOpt1.Checked:=true;
if Main.Settings.ADel then FileOpt2.Checked:=true
                      else FileOpt1.Checked:=true;
if Main.Settings.ASet then ASetOpt1.Checked:=true
                      else ASetOpt2.Checked:=true;
if Main.Settings.ACTr then ACTrOpt1.Checked:=true;
WDirPath.Text:=Main.Settings.WDir;
end;

procedure TSettingsW.OkBClick(Sender: TObject);
begin
if BGOpt1.Checked then begin
                       Form1.BgOpt1.Checked:=true;
                       Main.Settings.Bckg:='Ameoba';
                       if Main.PlayStatement then begin // if playing in progres, the window should been changed
                                                  Form1.GenericBG.Canvas.Pen.Width:=5;
                                                  Form1.GenericBG.Canvas.Brush.Color:=clBlack;
                                                  Form1.GenericBG.Canvas.Pen.Color:=clBlack;
                                                  Form1.GenericBG.Canvas.Rectangle(0,0,665,320);
                                                  ResetAmeobaPosition;   // in PlayerU.dcu
                                                  RandomizeGenericBrushForAmeoba;  // in PlayerU.dcu
                                                  end;
                       end else
if BGOpt2.Checked then begin
                       Form1.BgOpt2.Checked:=true;
                       Main.Settings.Bckg:='Flowers';
                       if Main.PlayStatement then begin // if playing in progres, the window should been changed
                                                  Form1.GenericBG.Canvas.Pen.Width:=1;
                                                  Form1.GenericBG.Canvas.Brush.Color:=clBlack;
                                                  Form1.GenericBG.Canvas.Pen.Color:=clBlack;
                                                  Form1.GenericBG.Canvas.Rectangle(0,0,665,320);
                                                  RandomizeGenericBrushForGeneric;  // in PlayerU.dcu
                                                  end;
                       end else
if BGOpt3.Checked then begin
                       Form1.BgOpt3.Checked:=true;
                       Main.Settings.Bckg:='Universe';
                       if Main.PlayStatement then begin // if playing in progres, the window should been changed
                                                  Form1.GenericBG.Canvas.Brush.Color:=clBlack;
                                                  Form1.GenericBG.Canvas.Pen.Color:=clBlack;
                                                  Form1.GenericBG.Canvas.Rectangle(0,0,665,320);
                                                  end;
                       end else
if BGOpt4.Checked then begin
                       Form1.BgOpt4.Checked:=true;
                       Main.Settings.Bckg:='Lights';
                       if Main.PlayStatement then begin // if playing in progres, the window should been changed
                                                  Form1.GenericBG.Canvas.Pen.Width:=5;
                                                  Form1.GenericBG.Canvas.Brush.Color:=clBlack;
                                                  Form1.GenericBG.Canvas.Pen.Color:=clBlack;
                                                  Form1.GenericBG.Canvas.Rectangle(0,0,665,320);
                                                  ResetLightsPosition; // in PlayerU.dcu
                                                  RandomizeGenericBrushForAmeoba;  // in PlayerU.dcu
                                                  end;
                        end;
if ARewind.Checked then Main.Settings.ARwd:=true
                   else Main.Settings.ARwd:=false;
ShowMessage(TranslateText('XOptionsUpdatedPlayer',Settings.Lang));
// create config file
CreateConfigFile;
//
end;

procedure TSettingsW.OkB2Click(Sender: TObject);
var OldLang: string; // this var will tell if language was changed and if is necessary to run the procedure and translate all the texts (time saver)
begin
//set ID3 Tags options
if OptID3v1.Checked then begin
                         Main.Settings.ID3V:=true; // vice versa
                         Form1.ID3Changer.Click;    // here it will turn right
                         end
                    else begin
                         Main.Settings.ID3V:=false; // vice versa
                         Form1.ID3Changer.Click;   // here it will turn right
                         end;
if ConvertTags.Checked then Main.Settings.CTgs:=true
                       else Main.Settings.CTgs:=false;
if KillTags.Checked then Main.Settings.DID3:=true
                    else Main.Settings.DID3:=false;
// set Behaviour options
if StartOpt1.Checked then Main.Settings.ALod:=false else
if StartOpt2.Checked then Main.Settings.ALod:=true;
if DirectoryExists(WDirPath.Text) then Main.Settings.WDir:=WDirPath.Text
                                  else try
                                       MkDir(WDirPath.Text);
                                       Main.Settings.WDir:=WDirPath.Text;
                                       except
                                       ShowMessage(TranslateText('ECannotCreateDir',Settings.Lang));
                                       end;
if FileOpt1.Checked then Main.Settings.ADel:=false else
if FileOpt2.Checked then Main.Settings.ADel:=true;
if ASetOpt1.Checked then Main.Settings.ASet:=true else
if ASetOpt2.Checked then Main.Settings.ASet:=false;
if ACTrOpt1.Checked then begin
                         Main.Settings.ACTr:=true;
                         Form1.AutoSetTrackNumber.Checked:=true;
                         end
                    else begin
                         Main.Settings.ACTr:=false;
                         Form1.AutoSetTrackNumber.Checked:=false;
                         end;
if SizeOpt1.Checked then begin
                         Main.Settings.FSiz:=1;
                         Form1.Size1.Caption:='Total Size (B) :';
                         Form1.Size2.Caption:='Size (B) :';
                         Form1.Size3.Caption:='Size (B) :';
                         end
                    else
if SizeOpt2.Checked then begin
                         Main.Settings.FSiz:=1000;
                         Form1.Size1.Caption:='Total Size (kB) :';
                         Form1.Size2.Caption:='Size (kB) :';
                         Form1.Size3.Caption:='Size (kB) :';
                         end
                    else begin
                         Main.Settings.FSiz:=1000000;
                         Form1.Size1.Caption:='Total Size (MB) :';
                         Form1.Size2.Caption:='Size (MB) :';
                         Form1.Size3.Caption:='Size (MB) :';
                         end;
// reset main form components
Form1.ResetSizeComponents('Coll');
Form1.ResetSizeComponents('Alb');
Form1.ResetSizeComponents('MP3');
// set Appearance options
case MP3Skin.ItemIndex of
-1: Main.Settings.Skin.SkinName:='Default';  // just to make sure...
0: Main.Settings.Skin.SkinName:='Default';
1: Main.Settings.Skin.SkinName:='Custom';
else Main.Settings.Skin.SkinName:='Default'; // just to make sure...
end;
case MP3Skin.ItemIndex of
0: begin
   // set values for Default Skin
   Main.Settings.Skin.SkinName:='Default';
   Form1.ChangeSkin(Main.Settings.Skin.SkinName);
   RepaintForm('SettingsW');
   end;
1: begin
   // set values for "Electric Blue" skin
   Main.Settings.Skin.SkinName:='lectric Blue';
   Form1.ChangeSkin(Main.Settings.Skin.SkinName);
   RepaintForm('SettingsW');
   end;
2: begin
   // set values for "Dark Deep Ocean" skin
   Main.Settings.Skin.SkinName:='Dark Deep Ocean';
   Form1.ChangeSkin(Main.Settings.Skin.SkinName);
   RepaintForm('SettingsW');
   end;
3: begin
   // set values for "Nymphomaniac Phantasia" skin
   Main.Settings.Skin.SkinName:='Nymphomaniac Phantasia';
   Form1.ChangeSkin(Main.Settings.Skin.SkinName);
   RepaintForm('SettingsW');
   end;
end;   
case MP3Res.ItemIndex of
-1: begin                           // just to make sure...
    Main.Settings.ResW:=800;
    Main.Settings.ResH:=600;
    Form1.ResOpt1.Checked:=true;
    Form1.ChangeResolution;
    end;
0: begin
   Main.Settings.ResW:=800;
   Main.Settings.ResH:=600;
   Form1.ResOpt1.Checked:=true;
   Form1.ChangeResolution;
   end;
1: begin
   Main.Settings.ResW:=1024;
   Main.Settings.ResH:=756;
   Form1.ResOpt2.Checked:=true;
   Form1.ChangeResolution;
   end;
2: begin
   Main.Settings.ResW:=1280;
   Main.Settings.ResH:=800;
   Form1.ResOpt3.Checked:=true;
   Form1.ChangeResolution;
   end;
else begin                          // just to make sure...
     Main.Settings.ResW:=800;
     Main.Settings.ResH:=600;
     Form1.ResOpt1.Checked:=true;
     Form1.ChangeResolution;
     end;
end;
OldLang:=Main.Settings.Lang;
case MP3Lang.ItemIndex of
-1: Main.Settings.Lang:='ENG';      // just to make sure...
0: Main.Settings.Lang:='ENG';
1: Main.Settings.Lang:='CZE';
else Main.Settings.Lang:='ENG';     // just to make sure...
end;
// make the translation
if OldLang<>Main.Settings.Lang then begin // translate all texts
                                    TranslateForm('Main',Main.Settings.Lang);
                                    TranslateForm('SettingsW',Main.Settings.Lang);
                                    end;
// create config file
CreateConfigFile;
//
ShowMessage(TranslateText('XOptionsUpdatedProgram',Settings.Lang));
end;

procedure TSettingsW.CloseBClick(Sender: TObject);
begin
SettingsW.Close;
end;

procedure TSettingsW.OwnSkinClick(Sender: TObject);
begin
//
MP3Skin.ItemIndex:=1;
//
Application.CreateForm(TSkinW,SkinW);
TranslateForm('SkinW',Main.Settings.Lang);
RepaintForm('SkinW');
SkinW.ShowModal;
SkinW.Free;
end;

procedure TSettingsW.MP3SkinChange(Sender: TObject);
begin
case MP3Skin.ItemIndex of
// other values we dont care now
4: begin
   // create form to let user do custom color selection
   Application.CreateForm(TSkinW,SkinW);
   TranslateForm('SkinW',Main.Settings.Lang);
   RepaintForm('SkinW');
   SkinW.ShowModal;
   SkinW.Free;
   end;
end;
end;

procedure TSettingsW.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Opened:=false;
end;

end.
