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
// *  File:           *  WorkingU.pas                            * //
// *  Purpose:        *  Misc procedures for MP3                 * //
// *  System Version: *  1.0                                     * //
// *  Last Modified:  *  2008-03-10 1000 GMT+1                   * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
/////////////////////////////////////////////////////////////////////

unit WorkingU;

interface

uses Windows,Dialogs, Forms, SysUtils;

procedure LoadExistingCollection(PathToSource: string);
procedure CreateBlankCollection;
procedure UpdateCollection;
procedure CreateInfoFile(PathToFile: string);
procedure RemoveAlbumFromCollection(CurrentActiveAlbum: integer);
{
procedure RenameCollection(OldCollName,NewCollName: string);
procedure RenameAlbum(OldAlbName,NewAlbName: string);
procedure RenameMP3(OldFileName,NewFileName: string);
}

implementation

uses Main, MP3Utilities, ID3Utilities, FileSystemUtilities;

procedure LoadExistingCollection(PathToSource: string);
// loads existing collection and sets the main form components
var InfoFile: textfile;
    Text: string;
    i,i2,ErrorsMP3,ErrorsA: integer;
    Sender: TObject;
begin
//CheckLastBackslash(PathToSource);
AssignFile(InfoFile,PathToSource);
try
Reset(InfoFile);
// loads the variables
ReadLN(InfoFile,MP3Collection.Name);
// Description can be written on more than one line...
MP3Collection.Desc:='';
repeat
ReadLN(InfoFile,Text);
if Text<>'_eoDesc' then MP3Collection.Desc:=MP3Collection.Desc+Text;
until Text='_eoDesc';
//Delete(MP3Collection.Desc,length(MP3Collection.Desc)-7,8); // delete this "_eoDesc" marker
//
ReadLN(InfoFile,MP3Collection.Path);
ReadLN(InfoFile,MP3Collection.AlbumsNo);
ReadLN(InfoFile,MP3Collection.MP3No);
ReadLN(InfoFile,MP3Collection.Size);
ReadLN(InfoFile,MP3Collection.Duration);
ReadLN(InfoFile,MP3Collection.LastEdit);
ReadLN(InfoFile); // skip spacer
// now read Albums info
MP3Collection.Albums:=nil;
for i:=0 to MP3Collection.AlbumsNo-1 do begin
                                        i2:=CheckForSpace('Albums');
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].ID);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].Order);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].Name);

                                        // description should be more lines
                                        MP3Collection.Albums[i2].Desc:='';
                                        repeat
                                        ReadLn(InfoFile,Text);
                                        if Text<>'_eoDesc' then MP3Collection.Albums[i2].Desc:=MP3Collection.Albums[i2].Desc+Text;
                                        until Text='_eoDesc'; // spacer
                                        //Delete(MP3Collection.Albums[i2].Desc,length(MP3Collection.Albums[i2].Desc)-7,8); // delete this "_eoDesc" marker

                                        ReadLn(InfoFile,MP3Collection.Albums[i2].MP3No);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].Size);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].Duration);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].Image);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].CommonValuesID3v1.Artist);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].CommonValuesID3v1.Album);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].CommonValuesID3v1.Year);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].CommonValuesID3v1.Comment);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].CommonValuesID3v1.Genre);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].CommonValuesID3v2.Artist);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].CommonValuesID3v2.Album);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].CommonValuesID3v2.Year);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].CommonValuesID3v2.Comment);
                                        ReadLn(InfoFile,MP3Collection.Albums[i2].CommonValuesID3v2.Genre);
                                        ReadLN(InfoFile); // skip spacer
                                        end;

// now read MP3 files info
MP3Collection.MP3s:=nil;
for i:=0 to MP3Collection.MP3No-1 do begin
                                     i2:=CheckForSpace('MP3s');
                                     ReadLn(InfoFile,MP3Collection.MP3s[i2].ID);
                                     ReadLn(InfoFile,MP3Collection.MP3s[i2].Order);
                                     ReadLn(InfoFile,MP3Collection.MP3s[i2].Album);
                                     ReadLn(InfoFile,MP3Collection.MP3s[i2].Path);
                                     MP3Collection.MP3s[i2].ID3v1:=ReadID3v1Tags(MP3Collection.MP3s[i2].Path);
                                     MP3Collection.MP3s[i2].ID3v2:=ReadID3v2Tags(MP3Collection.MP3s[i2].Path);
                                     ReadLn(InfoFile,MP3Collection.MP3s[i2].Name);
                                     ReadLn(InfoFile,MP3Collection.MP3s[i2].Size);
                                     ReadLn(InfoFile,MP3Collection.MP3s[i2].Duration);
                                     ReadLn(InfoFile,MP3Collection.MP3s[i2].Bitrate);
                                     ReadLn(InfoFile,MP3Collection.MP3s[i2].Image);
                                     ReadLN(InfoFile); // skip spacer
                                     end;
//

CloseFile(InfoFile);

// now checking the records for corrupted/missing mp3 files
ErrorsA:=0;
ErrorsMP3:=0;
Text:=MP3Collection.Path;
CheckLastBackslash(Text);
MP3Collection.Path:=Text;
for i:=0 to high(MP3Collection.Albums) do if (MP3Collection.Albums[i].Name<>'_Empty')
                                          and(MP3Collection.Albums[i].Name<>'_root')  then if not DirectoryExists(MP3Collection.Path+'_root\'+inttostr(MP3Collection.Albums[i].Order)+' - '+MP3Collection.Albums[i].Name) then begin
                                                                                                                                                                                                                               RemoveAlbumFromCollection(i); // will handle everything necessary
                                                                                                                                                                                                                               ErrorsA:=ErrorsA+1;
                                                                                                                                                                                                                               end;
for i:=0 to high(MP3Collection.MP3s) do if MP3Collection.MP3s[i].Name<>'_Empty' then if not FileExists(MP3Collection.MP3s[i].Path) then begin
                                                                                                                                        MP3Collection.MP3s[i].Name:='_Empty'; // this slot is held as empty from now

                                                                                                                                        ErrorsMP3:=ErrorsMP3+1;
                                                                                                                                        end;
if (ErrorsA>0)or(ErrorsMP3>0) then ShowMessage(TranslateText('WCorrupted1',Settings.Lang)+inttostr(ErrorsA)+TranslateText('WCorrupted2',Settings.Lang)+inttostr(ErrorsMP3)+TranslateText('WCorrupted3',Settings.Lang));

except // if any error

 try // the file hasnt have to be opened
  CloseFile(InfoFile);
 except
 end;
 ShowMessage(TranslateText('ECannotLoadCollection',Settings.Lang));
 CollectionStatement:=false;
end;
end;

procedure CreateBlankCollection;
// creates default blank collection
//var i:integer;
var Text: string;
begin
CollectionStatement:=true; // now is some collection opened
Form1.PrgOpt4.Enabled:=true; // this option can't be used once since now
// reseting some variables
CurrentActiveMP3:=-1;
CurrentActiveAlbum:=-1;
//
if MP3Collection.Path='' then MP3Collection.Path:=Main.InitDir+'Collections\MyCollection'; // it is initial load and the specific path is not defined
Text:=MP3Collection.Path; // string[255] isnt "normal" string for compiler...
CheckLastBackslash(Text);
MP3Collection.Path:=Text;
if not DirectoryExists(MP3Collection.Path) then MkDir(MP3Collection.Path) // we need to create new directory
                                           else begin
                                                // we have to tide the mess up in existing directory
                                                // clean previous instances of MP3 Collection threatening new creation
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
                                                end;
// create special sub-dirs
MkDir(MP3Collection.Path+'_art'); // where album and mp3 thumbnails will be stored
MkDir(MP3Collection.Path+'_root'); // where mp3 files will be stored
MkDir(MP3Collection.Path+'_temp'); // where mp3 files will be temporarily moved when renaming albums
// create "warning" files
CreateWarnFile(MP3Collection.Path+'_art\WARNING.txt');
CreateWarnFile(MP3Collection.Path+'_root\WARNING.txt');
//
MP3Collection.AlbumsNo:=1;
MP3Collection.MP3No:=0;
MP3Collection.Size:=0;
MP3Collection.LastEdit:=DateToStr(Now)+' '+TimeToStr(Now);
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
MP3Collection.Albums[0].Image:=InitDir+'EmptyAlbum.jpg';
// ininitalizing common values
MP3Collection.Albums[0].CommonValuesID3v1.Artist:='';
MP3Collection.Albums[0].CommonValuesID3v1.Album:='';
MP3Collection.Albums[0].CommonValuesID3v1.Comment:='';
MP3Collection.Albums[0].CommonValuesID3v1.Genre:=255;
MP3Collection.Albums[0].CommonValuesID3v1.Year:=1;
MP3Collection.Albums[0].CommonValuesID3v2.Artist:='';
MP3Collection.Albums[0].CommonValuesID3v2.Album:='';
MP3Collection.Albums[0].CommonValuesID3v2.Comment:='';
MP3Collection.Albums[0].CommonValuesID3v2.Genre:='255';
MP3Collection.Albums[0].CommonValuesID3v2.Year:='1';
//
MP3Collection.MP3s:=nil;
SetLength(MP3Collection.MP3s,5); // to prevent access violations
MP3Collection.MP3s[0].Name:='_Empty';
MP3Collection.MP3s[1].Name:='_Empty';
MP3Collection.MP3s[2].Name:='_Empty';
MP3Collection.MP3s[3].Name:='_Empty';
MP3Collection.MP3s[4].Name:='_Empty';
// special mp3
//SetLength(MP3Collection.MP3s,1);
//MP3Collection.MP3s[0].ID:=0;
//MP3Collection.MP3s[0].Name:='_hidden';
//
// initially writes info about this collection into config file
UpdateCollection;
// setting the components
Form1.ResetMP3Components;
end;

procedure UpdateCollection;
begin
// backup of data - after every change making backup
UpdateLastChangeDate; // current date and time
// create file only if filepath valid
// this file is initialy created when Collection is created, so normaly it should exist
// but, when something wrong with MP3Collection.Path, data wont be saved
if FileExists(MP3Collection.Path+'Info.col') then CreateInfoFile(MP3Collection.Path+'Info.col');
end;

procedure CreateInfoFile(PathToFile: string);
// writes info about collection into file
var InfoFile: textfile;
    i: integer;
    
begin
try
if Main.CollectionStatement then Main.Settings.Last:=MP3Collection.Path; // auto-update of last collection we worked with

AssignFile(InfoFile,PathToFile);

Rewrite(InfoFile);
WriteLn(InfoFile,MP3Collection.Name);
WriteLn(InfoFile,MP3Collection.Desc);
WriteLn(InfoFile,'_eoDesc'); // spacer
WriteLn(InfoFile,MP3Collection.Path);
WriteLn(InfoFile,MP3Collection.AlbumsNo);
WriteLn(InfoFile,MP3Collection.MP3No);
WriteLn(InfoFile,MP3Collection.Size);
WriteLn(InfoFile,MP3Collection.Duration);
WriteLn(InfoFile,MP3Collection.LastEdit);
WriteLn(InfoFile,'_eoCollInfo'); // spacer
CheckLastBackslash(Main.InitDir);// for further checking
for i:=0 to high(MP3Collection.Albums) do if MP3Collection.Albums[i].Name<>'_Empty' then
                                          begin
                                          WriteLn(InfoFile,MP3Collection.Albums[i].ID);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].Order);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].Name);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].Desc);
                                          WriteLn(InfoFile,'_eoDesc'); // spacer
                                          WriteLn(InfoFile,MP3Collection.Albums[i].MP3No);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].Size);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].Duration);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].Image);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].CommonValuesID3v1.Artist);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].CommonValuesID3v1.Album);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].CommonValuesID3v1.Year);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].CommonValuesID3v1.Comment);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].CommonValuesID3v1.Genre);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].CommonValuesID3v2.Artist);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].CommonValuesID3v2.Album);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].CommonValuesID3v2.Year);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].CommonValuesID3v2.Comment);
                                          WriteLn(InfoFile,MP3Collection.Albums[i].CommonValuesID3v2.Genre);
                                          // check of the image
                                          // if not FileExists(MP3Collection.Albums[i].Image) then MP3Collection.Albums[i].Image:=InitDir+'EmptyAlbum.jpg';
                                          //
                                          WriteLn(InfoFile,'_eoAlbInfo'); // spacer
                                          end;
for i:=0 to high(MP3Collection.MP3s)   do if MP3Collection.MP3s[i].Name<>'_Empty' then
                                          begin
                                          WriteLn(InfoFile,MP3Collection.MP3s[i].ID);
                                          WriteLn(InfoFile,MP3Collection.MP3s[i].Order);
                                          WriteLn(InfoFile,MP3Collection.MP3s[i].Album);
                                          WriteLn(InfoFile,MP3Collection.MP3s[i].Path);
                                          WriteLn(InfoFile,MP3Collection.MP3s[i].Name);
                                          WriteLn(InfoFile,MP3Collection.MP3s[i].Size);
                                          WriteLn(InfoFile,MP3Collection.MP3s[i].Bitrate);
                                          WriteLn(InfoFile,MP3Collection.MP3s[i].Duration);
                                          WriteLn(InfoFile,MP3Collection.MP3s[i].Image);
                                          // check of the image
                                          //if not FileExists(Main.InitDir+MP3Collection.MP3s[i].Image) then MP3Collection.MP3s[i].Image:=InitDir+'EmptyMP3.jpg';
                                          //
                                          WriteLn(InfoFile,'_eoMP3Info'); // spacer
                                          end;
CloseFile(InfoFile);
except
 try
  CloseFile(InfoFile);
 except
  // maybe will work, maybe not, but it is good to try it and dont let it open
 end;
ShowMessage(TranslateText('ECannotSaveCollection',Main.Settings.Lang));
end;
end;

procedure RemoveAlbumFromCollection(CurrentActiveAlbum: integer);
// remove album and all contents from collection
var i: integer;
    APIFrom, APITo: PChar;
    text: string;
begin
MP3Collection.Albums[CurrentActiveAlbum].Name:='_Empty'; // this slot is held as empty from now
// what is necessary to do?
// 0. physically delete the file (must be before renaming)
DelDir(MP3Collection.Path+MP3Collection.Albums[CurrentActiveAlbum].Name);
// 1. remove reference from Albums array
MP3Collection.Albums[CurrentActiveAlbum].Name:='_Empty'; // simple but effective
                                                         // other data will be overwritten by next newly added album
// 2. remove references from MP3s array + making backup of MP3 files in TEMP directory
for i:=0 to high(MP3Collection.MP3s) do if MP3Collection.MP3s[i].Album=CurrentActiveAlbum then begin
                                                                                               text:=MP3Collection.MP3s[i].Path;
                                                                                               APIFrom:=PChar(text);
                                                                                               APITo:=PChar(MP3Collection.Path+'_temp\'+inttostr(MP3Collection.MP3s[i].ID)+'_'+MP3Collection.MP3s[i].Name+'.mp3');
                                                                                               CopyFile(APIFrom,APITo,true); // backup file
                                                                                               MP3Collection.MP3s[i].Name:='_Empty'; // simple but effective
                                                                                                                                     // other data will be overwritten by next newly added MP3
                                                                                               end;
// 3. update collection stats (mp3no, size, duration)
MP3Collection.AlbumsNo:=MP3Collection.AlbumsNo-1;
MP3Collection.MP3No:=MP3Collection.MP3No-MP3Collection.Albums[CurrentActiveAlbum].MP3No;
MP3Collection.Size:=MP3Collection.Size-MP3Collection.Albums[CurrentActiveAlbum].Size;
MP3Collection.Duration:=MP3Collection.Duration-MP3Collection.Albums[CurrentActiveAlbum].Duration;
// 4. upgrade order of following Albums in Collction
OptimalizeAlbumOrder(MP3Collection.Albums[CurrentActiveAlbum].Order,MP3Collection.AlbumsNo+2); // we simulate it like the file moved on the bottom of the order
                                                                                               // - all Albums behind it, move to front by one
end;

{
procedure RenameCollection(OldCollName,NewCollName: string);
// rename collection dir from old to new name
begin
end;

procedure RenameAlbum(OldAlbName,NewAlbName: string);
// rename album dir from old to new file name
begin
end;

procedure RenameMP3(OldFileName,NewFileName: string);
// rename file from old to new file name
begin
end;
}

end.
