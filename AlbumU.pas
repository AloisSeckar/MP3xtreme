/////////////////////////////////////////////////////////////////////
//                                                                 //
//                   MP3 - Master Player 3xtreme                   //
//                     mp3 player and organizer                    //
//                                                                 //
//                  Copyright � Ellrohir 2007-2008                 //
//                                                                 //
//                                                                 //
//    Page Info                                                    //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// *  Author:         *  Ellrohir [ ellrohir@seznam.cz ]         * //
// *  Homepage:       *  http://ellrohir.xf.cz/                  * //
// *  File:           *  AlbumU.pas                              * //
// *  Purpose:        *  Form for adding/editing albums          * //
// *  System Version: *  1.0                                     * //
// *  Last Modified:  *  2008-03-11 1205 GMT+1                   * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
/////////////////////////////////////////////////////////////////////

unit AlbumU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtDlgs, ExtCtrls, jpeg;

type
  TAlbumW = class(TForm)
    MainBox: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    OkB: TButton;
    CancelB: TButton;
    AlbName: TEdit;
    AlbDesc: TMemo;
    Label3: TLabel;
    AlbOrder: TEdit;
    UpDown1: TUpDown;
    Label4: TLabel;
    AlbImage: TImage;
    Button1: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    procedure AlignLabels;
    procedure FormCreate(Sender: TObject);
    procedure OkBClick(Sender: TObject);
    procedure CancelBClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure AlbNameKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AlbumW: TAlbumW;
  Inicialization: boolean; // if the album is edited (wizard should load info) or newly created (wizard fills default values)
  AlbumID: word;

implementation

uses Main, MP3Utilities, FileSystemUtilities, PlayerU;

{$R *.dfm}

procedure TAlbumW.AlignLabels;
begin
// dunno why...
Label1.Left:=10;
Label2.Left:=10;
Label3.Left:=180;
Label4.Left:=10;
end;

procedure TAlbumW.FormCreate(Sender: TObject);
// some incialization
begin
if Inicialization then begin
                       UpDown1.Max:=Main.MP3Collection.AlbumsNo;
                       MainBox.Caption:=TranslateText('MSGOkBCreate',Main.Settings.Lang)+' '+TranslateText('MSGWizardAlbum',Main.Settings.Lang);
                       OkB.Caption:=TranslateText('MSGOkBCreate',Main.Settings.Lang);
                       UpDown1.Position:=high(Main.MP3Collection.Albums)+1;
                       end
                  else begin
                       UpDown1.Max:=Main.MP3Collection.AlbumsNo-1;
                       MainBox.Caption:=TranslateText('MSGOkBEdit',Main.Settings.Lang)+' '+TranslateText('MSGWizardAlbum',Main.Settings.Lang);
                       OkB.Caption:=TranslateText('MSGOkBEdit',Main.Settings.Lang);
                       UpDown1.Position:=Main.MP3Collection.Albums[AlbumID].Order;
                       // initial data load
                       AlbName.Text:=Main.MP3Collection.Albums[AlbumID].Name;
                       AlbDesc.Text:=Main.MP3Collection.Albums[AlbumID].Desc;
                       // initial image load
                       try
                        OpenPictureDialog1.FileName:=Main.MP3Collection.Albums[AlbumID].Image;
                        AlbImage.Picture.LoadFromFile(OpenPictureDialog1.FileName);
                       except
                        try
                         OpenPictureDialog1.FileName:=InitDir+'EmptyAlbum.jpg';
                         AlbImage.Picture.LoadFromFile(InitDir+'EmptyAlbum.jpg');
                         MP3Collection.Albums[AlbumID].Image:=InitDir+'EmptyAlbum.jpg';
                         ShowMessage(TranslateText('ECorruptedImageAlb',Settings.Lang));
                        except
                         // if this failes, the whole program is about to crash
                         ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'EmptyAlbum.jpg'+TranslateText('FEMissingFile2',Settings.Lang));
                         CrucialE:=true; // the program must be terminated with no asking
                         AlbumW.Close;
                         Form1.Close;
                        end;
                       end;
                       end;
AlignLabels;
end;

procedure TAlbumW.OkBClick(Sender: TObject);
// processing changes
var OldAlbName: string;
begin
OkB.Enabled:=false; // this should prevent "double clicks"
// checking validity of name parameter
case CheckName(AlbName.Text) of
2: ShowMessage(TranslateText('XCharNotAllowed',Main.Settings.Lang));
1: ShowMessage(TranslateText('XCharInvalid',Main.Settings.Lang));
0: begin // {loop 1}
try
OldAlbName:=Main.MP3Collection.Path; // i dont want to call new variable, so i use this one declared for another use
CheckLastBackslash(OldAlbName);
Main.MP3Collection.Path:=OldAlbName;
OldAlbName:=Main.MP3Collection.Albums[AlbumID].Name; // saving old name
if (not DirectoryExists(Main.MP3Collection.Path+'_root\'+AlbName.Text)){* - no problem with renaming and possible overwriting}
or(OldAlbName=AlbName.Text){** - there is nothing to upgrade with album name}
then begin
// this is done only when new album added
if Inicialization then begin
                       MkDir(Main.MP3Collection.Path+'_root\'+AlbName.Text);
                       Main.MP3Collection.AlbumsNo:=Main.MP3Collection.AlbumsNo+1;
                       Main.MP3Collection.Albums[AlbumID].ID:=AlbumID;
                       // other inicialization
                       MP3Collection.Albums[AlbumID].MP3No:=0;
                       MP3Collection.Albums[AlbumID].Size:=0;
                       MP3Collection.Albums[AlbumID].Duration:=0;
                       // ininitalizing common values
                       MP3Collection.Albums[AlbumID].CommonValuesID3v1.Artist:='';
                       MP3Collection.Albums[AlbumID].CommonValuesID3v1.Album:='';
                       MP3Collection.Albums[AlbumID].CommonValuesID3v1.Comment:='';
                       MP3Collection.Albums[AlbumID].CommonValuesID3v1.Genre:=255;
                       MP3Collection.Albums[AlbumID].CommonValuesID3v1.Year:=1;
                       MP3Collection.Albums[AlbumID].CommonValuesID3v2.Artist:='';
                       MP3Collection.Albums[AlbumID].CommonValuesID3v2.Album:='';
                       MP3Collection.Albums[AlbumID].CommonValuesID3v2.Comment:='';
                       MP3Collection.Albums[AlbumID].CommonValuesID3v2.Genre:='255';
                       MP3Collection.Albums[AlbumID].CommonValuesID3v2.Year:='1';
                       // create warn file
                       CreateWarnFile(MP3Collection.Path+'_root\'+AlbName.Text+'\WARNING.txt');
                       end;
//
// this is done anyway
Main.MP3Collection.Albums[AlbumID].Name:=AlbName.Text;
 // test if it is necessary to rename directory (album name changed
 if not Inicialization then if (OldAlbName<>AlbName.Text)
                            and(OldAlbName<>'_Empty')  then begin
                                                             MkDir(Main.MP3Collection.Path+'_root\'+inttostr(Main.MP3Collection.Albums[AlbumID].Order)+' - '+Main.MP3Collection.Albums[AlbumID].Name);
                                                             MoveMP3s(AlbumID); // in MP3Utilities.dcu
                                                             CheckMP3sInQuery(AlbumID); // in PlayerU.dcu
                                                             RmDir(Main.MP3Collection.Path+'_root\'+OldAlbName); // if possible
                                                             end;
 //
Main.MP3Collection.Albums[AlbumID].Desc:=AlbDesc.Text;
// saving image thumbnail
if Main.MP3Collection.Albums[AlbumID].Image<>InitDir+'EmptyAlbum.bmp' then begin // this "default" image doesnt have to handled
                                                                           Main.MP3Collection.Albums[AlbumID].Image:=MP3Collection.Path+'_art\Album_'+inttostr(AlbumID)+'.jpg';
                                                                           AlbImage.Picture.SaveToFile(MP3Collection.Path+'_art\Album_'+inttostr(AlbumID)+'.jpg');
                                                                           //Main.MP3Collection.Albums[AlbumID].Image:=OpenPictureDialog1.FileName;
                                                                           //ImgSrc:=PChar(OpenPictureDialog1.FileName);
                                                                           //ImgDest:=PChar(MP3Collection.Path+'_art\Album'+inttostr(AlbumID)+'.bmp');
                                                                           //CopyFile(ImgSrc,ImgDest,false);
                                                                           end;
//
// Album Order has to be controlled
try
 if Inicialization then Main.MP3Collection.Albums[AlbumID].Order:=UpDown1.Position; // otherwise no previous value
 OptimalizeAlbumOrder(Main.MP3Collection.Albums[AlbumID].Order,UpDown1.Position); // first move the rest
 SetAlbumFolderNumber(AlbumID,Main.MP3Collection.Albums[AlbumID].Order,UpDown1.Position,Inicialization); // (in MP3Utilities.dcu)         // than update the folder name
 CheckMP3sInQuery(AlbumID); // in PlayerU.dcu
 Main.MP3Collection.Albums[AlbumID].Order:=UpDown1.Position;                      // than update the position
 Form1.ResetMP3Components; // rewrite program components
 Form1.AlbumList.ItemIndex:=AlbumID;
 Form1.AlbumListClick(Sender);
 AlbumW.Close; // only if this step is properly handled - otherwise it will stay opened to user can update the value
 except
 ShowMessage(TranslateText('EInvalidInput',Settings.Lang));
end;
end
else ShowMessage(TranslateText('EDirectoryExists',Settings.Lang));
except // if user types in some nonsence under that new directory cannot be created
ShowMessage(TranslateText('EInvalidPath',Settings.Lang));
end;
end; // {loop 1}
end; // end of "Case"
OkB.Enabled:=true; // should be used again
end;

procedure TAlbumW.CancelBClick(Sender: TObject);
begin
AlbumW.Close;
end;

procedure TAlbumW.Button1Click(Sender: TObject);
begin
if OpenPictureDialog1.Execute then begin
                                   OpenPictureDialog1.InitialDir:=GetCurrentDir;
                                   try
                                   AlbImage.Picture.LoadFromFile(OpenPictureDialog1.FileName);
                                   //AlbImage.Picture.Graphic.LoadFromFile(OpenPictureDialog1.FileName);
                                   except
                                   // nothing so far
                                   end;
                                   end;
end;

procedure TAlbumW.AlbNameKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
// disallows invalid inputs
// only allowed - backspace, enter, space, nums 0-9, letters a-z, letters A-Z, some special letters
//var text: string;
//    allowed: boolean;
begin
{
if length(AlbName.Text)>0 then begin
                               text:=AlbName.Text;
                               allowed:=false;
                               if (ord(text[length(text)])=8) then allowed:=true
                               else
                               if (ord(text[length(text)])=13) then allowed:=true
                               else
                               if (ord(text[length(text)])=32) then allowed:=true
                               else
                               if ((ord(text[length(text)])<=35)and(ord(text[length(text)])>=38)) then allowed:=true
                               else
                               if ((ord(text[length(text)])<=48)and(ord(text[length(text)])>=57)) then allowed:=true
                               else
                               if ((ord(text[length(text)])<=64)and(ord(text[length(text)])>=90)) then allowed:=true
                               else
                               if ((ord(text[length(text)])<=97)and(ord(text[length(text)])>=122)) then allowed:=true;

                               if not allowed then delete(text,length(text),1);
                               AlbName.Text:=text;
                               end;
}                               
end;

end.
