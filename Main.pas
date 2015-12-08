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
// *  File:           *  Main.pas                                * //
// *  Purpose:        *  Main program file                       * //
// *  System Version: *  1.0                                     * //
// *  Last Modified:  *  2008-03-11 1220 GMT+1                   * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
/////////////////////////////////////////////////////////////////////

unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, StdCtrls, Buttons, ExtCtrls, MPlayer, jpeg, MixerU {by Ferdabasek};
  //FileCtrl;

type
  TID3v1S    = record // special "ID3 tag" - used for remembering default values used for whole album
                      // "Name" and "Track" not included (various for each track)
               Artist: string[30];
               Album: string[30];
               Year: word;
               Comment: string[29];
               Genre: byte;
               end;
  TID3v2S    = record // special "ID3 tag" - used for remembering default values used for whole album
                      // "Name" and "Track" not included (various for each track)
               Artist: string;
               Album: string;
               Year: string;
               Comment: string;
               Genre: string;
               end;
  TID3v1   = record // keeps info about ID3v1 tags
             Title: string[30];
             Artist: string[30];
             Album: string[30];
             Year: string[4];
             Comment: string[29];
             Track: byte;
             Genre: byte;
             end;
   TID3v2  = record // keeps info about ID3v2 tags
             Title: string;
             Artist: string;
             Album: string;
             Year: string;
             Comment: string;
             Track: string;
             Genre: string;
             end;
  TAmeobaMovement = record // extended "TPoint" variable
                    X: integer;      // x-coord
                    Y: integer;      // y-coord
                    Movement: byte;  // only values 1 to 20
                    end;
  TGenericBGBrush = record // special graphic variables for painting GenericBG
                    Color: TColor;          // color currently used for painting
                    Coords: TPoint;         // coords where the painting is started ("Flowers" pattern only)
                    ColorDuration: integer; // how long will be painted with current color
                    ColorElapsed: integer;  // how long is already painted with current color
                    // following variables are only for purpose of one GenericBG pattern
                    AmeobaTop: TAmeobaMovement;
                    AmeobaLeft: TAmeobaMovement;
                    AmeobaRight: TAmeobaMovement;
                    AmeobaBottom: TAmeobaMovement;
                    //AmeobaTopLeft: TAmeobaMovement;
                    //AmeobaTopRight: TAmeobaMovement;
                    //AmeobaBottomLeft: TAmeobaMovement;
                    //AmeobaBottomRight: TAmeobaMovement;
                    // the same here - just special GenericBG pattern
                    LightsTopLeft: TAmeobaMovement;
                    LightsTopLeft1: TAmeobaMovement;
                    LightsTopLeft2: TAmeobaMovement;
                    LightsTopLeft3: TAmeobaMovement;
                    LightsBottomRight: TAmeobaMovement;
                    LightsBottomRight1: TAmeobaMovement;
                    LightsBottomRight2: TAmeobaMovement;
                    LightsBottomRight3: TAmeobaMovement;
                    end;
  TSkin= record // info about visual appearance
         SkinName: string;
         BGImage: string;
         BGColor: TColor;
         FontColor1: TColor;
         FontColor2: TColor;
         FontColor3: TColor;
         TrackBG: TColor;
         end;
  TConfig = record // basic config data for the program
            //Skin: string[50]; // appearance of the program (colours, bg images)
            ResH: integer;    // height of form
            ResW: integer;    // width of form
            Lang: string[50]; // used language
            PVol: byte;       // default player volume which is set at startup
            Bckg: string[50]; // used background pattern in player
            ARwd: boolean;    // automatic rewind options
            ID3V: boolean;    // version of ID3 tags (true - ID3v2, false - ID3v1)
            CTgs: boolean;    // if auto-convert ID3v2 to ID3v1 when working with them
            DID3: boolean;    // if auto-delete previous ID3v2 tags version when saving new
            WDir: string;     // working directory where collections are created and stored
            ALod: boolean;    // auto-load of collection at startup allowed/disallowed
            ADel: boolean;    // auto-delete mp3 files imported to collection from their previous location
            ASet: boolean;    // auto set "Common Values" for imported mp3
            ACTr: boolean;    // auto count track number from mp3 order
            Last: string;     // path to the last opened collection
            LDir: string;     // path to the last dir user browsed for mp3 files
            FSiz: integer;    // in which units the size of files should be represented (MB - 1000000,kB - 1000,B - 1);
            Skin: TSkin;      // info about crrent visal appearance
            end;

  TMyTime = record // info about time
          H: byte; // hours
          M: byte; // minutes
          S: byte; // seconds
          end;
  TPlayedMP3 = record
               ID: integer; // order in Track Query
               Source: string; // the path to the actual file
               Bitrate: word; // bitrate of the current mp3
               ID3v1: TID3v1; // ID3v1 tags values for currently played mp3 file
               ID3v2: TID3v2; // ID3v2 tags values for currently played mp3 file
               Length: TMyTime; // the length of actual file
               Progress: integer; // how much from the mp3 was already played
               end;
  TMP3Que = record
            ID: integer; // order in Track Query
            Path: string;// path to the file
            Name: string; // title of the MP3
            end;
         TMP3 = record
                ID: word; // identification
                Order: word; // the order of the mp3 in the album
                Album: word; // id of owner album
                Path: string[255]; // path to the mp3
                Name: string[100]; // name of the mp3
                ID3v1: TID3v1;  // ID3v1 tags values for the mp3
                ID3v2: TID3v2;  // ID3v2 tags values for the mp3
                Size: longint;  // size of the mp3
                Bitrate: word; // bitrate of the current mp3
                Duration: LongInt; // length of the mp3
                Image: string[255]; // small thumbnail
                //Lyrics: WideString; // lyrics of the song
                end;
       TAlbum = record
                ID: word; // identification
                Order: word; // the order of the album in the collection
                Name: string[25]; // name of the album
                Desc: string[250]; // brief description of the album
                MP3No: word;    // number of mp3 files in the album
                Size: longint;  // total size of the data in the album
                Duration: LongInt; // total playing time of all files in the album
                Image: string[255]; // small thumbnail
                CommonValuesID3v1: TID3v1S; // values that are automatically set for whole album - ID3v1
                CommonValuesID3v2: TID3v2S; // values that are automatically set for whole album - ID3v2
                end;
  TCollection = record // info about mp3 collection
                Name: string[100]; // name of the collection
                Desc: string[250]; // brief description of the collection
                Path: string[255]; // path to the collecton sub-directories and files
                AlbumsNo: word; // number of albums in the collection
                MP3No: word;    // number of mp3 files in the collection
                Size: longint;  // total size of the data in the collection
                Duration: LongInt; // total playing time of all files in the collection
                LastEdit: string[25]; // date of last edition
                Albums: array of TAlbum;
                MP3s: array of TMP3;
                end;
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Menu1: TMenuItem;
    Menu3: TMenuItem;
    Menu4: TMenuItem;
    Menu5: TMenuItem;
    Menu6: TMenuItem;
    PrgOpt1: TMenuItem;
    PrgOpt2: TMenuItem;
    PrgOpt3: TMenuItem;
    Menu2: TMenuItem;
    PlrOpt1: TMenuItem;
    PlrOpt2: TMenuItem;
    MP3Opt1: TMenuItem;
    MP3Opt2: TMenuItem;
    MP3Opt3: TMenuItem;
    AlbOpt1: TMenuItem;
    AlbOpt2: TMenuItem;
    AlbOpt3: TMenuItem;
    ColOpt1: TMenuItem;
    ColOpt2: TMenuItem;
    ColOpt3: TMenuItem;
    MainNav: TPageControl;
    Player: TTabSheet;
    Collection: TTabSheet;
    PlayB: TBitBtn;
    Label1: TLabel;
    ElapsedTime: TTimer;
    PlayTime: TLabel;
    PauseB: TBitBtn;
    StopB: TBitBtn;
    PlayTrack: TLabel;
    ElapsedTimeBar: TProgressBar;
    BGImage: TImage;
    OptOpt1: TMenuItem;
    SkinOpt1: TMenuItem;
    OptOpt2: TMenuItem;
    ResOpt1: TMenuItem;
    ResOpt2: TMenuItem;
    ResOpt3: TMenuItem;
    OptOpt3: TMenuItem;
    LngOpt1: TMenuItem;
    LngOpt2: TMenuItem;
    HiddenPlayer: TMediaPlayer;
    BrowseB: TButton;
    OpenMP3: TOpenDialog;
    ElapsedTime2: TTimer;
    GenericBG: TImage;
    GenericBGRepaint: TTimer;
    GenericBGPanel: TPanel;
    PlrOpt3: TMenuItem;
    OptOpt4: TMenuItem;
    PrgOpt4: TMenuItem;
    Menu7: TMenuItem;
    HelpOpt1: TMenuItem;
    HelpOpt2: TMenuItem;
    TrackQuery: TListBox;
    Label2: TLabel;
    TrackQueryOptions: TPopupMenu;
    TQOpt1: TMenuItem;
    TQOpt2: TMenuItem;
    TQOpt3: TMenuItem;
    TQOpt4: TMenuItem;
    GroupBox1: TGroupBox;
    OpenCollection: TOpenDialog;
    GroupBox2: TGroupBox;
    GroupBox4: TGroupBox;
    AlbumList: TListBox;
    AlbName: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    EditA: TButton;
    AddA: TButton;
    AlbUp: TBitBtn;
    AlbDown: TBitBtn;
    AlbMP3Count: TLabel;
    AlbDuration: TLabel;
    Size2: TLabel;
    AlbSize: TLabel;
    MP3List: TListBox;
    MP3Name: TLabel;
    Size3: TLabel;
    Label12: TLabel;
    EditM: TButton;
    MP3Up: TBitBtn;
    MP3Down: TBitBtn;
    AddMP3: TButton;
    MP3Size: TLabel;
    MP3Duration: TLabel;
    Label9: TLabel;
    MP3Album: TLabel;
    Label3: TLabel;
    CollName: TLabel;
    CollDesc: TMemo;
    Label4: TLabel;
    Label5: TLabel;
    CollPath: TLabel;
    CollectionE: TButton;
    GroupBox3: TGroupBox;
    Label10: TLabel;
    Label13: TLabel;
    Size1: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    CollStatsAlb: TLabel;
    CollStatsMP3: TLabel;
    CollStatsDuration: TLabel;
    CollStatsSize: TLabel;
    CollStatsLastEdit: TLabel;
    MP3ImpOpt1: TMenuItem;
    MP3ImpOpt2: TMenuItem;
    ID3: TTabSheet;
    GroupBox5: TGroupBox;
    MP3List2: TComboBox;
    GroupBox6: TGroupBox;
    AlbumList2: TComboBox;
    Label8: TLabel;
    Label11: TLabel;
    Label17: TLabel;
    CurrentMP3Name: TLabel;
    Label14: TLabel;
    ID3Changer: TButton;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    ID3Title: TEdit;
    ID3Artist: TEdit;
    ID3Comment: TEdit;
    ID3Album: TEdit;
    ID3Year: TEdit;
    ID3Genre: TEdit;
    ID3Track: TEdit;
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    UpDown3: TUpDown;
    SaveID3: TButton;
    PlayA: TButton;
    PlayM: TButton;
    PlayM2: TButton;
    Album: TTabSheet;
    GroupBox7: TGroupBox;
    Label18: TLabel;
    AlbumList3: TComboBox;
    GroupBox8: TGroupBox;
    Label26: TLabel;
    CurrentAlbumName: TLabel;
    SkinOpt2: TMenuItem;
    EditA2: TButton;
    ID3Artist2: TEdit;
    ID3Album2: TEdit;
    ID3Comment2: TEdit;
    ID3Genre2: TEdit;
    UpDown7: TUpDown;
    Label32: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    ID3Year2: TEdit;
    UpDown4: TUpDown;
    Label33: TLabel;
    ID3Changer2: TButton;
    Label34: TLabel;
    EditM2: TButton;
    SaveID32: TButton;
    PlayA2: TButton;
    VolumeControler: TTrackBar;
    CurrentMP3Image: TImage;
    CurrentAlbumImage: TImage;
    IgnoreArtist: TPanel;
    IgnoreComment: TPanel;
    IgnoreGenre: TPanel;
    IgnoreYear: TPanel;
    IgnoreAlbum: TPanel;
    PlrOpt4: TMenuItem;
    SmallIconsPanel: TPanel;
    PlayTimeSmall: TLabel;
    PlayTrackSmall: TLabel;
    PlayBSmall: TBitBtn;
    PauseBSmall: TBitBtn;
    StopBSmall: TBitBtn;
    VolumeControlerSmall: TTrackBar;
    ShowMainNav: TBitBtn;
    BrowseBSmall: TButton;
    HideMainNav: TBitBtn;
    ElapsedTimeBarSmall: TProgressBar;
    MP3OrderOptions: TPopupMenu;
    MoveUp1: TMenuItem;
    MoveDown1: TMenuItem;
    AlbumOrderOptions: TPopupMenu;
    MoveUp2: TMenuItem;
    MoveDown2: TMenuItem;
    Delete2: TMenuItem;
    Delete1: TMenuItem;
    OptOpt5: TMenuItem;
    BgOpt1: TMenuItem;
    BGOpt2: TMenuItem;
    BGOpt3: TMenuItem;
    BGOpt4: TMenuItem;
    SkinOpt3: TMenuItem;
    SkinOpt4: TMenuItem;
    SkinOpt5: TMenuItem;
    AutoSetTrackNumber: TCheckBox;
    DelA: TButton;
    DelM: TButton;
    function GetMP3LengthViaTMediaPlayer(source: string): LongInt;
    procedure AlignLabels;
    procedure ResetSizeComponents(SizeComp: string);
    procedure ResetLastEdit;
    procedure ResetAlbumLists;
    procedure ResetMP3Lists;
    procedure ResetMP3Components;
    procedure ChangeSkin(Skin: string);
    procedure ChangeResolution;
    procedure ChangeLanguage;
    procedure RewriteElapsedTime;
    procedure PrgOpt3Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ElapsedTimeTimer(Sender: TObject);
    procedure PlayBClick(Sender: TObject);
    procedure PauseBClick(Sender: TObject);
    procedure StopBClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SkinOpt1Click(Sender: TObject);
    procedure ResOpt1Click(Sender: TObject);
    procedure ResOpt2Click(Sender: TObject);
    procedure ResOpt3Click(Sender: TObject);
    procedure LngOpt1Click(Sender: TObject);
    procedure LngOpt2Click(Sender: TObject);
    procedure PlrOpt1Click(Sender: TObject);
    procedure AssignMP3Click(Sender: TObject);
    procedure ElapsedTime2Timer(Sender: TObject);
    procedure GenericBGRepaintTimer(Sender: TObject);
    procedure PlrOpt3Click(Sender: TObject);
    procedure OpenMP3FolderChange(Sender: TObject);
    procedure TrackQueryDblClick(Sender: TObject);
    procedure TQOpt2Click(Sender: TObject);
    procedure PrgOpt1Click(Sender: TObject);
    procedure XButtonClick(Sender: TObject);
    procedure CollectionEClick(Sender: TObject);
    procedure PrgOpt2Click(Sender: TObject);
    procedure PrgOpt4Click(Sender: TObject);
    procedure EditAClick(Sender: TObject);
    procedure AddAClick(Sender: TObject);
    procedure AlbumListClick(Sender: TObject);
    procedure MP3ListClick(Sender: TObject);
    procedure AddMClick(Sender: TObject);
    procedure EditMClick(Sender: TObject);
    procedure AlbUpClick(Sender: TObject);
    procedure AlbDownClick(Sender: TObject);
    procedure MP3UpClick(Sender: TObject);
    procedure MP3DownClick(Sender: TObject);
    procedure MP3ImpOpt2Click(Sender: TObject);
    procedure ID3ChangerClick(Sender: TObject);
    procedure SaveID3Click(Sender: TObject);
    procedure AlbumList2Change(Sender: TObject);
    procedure MP3List2Change(Sender: TObject);
    procedure PlayAClick(Sender: TObject);
    procedure PlayMClick(Sender: TObject);
    procedure PlayM2Click(Sender: TObject);
    procedure EditM2Click(Sender: TObject);
    procedure AlbumList3Change(Sender: TObject);
    procedure SkinOpt2Click(Sender: TObject);
    procedure PlayA2Click(Sender: TObject);
    procedure EditA2Click(Sender: TObject);
    procedure VolumeControlerChange(Sender: TObject);
    procedure TQOpt3Click(Sender: TObject);
    procedure TQOpt4Click(Sender: TObject);
    procedure SaveID32Click(Sender: TObject);
    procedure IgnoreActionClick(Sender: TObject);
    procedure PlrOpt4Click(Sender: TObject);
    procedure MoveUp1Click(Sender: TObject);
    procedure MoveDown1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure Delete2Click(Sender: TObject);
    procedure HelpOpt2Click(Sender: TObject);
    procedure BgOpt1Click(Sender: TObject);
    procedure BGOpt2Click(Sender: TObject);
    procedure BGOpt3Click(Sender: TObject);
    procedure BGOpt4Click(Sender: TObject);
    procedure SkinOpt3Click(Sender: TObject);
    procedure SkinOpt5Click(Sender: TObject);
    procedure SkinOpt4Click(Sender: TObject);
    procedure AutoSetTrackNumberClick(Sender: TObject);
    procedure ColOpt3Click(Sender: TObject);
    procedure UpDown2Click(Sender: TObject; Button: TUDBtnType);
    procedure HelpOpt1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  InitDir: string; // keeps the info about program directory during whole run
  Settings: TConfig; // keeps the config variables
  CrucialE: boolean; // for forced program terminate

  GenericBrush: TGenericBGBrush; // used for creating GenericBG patterns

  MP3TrackQue: array of TMP3Que; // basic info about mp3 tracks in query
  CurrentMP3: TPlayedMP3;
  PlayStatement: boolean; // if mp3 player is active and plays the song
  Elapsed: TMyTime; // how much time is the track played so far
  VolumeControl: TMixer; // allows inside-program volume control  (from FileCtrl.dcu by Ferdabasek)

  CollectionStatement: boolean; // if there is any collection opened

  MP3Collection: TCollection; // elementary program variable - info about edited mp3 collection
  CurrentActiveAlbum: integer; // index of current album, where we can add mp3s
  CurrentActiveMP3: integer; // index of current mp3, where ID3s are edited

implementation

uses SettingsU, CollectionU, AlbumU, MP3U, ImportU, SkinU, AboutU, // units for additional windows
     PlayerU, // unit for MP3 Player utilities
     WorkingU, MP3Utilities, ID3Utilities, FileSystemUtilities; // units with other utility functions and procedures

{$R *.dfm}

function TForm1.GetMP3LengthViaTMediaPlayer(source: string): LongInt;
// TMediaPlayer can get the length automatically, so i will use it
begin
HiddenPlayer.FileName:=source;  // assigning MP3 file
HiddenPlayer.Open;
Result:=HiddenPlayer.TrackLength[0];
HiddenPlayer.Close;
end;

procedure TForm1.AlignLabels;
// this has to be done, because lables with taRightJustify Alignment are moving themselves...
// dunno why, but it has to be...
begin
// dunno why... (it must be when the font is alinged to right)
Label3.Left:=15;
Label4.Left:=15;
Label5.Left:=15;
Label14.Left:=20;
Label17.Left:=20;
Label20.Left:=20;
Label21.Left:=20;
Label22.Left:=20;
Label23.Left:=420;
Label24.Left:=420;
Label25.Left:=420;
Label26.Left:=20;
Label27.Left:=420;
Label28.Left:=20;
Label29.Left:=420;
Label30.Left:=20;
Label31.Left:=20;
PlayTime.Left:=655;
PlayTimeSmall.Left:=178;
end;

procedure TForm1.ResetSizeComponents(SizeComp: string);
// refills size components according to the selected size representation (B,kB,MB)
var size: real;
begin
if SizeComp='Coll' then begin
                        if Settings.FSiz>1 then begin // use rounding
                                                size:=RoundSize(MP3Collection.Size);
                                                CollStatsSize.Caption:=floattostrf(size,ffNumber,15,2);
                                                end
                                           else begin // do not use rounding
                                                CollStatsSize.Caption:=inttostr(MP3Collection.Size);
                                                end;
                        end
                   else
if SizeComp='Alb'  then begin
                        if (high(MP3Collection.Albums)>-1)and(AlbumList.ItemIndex>-1) then
                        if Settings.FSiz>1 then begin // use rounding
                                                size:=RoundSize(MP3Collection.Albums[AlbumList.ItemIndex].Size);
                                                AlbSize.Caption:=floattostrf(size,ffNumber,15,2);
                                                end
                                           else begin // do not use rounding
                                                AlbSize.Caption:=inttostr(MP3Collection.Albums[AlbumList.ItemIndex].Size);
                                                end;
                        end
                   else
if SizeComp='MP3'  then begin
                        if (high(MP3Collection.MP3s)>-1)and(MP3List.ItemIndex>-1) then
                        if Settings.FSiz>1 then begin // use rounding
                                                size:=RoundSize(MP3Collection.MP3s[MP3List.ItemIndex].Size);
                                                MP3Size.Caption:=floattostrf(size,ffNumber,15,2);
                                                end
                                           else begin // do not use rounding
                                                MP3Size.Caption:=inttostr(MP3Collection.MP3s[MP3List.ItemIndex].Size);
                                                end;
                        end;
end;

procedure TForm1.ResetLastEdit;
// only rewrites actual value of "Last Edit" component
begin
CollStatsLastEdit.Caption:=MP3Collection.LastEdit;
end;

procedure TForm1.ResetAlbumLists;
// re-fills AlbumLists with actual order
var i,i2: integer;
begin
// reset first AlbumList
AlbumList.Items.Clear;
AlbumList.ItemIndex:=-1;
AlbumList.Items.Add('...'); // "root album"
// reset second AlbumList
AlbumList2.Items.Clear;
AlbumList2.ItemIndex:=-1;
AlbumList2.Items.Add('...'); // "root album"
// reset third AlbumList
AlbumList3.Items.Clear;
AlbumList3.ItemIndex:=-1;
AlbumList3.Items.Add('...'); // "root album"

// add albums into lists
if MP3Collection.AlbumsNo>1 then begin
                                 for i:=1 to MP3Collection.AlbumsNo-1 do begin
                                                                         i2:=0;
                                                                         repeat
                                                                         i2:=i2+1;
                                                                         until MP3Collection.Albums[i2].Order=i;
                                                                         AlbumList.Items.Add(MP3Collection.Albums[i2].Name);
                                                                         AlbumList2.Items.Add(MP3Collection.Albums[i2].Name);
                                                                         AlbumList3.Items.Add(MP3Collection.Albums[i2].Name);
                                                                         end;
                                 end;
end;

procedure TForm1.ResetMP3Lists;
// fills MP3Lists according to the album selection and in actual order
type TMatch = record
              ID: word;
              Order: word;
              end;
var i,max: integer;
    change: boolean;
    saved: TMatch;
    Matches: array of TMatch;
    MatchesNo: integer;
begin
// reset first MP3Lists
MP3List.Items.Clear;
MP3List.ItemIndex:=-1;
MP3List2.Items.Clear;
MP3List2.ItemIndex:=-1;

SetLength(Matches,High(MP3Collection.MP3s)+1);
MatchesNo:=-1;
// add albums into lists
if MP3Collection.MP3No>0 then begin
                              for i:=0 to high(MP3Collection.MP3s) do if (MP3Collection.MP3s[i].Name<>'_Empty')
                                                                      and(MP3Collection.MP3s[i].Album=CurrentActiveAlbum) then begin
                                                                                                                               MatchesNo:=MatchesNo+1;
                                                                                                                               Matches[MatchesNo].ID:=i;
                                                                                                                               Matches[MatchesNo].Order:=MP3Collection.MP3s[i].Order;
                                                                                                                               end;
                              SetLength(Matches,MatchesNo+1); // cutting the unused slots
                              // sorting array
                              max:=MatchesNo+1;
                              repeat
                              max:=max-1;
                              change:=false;
                              for i:=0 to max-1 do if Matches[i].Order>Matches[i+1].Order then begin
                                                                                             saved:=Matches[i+1];
                                                                                             Matches[i+1]:=Matches[i];
                                                                                             Matches[i]:=saved;
                                                                                             change:=true;
                                                                                             end;
                              until (max=0)or(change=false);
                              //
                              for i:=0 to high(Matches) do begin
                                                           MP3List.Items.Add(MP3Collection.MP3s[Matches[i].ID].Name);
                                                           MP3List2.Items.Add(MP3Collection.MP3s[Matches[i].ID].Name);
                                                           end;
                              end
                         else begin
                              MP3List.Items.Add('No MP3s');
                              MP3List2.Items.Add('No MP3s');
                              end;
end;

procedure TForm1.ResetMP3Components;
// re-fills components with loaded/created values
// var i: integer;
begin
CollName.Caption:=MP3Collection.Name;
//Text:=MP3Collection.Desc; // TCaption is not string for the compiler
//CutEOL(Text);
CollDesc.Text:=MP3Collection.Desc;
if MP3Collection.Path<>Main.InitDir+'Collections\MyCollection' then begin
                                                                    CollPath.Caption:=CutPreviousPath(MP3Collection.Path,35);
                                                                    CollPath.Hint:=MP3Collection.Path;
                                                                    end
                                                               else CollPath.Caption:=TranslateText('MSGNoCollOpened',Settings.Lang);
if MP3Collection.AlbumsNo>=1 then CollStatsAlb.Caption:=inttostr(MP3Collection.AlbumsNo-1) // we dont count "_root"
                             else CollStatsAlb.Caption:='0';                               // to prevent "-1" value
CollStatsMP3.Caption:=inttostr(MP3Collection.MP3No);
CollStatsDuration.Caption:=DurationInTime(MP3Collection.Duration,false); // in MP3Utilities.dcu
CollStatsLastEdit.Caption:=MP3Collection.LastEdit;

ResetAlbumLists;

AlbName.Caption:='No Album Selected';
AlbMP3Count.Caption:='...';
AlbSize.Caption:='...';
AlbDuration.Caption:='...';

// Run external procedures participating in
ResetMP3Lists;
Form1.ResetSizeComponents('Coll');
Form1.ResetSizeComponents('Alb');
Form1.ResetSizeComponents('MP3');
//

MP3Name.Caption:='No MP3 Selected';
MP3Album.Caption:='...';
MP3Size.Caption:='...';
MP3Duration.Caption:='...';

// reseting the lists texts
MP3List2.Text:='MP3 File';
AlbumList2.Text:='MP3 Album';
AlbumList2.Text:='MP3 Album';

// Other necessary processes
// sets the tab
MainNav.ActivePageIndex:=1;
// updates Last Working Directory variable
// Settings.Last:=MP3Collection.Path;
// now it is definitely allowed to re-open last collection
// PrgOpt4.Enabled:=true;  - no it isnt !!!

// security
EditA2.Enabled:=false;
EditM2.Enabled:=false;
PlayA2.Enabled:=false;
PlayM2.Enabled:=false;
end;

procedure TForm1.ChangeSkin(Skin: string);
// changes the colors and images according to the skin selection
begin
if Skin='Default' then begin
                       Settings.Skin.SkinName:='Default';
                       Settings.Skin.BGImage:=InitDir+'Skins\Default\background.jpg';
                       Settings.Skin.BGColor:=clGray;
                       Settings.Skin.FontColor1:=clBlack;
                       Settings.Skin.FontColor2:=clWhite;
                       Settings.Skin.FontColor3:=clGreen;
                       Settings.Skin.TrackBG:=clTeal;
                       end
                  else
if Skin='Electric Blue' then begin
                             Settings.Skin.SkinName:='Electric Blue';
                             Settings.Skin.BGImage:=InitDir+'Skins\Electric Blue\background.jpg';
                             Settings.Skin.BGColor:=13100669;
                             Settings.Skin.FontColor1:=4227072;
                             Settings.Skin.FontColor2:=clBlack;
                             Settings.Skin.FontColor3:=32768;
                             Settings.Skin.TrackBG:=clBlack;
                             end
                  else
if Skin='Dark Deep Ocean' then begin
                               Settings.Skin.SkinName:='Dark Deep Ocean';
                               Settings.Skin.BGImage:=InitDir+'Skins\Dark Deep Ocean\background.jpg';
                               Settings.Skin.BGColor:=12615808;
                               Settings.Skin.FontColor1:=4194304;
                               Settings.Skin.FontColor2:=clBlack;
                               Settings.Skin.FontColor3:=151;
                               Settings.Skin.TrackBG:=clBlack;
                               end
                          else
if Skin='Nymphomaniac Phantasia' then begin
                                      Settings.Skin.SkinName:='Nymphomaniac Phantasia';
                                      Settings.Skin.BGImage:=InitDir+'Skins\Nymphomaniac Phantasia\background.jpg';
                                      Settings.Skin.BGColor:=1710845;
                                      Settings.Skin.FontColor1:=clWhite;
                                      Settings.Skin.FontColor2:=clBlack;
                                      Settings.Skin.FontColor3:=clBlack;
                                      Settings.Skin.TrackBG:=clBlack;
                                      end
                                 else
if Skin='Custom' then Settings.Skin.SkinName:='Custom';
// setting menu items                       
if Settings.Skin.SkinName='Default' then SkinOpt1.Checked:=true else
if Settings.Skin.SkinName='Electric Blue' then SkinOpt5.Checked:=true else
if Settings.Skin.SkinName='Dark Deep Ocean' then SkinOpt3.Checked:=true else
if Settings.Skin.SkinName='Nymphomaniac Phantasia' then SkinOpt4.Checked:=true else
if Settings.Skin.SkinName='Custom' then SkinOpt2.Checked:=true;
// repainting to actual selection
RepaintForm('Main');
// create config file
CreateConfigFile;
end;

procedure TForm1.ChangeResolution;
// changes the dimensions of window according to the res selection
begin
Form1.Width:=Settings.ResW;
Form1.Height:=Settings.ResH;
end;

procedure TForm1.ChangeLanguage;
// changes used language according to the language selection
begin
TranslateForm('Main',Settings.Lang);
end;

procedure TForm1.RewriteElapsedTime;
// updates the elapsed track time on Player
var ResultTime: string;
begin
ResultTime:='';
// filling
if Elapsed.H>9 then ResultTime:=inttostr(Elapsed.H)+':' else
if Elapsed.H>0 then ResultTime:='0'+inttostr(Elapsed.H)+':';
if Elapsed.M>9 then ResultTime:=ResultTime+inttostr(Elapsed.M)+':'
               else ResultTime:=ResultTime+'0'+inttostr(Elapsed.M)+':';
if Elapsed.S>9 then ResultTime:=ResultTime+inttostr(Elapsed.S)
               else ResultTime:=ResultTime+'0'+inttostr(Elapsed.S);
//
PlayTimeSmall.Caption:=ResultTime;
PlayTimeSmall.Left:=178;
PlayTime.Caption:=ResultTime;
PlayTime.Left:=650;
end;

procedure TForm1.PrgOpt3Click(Sender: TObject);
// exit button click
begin
Form1.Close;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
// confirmation while closing application
begin
if CrucialE then CanClose:=true else
if MessageDlg(TranslateText('QQuit',Settings.Lang),mtConfirmation,[mbYes,mbNo],0)=IDYes then CanClose:=true
                                                                                        else CanClose:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
// initial procedures after application starts
var Missing: boolean;
    Config: textfile;
    Data: string;
begin
CrucialE:=false; // hope will never happen... :)
Form1.Left:=0;
Form1.Top:=0;
PlayTime.Left:=650;
InitDir:=GetCurrentDir; // the dir will change many times during the program run
CheckLastBackslash(InitDir); // to make sure it will end with "\" for further use in the program
HiddenPlayer.TimeFormat:=tfMilliseconds; // cannot be set via object inspector
Form1.DoubleBuffered:=true;
MainNav.DoubleBuffered:=true;
GenericBGPanel.DoubleBuffered:=true;
GenericBG.Canvas.Brush.Color:=clBlack;
GenericBG.Canvas.Pen.Color:=clBlack;
GenericBG.Canvas.Rectangle(0,0,666,321);
VolumeControl:=TMixer.Create(Self);// needs to be created before checking of file list

Missing:=false;
// checking for crucial files - if they are missed, the program cannot run properly and it shuts down immedeately
//if FileExists(InitDir+'\Skins\Default\Config.ini')=false then Missing:=true;
if FileExists(InitDir+'Skins\Default\background.jpg')=false then Missing:=true;
if FileExists(InitDir+'Lang\ENG.lng')=false then Missing:=true;
if FileExists(InitDir+'Empty.jpg')=false then Missing:=true;
if FileExists(InitDir+'EmptyAlbum.jpg')=false then Missing:=true;
if FileExists(InitDir+'EmptyMP3.jpg')=false then Missing:=true;
//
if Missing then begin // terminate the program
                ShowMessage(TranslateText('FEMissingFiles',Settings.Lang));
                CrucialE:=true;
                Form1.Close;
                end
else begin // continue in standard running and inicialization

// reseting some variables
CurrentActiveMP3:=-1;
CurrentActiveAlbum:=-1;
CollectionStatement:=false;

// reading the settings file
AssignFile(Config,InitDir+'Config.ini');
try
Reset(Config);
{
// 1. * Program graphic skin *
readln(Config,Data);
Delete(Data,1,7);
Settings.Skin:=Data;
// validating - if someone altered the .ini file manualy and wrote incorrect data...
if FileExists(InitDir+'\Skins\'+Settings.Skin+'\Config.ini')=false then begin
                                                                        Settings.Skin:='Default';
                                                                        Missing:=true; // error message will be shown later
                                                                        end;
}
// 2. * Program window height *
readln(Config,Data);
Delete(Data,1,7);
// validating - first level - if integer value
try Settings.ResH:=strtoint(Data) except
                                  Settings.ResH:=600;
                                  Missing:=true;
                                  end;
// validating - second level - if supported value (6OO,756,800)
if (Settings.ResH=600)or(Settings.ResH=756)or(Settings.ResH=800) then // do nothing
                                                                 else begin
                                                                      Settings.ResH:=600;
                                                                      Missing:=true; // error message will be shown later
                                                                      end;
// 3. * Program window width *
readln(Config,Data);
Delete(Data,1,7);
// validating - first level - if integer value
try Settings.ResW:=strtoint(Data) except
                                  Settings.ResW:=800;
                                  Missing:=true;
                                  end;
// validating - second level - if supported value (800,1024,1280)
if (Settings.ResW=800)or(Settings.ResW=1024)or(Settings.ResW=1280) then // do nothing
                                                                   else begin
                                                                        Settings.ResW:=800;
                                                                        Missing:=true; // error message will be shown later
                                                                        end;
// 4. * Program language * (ENG,CZE supported by default)
readln(Config,Data);
Delete(Data,1,7);
Settings.Lang:=Data;
// validating
if FileExists(InitDir+'Lang\'+Settings.Lang+'.lng')=false then begin
                                                               Settings.Lang:='ENG';
                                                               Missing:=true; // error message will be shown later
                                                               end;

// 5. * Defauld Volume * (values between 0 and 255 wich will be set)
readln(Config,Data);
Delete(Data,1,7);
try
Settings.PVol:=strtoint(Data);
except
Settings.PVol:=255;
Missing:=true;
end;
// 6. * Generic BG for player * ("Flowers", "Ameoba", "Universe" and "Lights" supported)
readln(Config,Data);
Delete(Data,1,7);
Settings.Bckg:=Data;
// validating
if (Settings.Bckg='Flowers')
 or(Settings.Bckg='Ameoba')
 or(Settings.Bckg='Universe')
 or(Settings.Bckg='Lights')  then // do nothing
                             else begin
                                  Settings.Bckg:='Ameoba';
                                  Missing:=true; // error message will be shown later
                                  end;
// 7. * Auto Rewind Option * (if the track will be automaticaly launched again after end)
readln(Config,Data);
Delete(Data,1,7);
if Data='1' then Settings.ARwd:=true else
if Data='0' then Settings.ARwd:=false else begin
                                           Settings.ARwd:=false;
                                           Missing:=true; // error message will be shown later
                                           end;
// 8. * ID3 tags * (ID3v1 or ID3v2)
readln(Config,Data);
Delete(Data,1,7);
if Data='1' then Settings.ID3V:=true else
if Data='0' then Settings.ID3V:=false else begin
                                           Settings.ID3V:=true;
                                           Missing:=true; // error message will be shown later
                                           end;
// tags coversion option
readln(Config,Data);
Delete(Data,1,7);
if Data='1' then Settings.CTgs:=true else
if Data='0' then Settings.CTgs:=false else begin
                                           Settings.CTgs:=false;
                                           Missing:=true; // error message will be shown later
                                           end;
// tags delete option
readln(Config,Data);
Delete(Data,1,7);
if Data='1' then Settings.DID3:=true else
if Data='0' then Settings.DID3:=false else begin
                                           Settings.DID3:=false;
                                           Missing:=true; // error message will be shown later
                                           end;
// 9. * Working Directory * (Directory, where created mp3collections are stored)
readln(Config,Data);
Delete(Data,1,7);
if DirectoryExists(Data) then Settings.WDir:=Data
                         else Settings.WDir:=InitDir+'Collections';
// 10. * Auto Open Last Opened Collection * (Allows to automatically load and work with current MP3 collection)
readln(Config,Data);
Delete(Data,1,7);
if Data='1' then Settings.ALod:=true else
if Data='0' then Settings.ALod:=false else begin
                                           Settings.ALod:=false;
                                           Missing:=true; // error message will be shown later
                                           end;
// 11. * Auto Delete MP3 Files * (Allows to automatically delete file from previous location when import to collection)
readln(Config,Data);
Delete(Data,1,7);
if Data='1' then Settings.ADel:=true else
if Data='0' then Settings.ADel:=false else begin
                                           Settings.ADel:=false;
                                           Missing:=true; // error message will be shown later
                                           end;
// 12. * Auto Set Common Values * (Automatically set default tag values for imported MP3s)
readln(Config,Data);
Delete(Data,1,7);
if Data='1' then Settings.ASet:=true else
if Data='0' then Settings.ASet:=false else begin
                                           Settings.ASet:=false;
                                           Missing:=true; // error message will be shown later
                                           end;
// auto count track from mp3 order option
readln(Config,Data);
Delete(Data,1,7);
if Data='1' then Settings.ACTr:=true else
if Data='0' then Settings.ACTr:=false else begin
                                           Settings.ACTr:=false;
                                           Missing:=true; // error message will be shown later
                                           end;
// 13. * Last Opened Collection * (Path to the last collection user worked with)
readln(Config,Data);
Delete(Data,1,7);
if DirectoryExists(Data) then Settings.Last:=Data
                         else Settings.Last:='None';
// 14. * Last Opened Directory * (Path to the last dir user browsed for mp3)
readln(Config,Data);
Delete(Data,1,7);
if DirectoryExists(Data) then Settings.LDir:=Data
                         else Settings.LDir:='None';
// 15. * File Size Representation * (MB - 1000000,kB - 1000,B - 1)
readln(Config,Data);
Delete(Data,1,7);
if Data='1' then Settings.FSiz:=1 else
if Data='1000' then Settings.FSiz:=1000 else
if Data='1000000' then Settings.FSiz:=1000000 else begin
                                                   Settings.FSiz:=1000000;
                                                   Missing:=true; // error message will be shown later
                                                   end;
// 16. * Skin Settings *
readln(Config,Data);
Delete(Data,1,7);
Settings.Skin.SkinName:=Data;
readln(Config,Data);
Delete(Data,1,7);
if FileExists(Data) then Settings.Skin.BGImage:=Data
                    else Settings.Skin.BGImage:=InitDir+'Skins\background.jpg';
readln(Config,Data);
Delete(Data,1,7);
try
Settings.Skin.BGColor:=StringToColor(Data);
except
Settings.Skin.BGColor:=clGray;
Missing:=true;
end;
readln(Config,Data);
Delete(Data,1,7);
try
Settings.Skin.FontColor1:=StringToColor(Data);
except
Settings.Skin.FontColor1:=clBlack;
Missing:=true;
end;
readln(Config,Data);
Delete(Data,1,7);
try
Settings.Skin.FontColor2:=StringToColor(Data);
except
Settings.Skin.FontColor2:=clWhite;
Missing:=true;
end;
readln(Config,Data);
Delete(Data,1,7);
try
Settings.Skin.FontColor3:=StringToColor(Data);
except
Settings.Skin.FontColor3:=clGreen;
Missing:=true;
end;
readln(Config,Data);
Delete(Data,1,7);
try
Settings.Skin.TrackBG:=StringToColor(Data);
except
Settings.Skin.TrackBG:=clTeal;
Missing:=true;
end;
//
CloseFile(Config);
except

try
CloseFile(Config); // this block is for the case if error occurs when the file already opened
                   // it should have been closed then in order not to cause problems later...
except
end;

//Settings.Skin:='Default';
Settings.ResH:=600;
Settings.ResW:=800;
Settings.Lang:='ENG';
Settings.PVol:=255;
Settings.Bckg:='Ameoba';
Settings.ARwd:=false;
Settings.ID3V:=true;
Settings.CTgs:=false;
Settings.CTgs:=false;
Settings.WDir:=InitDir+'Collections';
Settings.ALod:=false;
Settings.ADel:=false;
Settings.ASet:=false;
Settings.ACTr:=false;
Settings.Last:='None';
Settings.LDir:='None';
Settings.FSiz:=1000000;
ChangeSkin('Default');
Missing:=true; // error message will be shown later
end;

// if statement to show error message
if Missing then ShowMessage(TranslateText('WMissingData',Settings.Lang));

// setting everything according to actual settings
if Settings.ResH=600       then ResOpt1.Checked:=true else
if Settings.ResH=756       then ResOpt2.Checked:=true else
                                ResOpt3.Checked:=true;
if Settings.Bckg='Ameoba'  then BGOpt1.Checked:=true else
if Settings.Bckg='Flowers' then BGOpt2.Checked:=true else
if Settings.Bckg='Universe'then BGOpt3.Checked:=true else
if Settings.Bckg='Lights'  then BGOpt4.Checked:=true;
if Settings.Lang='ENG'     then LngOpt1.Checked:=true else
if Settings.Lang='CZE'     then LngOpt2.Checked:=true;// else
                                //LngOpt3.Checked:=true;
if Settings.Last='None' then PrgOpt4.Enabled:=false
                        else begin
                             // something can happen with the lastly saved collection since the last program run
                             CheckLastBackslash(Settings.Last);
                             if not FileExists(Settings.Last+'Info.col') then PrgOpt4.Enabled:=false;
                             end;
OpenMP3.Title:=TranslateText('MSGOpen',Settings.Lang);
OpenCollection.Title:=TranslateText('MSGOpen',Settings.Lang);
{
it is vain to have it here - will be rewriten in "TranslateFrom" method anyway...
case  Settings.FSiz of
1: begin
   Size1.Caption:='Total Size (B) :';
   Size2.Caption:='Size (B) :';
   Size3.Caption:='Size (B) :';
   end;
1000: begin
      Size1.Caption:='Total Size (kB) :';
      Size2.Caption:='Size (kB) :';
      Size3.Caption:='Size (kB) :';
      end;
1000000: begin
         Size1.Caption:='Total Size (MB) :';
         Size2.Caption:='Size (MB) :';
         Size3.Caption:='Size (MB) :';
         end;
end;
}

VolumeControlerSmall.Position:=Settings.PVol;
VolumeControler.Position:=Settings.PVol;

AutoSetTrackNumber.Checked:=Settings.ACTr;

// processing the options
ChangeSkin(Settings.Skin.SkinName);
ChangeResolution;
ChangeLanguage;

if Settings.ALod then begin
                      if FileExists(Settings.Last+'Info.col') then LoadExistingCollection(Settings.Last+'Info.col') // open the last, if any exists
                                                              else CollectionStatement:=false; // no colection opened
                      end
                 else CollectionStatement:=false; // no collection opened
ResetMP3Components;
if Settings.Last='None' then PrgOpt4.Enabled:=false; // only can be used when there was any collection opened and edited before
MainNav.ActivePageIndex:=0;
PlayStatement:=false;
// which ID3 tags version will be taken "defaultly"
if Settings.ID3V then begin
                      // lets pretent user's click
                      // there are a couple of things that have to be set
                      // so turn the situation round and then do as if user clicked the changing buttton
                      Settings.ID3V:=false;
                      ID3ChangerClick(Sender);
                      end
                 else begin
                      // lets pretent user's click
                      // there are a couple of things that have to be set
                      // so turn the situation round and then do as if user clicked the changing buttton
                      Settings.ID3V:=true;
                      ID3ChangerClick(Sender);
                      end;
//
AlignLabels;
end;
end;

procedure TForm1.ElapsedTimeTimer(Sender: TObject);
// moving the watch while playing MP3 track
var TrackEnd: boolean;
begin
// check for the end of the track ...
TrackEnd:=CheckIfEnd(Elapsed,CurrentMP3.Length);
if TrackEnd then begin
                 StopBClick(Sender); // we will do as if the stop button was hit...
                 // if automatic rewind option - returns currently played file to its start
                 if Settings.ARwd then begin
                                       PlayB.Click; // launch this song again
                                       end
                                  else
                 // checks if some tracks in query - then automatically go to the next one
                 if TrackQuery.Items.Count>CurrentMP3.ID+1 then begin
                                                                TrackQuery.ItemIndex:=CurrentMP3.ID+1;
                                                                CurrentMP3.Source:=MP3TrackQue[TrackQuery.ItemIndex].Path; // read the next one
                                                                //TrackQuery.Items[TrackQuery.ItemIndex].Path;
                                                                PlayB.Click; // launch the next one
                                                                end;
                 end
            else begin
                 // ...or still playing
                 Elapsed.S:=Elapsed.S+1;
                 if Elapsed.S >= 60 then begin
                                         Elapsed.S:=0;
                                         Elapsed.M:=Elapsed.M+1;
                                         if Elapsed.M >= 60 then begin
                                                                 Elapsed.M:=0;
                                                                 Elapsed.H:=Elapsed.H+1;
                                                                 end;
                                        end;
                 RewriteElapsedTime;
                 end;
end;

procedure TForm1.PlayBClick(Sender: TObject);
// starts the playing of MP3 track
var text: ^string; // we can spare some memory with pointer, because this variable don´t have to be used during the procedure
begin
if PlayStatement=false then begin // only starts new playing when no in progress
                            if (CurrentMP3.Source<>'')
                            and(FileExists(CurrentMP3.Source)) then begin // checking
                                                             try // there must be this error block...who knows what will happen...
                                                             PlayStatement:=true;
                                                             RandomizeGenericBrushForGeneric;
                                                             if Settings.Bckg='Ameoba' then ResetAmeobaPosition  // in PlayerU.dcu
                                                             else
                                                             if Settings.Bckg='Lights' then ResetLightsPosition; // in PlayerU.dcu
                                                             GenericBGRepaint.Enabled:=true;

                                                             // ID3 tags
                                                             if Settings.ID3V then begin
                                                                                   CurrentMP3.ID3v2:=ReadID3v2Tags(CurrentMP3.Source);
                                                                                   // filling info about ID3 tags
                                                                                   PlayTrack.Caption:=inttostr(CurrentMP3.ID+1)+' : '+CurrentMP3.ID3v2.Artist+' - '+CurrentMP3.ID3v2.Title;
                                                                                   PlayTrack.Hint:=TranslateText('MSGNowPlaying',Settings.Lang)+': '+CurrentMP3.ID3v2.Artist+' - '+CurrentMP3.ID3v2.Title+' ('+CurrentMP3.ID3v2.Album+')';
                                                                                   PlayTrackSmall.Caption:=CurrentMP3.ID3v2.Title;
                                                                                   PlayTrackSmall.Hint:=TranslateText('MSGNowPlaying',Settings.Lang)+': '+CurrentMP3.ID3v2.Artist+' - '+CurrentMP3.ID3v2.Title+' ('+CurrentMP3.ID3v2.Album+')';
                                                                                   end
                                                                              else begin
                                                                                   CurrentMP3.ID3v1:=ReadID3v1Tags(CurrentMP3.Source);
                                                                                   // filling info about ID3 tags
                                                                                   PlayTrack.Caption:=inttostr(CurrentMP3.ID+1)+' : '+CurrentMP3.ID3v1.Artist+' - '+CurrentMP3.ID3v1.Title+' ('+CurrentMP3.ID3v1.Album+')';
                                                                                   PlayTrackSmall.Caption:=CurrentMP3.ID3v1.Title;
                                                                                   PlayTrackSmall.Hint:='Now playing : '+CurrentMP3.ID3v1.Artist+' - '+CurrentMP3.ID3v1.Title+' ('+CurrentMP3.ID3v1.Album+')';
                                                                                   end;
                                                             //

                                                             HiddenPlayer.FileName:=CurrentMP3.Source;        // assigning MP3 file

                                                             CurrentMP3.Bitrate:=GetMP3Bitrate(CurrentMP3.Source); // in MP3Utilities.dcu
                                                             HiddenPlayer.Open;
                                                             CurrentMP3.Length:=RecountMP3Duration(HiddenPlayer.TrackLength[0]);
                                                             ElapsedTimeBar.Max:=HiddenPlayer.TrackLength[0];
                                                             ElapsedTimeBar.Position:=0;
                                                             ElapsedTimeBarSmall.Max:=HiddenPlayer.TrackLength[0];
                                                             ElapsedTimeBarSmall.Position:=0;

                                                             Elapsed.H:=0;
                                                             Elapsed.M:=0;
                                                             Elapsed.S:=0;
                                                             RewriteElapsedTime;

                                                             HiddenPlayer.Play;
                                                             
                                                             ElapsedTime.Enabled:=true;
                                                             ElapsedTime2.Enabled:=true;
                                                             except
                                                             // shut down everything that should be already launched
                                                             PlayStatement:=false;
                                                             ElapsedTime.Enabled:=false;
                                                             ElapsedTime2.Enabled:=false;
                                                             GenericBGRepaint.Enabled:=false;
                                                             GenericBG.Canvas.Brush.Color:=clBlack;
                                                             GenericBG.Canvas.Pen.Color:=clBlack;
                                                             GenericBG.Canvas.Rectangle(0,0,666,321);
                                                             ElapsedTimeBar.Position:=0;
                                                             //
                                                             ShowMessage(TranslateText('ECannotLaunchMP3',Settings.Lang));
                                                             end;
                                                             end;
                            end
                       else begin
                            // if playing already in progress, still can serve as Resume button, when song is PAUSED
                            if ElapsedTime.Enabled=false then begin
                                                              ElapsedTime.Enabled:=true;
                                                              ElapsedTime2.Enabled:=true;
                                                              RandomizeGenericBrushForGeneric;
                                                              GenericBGRepaint.Enabled:=true;
                                                              HiddenPlayer.Resume;

                                                              new(text);
                                                              text^:=PlayTrack.Caption;
                                                              Delete(text^,Length(text^)-8,10);
                                                              PlayTrack.Caption:=text^;
                                                              dispose(text);
                                                              end;
                            end;
end;

procedure TForm1.PauseBClick(Sender: TObject);
// pausing/resuming the playing of the MP3 track
var text: string;
begin
if PlayStatement then begin // only if any playing in progress
                      if ElapsedTime.Enabled then begin
                                                  //PlayStatement:=false;
                                                  ElapsedTime.Enabled:=false;
                                                  ElapsedTime2.Enabled:=false;
                                                  GenericBGRepaint.Enabled:=false;
                                                  HiddenPlayer.Pause;
                                                  PlayTrack.Caption:=PlayTrack.Caption+' [PAUSED]';
                                                  end
                                             else begin
                                                  //PlayStatement:=true;
                                                  ElapsedTime.Enabled:=true;
                                                  ElapsedTime2.Enabled:=true;
                                                  RandomizeGenericBrushForGeneric;
                                                  GenericBGRepaint.Enabled:=true;
                                                  HiddenPlayer.Resume;
                                                  Text:=PlayTrack.Caption;
                                                  Delete(Text,Length(Text)-8,10);
                                                  PlayTrack.Caption:=Text;
                                                  end;
                      end;
end;

procedure TForm1.StopBClick(Sender: TObject);
// closes down everything used while playing MP3 track
begin
if PlayStatement then begin // only if any playing in progress
                      PlayStatement:=false;
                      ElapsedTime.Enabled:=false;
                      ElapsedTime2.Enabled:=false;
                      GenericBGRepaint.Enabled:=false;
                      GenericBGRepaint.Interval:=25;
                      HiddenPlayer.Stop;
                      HiddenPlayer.Close;

                      {
                      ElapsedTimeBar.Position:=0;
                      Elapsed.H:=0;
                      Elapsed.M:=0;
                      Elapsed.S:=0;
                      RewriteElapsedTime;
                      }

                      GenericBG.Canvas.Brush.Color:=clBlack;
                      GenericBG.Canvas.Pen.Color:=clBlack;
                      GenericBG.Canvas.Rectangle(0,0,666,321);
                      // this only if the track wasnt deleted from the Tracklist
                      if TrackQuery.Items.Count>CurrentMP3.ID then
                                                              if CurrentMP3.Source=TrackQuery.Items[CurrentMP3.ID] then PlayTrack.Caption:=PlayTrack.Caption+' [STOPPED]'
                                                                                                                   else PlayTrack.Caption:='...'
                                                              else PlayTrack.Caption:='...';

                      end;
end;

procedure TForm1.FormResize(Sender: TObject);
// dynamic change of the form components while form is resised
begin
BGImage.Width:=Form1.Width;
BGImage.Height:=Form1.Height-50;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
// will save the actual configration (maybe changed during the program?) for the next launch
begin
if CollectionStatement then UpdateCollection;
CreateConfigFile; // in MP3Utilities.dcu

VolumeControl.Hlasitost:=255; // reseting previous sound settings for other programs
VolumeControl.Destroy; // tiding up
end;

procedure TForm1.SkinOpt1Click(Sender: TObject);
// selects default application skin
begin
SkinOpt1.Checked:=true;
Settings.Skin.SkinName:='Default';
ChangeSkin(Settings.Skin.SkinName);
end;

procedure TForm1.ResOpt1Click(Sender: TObject);
// selects resolution 800x600
begin
ResOpt1.Checked:=true;
Settings.ResH:=600;
Settings.ResW:=800;
ChangeResolution;
end;

procedure TForm1.ResOpt2Click(Sender: TObject);
// selects resolution 1024x756
begin
ResOpt2.Checked:=true;
Settings.ResH:=756;
Settings.ResW:=1024;
ChangeResolution;
end;

procedure TForm1.ResOpt3Click(Sender: TObject);
// selects resolution 1280x800
begin
ResOpt3.Checked:=true;
Settings.ResH:=800;
Settings.ResW:=1280;
ChangeResolution;
end;

procedure TForm1.LngOpt1Click(Sender: TObject);
// selects English language
begin
LngOpt1.Checked:=true;
Settings.Lang:='ENG';
ChangeLanguage;
end;

procedure TForm1.LngOpt2Click(Sender: TObject);
// selects Czech language
begin
LngOpt2.Checked:=true;
Settings.Lang:='CZE';
ChangeLanguage;
end;

procedure TForm1.PlrOpt1Click(Sender: TObject);
// starts playing of current MP3 track
begin
AssignMP3Click(Sender);
end;

procedure TForm1.AssignMP3Click(Sender: TObject);
// assigns MP3 file  and starts the playing
begin
if Settings.LDir<>'None' then begin
                              if DirectoryExists(Settings.LDir) then OpenMP3.InitialDir:=Settings.LDir
                                                                else OpenMP3.InitialDir:=InitDir;
                              end
                         else OpenMP3.InitialDir:=InitDir;
if OpenMP3.Execute then begin
                        if PlayStatement=true then StopB.Click; // we need to stop the playing first if any in progress
                        CurrentMP3.ID:=0;
                        CurrentMP3.Source:=OpenMP3.Files[0];
                        AssignTrackQuery(OpenMP3.Files);
                        // enable buttons of TQ pop-up menu
                        TQOpt1.Enabled:=true;
                        TQOpt2.Enabled:=true;
                        TQOpt3.Enabled:=true;
                        TQOpt4.Enabled:=true;
                        //
                        PlayB.Click; // we will do as if the start button was hit...
                        end;
end;

procedure TForm1.ElapsedTime2Timer(Sender: TObject);
// moves the elapsed time bars
begin
ElapsedTimeBar.Position:=HiddenPlayer.Position;
ElapsedTimeBarSmall.Position:=HiddenPlayer.Position;
end;

procedure TForm1.GenericBGRepaintTimer(Sender: TObject);
// repaints the GENERIC BG Sceen
var TargetCoords: TPoint;
    //RandomNumber: integer;
begin
if Settings.Bckg='Flowers' then begin
                                GenericBGRepaint.Interval:=25;
                                if (GenericBrush.ColorElapsed>=GenericBrush.ColorDuration) then RandomizeGenericBrushForGeneric;
                                GenericBrush.ColorElapsed:=GenericBrush.ColorElapsed+1;
                                TargetCoords.X:=random(99)-50+GenericBrush.Coords.X+random(GenericBrush.ColorElapsed)-random(GenericBrush.ColorElapsed);
                                TargetCoords.Y:=random(95)-50+GenericBrush.Coords.Y+random(GenericBrush.ColorElapsed)-random(GenericBrush.ColorElapsed);
                                GenericBG.Canvas.Pen.Color:=GenericBrush.Color;
                                GenericBG.Canvas.MoveTo(TargetCoords.X,TargetCoords.Y);
                                GenericBG.Canvas.LineTo(GenericBrush.Coords.X,GenericBrush.Coords.Y);
                                end
                           else
if Settings.Bckg='Ameoba' then begin
                               GenericBGRepaint.Interval:=25;
                               GenericBG.Canvas.Brush.Color:=clBlack;
                               GenericBG.Canvas.Pen.Color:=clBlack;
                               GenericBG.Canvas.Rectangle(0,0,665,320);if (GenericBrush.ColorElapsed>=GenericBrush.ColorDuration) then RandomizeGenericBrushForAmeoba;
                               GenericBrush.ColorElapsed:=GenericBrush.ColorElapsed+1;
                               // handling the movement
                               HandleAmeobaMovement(GenericBrush.AmeobaTop);  // in PlayerU.dcu
                               HandleAmeobaMovement(GenericBrush.AmeobaLeft);
                               HandleAmeobaMovement(GenericBrush.AmeobaRight);
                               HandleAmeobaMovement(GenericBrush.AmeobaBottom);

                               //HandleAmeobaMovement(GenericBrush.AmeobaTopRight);  // in PlayerU.dcu
                               //HandleAmeobaMovement(GenericBrush.AmeobaTopLeft);
                               //HandleAmeobaMovement(GenericBrush.AmeobaBottomRight);
                               //HandleAmeobaMovement(GenericBrush.AmeobaBottomLeft);

                               // painting ameoba
                               GenericBG.Canvas.Pen.Color:=GenericBrush.Color;
                               GenericBG.Canvas.Pen.Width:=5;
                               {GenericBG.Canvas.MoveTo(GenericBrush.AmeobaTop.X,GenericBrush.AmeobaTop.Y);
                               GenericBG.Canvas.LineTo(GenericBrush.AmeobaLeft.X,GenericBrush.AmeobaLeft.Y);
                               GenericBG.Canvas.LineTo(GenericBrush.AmeobaRight.X,GenericBrush.AmeobaRight.Y);
                               GenericBG.Canvas.MoveTo(GenericBrush.AmeobaBottom.X,GenericBrush.AmeobaBottom.Y);
                               GenericBG.Canvas.LineTo(GenericBrush.AmeobaLeft.X,GenericBrush.AmeobaLeft.Y);
                               GenericBG.Canvas.LineTo(GenericBrush.AmeobaRight.X,GenericBrush.AmeobaRight.Y);}
                               GenericBG.Canvas.MoveTo(GenericBrush.AmeobaTop.X,GenericBrush.AmeobaTop.Y);
                               //GenericBG.Canvas.LineTo(GenericBrush.AmeobaTopLeft.X,GenericBrush.AmeobaTopLeft.Y);
                               //GenericBG.Canvas.MoveTo(GenericBrush.AmeobaTopLeft.X,GenericBrush.AmeobaTopLeft.Y);
                               GenericBG.Canvas.LineTo(GenericBrush.AmeobaLeft.X,GenericBrush.AmeobaLeft.Y);
                               GenericBG.Canvas.MoveTo(GenericBrush.AmeobaLeft.X,GenericBrush.AmeobaLeft.Y);
                               //GenericBG.Canvas.LineTo(GenericBrush.AmeobaBottomLeft.X,GenericBrush.AmeobaBottomLeft.Y);
                               //GenericBG.Canvas.MoveTo(GenericBrush.AmeobaBottomLeft.X,GenericBrush.AmeobaBottomLeft.Y);
                               GenericBG.Canvas.LineTo(GenericBrush.AmeobaBottom.X,GenericBrush.AmeobaBottom.Y);
                               GenericBG.Canvas.MoveTo(GenericBrush.AmeobaBottom.X,GenericBrush.AmeobaBottom.Y);
                               //GenericBG.Canvas.LineTo(GenericBrush.AmeobaBottomRight.X,GenericBrush.AmeobaBottomRight.Y);
                               //GenericBG.Canvas.MoveTo(GenericBrush.AmeobaBottomRight.X,GenericBrush.AmeobaBottomRight.Y);
                               GenericBG.Canvas.LineTo(GenericBrush.AmeobaRight.X,GenericBrush.AmeobaRight.Y);
                               GenericBG.Canvas.MoveTo(GenericBrush.AmeobaRight.X,GenericBrush.AmeobaRight.Y);
                               //GenericBG.Canvas.LineTo(GenericBrush.AmeobaTopRight.X,GenericBrush.AmeobaTopRight.Y);
                               //GenericBG.Canvas.MoveTo(GenericBrush.AmeobaTopRight.X,GenericBrush.AmeobaTopRight.Y);
                               GenericBG.Canvas.LineTo(GenericBrush.AmeobaTop.X,GenericBrush.AmeobaTop.Y);
                               end
                          else
if Settings.Bckg='Lights' then begin
                               GenericBGRepaint.Interval:=15;
                               GenericBG.Canvas.Brush.Color:=clBlack;
                               GenericBG.Canvas.Pen.Color:=clBlack;
                               GenericBG.Canvas.Rectangle(0,0,665,320);if (GenericBrush.ColorElapsed>=GenericBrush.ColorDuration) then RandomizeGenericBrushForAmeoba;
                               GenericBrush.ColorElapsed:=GenericBrush.ColorElapsed+1;
                               // handling the movement
                               HandleAmeobaMovement(GenericBrush.LightsTopLeft1);  // in PlayerU.dcu
                               HandleAmeobaMovement(GenericBrush.LightsTopLeft2);
                               HandleAmeobaMovement(GenericBrush.LightsTopLeft3);
                               HandleAmeobaMovement(GenericBrush.LightsBottomRight1);
                               HandleAmeobaMovement(GenericBrush.LightsBottomRight2);
                               HandleAmeobaMovement(GenericBrush.LightsBottomRight3);

                               // painting lights
                               GenericBG.Canvas.Pen.Color:=GenericBrush.Color;
                               GenericBG.Canvas.Pen.Width:=5;

                               GenericBG.Canvas.MoveTo(0,0);
                               GenericBG.Canvas.LineTo(GenericBrush.LightsTopLeft1.X,GenericBrush.LightsTopLeft1.Y);
                               GenericBG.Canvas.MoveTo(0,0);
                               GenericBG.Canvas.LineTo(GenericBrush.LightsTopLeft2.X,GenericBrush.LightsTopLeft2.Y);
                               GenericBG.Canvas.MoveTo(0,0);
                               GenericBG.Canvas.LineTo(GenericBrush.LightsTopLeft3.X,GenericBrush.LightsTopLeft3.Y);
                               GenericBG.Canvas.MoveTo(665,320);
                               GenericBG.Canvas.LineTo(GenericBrush.LightsBottomRight1.X,GenericBrush.LightsBottomRight1.Y);
                               GenericBG.Canvas.MoveTo(665,320);
                               GenericBG.Canvas.LineTo(GenericBrush.LightsBottomRight2.X,GenericBrush.LightsBottomRight2.Y);
                               GenericBG.Canvas.MoveTo(665,320);
                               GenericBG.Canvas.LineTo(GenericBrush.LightsBottomRight3.X,GenericBrush.LightsBottomRight3.Y);
                               end
                          else
if Settings.Bckg='Universe' then begin
                                 end;
end;

procedure TForm1.PlrOpt3Click(Sender: TObject);
// opens settings window
begin
Application.CreateForm(TSettingsW, SettingsW);
TranslateForm('SettingsW',Main.Settings.Lang);
RepaintForm('SettingsW');
SettingsW.ShowModal;
SettingsW.Free;
end;

procedure TForm1.OpenMP3FolderChange(Sender: TObject);
// updates last opened directory
begin
Settings.LDir:=GetCurrentDir;
end;

procedure TForm1.TrackQueryDblClick(Sender: TObject);
// launches the mp3 according to the user choice
begin
if PlayStatement=true then StopB.Click; // we need to stop the playing first if any in progress
CurrentMP3.ID:=TrackQuery.ItemIndex;
CurrentMP3.Source:=MP3TrackQue[TrackQuery.ItemIndex].Path;
PlayB.Click; // launch this newly selected one
end;

procedure TForm1.TQOpt2Click(Sender: TObject);
var index: integer;
begin
index:=TrackQuery.ItemIndex; // has to be kept - otherwise it will change value to -1 in the next step
DeleteFromTrackQuery(TrackQuery.ItemIndex);
TrackQuery.Items.Delete(TrackQuery.ItemIndex);
if CurrentMP3.ID=index then // we need to stop the track if deleted
if PlayStatement=true then begin           // buz only if it was played
                           StopB.Click; // stop the playing
                           if TrackQuery.Items.Count>CurrentMP3.ID then begin // skip to next track (if possible)
                                                                        TrackQuery.ItemIndex:=CurrentMP3.ID;
                                                                        //CurrentMP3.ID:=TrackQuery.ItemIndex;
                                                                        CurrentMP3.Source:=MP3TrackQue[TrackQuery.ItemIndex].Path; // read the next one
                                                                        PlayB.Click; // launch the next one
                                                                        end;
                           end;
end;

procedure TForm1.PrgOpt1Click(Sender: TObject);
// creates new blank Collection
begin
// first backuping (if there is anything to backup)
if CollectionStatement then UpdateCollection;
// showing the wizard for the user
CollectionU.Inicialization:=true;
Application.CreateForm(TCollectionW,CollectionW);
TranslateForm('CollectionW',Main.Settings.Lang);
RepaintForm('CollectionW');
CollectionW.ShowModal;
if CollectionW.Cancel2B.Tag=0 then CreateBlankCollection; // if the process wasnt cancelled by user
                                                          // otherwise nothing from the following can happen

{
// i only keep it here for sure...

begin // if the process wasnt cancelled by user
                                         // otherwise nothing from the following can happen
CollectionStatement:=true; // now is some collection opened
PrgOpt4.Enabled:=false; // this option can't be used since now
// reseting some variables
CurrentActiveMP3:=-1;
CurrentActiveAlbum:=-1;
//
Text:=MP3Collection.Path; // string[255] isnt "normal" string for compiler...
CheckLastBackslash(Text);
MP3Collection.Path:=Text;
// create special sub-dirs
MkDir(MP3Collection.Path+'_art'); // where album and mp3 thumbnails will be stored
MkDir(MP3Collection.Path+'_root'); // where mp3 files will be stored
MkDir(MP3Collection.Path+'_temp'); // where mp3 files will be temporarily moved when renaming albums
// create "warning" files
AssignFile(WFile,MP3Collection.Path+'_art\WARNING.txt');
Rewrite(WFile);
WriteLn(WFile,'WARNING : Do not rename files in this directory in any case !!!');
WriteLn(WFile);
WriteLn(WFile,'If you alter any file name other way than via MP3xtreme, the references will be automatically removed from your collection !!!');
CloseFile(WFile);
AssignFile(WFile,MP3Collection.Path+'_root\WARNING.txt');
Rewrite(WFile);
WriteLn(WFile,'WARNING : Do not rename files in this directory in any case !!!');
WriteLn(WFile);
WriteLn(WFile,'If you alter any file name other way than via MP3xtreme, the references will be automatically removed from your collection !!!');
CloseFile(WFile);
//
MP3Collection.AlbumsNo:=1;
MP3Collection.MP3No:=0;
MP3Collection.Size:=0;
MP3Collection.LastEdit:='Right Now';
MP3Collection.Albums:=nil;
// creates "root" album
SetLength(MP3Collection.Albums,1);
MP3Collection.Albums[0].ID:=0;
MP3Collection.Albums[0].Order:=0;
MP3Collection.Albums[0].Name:='_root';
MP3Collection.Albums[0].Desc:='System root directory';
MP3Collection.Albums[0].MP3No:=0;
MP3Collection.Albums[0].Size:=0;
MP3Collection.Albums[0].Duration:=0;
MP3Collection.Albums[0].Image:='EmptyAlbum.jpg';
// for eliminating conversion errors
MP3Collection.Albums[0].CommonValues.Genre:='12';
MP3Collection.Albums[0].CommonValues.Year:='2008';
//
MP3Collection.MP3s:=nil;
// initially writes info about this collection into config file
CreateInfoFile(MP3Collection.Path+'Info.col');
// setting the components
ResetMP3Components;
// reseting the lists texts
MP3List2.Text:='MP3 File';
AlbumList2.Text:='MP3 Album';
AlbumList2.Text:='MP3 Album';
//
end;
}

// free the CollectionW window in the end to free the memory - in all cases
CollectionW.Free;
end;

procedure TForm1.XButtonClick(Sender: TObject);
begin
AlbumU.Inicialization:=true;
AlbumU.AlbumID:=CheckForSpace('Albums');
Application.CreateForm(TAlbumW,AlbumW);
TranslateForm('AlbumW',Main.Settings.Lang);
RepaintForm('AlbumW');
AlbumW.ShowModal;
AlbumW.Free;
// backup of data - after every change making backup
UpdateCollection;
end;

procedure TForm1.CollectionEClick(Sender: TObject);
// allows editing of Collection settings
var OldName: string;
begin
if CollectionStatement then begin
// backuping old name
OldName:=MP3Collection.Path;
//
CollectionU.Inicialization:=false;
Application.CreateForm(TCollectionW,CollectionW);
TranslateForm('CollectionW',Main.Settings.Lang);
RepaintForm('CollectionW');
CollectionW.ShowModal;
if CollectionW.CancelB.Tag<>1 then begin
                                   // rename coll if needed
                                   if OldName<>MP3Collection.Path then begin
                                                                       // if user changes the name or path of the collection
                                                                       MkDir(MP3Collection.Path);
                                                                       MoveDir(OldName+'\_art',MP3Collection.Path+'\_art'); // copy to new location (in FileSystemUtilities.dcu)
                                                                       MoveDir(OldName+'\_root',MP3Collection.Path+'\_root'); // copy to new location (in FileSystemUtilities.dcu)
                                                                       MoveDir(OldName+'\_temp',MP3Collection.Path+'\_temp'); // copy to new location (in FileSystemUtilities.dcu)
                                                                       RenameFile(OldName+'Info.col',MP3Collection.Path+'Info.col');
                                                                       try
                                                                       RemoveDir(OldName);
                                                                       except
                                                                       ShowMessage('Not empty');
                                                                       end;
                                                                       //DelDir(Main.MP3Collection.Path+OldName);  // erase the old location (in FileSystemUtilities.dcu)
                                                                       // RenameCollection(OldName,MP3Collection.Name);
                                                                       end;
                                   // backup of data - after every change making backup
                                   UpdateCollection;
                                   // setting components
                                   CollName.Caption:=MP3Collection.Name;
                                   CollDesc.Lines.Clear;
                                   CollDesc.Text:=MP3Collection.Desc;
                                   CollPath.Caption:=MP3Collection.Path;
                                   end;
CollectionW.Free;
end else ShowMessage(TranslateText('ENoCollection',Settings.Lang));
end;

procedure TForm1.PrgOpt2Click(Sender: TObject);
// loads previously saved collection
begin
OpenCollection.Title:=TranslateText('MSGOpenColl',Settings.Lang);
if Settings.Last<>'None' then begin
                              if DirectoryExists(Settings.Last) then OpenCollection.InitialDir:=Settings.Last
                                                                else OpenCollection.InitialDir:=InitDir+'Collections';
                              end
                         else OpenCollection.InitialDir:=InitDir+'Collections';
if OpenCollection.Execute then begin
                               // save old (if any)
                               UpdateCollection;
                               // load new
                               LoadExistingCollection(OpenCollection.FileName); // in WorkingU.dcu
                               CollectionStatement:=true; // now is some collection opened
                               PrgOpt4.Enabled:=false; // this option can't be used since now
                               // reseting some variables
                               CurrentActiveMP3:=-1;
                               CurrentActiveAlbum:=-1;
                               //
                               ResetMP3Components;
                               // reseting the lists texts
                               MP3List2.Text:='MP3 File';
                               AlbumList2.Text:='MP3 Album';
                               AlbumList2.Text:='MP3 Album';
                               //
                               end;
end;

procedure TForm1.PrgOpt4Click(Sender: TObject);
// auto-opens last opened collection
begin
// save old (if any)
// CreateInfoFile(MP3Collection.Path+'Info.col');
// load new
CheckLastBackslash(Settings.Last);
Settings.Last:=Settings.Last+'Info.col';
LoadExistingCollection(Settings.Last); // in WorkingU.dcu
CollectionStatement:=true; // now is some collection opened
PrgOpt4.Enabled:=false; // this option can be used only once (on startup)
// reseting some variables
CurrentActiveMP3:=-1;
CurrentActiveAlbum:=-1;
//
ResetMP3Components;
// reseting the lists texts
MP3List2.Text:='MP3 File';
AlbumList2.Text:='MP3 Album';
AlbumList2.Text:='MP3 Album';
//
end;

procedure TForm1.EditAClick(Sender: TObject);
// allows to edit selected Album from Collection
//var OldName: string;
begin
if CollectionStatement then begin
if AlbumList.ItemIndex>0 then begin // if any album selected and if it isnt "_root" album
                              // backuping old name
                              //OldName:=MP3Collection.Albums[AlbumList.ItemIndex].Name;
                              //
                              AlbumU.Inicialization:=false;
                              AlbumU.AlbumID:=AlbumList.ItemIndex;
                              Application.CreateForm(TAlbumW,AlbumW);
                              TranslateForm('AlbumW',Main.Settings.Lang);
                              RepaintForm('AlbumW');
                              AlbumW.ShowModal;
                              AlbumW.Free;
                              // rename album if needed
                              { - already done in AlbumU.dcu
                              if OldName<>MP3Collection.Albums[AlbumList.ItemIndex].Name then begin
                                                                                              RenameAlbum(OldName,MP3Collection.Albums[AlbumList.ItemIndex].Name); // if user changes the name of the album
                                                                                              ResetAlbumLists;
                                                                                              end;
                              }
                              // backup of data - after every change making backup
                              UpdateCollection;
                              end;
end else ShowMessage(TranslateText('ENoCollection',Settings.Lang));
end;

procedure TForm1.AddAClick(Sender: TObject);
// allows to add new Album to Collection
begin
if CollectionStatement then begin
AlbumU.Inicialization:=true;
AlbumU.AlbumID:=CheckForSpace('Albums');
Application.CreateForm(TAlbumW,AlbumW);
TranslateForm('AlbumW',Main.Settings.Lang);
RepaintForm('AlbumW');
AlbumW.ShowModal;
AlbumW.Free;
// backup of data - after every change making backup
UpdateCollection;
end else ShowMessage(TranslateText('ENoCollection',Settings.Lang));
end;

procedure TForm1.AlbumListClick(Sender: TObject);
// displays closer info about actual selection
// note - because of "root album" with index O the ItemIndex is raised by one
var i: integer;
begin
if CollectionStatement then
if AlbumList.Items[AlbumList.ItemIndex]<>'No Albums' then // only if any albums exist
begin
// reseting something - to make sure nothing wrong will happen
CurrentActiveMP3:=-1;
AlbumList2.ItemIndex:=-1;
AlbumList3.ItemIndex:=-1;
MP3List2.ItemIndex:=-1;
CurrentMP3Name.Caption:='...';
try
 CurrentMP3Image.Picture.LoadFromFile(InitDir+'EmptyAlbum.jpg');
except
 // if this failes, the whole program is about to crash
 ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'EmptyAlbum.jpg'+TranslateText('FEMissingFile2',Settings.Lang));
 CrucialE:=true; // the program must be terminated with no asking
 Form1.Close;
end;
ID3Title.Text:='';
ID3Artist.Text:='';
ID3Album.Text:='';
ID3Comment.Text:='';
UpDown1.Position:=2008;
UpDown2.Position:=12;
UpDown3.Position:=0;
//
// searching for CurrentActiveAlbum ID
if AlbumList.ItemIndex=0 then CurrentActiveAlbum:=0 // special case for "_root" album
                         else begin                 // otherwise we have to search
                              i:=-1;
                              repeat
                              i:=i+1;
                              until (MP3Collection.Albums[i].Name=AlbumList.Items[AlbumList.ItemIndex]);
                              CurrentActiveAlbum:=i;
                              end;
//
AlbName.Caption:=CutText(MP3Collection.Albums[CurrentActiveAlbum].Name,19);
AlbName.Hint:=MP3Collection.Albums[CurrentActiveAlbum].Name;
if AlbName.Caption='_root' then begin
                                AlbName.Caption:='Collection Dir';
                                AlbName.Hint:='Collection root directory';
                                end;
AlbMP3Count.Caption:=inttostr(MP3Collection.Albums[CurrentActiveAlbum].MP3No);
ResetSizeComponents('Alb');
AlbDuration.Caption:=DurationInTime(MP3Collection.Albums[CurrentActiveAlbum].Duration,true);
//
ResetMP3Lists;
end;
end;

procedure TForm1.MP3ListClick(Sender: TObject);
// displays closer info about actual selection
var i: integer;
begin
if MP3List.Items[MP3List.ItemIndex]<>'No MP3s' then // only if any mp3s exist
begin
// searching for CurrentActiveMP3 ID
i:=-1;
repeat
i:=i+1;
until (MP3Collection.MP3s[i].Name=MP3List.Items[MP3List.ItemIndex])and(MP3Collection.MP3s[i].Album=CurrentActiveAlbum);
CurrentActiveMP3:=i;
//
MP3Name.Caption:=CutText(MP3Collection.MP3s[CurrentActiveMP3].Name,19);
if CurrentActiveAlbum>0 then MP3Name.Hint:=MP3Collection.MP3s[CurrentActiveMP3].Name+' ('+MP3Collection.Albums[CurrentActiveAlbum].Name+')'
                        else MP3Name.Hint:=MP3Collection.MP3s[CurrentActiveMP3].Name+' (...)';
if MP3Collection.Albums[CurrentActiveAlbum].Name='_root' then MP3Album.Caption:='...'
                                                         else MP3Album.Caption:=MP3Collection.Albums[CurrentActiveAlbum].Name;
ResetSizeComponents('MP3');
MP3Duration.Caption:=DurationInTime(MP3Collection.MP3s[CurrentActiveMP3].Duration,true);
end;
end;

procedure TForm1.AddMClick(Sender: TObject);
// allows to add new single MP3 to Collection
begin
if CollectionStatement then begin
MP3U.Inicialization:=true;
MP3U.MP3ID:=CheckForSpace('MP3s');
if CurrentActiveAlbum=-1 then MP3U.AlbumID:=0 // defaultly inserting into "_root" album
                         else MP3U.AlbumID:=CurrentActiveAlbum; // if any album selected, then import into it
Application.CreateForm(TMP3W,MP3W);
TranslateForm('MP3W',Main.Settings.Lang);
RepaintForm('MP3W');
MP3W.ShowModal;
MP3W.Free;
// backup of data - after every change making backup
UpdateCollection;
end else ShowMessage(TranslateText('ENoCollection',Settings.Lang));
end;

procedure TForm1.EditMClick(Sender: TObject);
var i: integer;
    //OldName: string;
begin
if CollectionStatement then begin
if (MP3List.ItemIndex>-1)
and(MP3List.Items[MP3List.ItemIndex]<>'No MP3s')
                        then begin // only if any mp3 selected and exists
                             MP3U.Inicialization:=false;
                             // search for ID
                             i:=-1;
                             repeat
                             i:=i+1;
                             until MP3Collection.MP3s[i].Name=MP3List.Items[MP3List.ItemIndex];
                             // backuping old name
                             //OldName:=MP3Collection.MP3s[i].Name;
                             //
                             MP3U.MP3ID:=MP3Collection.MP3s[i].ID;
                             MP3U.AlbumID:=MP3Collection.MP3s[i].Album;
                             Application.CreateForm(TMP3W,MP3W);
                             TranslateForm('MP3W',Main.Settings.Lang);
                             RepaintForm('MP3W');
                             MP3W.ShowModal;
                             MP3W.Free;
                             // rename album if needed
                             { - already done in MP3U.dcu
                             if OldName<>MP3Collection.MP3s[i].Name then begin
                                                                         RenameMP3(OldName,MP3Collection.MP3s[i].Name); // if user changes the name of the file
                                                                         ResetMP3Lists;
                                                                         end;
                             }
                             // backup of data - after every change making backup
                             UpdateCollection;
                             end
                        else ShowMessage(TranslateText('XNoMP3',Settings.Lang));
end else ShowMessage(TranslateText('ENoCollection',Settings.Lang));                        
end;

procedure TForm1.AlbUpClick(Sender: TObject);
var index,id: integer;
begin
if CollectionStatement then begin
if AlbumList.Items[AlbumList.ItemIndex]='...' then id:=0
                                              else begin
                                                   id:=0;
                                                   repeat id:=id+1
                                                   until MP3Collection.Albums[id].Name=AlbumList.Items[AlbumList.ItemIndex];
                                                   end;

if MP3Collection.Albums[id].Order>1 then begin // album cannot be higher than second (after "_root")
                                         index:=AlbumList.ItemIndex-1;
                                         OptimalizeAlbumOrder(MP3Collection.Albums[id].Order,MP3Collection.Albums[id].Order-1); // first move the rest
                                         MP3Collection.Albums[id].Order:=MP3Collection.Albums[id].Order-1;                     // than update
                                         // backup of data - after every change making backup
                                         UpdateCollection;
                                         ResetAlbumLists;
                                         ResetLastEdit;
                                         AlbumList.ItemIndex:=index;
                                         end;
end;                                         
end;

procedure TForm1.AlbDownClick(Sender: TObject);
var index,id: integer;
begin
if CollectionStatement then begin
if AlbumList.Items[AlbumList.ItemIndex]='...' then id:=0
                                              else begin
                                                   id:=0;
                                                   repeat id:=id+1
                                                   until MP3Collection.Albums[id].Name=AlbumList.Items[AlbumList.ItemIndex];
                                                   end;

if (MP3Collection.Albums[id].Order<MP3Collection.AlbumsNo-1)
and(MP3Collection.Albums[id].ID<>0) then begin // album cannot be lower than last and "_root" cannot be moved down
                                         index:=AlbumList.ItemIndex+1;
                                         OptimalizeAlbumOrder(MP3Collection.Albums[id].Order,MP3Collection.Albums[id].Order+1); // first move the rest
                                         MP3Collection.Albums[id].Order:=MP3Collection.Albums[id].Order+1;                     // than update
                                         // backup of data - after every change making backup
                                         UpdateCollection;
                                         ResetAlbumLists;
                                         ResetLastEdit;
                                         AlbumList.ItemIndex:=index;
                                         end;
end;                                         
end;

procedure TForm1.MP3UpClick(Sender: TObject);
// change MP3 file order in Album
var i: integer;
begin
if CollectionStatement then begin
if MP3List.ItemIndex>0 then begin // otherwise there is nothing to do
                            // searching for CurrentActiveMP3 ID
                            i:=-1;
                            repeat
                            i:=i+1;
                            until (MP3Collection.MP3s[i].Name=MP3List.Items[MP3List.ItemIndex])and(MP3Collection.MP3s[i].Album=CurrentActiveAlbum);
                            CurrentActiveMP3:=i;
                            //
                            OptimalizeMP3Order(MP3Collection.MP3s[CurrentActiveMP3].Order,MP3Collection.MP3s[CurrentActiveMP3].Order-1);
                            MP3Collection.MP3s[CurrentActiveMP3].Order:=MP3Collection.MP3s[CurrentActiveMP3].Order-1;
                            SetMP3FileNumber(CurrentActiveMP3,MP3Collection.MP3s[CurrentActiveMP3].Order+1,MP3Collection.MP3s[CurrentActiveMP3].Order,false);
                            i:=MP3List.ItemIndex;
                            ResetMP3Lists;
                            MP3List.ItemIndex:=i-1;
                            MP3ListClick(Sender);
                            // backup of data - after every change making backup
                            UpdateCollection;
                            end;
end;
end;

procedure TForm1.MP3DownClick(Sender: TObject);
// change MP3 file order in Album
var i: integer;
begin
if CollectionStatement then begin
if MP3List.ItemIndex>0 then begin // otherwise there is nothing to do
                            // searching for CurrentActiveMP3 ID
                            i:=-1;
                            repeat
                            i:=i+1;
                            until (MP3Collection.MP3s[i].Name=MP3List.Items[MP3List.ItemIndex])and(MP3Collection.MP3s[i].Album=CurrentActiveAlbum);
                            CurrentActiveMP3:=i;
                            //
                            OptimalizeMP3Order(MP3Collection.MP3s[CurrentActiveMP3].Order,MP3Collection.MP3s[CurrentActiveMP3].Order+1);
                            MP3Collection.MP3s[CurrentActiveMP3].Order:=MP3Collection.MP3s[CurrentActiveMP3].Order+1;
                            SetMP3FileNumber(CurrentActiveMP3,MP3Collection.MP3s[CurrentActiveMP3].Order-1,MP3Collection.MP3s[CurrentActiveMP3].Order,false);
                            i:=MP3List.ItemIndex;
                            ResetMP3Lists;
                            MP3List.ItemIndex:=i+1;
                            MP3ListClick(Sender);
                            // backup of data - after every change making backup
                            UpdateCollection;
                            end;
end;
end;

procedure TForm1.MP3ImpOpt2Click(Sender: TObject);
// allows multiple section of imported MP3s
begin
if CollectionStatement then begin
if OpenMP3.Execute then begin
                        if CurrentActiveAlbum=-1 then CurrentActiveAlbum:=0; // defaultly inserting into "_root" album
                                                 //else MP3U.AlbumID:=CurrentActiveAlbum; // if any album selected, then import into it
                        // visualization of importing
                        Application.CreateForm(TImportW,ImportW);
                        RepaintForm('ImportW');
                        TranslateForm('ImportW',Main.Settings.Lang);
                        ImportW.Show;
                        ImportU.Items:=OpenMP3.Files;
                        ImportW.ImportFiles;
                        //
                        ResetMP3Components;
                        AlbumList.ItemIndex:=CurrentActiveAlbum;
                        AlbumListClick(Sender);
                        // backup of data - after every change making backup
                        UpdateCollection;
                        end;
end else ShowMessage(TranslateText('ENoCollection',Settings.Lang));                      
end;

procedure TForm1.ID3ChangerClick(Sender: TObject);
var text: string;
    tryGenre: integer;
begin
if Settings.ID3V then begin
                                   Settings.ID3V:=false;
                                   ID3Changer.Caption:='ID3v1';
                                   ID3Changer2.Caption:='ID3v1';
                                   ID3Changer.Hint:='Current : ID3v1';
                                   ID3Changer2.Hint:='Current : ID3v1';
                                   // setting limits for text fields (ID3v1 records can be only 30 chars long (comment 29))
                                   ID3Title.MaxLength:=30;
                                   ID3Artist.MaxLength:=30;
                                   ID3Album.MaxLength:=30;
                                   ID3Comment.MaxLength:=29;
                                   ID3Artist2.MaxLength:=30;
                                   ID3Album2.MaxLength:=30;
                                   ID3Comment2.MaxLength:=29;
                                   ID3Genre.ReadOnly:=true;
                                   //
                                   if CurrentActiveMP3>-1 then begin // only if there is anything to be loaded
                                                               // reload ID3v1 tags
                                                               ID3Title.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Title;
                                                               ID3Artist.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Artist;
                                                               ID3Album.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Album;
                                                               ID3Comment.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Comment;
                                                               try
                                                               UpDown1.Position:=strtoint(MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Year);
                                                               except
                                                               UpDown1.Position:=1900;
                                                               end;
                                                               // genre in ID3v1 is limited and represented by number
                                                               UpDown2.Position:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Genre;
                                                               ID3Genre.Text:=GetValueFromGenresTable(UpDown2.Position);
                                                               //
                                                               try
                                                               UpDown3.Position:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Track;
                                                               except
                                                               UpDown3.Position:=0;
                                                               end;
                                                               end;
                                   ShowMessage(TranslateText('NID3v1',Settings.Lang));
                                   end
                              else begin
                                   Settings.ID3V:=true;
                                   ID3Changer.Caption:='ID3v2';
                                   ID3Changer2.Caption:='ID3v2';
                                   ID3Changer.Hint:='Current : ID3v2';
                                   ID3Changer2.Hint:='Current : ID3v2';
                                   // setting limits for text fields (ID3v2 records can be unlimited)
                                   ID3Title.MaxLength:=0;
                                   ID3Artist.MaxLength:=0;
                                   ID3Album.MaxLength:=0;
                                   ID3Comment.MaxLength:=0;
                                   ID3Artist2.MaxLength:=0;
                                   ID3Album2.MaxLength:=0;
                                   ID3Comment2.MaxLength:=0;
                                   ID3Genre.ReadOnly:=false;
                                   //
                                   if CurrentActiveMP3>-1 then begin // only if there is anything to be loaded
                                                               // reload ID3v2 tags
                                                               ID3Title.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Title;
                                                               ID3Artist.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Artist;
                                                               ID3Album.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Album;
                                                               ID3Comment.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Comment;
                                                               try
                                                               UpDown1.Position:=strtoint(MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Year);
                                                               except
                                                               UpDown1.Position:=1900;
                                                               end;
                                                               // genre is a but harder
                                                               text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Genre;
                                                               // eliminating known problematic characters in genre expression
                                                               // so far i encountered " 'number' " and " (number) "
                                                               // other similar can be added when i notice them
                                                               while Pos('''',text)>0 do delete(text,Pos('''',text),1);
                                                               while Pos('(',text)>0 do delete(text,Pos('(',text),1);
                                                               while Pos(')',text)>0 do delete(text,Pos(')',text),1);
                                                               // maybe in ID3v2 the tag is written as string
                                                               // so try to convert it into inreger
                                                               tryGenre:=GetIndexFromGenresTable(text);
                                                               if tryGenre=255 then begin
                                                                                    UpDown2.Position:=12;
                                                                                    ID3Genre.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Genre; // lets see what is in genre saved
                                                                                    end
                                                                               else begin
                                                                                    UpDown2.Position:=tryGenre;
                                                                                    ID3Genre.Text:=GetValueFromGenresTable(UpDown2.Position);
                                                                                    end;
                                                               //
                                                               try
                                                               UpDown3.Position:=strtoint(MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Track);
                                                               except
                                                               UpDown3.Position:=0;
                                                               end;
                                                               end;
                                   //
                                   end;
end;

procedure TForm1.SaveID3Click(Sender: TObject);
//var text: ^string; // we can spare some memory with pointer, because this variable don´t have to be used during the procedure
begin
if CurrentActiveMP3<>-1 then begin
if Settings.ID3V=false then begin // ID3v1 tags
                                   // updating
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Title:=ID3Title.Text;
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Artist:=ID3Artist.Text;
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Album:=ID3Album.Text;
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Comment:=ID3Comment.Text;
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Year:=inttostr(UpDown1.Position);
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Genre:=UpDown2.Position;
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Track:=UpDown3.Position;
                                   // writing physicaly to file
                                   WriteID3v1Tags(MP3Collection.MP3s[CurrentActiveMP3].Path);
                                   // reload
                                   // MP3Collection.MP3s[CurrentActiveMP3].ID3v1:=ReadID3v1Tags(MP3Collection.MP3s[CurrentActiveMP3].Path);
                                   if CurrentMP3.Source=MP3Collection.MP3s[CurrentActiveMP3].Path then CurrentMP3.ID3v1:=ReadID3v1Tags(MP3Collection.MP3s[CurrentActiveMP3].Path);
                                   end
                              else begin // ID3v2 tags
                                   // updating
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Title:=ID3Title.Text;
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Artist:=ID3Artist.Text;
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Album:=ID3Album.Text;
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Comment:=ID3Comment.Text;
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Track:=inttostr(UpDown3.Position);
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Genre:=inttostr(UpDown2.Position);
                                   MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Year:=inttostr(UpDown1.Position);
                                   // writing physicaly to file
                                   WriteID3v2Tags(MP3Collection.MP3s[CurrentActiveMP3].Path,CurrentActiveMP3);
                                   // reload
                                   if CurrentMP3.Source=MP3Collection.MP3s[CurrentActiveMP3].Path then CurrentMP3.ID3v2:=ReadID3v2Tags(MP3Collection.MP3s[CurrentActiveMP3].Path);

                                   // automatic conversion into ID3v1 tags (if user has it selected)
                                   if Settings.CTgs then begin
                                                         // copying tags
                                                         ConvertID3v2ToID3v1(CurrentActiveMP3); // in ID3Utilities.dcu
                                                         // writing physicaly to file
                                                         WriteID3v1Tags(MP3Collection.MP3s[CurrentActiveMP3].Path);
                                                         // reload tags
                                                         if CurrentMP3.Source=MP3Collection.MP3s[CurrentActiveMP3].Path then CurrentMP3.ID3v1:=ReadID3v1Tags(MP3Collection.MP3s[CurrentActiveMP3].Path);
                                                         end;
                                   end;
end;                                   
end;

procedure TForm1.AlbumList2Change(Sender: TObject);
// fills MP3List according to the album selection
var i: integer;
begin
if CollectionStatement then
if AlbumList2.Text<>'No MP3 Albums' then begin // abuse on startup prevention
CurrentActiveAlbum:=AlbumList2.ItemIndex;
MP3List2.Items.Clear;
MP3List2.ItemIndex:=-1;
if MP3Collection.MP3No>0 then begin
                              for i:=0 to high(MP3Collection.MP3s) do if (MP3Collection.MP3s[i].Name<>'_Empty')
                                                                      and(MP3Collection.MP3s[i].Album=CurrentActiveAlbum) then MP3List2.Items.Add(MP3Collection.MP3s[i].Name);
                              end
                         else MP3List2.Items.Add('No MP3s');
MP3List2.ItemIndex:=0;
end;
end;

procedure TForm1.MP3List2Change(Sender: TObject);
// fills editing fields with selected mp3´s ID3 tags
var i: integer;
    text: string;
begin
if MP3List2.Text<>'No MP3s' then begin // abuse on startup prevention
EditM2.Enabled:=true; // security option
PlayM2.Enabled:=true; // security option
//
i:=-1;
repeat
i:=i+1;
until (MP3Collection.MP3s[i].Name=MP3List2.Items[MP3List2.ItemIndex])and(MP3Collection.MP3s[i].Album=CurrentActiveAlbum);
CurrentActiveMP3:=i;
//
if AlbumList2.Items[AlbumList2.ItemIndex]<>'...' then
                                                 text:=MP3Collection.MP3s[CurrentActiveMP3].Name+' ('+AlbumList2.Items[AlbumList2.ItemIndex]+')'
                                                 else
                                                 text:=MP3Collection.MP3s[CurrentActiveMP3].Name+' ( ... )';
CurrentMP3Name.Hint:=text; // in hint is displayed whole text
try
CurrentMP3Image.Picture.LoadFromFile(MP3Collection.MP3s[CurrentActiveMP3].Image);
except
 try
 CurrentMP3Image.Picture.LoadFromFile(InitDir+'EmptyMP3.jpg');
 MP3Collection.MP3s[CurrentActiveMP3].Image:=InitDir+'EmptyMP3.jpg';
 ShowMessage(TranslateText('ECorruptedImageMP3',Settings.Lang));
 except
 // if this failes, the whole program is about to crash
 ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'EmptyMP3.jpg'+TranslateText('FEMissingFile2',Settings.Lang));
 CrucialE:=true; // the program must be terminated with no asking
 Form1.Close;
 end;
end;
if length(text)>35 then begin // in the caption can be only first 35 letters
                        delete(text,35,256);
                        if text[length(text)]='(' then insert(' ',text,length(text)+1); // spacer
                        insert('...',text,length(text)+1); // marks, that the whole name is longer
                        if pos('(',text)>0 then insert(' )',text,length(text)+1); // close the parenthesis if opened
                        end;
CurrentMP3Name.Caption:=text;
// now it depends on ID3 tags version we are working with
if Settings.ID3V=false then begin
                                   ID3Title.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Title;
                                   ID3Artist.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Artist;
                                   ID3Album.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Album;
                                   ID3Comment.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Comment;
                                   try
                                   UpDown1.Position:=strtoint(MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Year);
                                   except
                                   UpDown1.Position:=1900;
                                   end;
                                   UpDown2.Position:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Genre;
                                   ID3Genre.Text:=inttostr(UpDown2.Position);
                                   UpDown3.Position:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Track;
                                   end
                              else begin
                                   ID3Title.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Title;
                                   ID3Artist.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Artist;
                                   ID3Album.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Album;
                                   ID3Comment.Text:=MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Comment;
                                   try
                                   UpDown1.Position:=strtoint(MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Year);
                                   except
                                   UpDown1.Position:=1900;
                                   end;
                                   // genre
                                   UpDown2.Position:=12;
                                   //
                                   try
                                   UpDown3.Position:=strtoint(MP3Collection.MP3s[CurrentActiveMP3].ID3v2.Track);
                                   except
                                   UpDown3.Position:=0;
                                   end;
                                   end;
end;

end;

procedure TForm1.PlayAClick(Sender: TObject);
// fills all mp3s from album into Player Query and starts playing the first
var i: integer;
begin
if AlbumList.ItemIndex>-1 then begin // only if any album selected
                               // fill files which will be added and add them
                               OpenMP3.Files.Clear;
                               for i:=0 to high(MP3Collection.MP3s) do if MP3Collection.MP3s[i].Album=AlbumList.ItemIndex then OpenMP3.Files.Add(MP3Collection.MP3s[i].Path);
                               if OpenMP3.Files.Count>0 then begin // only if album contains any mp3s
                                                             AssignTrackQuery(OpenMP3.Files);
                                                             // initialize playing
                                                             if PlayStatement=true then StopB.Click; // we need to stop the playing first if any in progress
                                                             CurrentMP3.ID:=0;
                                                             CurrentMP3.Source:=MP3TrackQue[0].Path;
                                                             // enable buttons of TQ pop-up menu
                                                             TQOpt1.Enabled:=true;
                                                             TQOpt2.Enabled:=true;
                                                             TQOpt3.Enabled:=true;
                                                             TQOpt4.Enabled:=true;
                                                             //
                                                             MainNav.ActivePageIndex:=0;
                                                             PlayB.Click; // we will do as if the start button was hit...
                                                             end
                                                         else ShowMessage(TranslateText('XEmptyAlbum',Settings.Lang));
                               end;
end;

procedure TForm1.PlayMClick(Sender: TObject);
// fills one selected mp3s into Player Query and starts playing it
//var MP3Files: TStrings;
begin
if (MP3List.ItemIndex>-1)
and(MP3List.Items[MP3List.ItemIndex]<>'No MP3s')
                        then begin // only if any mp3 selected and exists
                             // fill the mp3 file
                             OpenMP3.Files.Clear;
                             OpenMP3.Files.Add(MP3Collection.MP3s[MP3List.ItemIndex].Path);
                             AssignTrackQuery(OpenMP3.Files);
                             // initialize playing
                             if PlayStatement=true then StopB.Click; // we need to stop the playing first if any in progress
                             CurrentMP3.ID:=0;
                             CurrentMP3.Source:=MP3TrackQue[0].Path;
                             // enable buttons of TQ pop-up menu
                             TQOpt1.Enabled:=true;
                             TQOpt2.Enabled:=true;
                             TQOpt3.Enabled:=true;
                             TQOpt4.Enabled:=true;
                             //
                             MainNav.ActivePageIndex:=0;
                             PlayB.Click; // we will do as if the start button was hit...
                             end
                        else ShowMessage(TranslateText('XNoMP3',Settings.Lang));
end;

procedure TForm1.PlayM2Click(Sender: TObject);
// fills one selected mp3s into Player Query and starts playing it
//var MP3Files: TStrings;
begin
if CurrentActiveMP3<>-1 then begin
                             // fill the mp3 file
                             OpenMP3.Files.Clear;
                             OpenMP3.Files.Add(MP3Collection.MP3s[CurrentActiveMP3].Path);
                             AssignTrackQuery(OpenMP3.Files);
                             // initialize playing
                             if PlayStatement=true then StopB.Click; // we need to stop the playing first if any in progress
                             CurrentMP3.ID:=0;
                             CurrentMP3.Source:=MP3TrackQue[0].Path;
                             // enable buttons of TQ pop-up menu
                             TQOpt1.Enabled:=true;
                             TQOpt2.Enabled:=true;
                             TQOpt3.Enabled:=true;
                             TQOpt4.Enabled:=true;
                             //
                             MainNav.ActivePageIndex:=0;
                             PlayB.Click; // we will do as if the start button was hit...
                             end;
end;

procedure TForm1.EditM2Click(Sender: TObject);
begin
if CurrentActiveMP3<>-1 then begin
                             MP3U.Inicialization:=false;
                             MP3U.MP3ID:=MP3Collection.MP3s[CurrentActiveMP3].ID;
                             MP3U.AlbumID:=MP3Collection.MP3s[CurrentActiveMP3].Album;
                             Application.CreateForm(TMP3W,MP3W);
                             TranslateForm('MP3W',Main.Settings.Lang);
                             RepaintForm('MP3W');
                             MP3W.ShowModal;
                             MP3W.Free;
                             // reset MP3 list
                             ResetMP3Lists;
                             end;
end;

procedure TForm1.AlbumList3Change(Sender: TObject);
begin
if CollectionStatement then
if AlbumList3.Text<>'No MP3 Albums' then begin // abuse on startup prevention
EditA2.Enabled:=true;// security option
PlayA2.Enabled:=true;// security option
CurrentActiveAlbum:=AlbumList3.ItemIndex;
CurrentAlbumName.Caption:=AlbumList3.Items[AlbumList3.ItemIndex];
try
CurrentAlbumImage.Picture.LoadFromFile(MP3Collection.Albums[CurrentActiveAlbum].Image);
except
 try
 CurrentMP3Image.Picture.LoadFromFile(InitDir+'EmptyAlbum.jpg');
 MP3Collection.Albums[CurrentActiveAlbum].Image:=InitDir+'EmptyAlbum.jpg';
 ShowMessage(TranslateText('ECorruptedImageAlb',Settings.Lang));
 except
 // if this failes, the whole program is about to crash
 ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'EmptyAlbum.jpg'+TranslateText('FEMissingFile2',Settings.Lang));
 CrucialE:=true; // the program must be terminated with no asking
 Form1.Close;
 end;
end;
// setting values for "Common values" of ID3 tags
if Settings.ID3V=false then begin
                                    ID3Artist2.Text:=MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Artist;
                                    ID3Album2.Text:=MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Album;
                                    ID3Comment2.Text:=MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Comment;
                                    try
                                     ID3Year2.Text:=inttostr(MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Year);
                                     UpDown4.Position:=MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Year;
                                    except
                                     ID3Year2.Text:='2008';
                                     UpDown4.Position:=2008;
                                    end;
                                    try
                                     ID3Genre2.Text:=inttostr(MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Genre);
                                     UpDown7.Position:=MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Genre;
                                    except
                                    ID3Genre2.Text:='12';
                                    UpDown7.Position:=12;
                                    end;
                                    end
                               else begin
                                    ID3Artist2.Text:=MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Artist;
                                    ID3Album2.Text:=MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Album;
                                    ID3Comment2.Text:=MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Comment;
                                    ID3Year2.Text:=MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Year;
                                    try
                                     UpDown4.Position:=strtoint(MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Year);
                                    except
                                     UpDown4.Position:=2008;
                                    end;
                                    ID3Genre2.Text:=MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Genre;
                                    try
                                     UpDown7.Position:=strtoint(MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Genre);
                                    except
                                    UpDown7.Position:=12;
                                    end;
                                    end;
end;
end;

procedure TForm1.SkinOpt2Click(Sender: TObject);
begin
Application.CreateForm(TSkinW,SkinW);
TranslateForm('SkinW',Main.Settings.Lang);
RepaintForm('SkinW');
SkinW.ShowModal;
SkinW.Free;
end;

procedure TForm1.PlayA2Click(Sender: TObject);
// fills all mp3s from album into Player Query and starts playing the first
var i: integer;
begin
if CurrentActiveAlbum<>-1 then  begin // only if any album selected
                                // fill files which will be added and add them
                                OpenMP3.Files.Clear;
                                for i:=0 to high(MP3Collection.MP3s) do if MP3Collection.MP3s[i].Album=CurrentActiveAlbum then OpenMP3.Files.Add(MP3Collection.MP3s[i].Path);
                                if OpenMP3.Files.Count>0 then begin // only if album contains any mp3s
                                                              AssignTrackQuery(OpenMP3.Files);
                                                              // initialize playing
                                                              if PlayStatement=true then StopB.Click; // we need to stop the playing first if any in progress
                                                              CurrentMP3.ID:=0;
                                                              CurrentMP3.Source:=MP3TrackQue[0].Path;
                                                              // enable buttons of TQ pop-up menu
                                                              TQOpt1.Enabled:=true;
                                                              TQOpt2.Enabled:=true;
                                                              TQOpt3.Enabled:=true;
                                                              TQOpt4.Enabled:=true;
                                                              //
                                                              MainNav.ActivePageIndex:=0;
                                                              PlayB.Click; // we will do as if the start button was hit...
                                                              end
                                                          else ShowMessage(TranslateText('XEmptyAlbum',Settings.Lang));
                                end;
end;

procedure TForm1.EditA2Click(Sender: TObject);
// allows to edit selected Album from Collection
//var OldName: string;
begin
if CurrentActiveAlbum>0 then   begin // if any album selected and if it isnt "_root" album
                               // backuping old name
                               //OldName:=MP3Collection.Albums[AlbumList3.ItemIndex].Name;
                               //
                               AlbumU.Inicialization:=false;
                               AlbumU.AlbumID:=AlbumList3.ItemIndex;
                               Application.CreateForm(TAlbumW,AlbumW);
                               TranslateForm('AlbumW',Main.Settings.Lang);
                               RepaintForm('AlbumW');
                               AlbumW.ShowModal;
                               AlbumW.Free;
                               // rename album if needed
                               { - already done in AlbumU.dcu
                               if OldName<>MP3Collection.Albums[AlbumList3.ItemIndex].Name then begin
                                                                                                RenameAlbum(OldName,MP3Collection.Albums[AlbumList3.ItemIndex].Name); // if user changes the name of the album
                                                                                                ResetAlbumLists;
                                                                                                end;
                               }
                               // backup of data - after every change making backup
                               UpdateCollection;
                               end;
end;

procedure TForm1.VolumeControlerChange(Sender: TObject);
begin
// we have to differ - two different trackbars are using this procedure
if (Sender as TTrackBar).Tag = 0 then begin
                                      VolumeControlerSmall.Position:=VolumeControler.Position;
                                      VolumeControler.Hint:='Volume : '+inttostr(VolumeInPercents(VolumeControler.Position))+'%';
                                      VolumeControlerSmall.Hint:='Volume : '+inttostr(VolumeInPercents(VolumeControler.Position))+'%';
                                      VolumeControl.Hlasitost:=VolumeControler.Position;
                                      Settings.PVol:=VolumeControler.Position;
                                      end
                                 else begin
                                      VolumeControler.Position:=VolumeControlerSmall.Position;
                                      VolumeControler.Hint:='Volume : '+inttostr(VolumeInPercents(VolumeControlerSmall.Position))+'%';
                                      VolumeControlerSmall.Hint:='Volume : '+inttostr(VolumeInPercents(VolumeControlerSmall.Position))+'%';
                                      VolumeControl.Hlasitost:=VolumeControlerSmall.Position;
                                      Settings.PVol:=VolumeControlerSmall.Position;
                                      end;
end;

procedure TForm1.TQOpt3Click(Sender: TObject);
var Container: string;
begin
if TrackQuery.ItemIndex<>0 then begin
                                // updating id for player
                                if CurrentMP3.ID=TrackQuery.ItemIndex then CurrentMP3.ID:=CurrentMP3.ID-1 else
                                if CurrentMP3.ID=TrackQuery.ItemIndex-1 then CurrentMP3.ID:=CurrentMP3.ID+1;
                                // moving item
                                Container:=TrackQuery.Items[TrackQuery.ItemIndex];
                                TrackQuery.Items[TrackQuery.ItemIndex]:=TrackQuery.Items[TrackQuery.ItemIndex-1];
                                TrackQuery.Items[TrackQuery.ItemIndex-1]:=Container;
                                TrackQuery.ItemIndex:=TrackQuery.ItemIndex-1;
                                end;
end;

procedure TForm1.TQOpt4Click(Sender: TObject);
var Container: string;
begin
if TrackQuery.ItemIndex<>TrackQuery.Items.Count-1 then begin
                                                       // updating id for player
                                                       if CurrentMP3.ID=TrackQuery.ItemIndex then CurrentMP3.ID:=CurrentMP3.ID+1 else
                                                       if CurrentMP3.ID=TrackQuery.ItemIndex+1 then CurrentMP3.ID:=CurrentMP3.ID-1;
                                                       // moving item
                                                       Container:=TrackQuery.Items[TrackQuery.ItemIndex];
                                                       TrackQuery.Items[TrackQuery.ItemIndex]:=TrackQuery.Items[TrackQuery.ItemIndex+1];
                                                       TrackQuery.Items[TrackQuery.ItemIndex+1]:=Container;
                                                       TrackQuery.ItemIndex:=TrackQuery.ItemIndex+1;
                                                       end;
end;

procedure TForm1.SaveID32Click(Sender: TObject);
var i,mp3s: integer;
begin
if  CurrentActiveAlbum<>-1 then begin
                                if Settings.ID3V=false then begin
                                                                    if IgnoreArtist.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Artist:=ID3Artist2.Text;
                                                                    if IgnoreAlbum.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Album:=ID3Album2.Text;
                                                                    if IgnoreComment.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Comment:=ID3Comment2.Text;
                                                                    if IgnoreYear.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Year:=UpDown4.Position;
                                                                    if IgnoreGenre.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Genre:=UpDown7.Position;
                                                                    end
                                                               else begin
                                                                    if IgnoreArtist.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Artist:=ID3Artist2.Text;
                                                                    if IgnoreAlbum.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Album:=ID3Album2.Text;
                                                                    if IgnoreComment.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Comment:=ID3Comment2.Text;
                                                                    if IgnoreYear.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Year:=inttostr(UpDown4.Position);
                                                                    if IgnoreGenre.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v2.Genre:=inttostr(UpDown7.Position);
                                                                    if Settings.CTgs then begin
                                                                                          if IgnoreArtist.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Artist:=ID3Artist2.Text;
                                                                                          if IgnoreAlbum.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Album:=ID3Album2.Text;
                                                                                          if IgnoreComment.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Comment:=ID3Comment2.Text;
                                                                                          if IgnoreYear.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Year:=UpDown4.Position;
                                                                                          if IgnoreGenre.Tag=0 then MP3Collection.Albums[CurrentActiveAlbum].CommonValuesID3v1.Genre:=UpDown7.Position;
                                                                                          end;
                                                                    end;
mp3s:=0; // number of edited mp3s
         // we can stop the cycle much sooner with it
         //   - when we know we have encountered all MP3s from current album, it is no need to continue searching true the rest of the field
i:=-1;
repeat
i:=i+1;
if MP3Collection.MP3s[i].Album=CurrentActiveAlbum then begin
                                                       mp3s:=mp3s+1; // raise the number of encoutered mp3s
                                                       if Settings.ID3V=false then begin
                                                                                           // we are editing ID3v1 tags
                                                                                           // updating
                                                                                           if IgnoreArtist.Tag=0  then MP3Collection.MP3s[i].ID3v1.Artist:=ID3Artist2.Text;
                                                                                           if IgnoreAlbum.Tag=0   then MP3Collection.MP3s[i].ID3v1.Album:=ID3Album2.Text;
                                                                                           if IgnoreComment.Tag=0 then MP3Collection.MP3s[i].ID3v1.Comment:=ID3Comment2.Text;
                                                                                           if IgnoreYear.Tag=0    then MP3Collection.MP3s[i].ID3v1.Year:=inttostr(UpDown4.Position);
                                                                                           if IgnoreGenre.Tag=0   then MP3Collection.MP3s[i].ID3v1.Genre:=UpDown7.Position;
                                                                                           if AutoSetTrackNumber.Checked then try
                                                                                                                               MP3Collection.MP3s[i].ID3v1.Track:=MP3Collection.MP3s[i].Order;
                                                                                                                              except
                                                                                                                               MP3Collection.MP3s[i].ID3v1.Track:=0; // if the Order parameter (word type) is bigger than 255
                                                                                                                              end;
                                                                                           // writing physicaly to file
                                                                                           WriteID3v1Tags(MP3Collection.MP3s[i].Path);
                                                                                           // reload
                                                                                           if CurrentMP3.Source=MP3Collection.MP3s[i].Path then CurrentMP3.ID3v1:=ReadID3v1Tags(MP3Collection.MP3s[i].Path);
                                                                                           end
                                                                                      else begin
                                                                                           // we are editing ID3v2 tags
                                                                                           // updating
                                                                                           if IgnoreArtist.Tag=0  then MP3Collection.MP3s[i].ID3v2.Artist:=ID3Artist2.Text;
                                                                                           if IgnoreAlbum.Tag=0   then MP3Collection.MP3s[i].ID3v2.Album:=ID3Album2.Text;
                                                                                           if IgnoreComment.Tag=0 then MP3Collection.MP3s[i].ID3v2.Comment:=ID3Comment2.Text;
                                                                                           if IgnoreYear.Tag=0    then MP3Collection.MP3s[i].ID3v2.Year:=inttostr(UpDown4.Position);
                                                                                           if IgnoreGenre.Tag=0   then MP3Collection.MP3s[i].ID3v2.Genre:=inttostr(UpDown7.Position);
                                                                                           if AutoSetTrackNumber.Checked then MP3Collection.MP3s[i].ID3v2.Track:=inttostr(MP3Collection.MP3s[i].Order);

                                                                                           // writing physicaly to file
                                                                                           WriteID3v2Tags(MP3Collection.MP3s[i].Path,CurrentActiveMP3);
                                                                                           // reload
                                                                                           if CurrentMP3.Source=MP3Collection.MP3s[i].Path then CurrentMP3.ID3v2:=ReadID3v2Tags(MP3Collection.MP3s[i].Path);
                                                                                           // auto-conversion to ID3v1
                                                                                           if Settings.CTgs then begin
                                                                                                                 // copying tags
                                                                                                                 ConvertID3v2ToID3v1(CurrentActiveMP3); // in ID3Utilities.dcu
                                                                                                                 // writing physicaly to file
                                                                                                                 WriteID3v1Tags(MP3Collection.MP3s[i].Path);
                                                                                                                 // reload
                                                                                                                 if CurrentMP3.Source=MP3Collection.MP3s[i].Path then CurrentMP3.ID3v1:=ReadID3v1Tags(MP3Collection.MP3s[i].Path);
                                                                                                                 end;
                                                                                           end;

                                                       end;
until (i>=high(MP3Collection.MP3s))or(mp3s>=MP3Collection.Albums[CurrentActiveAlbum].MP3No);
end;
end;

procedure TForm1.IgnoreActionClick(Sender: TObject);
// universal for all five Ignore markers
begin
if (Sender as TPanel).Tag=0 then begin
                                 (Sender as TPanel).BevelInner:=bvLowered;
                                 (Sender as TPanel).BevelOuter:=bvLowered;
                                 (Sender as TPanel).Color:=clRed;
                                 (Sender as TPanel).Tag:=1;
                                 end
                            else begin
                                 (Sender as TPanel).BevelInner:=bvRaised;
                                 (Sender as TPanel).BevelOuter:=bvRaised;
                                 (Sender as TPanel).Color:=clBtnFace;
                                 (Sender as TPanel).Tag:=0;
                                 end;
end;

procedure TForm1.PlrOpt4Click(Sender: TObject);
// enables hiding of the Player Component
begin
if MainNav.Visible then begin
                        MainNav.Visible:=false;
                        HideMainNav.Visible:=false;
                        PlrOpt4.Caption:=TranslateText('MSGPlrOpt4show',Settings.Lang);
                        SmallIconsPanel.Visible:=true;
                        end
                   else begin
                        MainNav.Visible:=true;
                        HideMainNav.Visible:=true;
                        PlrOpt4.Caption:=TranslateText('MSGPlrOpt4hide',Settings.Lang);
                        SmallIconsPanel.Visible:=false;
                        end;

end;

procedure TForm1.MoveUp1Click(Sender: TObject);
// pop-up menu substitution for button click
// moving Album up in order
begin
MP3UpClick(Sender);
end;

procedure TForm1.MoveDown1Click(Sender: TObject);
// pop-up menu substitution for button click
// moving Album down in order
begin
MP3DownClick(Sender);
end;

procedure TForm1.Delete1Click(Sender: TObject);
// will delete selected MP3 from collection
var APIFrom, APITo: PChar;
    text: string;
begin
if CollectionStatement then begin
if CurrentActiveMP3>-1 then begin
                            // what is necessary to do?
                            // 0. making backup file in TEMP directory
                            text:=MP3Collection.MP3s[CurrentActiveMP3].Path;
                            APIFrom:=PChar(text);
                            APITo:=PChar(MP3Collection.Path+'_temp\'+inttostr(MP3Collection.MP3s[CurrentActiveMP3].ID)+'_'+MP3Collection.MP3s[CurrentActiveMP3].Name+'.mp3');
                            CopyFile(APIFrom,APITo,false); // backup file
                            // 1. remove reference from MP3s array
                            MP3Collection.MP3s[CurrentActiveMP3].Name:='_Empty'; // simple but effective
                                                                                 // other data will be overwritten by next newly added MP3
                            // 2. update collection and album stats (mp3no, size, duration)
                            MP3Collection.MP3No:=MP3Collection.MP3No-1;
                            MP3Collection.Size:=MP3Collection.Size-MP3Collection.MP3s[CurrentActiveMP3].Size;
                            MP3Collection.Duration:=MP3Collection.Duration-MP3Collection.MP3s[CurrentActiveMP3].Duration;
                            MP3Collection.Albums[MP3Collection.MP3s[CurrentActiveMP3].Album].MP3No:=MP3Collection.Albums[MP3Collection.MP3s[CurrentActiveMP3].Album].MP3No-1;
                            MP3Collection.Albums[MP3Collection.MP3s[CurrentActiveMP3].Album].Size:=MP3Collection.Albums[MP3Collection.MP3s[CurrentActiveMP3].Album].Size-MP3Collection.MP3s[CurrentActiveMP3].Size;
                            MP3Collection.Albums[MP3Collection.MP3s[CurrentActiveMP3].Album].Duration:=MP3Collection.Albums[MP3Collection.MP3s[CurrentActiveMP3].Album].Duration-MP3Collection.MP3s[CurrentActiveMP3].Duration;
                            // 3. physically delete the file
                            DeleteFile(MP3Collection.MP3s[CurrentActiveMP3].Path);
                            // 4. upgrade order of following MP3s in current album
                            OptimalizeMP3Order(MP3Collection.MP3s[CurrentActiveMP3].Order,MP3Collection.Albums[MP3Collection.MP3s[CurrentActiveMP3].Album].MP3No+2); // we simulate it like the file moved on the bottom of the order                                                                                                                                                    // - all files behind it, move to front by one
                            // final reseting
                            ResetMP3Components;
                            AlbumList.ItemIndex:=MP3Collection.MP3s[CurrentActiveMP3].Album;
                            AlbumListClick(Sender);
                            CurrentActiveMP3:=-1;
                            // backup of data - after every change making backup
                            UpdateCollection;
                            ShowMessage(TranslateText('XRemoveMP3',Settings.Lang));
                            end
                       else ShowMessage(TranslateText('XNoMP3',Settings.Lang));
end else ShowMessage(TranslateText('ENoCollection',Settings.Lang));
end;

procedure TForm1.Delete2Click(Sender: TObject);
// will delete selected Album from collection
begin
if CollectionStatement then begin
if CurrentActiveAlbum>-1 then begin
                            if CurrentActiveAlbum=0 then ShowMessage(TranslateText('XCannotDeleteRoot',Settings.Lang))
                                                    else
                            // ask first before doing something
                            if MessageDlg(TranslateText('QConfirmDelGeneral',Settings.Lang)+' '+TranslateText('QConfirmDelAlb',Settings.Lang),mtConfirmation,[mbYes,mbNo],0)=IDYes then
                            begin
                            // everything is in following procedure

                            RemoveAlbumFromCollection(CurrentActiveAlbum); // in WorkingU.dcu

                            // final reseting
                            ResetMP3Components;
                            CurrentActiveAlbum:=-1;
                            CurrentActiveMP3:=-1;
                            // backup of data - after every change making backup
                            UpdateCollection;
                            ShowMessage(TranslateText('XRemoveAlb',Settings.Lang));
                            end
                            end
                       else ShowMessage(TranslateText('XNoAlbum',Settings.Lang));
end else ShowMessage(TranslateText('ENoCollection',Settings.Lang));
end;

procedure TForm1.HelpOpt2Click(Sender: TObject);
begin
Application.CreateForm(TAboutW,AboutW);
RepaintForm('AboutW');
AboutW.ShowModal;
AboutW.Free;
end;

procedure TForm1.BgOpt1Click(Sender: TObject);
begin
BgOpt1.Checked:=true;
Settings.Bckg:='Ameoba';
if PlayStatement then begin // if playing in progres, the window should been changed
                      Form1.GenericBG.Canvas.Pen.Width:=5;
                      Form1.GenericBG.Canvas.Brush.Color:=clBlack;
                      Form1.GenericBG.Canvas.Pen.Color:=clBlack;
                      Form1.GenericBG.Canvas.Rectangle(0,0,665,320);
                      ResetAmeobaPosition;   // in PlayerU.dcu
                      RandomizeGenericBrushForAmeoba;  // in PlayerU.dcu
                      end;
end;

procedure TForm1.BGOpt2Click(Sender: TObject);
begin
BgOpt2.Checked:=true;
Settings.Bckg:='Flowers';
if PlayStatement then begin // if playing in progres, the window should been changed
                      Form1.GenericBG.Canvas.Pen.Width:=1;
                      Form1.GenericBG.Canvas.Brush.Color:=clBlack;
                      Form1.GenericBG.Canvas.Pen.Color:=clBlack;
                      Form1.GenericBG.Canvas.Rectangle(0,0,665,320);
                      RandomizeGenericBrushForGeneric;  // in PlayerU.dcu
                      end;
end;

procedure TForm1.BGOpt3Click(Sender: TObject);
begin
BgOpt3.Checked:=true;
Settings.Bckg:='Universe';
if PlayStatement then begin // if playing in progres, the window should been changed
                      Form1.GenericBG.Canvas.Brush.Color:=clBlack;
                      Form1.GenericBG.Canvas.Pen.Color:=clBlack;
                      Form1.GenericBG.Canvas.Rectangle(0,0,665,320);
                      end;
end;

procedure TForm1.BGOpt4Click(Sender: TObject);
begin
BgOpt4.Checked:=true;
Settings.Bckg:='Lights';
if PlayStatement then begin // if playing in progres, the window should been changed
                      Form1.GenericBG.Canvas.Pen.Width:=5;
                      Form1.GenericBG.Canvas.Brush.Color:=clBlack;
                      Form1.GenericBG.Canvas.Pen.Color:=clBlack;
                      Form1.GenericBG.Canvas.Rectangle(0,0,665,320);
                      ResetLightsPosition; // in PlayerU.dcu
                      RandomizeGenericBrushForAmeoba;  // in PlayerU.dcu
                      end;
end;

procedure TForm1.SkinOpt3Click(Sender: TObject);
begin
SkinOpt3.Checked:=true;
Settings.Skin.SkinName:='Dark Deep Ocean';
ChangeSkin(Settings.Skin.SkinName);
end;

procedure TForm1.SkinOpt5Click(Sender: TObject);
begin
SkinOpt5.Checked:=true;
Settings.Skin.SkinName:='Electric Blue';
ChangeSkin(Settings.Skin.SkinName);
end;

procedure TForm1.SkinOpt4Click(Sender: TObject);
begin
SkinOpt4.Checked:=true;
Settings.Skin.SkinName:='Nymphomaniac Phantasia';
ChangeSkin(Settings.Skin.SkinName);
end;

procedure TForm1.AutoSetTrackNumberClick(Sender: TObject);
begin
if AutoSetTrackNumber.Checked then begin
                                   Settings.ACTr:=false;
                                   end
                              else begin
                                   Settings.ACTr:=true;
                                   end;
end;

procedure TForm1.ColOpt3Click(Sender: TObject);
// will delete all references about current collection
begin
if CollectionStatement then begin
                            if MessageDlg(TranslateText('QConfirmDelGeneral',Settings.Lang)+' '+TranslateText('QConfirmDelColl',Settings.Lang),mtConfirmation,[mbYes,mbNo],0)=IDYes then
                            begin
                            // we only need to delete subdirectories and Info.col file
                            try
                            DelDir(MP3Collection.Path+'_art'); // in FileSystemUtilities.dcu
                            except
                            // do nothing
                            end;
                            try
                            DelDir(MP3Collection.Path+'_root'); // in FileSystemUtilities.dcu
                            except
                            // do nothing
                            end;
                            try
                            DelDir(MP3Collection.Path+'_temp'); // in FileSystemUtilities.dcu
                            except
                            // do nothing
                            end;
                            try
                            DeleteFile(MP3Collection.Path+'Info.col');
                            except
                            // do nothing
                            end;
                            try
                            RmDir(MP3Collection.Path);
                            except
                            ShowMessage('Not empty');
                            end;
                            // we wont be deleting all files in collection - who knows in which directory we are
                            // we only delete files created and used by MP3
                            //
                            MP3Collection.Path:='';
                            CreateBlankCollection; // this will handle all other things

                            CollectionStatement:=false; // for sure (i am now not sure, where it is set)
                            end;
                            end;
end;

procedure TForm1.UpDown2Click(Sender: TObject; Button: TUDBtnType);
// just a little feature
begin
ID3Genre.Text:=GetValueFromGenresTable(UpDown2.Position);
end;

procedure TForm1.HelpOpt1Click(Sender: TObject);
// no .hlp available yet
begin
ShowMessage(TranslateText('MSGNoHelp',Settings.Lang));
end;

end.
