/////////////////////////////////////////////////////////////////////
//                                                                 //
//                   MP3 - Master Player 3xtreme                   //
//                     mp3 player and organizer                    //
//                                                                 //
//                 Copyright � Ellrohir 2007-2008                  //
//                                                                 //
//                                                                 //
//    Page Info                                                    //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// *  Author:         *  Ellrohir [ ellrohir@seznam.cz ]         * //
// *  Homepage:       *  http://ellrohir.xf.cz/                  * //
// *  File:           *  ImportU.pas                             * //
// *  Purpose:        *  Unit for copying mp3 files to new locs  * //
// *  System Version: *  1.0                                     * //
// *  Last Modified:  *  2008-03-10 1045 GMT+1                   * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
/////////////////////////////////////////////////////////////////////

unit ImportU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, jpeg;

type
  TImportW = class(TForm)
    ImportProgress: TProgressBar;
    Label1: TLabel;
    MP3Image: TImage;
    procedure ImportOne;
    procedure ImportFiles;

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ImportW: TImportW;
  Items: TStrings;
  //PathToSource,PathToTarget: string;

implementation

uses Main, MP3Utilities, ID3Utilities;

{$R *.dfm}

procedure TImportW.ImportOne;
// only dumb "animation" of importing
var i,i2: integer;
begin
ImportProgress.Position:=0;
ImportProgress.Max:=1000;
for i:=1 to 1000 do begin
                    for i2:=1 to 100 do Application.ProcessMessages;
                    ImportProgress.Position:=i;
                    end;
ImportW.Close;
end;

procedure TImportW.ImportFiles;
var i,i2,i3,MP3ID,Existing: integer;
    status: integer;
    execute: boolean;
    FilePath,MP3Name: string;
    APIFrom,APITo: PAnsiChar;
begin
ImportProgress.Max:=Items.Count*500;
for i:=0 to Items.Count-1 do begin
                             status:=IDHelp; // "default" value which wont be used
                             if status<>IDCancel then begin
                                                      // visualization - part1
                                                      Label1.Caption:=TranslateText('MSGImport',Main.Settings.Lang)+' '+inttostr(i+1)+'/'+inttostr(Items.Count);
                                                      //execute:=true; // file can be imported now
                                                      // getting MP3 name
                                                      // setting file name
                                                      MP3Name:=Items[i];
                                                      CutPath(MP3Name);
                                                      Delete(MP3Name,101,256); // only 100 chars allowed
                                                      //
                                                      FilePath:=Main.MP3Collection.Path;
                                                      CheckLastBackslash(FilePath);
                                                      FilePath:=FilePath+'_root\';
                                                      if (CurrentActiveAlbum>0) then FilePath:=FilePath+inttostr(MP3Collection.Albums[CurrentActiveAlbum].Order)+' - '+MP3Collection.Albums[CurrentActiveAlbum].Name+'\';
                                                      FilePath:=FilePath+MP3Name+'.mp3';

                                                      // now checking if file can be written
                                                      Existing:=CheckExistence(MP3Name,CurrentActiveAlbum);
                                                      if Existing>-1 then status:=MessageDlg('File with same name already exists in selected album. Overwrite?',mtConfirmation,[mbYes,mbNo,mbCancel],0);
                                                      if status=IDNo then execute:=false
                                                                     else execute:=true;

                                                      if execute then begin // file can be imported
                                                                      if Existing>-1 then begin
                                                                                          MP3ID:=Existing;
                                                                                          Main.MP3Collection.MP3s[MP3ID].Order:=MP3Collection.MP3s[Existing].Order;
                                                                                          end
                                                                                     else begin
                                                                                          MP3ID:=CheckForSpace('MP3s');
                                                                                          Main.MP3Collection.MP3s[MP3ID].Order:=MP3Collection.Albums[CurrentActiveAlbum].MP3No+1;
                                                                                          end;
                                                                      try // if any single error occurs, all will fail
                                                                      MP3Collection.MP3s[MP3ID].ID:=MP3ID;
                                                                      // updating file sizes, duration and mp3 count
                                                                      MP3Collection.MP3No:=MP3Collection.MP3No+1;
                                                                      MP3Collection.Albums[CurrentActiveAlbum].MP3No:=MP3Collection.Albums[CurrentActiveAlbum].MP3No+1;
                                                                      try
                                                                      // size of the file
                                                                      Main.MP3Collection.MP3s[MP3ID].Size:=GetFileSize(Items[i]);
                                                                      Main.MP3Collection.Albums[CurrentActiveAlbum].Size:=Main.MP3Collection.Albums[CurrentActiveAlbum].Size+Main.MP3Collection.MP3s[MP3ID].Size;
                                                                      Main.MP3Collection.Size:=Main.MP3Collection.Size+Main.MP3Collection.MP3s[MP3ID].Size;
                                                                      // duration
                                                                      Main.MP3Collection.MP3s[MP3ID].Duration:=Form1.GetMP3LengthViaTMediaPlayer(Items[i]); // in Main.dcu
                                                                      Main.MP3Collection.Duration:=Main.MP3Collection.Duration+Main.MP3Collection.MP3s[MP3ID].Duration;
                                                                      Main.MP3Collection.Albums[CurrentActiveAlbum].Duration:=Main.MP3Collection.Albums[CurrentActiveAlbum].Duration+Main.MP3Collection.MP3s[MP3ID].Duration;
                                                                      except
                                                                      end;
                                                                      // copying MP3 to the location
                                                                      APIFrom:=PChar(Items[i]);
                                                                      APITo:=PChar(FilePath);
                                                                      CopyFile(APIFrom,APITo,false);
                                                                      if Settings.ADel then DeleteFile(APIFrom); // automatic delete of source files
                                                                      //
                                                                      // filling other info
                                                                      Main.MP3Collection.MP3s[MP3ID].Name:=MP3Name;
                                                                      Main.MP3Collection.MP3s[MP3ID].Album:=CurrentActiveAlbum;
                                                                      Main.MP3Collection.MP3s[MP3ID].Path:=FilePath;
                                                                      SetMP3FileNumber(MP3ID, 0, Main.MP3Collection.MP3s[MP3ID].Order, true);
                                                                      // image
                                                                      if Main.MP3Collection.Albums[CurrentActiveAlbum].Image<>InitDir+'EmptyAlbum.jpg' then begin
                                                                                                                                                            try // try to load setted album image
                                                                                                                                                             MP3Image.Picture.LoadFromFile(Main.MP3Collection.Albums[CurrentActiveAlbum].Image);
                                                                                                                                                            except // if not exists
                                                                                                                                                             try // try to load defaulf MP3 image
                                                                                                                                                              MP3Image.Picture.LoadFromFile(InitDir+'EmptyMP3.jpg');
                                                                                                                                                             except
                                                                                                                                                              // if this failes, the whole program is about to crash
                                                                                                                                                              ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'EmptyMP3.jpg'+TranslateText('FEMissingFile2',Settings.Lang));
                                                                                                                                                              CrucialE:=true; // the program must be terminated with no asking
                                                                                                                                                              ImportW.Close;
                                                                                                                                                              Form1.Close;
                                                                                                                                                             end;
                                                                                                                                                            end;
                                                                                                                                                            end;
                                                                      // saving and setting the image
                                                                      try
                                                                       MP3Image.Picture.SaveToFile(MP3Collection.Path+'_art\MP3_'+inttostr(MP3ID)+'.jpg');
                                                                       Main.MP3Collection.MP3s[MP3ID].Image:=MP3Collection.Path+'_art\MP3_'+inttostr(MP3ID)+'.jpg';
                                                                      except
                                                                       // nothing so far
                                                                      end;
                                                                      try // may cause errors
                                                                       // fills MP3Tags
                                                                       MP3Collection.MP3s[MP3ID].ID3v2:=ReadID3v2Tags(Main.MP3Collection.MP3s[MP3ID].Path);
                                                                       if Settings.CTgs then ConvertID3v2ToID3v1(MP3ID)
                                                                                        else MP3Collection.MP3s[MP3ID].ID3v1:=ReadID3v1Tags(Main.MP3Collection.MP3s[MP3ID].Path);
                                                                       if Settings.ASet then AutoSetTags(MP3ID,CurrentActiveAlbum);
                                                                       // automatic setting of Track parameter
                                                                       if Settings.ACTr then begin
                                                                                             Main.MP3Collection.MP3s[MP3ID].ID3v2.Track:=inttostr(Main.MP3Collection.MP3s[MP3ID].Order);
                                                                                             try
                                                                                              Main.MP3Collection.MP3s[MP3ID].ID3v1.Track:=Main.MP3Collection.MP3s[MP3ID].Order;
                                                                                             except
                                                                                              Main.MP3Collection.MP3s[MP3ID].ID3v1.Track:=0; // if order higher than 255
                                                                                             end;
                                                                                             end;
                                                                      except
                                                                        // i will handle it later
                                                                      end;
                                                                      except
                                                                       Main.MP3Collection.MP3s[MP3ID].Name:='_Empty'; // setting current slot as empty - anything that was added in it, will be ignored
                                                                       ShowMessage(TranslateText('ECannotImportMP3',Settings.Lang));
                                                                      end;
                                                                      end;
                                                          // visualization
                                                          for i2:=1 to 500 do begin
                                                                              for i3:=1 to 100 do Application.ProcessMessages;
                                                                              ImportProgress.Position:=ImportProgress.Position+1;
                                                                              end;
                                                      end;
                             end;
ImportW.Close;                                     
end;

{
// i changed the way i do this - via calling API functions

procedure TImportW.CopyMP3;
// "dumb" copying of MP3 files - byte to byte
var Source,Target: File of byte;
    i: integer;
    ch: byte;
    Size: longint;
begin
try
AssignFile(Source,PathToSource);
AssignFile(Target,PathToTarget);
Reset(Source);
Rewrite(Target);
// getting the size
Size:=FileSize(Source) div 100;
ImportW.ImportProgress.Max:=Size;
ImportW.ImportProgress.Position:=1;
//
// transfering bytes of the file
i:=0;
repeat
if i>=100 then begin  // visual effect
               i:=0;
               ImportProgress.Position:=ImportW.ImportProgress.Position+1;
               end;
i:=i+1;
read(Source,ch);
write(Target,ch);
until eof(Source);
//
CloseFile(Source);
CloseFile(Target);
except
ShowMessage('ERROR - MP3 file cannot be imported.');
end;
ImportW.Close;
end;
}

end.
