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
// *  File:           *  CollectionU.pas                         * //
// *  Purpose:        *  Form for adding/editing collections     * //
// *  System Version: *  1.0                                     * //
// *  Last Modified:  *  2008-03-11 1200 GMT+1                   * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
/////////////////////////////////////////////////////////////////////

unit CollectionU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl;

type
  TCollectionW = class(TForm)
    MainBox: TGroupBox;
    OkB: TButton;
    CancelB: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    CollName: TEdit;
    CollDesc: TMemo;
    CollPath: TEdit;
    Cancel2B: TButton;
    OpenDialog1: TOpenDialog;
    procedure AlignLabels;
    procedure CancelBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OkBClick(Sender: TObject);
    procedure Cancel2BClick(Sender: TObject);
    procedure BrowsePathsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CollectionW: TCollectionW;
  Inicialization: boolean; // if the collection is edited (wizard should load info) or newly created (wizard fills default values)

implementation

uses Main, MP3Utilities, WorkingU; // FileSystemUtilities;

{$R *.dfm}

procedure TCollectionW.AlignLabels;
begin
// dunno why...
Label1.Left:=10;
Label2.Left:=10;
Label3.Left:=10;
end;

procedure TCollectionW.CancelBClick(Sender: TObject);
begin
CollectionW.Close;
end;

procedure TCollectionW.FormCreate(Sender: TObject);
// some inicialization
begin
OpenDialog1.Title:=TranslateText('MSGFindCollLoc',Main.Settings.Lang);
if Inicialization then begin
                       CheckLastBackslash(Main.Settings.WDir);
                       CollPath.Text:=Main.Settings.WDir+'MyCollection';
                       CollectionW.Caption:=' '+TranslateText('MSGOkBCreate',Main.Settings.Lang)+' '+TranslateText('MSGWizardCollection',Main.Settings.Lang)+' ';
                       OkB.Caption:=TranslateText('MSGOkBCreate',Main.Settings.Lang);
                       // user has to have no chance to close the window w/o inserting some values
                       CollectionW.BorderIcons:=CollectionW.BorderIcons-[biSystemMenu];
                       CancelB.Visible:=false;
                       Cancel2B.Visible:=true; // this button enables to cancel the process safely
                       //
                       end
                  else begin
                       CollectionW.Caption:=' '+TranslateText('MSGOkBEdit',Main.Settings.Lang)+' '+TranslateText('MSGWizardCollection',Main.Settings.Lang)+' ';
                       OkB.Caption:=TranslateText('MSGOkBEdit',Main.Settings.Lang);
                       // fill in values
                       CollName.Text:=MP3Collection.Name;
                       CollDesc.Lines.Clear;
                       CollDesc.Lines.Add(MP3Collection.Desc);
                       CollPath.Text:=MP3Collection.Path;
                       end;
AlignLabels;
end;

procedure TCollectionW.OkBClick(Sender: TObject);
var Text: string;
    //APIPath: PChar;
    //i: integer;
begin
OkB.Enabled:=false; // this should prevent "double clicks"
// checking validity of name parameter
case CheckName(CollName.Text) of
2: ShowMessage(TranslateText('XCharNotAllowed',Main.Settings.Lang));
1: ShowMessage(TranslateText('XCharInvalid',Main.Settings.Lang));
0: begin // {loop 1}
if CollPath.Text=Main.InitDir+'Collections\MyCollection' then ShowMessage(TranslateText('XDirNotAllowed',Main.Settings.Lang))
                                                         else begin // {loop 2}
if inicialization then begin
Text:=CollPath.Text; // TCaption and string arent the same for compiler...
CheckLastBackslash(Text);
CollPath.Text:=Text;
try
if (FileExists(CollPath.Text+'Info.col'))
or(DirectoryExists(CollPath.Text+'_art'))
or(DirectoryExists(CollPath.Text+'_root')) // all those three conditions may cause lost data (info about collection, album images or mp3 themselves)
                                        then begin
                                             if MessageDlg(TranslateText('QRewriteColl',Settings.Lang),mtWarning,[mbYes,mbNo],0)=IDYes then
                                             // we are allowed to overwrite - so lets continue
                                             begin
                                              // first - delete everything in the directory related to previous instance of MP3 Collection - to prevent as much as mess as possible

                                              // we do this in CreateBlankCollection procedure in WorkingU.dcu

                                              //
                                              Main.MP3Collection.Name:=CollName.Text;
                                              Main.MP3Collection.Desc:=CollDesc.Text;
                                              Main.MP3Collection.Path:=CollPath.Text;
                                              //Main.Settings.WDir:=CollPath.Text; // updating
                                              // create new config file
                                              CreateConfigFile; // in MP3Utilities.dcu
                                              //
                                             CollectionW.Close;
                                             end;
                                             // else do nothing - it will keep the window open and user can change the directory
                                             end
                                        else begin
                                             // we need to create new directory
                                             // but nothing matters - no existing directory - no possible threat of file overwriting
                                             MkDir(CollPath.Text);
                                             Main.MP3Collection.Name:=CollName.Text;
                                             Main.MP3Collection.Desc:=CollDesc.Text;
                                             Main.MP3Collection.Path:=CollPath.Text;
                                             //Main.Settings.Last:=CollPath.Text; // updating
                                             Main.Settings.WDir:=CollPath.Text; // updating
                                             // backup of data - after every change making backup
                                             UpdateLastChangeDate; // current date and time

                                             // create new config file
                                             CreateConfigFile; // in MP3Utilities.dcu
                                             //
                                             CollectionW.Close;
                                             end;
except // if user types in some nonsence under that new directory cannot be created
ShowMessage(TranslateText('EInvalidPath',Settings.Lang));
end;
end else begin // this is done when only updating
         Main.MP3Collection.Name:=CollName.Text;
         Main.MP3Collection.Desc:=CollDesc.Text;
         Main.MP3Collection.Path:=CollPath.Text;
         CollectionW.Close;
         end;
end;  // {loop 2}
end;  // {loop 1}
end; // end of "Case"
OkB.Enabled:=true; // maybe will be needed again         
end;

procedure TCollectionW.Cancel2BClick(Sender: TObject);
begin
Cancel2B.Tag:=1;
CollectionW.Close;
end;

procedure TCollectionW.BrowsePathsClick(Sender: TObject);
begin
if OpenDialog1.Execute then CollPath.Text:=OpenDialog1.InitialDir;
end;

end.
