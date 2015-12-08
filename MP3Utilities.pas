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
// *  File:           *  MP3Utilities.pas                        * //
// *  Purpose:        *  Utility functions and procedures        * //
// *  System Version: *  1.0                                     * //
// *  Last Modified:  *  2008-03-11 1150 GMT+1                   * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
/////////////////////////////////////////////////////////////////////

unit MP3Utilities;

interface

uses Windows, SysUtils, Dialogs;

function TranslateText(Text,Lang: string): string;
function CutPreviousPath(Text: string; Chars: byte): string;
function CutText(Text: string; Chars: byte): string;
procedure TranslateForm(Form,Lang: string);
procedure RepaintForm(Form: string);
procedure CutBlankSpaces(var Text: string);
procedure CutEOL(var Text: string);
procedure CutPath(var Text: string);
procedure CheckLastBackslash(var Text: string);
function CheckName(Text: string): byte;
procedure OptimalizeAlbumOrder(old,new: word);
procedure OptimalizeMP3Order(old,new: word);
procedure SetAlbumFolderNumber(album, oldpos, newpos: word; init: boolean);
procedure SetMP3FileNumber(mp3, oldpos, newpos: word; init: boolean);
function CheckForSpace(DynArray: string): integer;
function GetFileSize(MP3Path: string): integer;
function RoundSize(FileSize: integer): real;
procedure OptimalizeFileSizes;
procedure UpdateLastChangeDate;
procedure CreateConfigFile;
procedure CreateWarnFile(path: string);
function VolumeInPercents(volume: byte): byte;
function DurationInTime(duration: longint; shortformat: boolean): string;
function GetMP3Bitrate(source: string): word;
function CheckExistence(MP3Name: string; Album: integer): integer;
procedure MoveMP3s(Album: integer);

implementation

uses Main, SettingsU, SkinU, MP3U, AlbumU, CollectionU, ImportU, AboutU, FileSystemUtilities, PlayerU;

function TranslateText(Text,Lang: string): string;
var LangFile: textfile;
    TranslatedText: string;
begin
AssignFile(LangFile,Main.InitDir+'\Lang\'+Lang+'.lng');
try
Reset(LangFile);
except
 try
  AssignFile(LangFile,Main.InitDir+'\Lang\ENG.lng');
 except
  // if this failes, the whole program is about to crash
  ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'\Lang\ENG.lng'+TranslateText('FEMissingFile2',Settings.Lang));
  CrucialE:=true; // the program must be terminated with no asking
  Form1.Close;
 end;
end;
repeat readln(LangFile,TranslatedText) until (pos(Text,TranslatedText)>0)or(eof(LangFile));
if eof(LangFile) then result:='String undefined'
                 else begin
                      Delete(TranslatedText,1,Pos('=',TranslatedText)+1);
                      result:=TranslatedText;
                      end;
CloseFile(LangFile);
end;

function CutPreviousPath(Text: string; Chars: byte): string;
// keeps only last part of the whole path
// the previous root path it alters with "..."
var changed: boolean;
begin
changed:=false;
while (pos('\',Text)>1)and(length(Text)>chars) do begin
                                                  Delete(Text,1,pos('\',Text));
                                                  changed:=true
                                                  end;
if changed then result:='...\'+Text
           else result:=Text;
end;

function CutText(Text: string; Chars: byte): string;
// if text is too long
begin
if length(Text)>Chars then begin
                           Delete(Text,Chars,length(Text)); // deletes everything from selected index
                           while Text[length(Text)]=' ' do Delete(Text,length(Text),1); // this will look awful
                           result:=Text+'...' // indicating that something was deleted
                           end
                      else result:=Text;
end;

procedure TranslateForm(Form,Lang: string);
begin
if Form='Main'     then begin
                        // menu items
                        Form1.Menu1.Caption:=TranslateText('MSGMenu1',Lang);
                        Form1.PrgOpt1.Caption:=TranslateText('MSGPrgOpt1',Lang);
                        Form1.PrgOpt2.Caption:=TranslateText('MSGPrgOpt2',Lang);
                        Form1.PrgOpt4.Caption:=TranslateText('MSGPrgOpt4',Lang);
                        Form1.PrgOpt3.Caption:=TranslateText('MSGPrgOpt3',Lang);
                        Form1.Menu2.Caption:=TranslateText('MSGMenu2',Lang);
                        Form1.PlrOpt1.Caption:=TranslateText('MSGPlrOpt1',Lang);
                        Form1.PlrOpt2.Caption:=TranslateText('MSGPlrOpt2',Lang);
                        Form1.PlrOpt3.Caption:=TranslateText('MSGPlrOpt3',Lang);
                        if Form1.MainNav.Visible then Form1.PlrOpt4.Caption:=TranslateText('MSGPlrOpt4hide',Lang)
                                                 else Form1.PlrOpt4.Caption:=TranslateText('MSGPlrOpt4show',Lang);
                        Form1.Menu3.Caption:=TranslateText('MSGMenu3',Lang);
                        Form1.ColOpt1.Caption:=TranslateText('MSGColOpt1',Lang);
                        Form1.ColOpt2.Caption:=TranslateText('MSGColOpt2',Lang);
                        Form1.ColOpt3.Caption:=TranslateText('MSGColOpt3',Lang);
                        Form1.Menu4.Caption:=TranslateText('MSGMenu4',Lang);
                        Form1.AlbOpt1.Caption:=TranslateText('MSGAlbOpt1',Lang);
                        Form1.AlbOpt2.Caption:=TranslateText('MSGAlbOpt2',Lang);
                        Form1.AlbOpt3.Caption:=TranslateText('MSGAlbOpt3',Lang);
                        Form1.Menu5.Caption:=TranslateText('MSGMenu5',Lang);
                        Form1.MP3Opt1.Caption:=TranslateText('MSGMP3Opt1',Lang);
                        Form1.MP3ImpOpt1.Caption:=TranslateText('MSGMP3ImpOpt1',Lang);
                        Form1.MP3ImpOpt2.Caption:=TranslateText('MSGMP3ImpOpt2',Lang);
                        Form1.MP3Opt2.Caption:=TranslateText('MSGMP3Opt2',Lang);
                        Form1.MP3Opt3.Caption:=TranslateText('MSGMP3Opt3',Lang);
                        Form1.Menu6.Caption:=TranslateText('MSGMenu6',Lang);
                        Form1.OptOpt1.Caption:=TranslateText('MSGOptOpt1',Lang);
                        Form1.SkinOpt2.Caption:=TranslateText('MSGSkinOpt2',Lang);
                        Form1.OptOpt2.Caption:=TranslateText('MSGOptOpt2',Lang);
                        Form1.OptOpt3.Caption:=TranslateText('MSGOptOpt3',Lang);
                        Form1.LngOpt1.Caption:=TranslateText('MSGLngOpt1',Lang);
                        Form1.LngOpt2.Caption:=TranslateText('MSGLngOpt2',Lang);
                        Form1.OptOpt5.Caption:=TranslateText('MSGOptOpt5',Lang);
                        Form1.OptOpt4.Caption:=TranslateText('MSGPlrOpt3',Lang);
                        Form1.Menu7.Caption:=TranslateText('MSGMenu7',Lang);
                        Form1.HelpOpt1.Caption:=TranslateText('MSGHelpOpt1',Lang);
                        Form1.HelpOpt2.Caption:=TranslateText('MSGHelpOpt2',Lang);
                        // genereal tabs
                        Form1.Player.Caption:=TranslateText('MSGPlayerTitle',Lang);
                        Form1.Collection.Caption:=TranslateText('MSGCollectionTitle',Lang);
                        Form1.Album.Caption:=TranslateText('MSGAlbumTitle',Lang);
                        Form1.ID3.Caption:=TranslateText('MSGMP3Title',Lang);
                        // player screen
                        Form1.Label1.Caption:=TranslateText('MSGNowPlaying',Lang);
                        Form1.Label2.Caption:=TranslateText('MSGTracklist',Lang);
                        // collection screen
                        Form1.GroupBox1.Caption:=TranslateText('MSGCollectionInfo',Lang);
                        Form1.Label3.Caption:=TranslateText('MSGName',Lang);
                        Form1.Label4.Caption:=TranslateText('MSGDesc',Lang);
                        Form1.Label5.Caption:=TranslateText('MSGPath',Lang);
                        Form1.CollectionE.Caption:=TranslateText('MSGChange',Lang);
                        Form1.GroupBox2.Caption:=TranslateText('MSGCollectionStats',Lang);
                        Form1.Label10.Caption:=TranslateText('MSGCollAlbums',Lang);
                        Form1.Label13.Caption:=TranslateText('MSGCollMP3s',Lang);
                        Form1.Label15.Caption:=TranslateText('MSGCollDuration',Lang);
                        Form1.Label16.Caption:=TranslateText('MSGLastEdit',Lang);
                        Form1.GroupBox3.Caption:=TranslateText('MSGAlbumsIncluded',Lang);
                        if Main.CurrentActiveAlbum<0 then Form1.AlbName.Caption:=TranslateText('MSGNoAlbum',Lang);
                        Form1.Label6.Caption:=TranslateText('MSGAlbMP3s',Lang);
                        Form1.Label7.Caption:=TranslateText('MSGDuration',Lang);
                        Form1.PlayA.Caption:=TranslateText('MSGPlay',Lang);
                        Form1.EditA.Caption:=TranslateText('MSGEdit',Lang);
                        Form1.AddA.Caption:=TranslateText('MSGAlbAdd',Lang);
                        Form1.DelA.Caption:=TranslateText('MSGAlbDel',Lang);
                        Form1.GroupBox4.Caption:=TranslateText('MPGMP3SIncluded',Lang);
                        if Main.CurrentActiveMP3<0 then Form1.MP3Name.Caption:=TranslateText('MSGNoMP3',Lang);
                        Form1.Label9.Caption:=TranslateText('MSGMP3Album',Lang);
                        Form1.Label12.Caption:=TranslateText('MSGDuration',Lang);
                        Form1.PlayM.Caption:=TranslateText('MSGPlay',Lang);
                        Form1.EditM.Caption:=TranslateText('MSGEdit',Lang);
                        Form1.AddMP3.Caption:=TranslateText('MSGMP3Add',Lang);
                        Form1.DelM.Caption:=TranslateText('MSGMP3Del',Lang);
                        // album screen
                        Form1.GroupBox7.Caption:=TranslateText('MSGAlbumSelect',Lang);
                        Form1.Label18.Caption:=TranslateText('MSGAlbumSelection',Lang);
                        if not Main.CollectionStatement then Form1.AlbumList3.Text:=TranslateText('MSGNoAlbums',Lang);
                        Form1.GroupBox8.Caption:=TranslateText('MSGAlbumInfo',Lang);
                        Form1.Label26.Caption:=TranslateText('MSGCurrent',Lang);
                        Form1.Label34.Caption:=TranslateText('MSGID3TagsChange',Lang);
                        Form1.Label30.Caption:=TranslateText('MSGID3Artist',Lang);
                        Form1.Label28.Caption:=TranslateText('MSGID3Album',Lang);
                        Form1.Label31.Caption:=TranslateText('MSGID3Comment',Lang);
                        Form1.Label27.Caption:=TranslateText('MSGID3Genre',Lang);
                        Form1.Label29.Caption:=TranslateText('MSGID3Year',Lang);
                        Form1.Label33.Caption:=TranslateText('MSGAlbSetCommon',Lang);
                        Form1.Label32.Caption:=TranslateText('MSGAlbSetCommonHint',Lang);
                        Form1.PlayA2.Caption:=TranslateText('MSGPlay',Lang);
                        Form1.EditA2.Caption:=TranslateText('MSGEdit',Lang);
                        Form1.SaveID32.Caption:=TranslateText('MSGSave',Lang);
                        Form1.IgnoreArtist.Caption:=TranslateText('MSGIgnore',Lang);
                        Form1.IgnoreAlbum.Caption:=TranslateText('MSGIgnore',Lang);
                        Form1.IgnoreComment.Caption:=TranslateText('MSGIgnore',Lang);
                        Form1.IgnoreYear.Caption:=TranslateText('MSGIgnore',Lang);
                        Form1.IgnoreGenre.Caption:=TranslateText('MSGIgnore',Lang);
                        Form1.AutoSetTrackNumber.Caption:=TranslateText('MSGAutoSetTrackNumber',Lang);
                        // mp3 screen
                        Form1.GroupBox5.Caption:=TranslateText('MSGMP3File',Lang);
                        Form1.Label8.Caption:=TranslateText('MSGMP3AlbumSelect',Lang);
                        Form1.Label11.Caption:=TranslateText('MSGMP3MP3Select',Lang);
                        if not Main.CollectionStatement then Form1.AlbumList2.Text:=TranslateText('MSGNoAlbums',Lang);
                        Form1.GroupBox6.Caption:=TranslateText('MSGID3Tags',Lang);
                        Form1.Label17.Caption:=TranslateText('MSGCurrent',Lang);
                        Form1.Label19.Caption:=TranslateText('MSGID3TagsChange',Lang);
                        Form1.Label14.Caption:=TranslateText('MSGID3Title',Lang);
                        Form1.Label20.Caption:=TranslateText('MSGID3Artist',Lang);
                        Form1.Label21.Caption:=TranslateText('MSGID3Album',Lang);
                        Form1.Label22.Caption:=TranslateText('MSGID3Comment',Lang);
                        Form1.Label25.Caption:=TranslateText('MSGID3Track',Lang);
                        Form1.Label24.Caption:=TranslateText('MSGID3Genre',Lang);
                        Form1.Label23.Caption:=TranslateText('MSGID3Year',Lang);
                        Form1.PlayM2.Caption:=TranslateText('MSGPlay',Lang);
                        Form1.EditM2.Caption:=TranslateText('MSGEdit',Lang);
                        Form1.SaveID3.Caption:=TranslateText('MSGSave',Lang);
                        // special
                        case Settings.FSiz of
                        1: begin
                           Form1.Size1.Caption:=TranslateText('MSGCollSize',Lang)+' (B) :';
                           Form1.Size2.Caption:=TranslateText('MSGCollSize',Lang)+' (B) :';
                           Form1.Size3.Caption:=TranslateText('MSGCollSize',Lang)+' (B) :';
                           end;
                        1000: begin
                              Form1.Size1.Caption:=TranslateText('MSGCollSize',Lang)+' (kB) :';
                              Form1.Size2.Caption:=TranslateText('MSGCollSize',Lang)+' (kB) :';
                              Form1.Size3.Caption:=TranslateText('MSGCollSize',Lang)+' (kB) :';
                              end;
                        1000000: begin
                                 Form1.Size1.Caption:=TranslateText('MSGCollSize',Lang)+' (MB) :';
                                 Form1.Size2.Caption:=TranslateText('MSGCollSize',Lang)+' (MB) :';
                                 Form1.Size3.Caption:=TranslateText('MSGCollSize',Lang)+' (MB) :';
                                 end;
                        end;
                        //
                        // hints
                        // player
                        Form1.HideMainNav.Hint:=TranslateText('HLPHideMainNav',Lang);
                        Form1.ShowMainNav.Hint:=TranslateText('HLPShowMainNav',Lang);
                        Form1.PlayB.Hint:=TranslateText('HLPPlayB',Lang);
                        Form1.PlayBSmall.Hint:=TranslateText('HLPPlayB',Lang);
                        Form1.PauseB.Hint:=TranslateText('HLPPauseB',Lang);
                        Form1.PauseBSmall.Hint:=TranslateText('HLPPauseB',Lang);
                        Form1.StopB.Hint:=TranslateText('HLPStopB',Lang);
                        Form1.StopBSmall.Hint:=TranslateText('HLPStopB',Lang);
                        Form1.BrowseB.Hint:=TranslateText('HLPBrowseB',Lang);
                        Form1.BrowseBSmall.Hint:=TranslateText('HLPBrowseB',Lang);
                        Form1.VolumeControler.Hint:=TranslateText('HLPVolumeC',Lang);
                        Form1.VolumeControlerSmall.Hint:=TranslateText('HLPVolumeC',Lang);
                        Form1.PlayTrack.Hint:=TranslateText('HLPPlayTr',Lang);
                        Form1.ElapsedTimeBarSmall.Hint:=TranslateText('HLPPlayTr',Lang);
                        Form1.PlayTime.Hint:=TranslateText('HLPPlayTm',Lang);
                        Form1.PlayTimeSmall.Hint:=TranslateText('HLPPlayTm',Lang);
                        Form1.ElapsedTimeBar.Hint:=TranslateText('HLPElapsedT',Lang);
                        Form1.ElapsedTimeBarSmall.Hint:=TranslateText('HLPElapsedT',Lang);
                        Form1.TrackQuery.Hint:=TranslateText('HLPTrackQ',Lang);
                        // collection
                        Form1.CollName.Hint:=TranslateText('HLPCollNameEx',Lang);
                        Form1.CollDesc.Hint:=TranslateText('HLPCollDescEx',Lang);
                        Form1.CollPath.Hint:=TranslateText('HLPCollPathEx',Lang);
                        Form1.CollectionE.Hint:=TranslateText('HLPCollEdit',Lang);
                        Form1.CollStatsAlb.Hint:=TranslateText('HLPCollStatsAlbEx',Lang);
                        Form1.CollStatsMP3.Hint:=TranslateText('HLPCollStatsMP3Ex',Lang);
                        Form1.CollStatsSize.Hint:=TranslateText('HLPCollStatsSizeEx',Lang);
                        Form1.CollStatsDuration.Hint:=TranslateText('HLPCollStatsDurationEx',Lang);
                        Form1.CollStatsLastEdit.Hint:=TranslateText('HLPCollStatsLastEditEx',Lang);
                        Form1.AlbumList.Hint:=TranslateText('HLPAlbListEx',Lang);
                        Form1.AlbName.Hint:=TranslateText('HLPAlbNameEx',Lang);
                        Form1.AlbMP3Count.Hint:=TranslateText('HLPAlbMP3Ex',Lang);
                        Form1.AlbSize.Hint:=TranslateText('HLPAlbSizeEx',Lang);
                        Form1.AlbDuration.Hint:=TranslateText('HLPAlbDurationEx',Lang);
                        Form1.PlayA.Hint:=TranslateText('HLPPlayAEx',Lang);
                        Form1.EditA.Hint:=TranslateText('HLPEditAEx',Lang);
                        Form1.AlbUp.Hint:=TranslateText('HLPAlbUpEx',Lang);
                        Form1.AlbDown.Hint:=TranslateText('HLPAlbDownEx',Lang);
                        Form1.AddA.Hint:=TranslateText('HLPAddAEx',Lang);
                        Form1.DelA.Hint:=TranslateText('HLPDelAEx',Lang);
                        Form1.MP3List.Hint:=TranslateText('HLPMP3ListEx',Lang);
                        Form1.MP3Name.Hint:=TranslateText('HLPMP3NameEx',Lang);
                        Form1.MP3Album.Hint:=TranslateText('HLPMP3AlbEx',Lang);
                        Form1.MP3Size.Hint:=TranslateText('HLPMP3SizeEx',Lang);
                        Form1.MP3Duration.Hint:=TranslateText('HLPMP3DurationEx',Lang);
                        Form1.PlayM.Hint:=TranslateText('HLPPlayMEx',Lang);
                        Form1.EditM.Hint:=TranslateText('HLPEditMEx',Lang);
                        Form1.MP3Up.Hint:=TranslateText('HLPMP3UpEx',Lang);
                        Form1.MP3Down.Hint:=TranslateText('HLPMP3DownEx',Lang);
                        Form1.AddMP3.Hint:=TranslateText('HLPAddMEx',Lang);
                        Form1.DelM.Hint:=TranslateText('HLPDelMEx',Lang);
                        // album
                        Form1.AlbumList3.Hint:=TranslateText('HLPAlbListEx',Lang);
                        Form1.CurrentAlbumName.Hint:=TranslateText('HLPCurrentAlbumNameEx',Lang);
                        Form1.CurrentAlbumImage.Hint:=TranslateText('HLPCurrentAlbumImageEx',Lang);
                        Form1.PlayA2.Hint:=TranslateText('HLPPlayAEx',Lang);
                        Form1.EditA2.Hint:=TranslateText('HLPEditAEx',Lang);
                        Form1.ID3Changer2.Hint:=TranslateText('HLPID3ChangerEx',Lang);
                        Form1.IgnoreArtist.Hint:=TranslateText('HLPIgnoreEx',Lang);
                        Form1.IgnoreAlbum.Hint:=TranslateText('HLPIgnoreEx',Lang);
                        Form1.IgnoreComment.Hint:=TranslateText('HLPIgnoreEx',Lang);
                        Form1.IgnoreGenre.Hint:=TranslateText('HLPIgnoreEx',Lang);
                        Form1.IgnoreYear.Hint:=TranslateText('HLPIgnoreEx',Lang);
                        Form1.ID3Artist2.Hint:=TranslateText('HLPID3ArtistAEx1',Lang);
                        Form1.ID3Album2.Hint:=TranslateText('HLPID3AlbAEx1',Lang);
                        Form1.ID3Comment2.Hint:=TranslateText('HLPID3CommentAEx1',Lang);
                        Form1.ID3Genre2.Hint:=TranslateText('HLPID3GenreAEx1',Lang);
                        Form1.ID3Year2.Hint:=TranslateText('HLPID3YearAEx1',Lang);
                        Form1.UpDown7.Hint:=TranslateText('HLPID3GenreAEx2',Lang);
                        Form1.UpDown4.Hint:=TranslateText('HLPID3YearAEx2',Lang);
                        Form1.AutoSetTrackNumber.Hint:=TranslateText('HLPAutoSetTrackNumberEx',Lang);
                        Form1.SaveID32.Hint:=TranslateText('HLPID3SaveAEx',Lang);

                        // mp3
                        Form1.AlbumList2.Hint:=TranslateText('HLPAlbListEx',Lang);
                        Form1.MP3List2.Hint:=TranslateText('HLPMP3ListEx',Lang);
                        Form1.CurrentMP3Name.Hint:=TranslateText('HLPCurrentMP3NameEx',Lang);
                        Form1.CurrentMP3Image.Hint:=TranslateText('HLPCurrentMP3ImageEx',Lang);
                        Form1.ID3Changer.Hint:=TranslateText('HLPID3ChangerEx',Lang);
                        Form1.ID3Title.Hint:=TranslateText('HLPID3TitleAEx1',Lang);
                        Form1.ID3Artist.Hint:=TranslateText('HLPID3ArtistAEx1',Lang);
                        Form1.ID3Album.Hint:=TranslateText('HLPID3AlbAEx1',Lang);
                        Form1.ID3Comment.Hint:=TranslateText('HLPID3CommentAEx1',Lang);
                        Form1.ID3Track.Hint:=TranslateText('HLPID3TrackAEx1',Lang);
                        Form1.UpDown3.Hint:=TranslateText('HLPID3TrackAEx2',Lang);
                        Form1.ID3Genre.Hint:=TranslateText('HLPID3GenreAEx1',Lang);
                        Form1.UpDown2.Hint:=TranslateText('HLPID3GenreAEx2',Lang);
                        Form1.ID3Year.Hint:=TranslateText('HLPID3YearAEx1',Lang);
                        Form1.UpDown1.Hint:=TranslateText('HLPID3YearAEx2',Lang);
                        Form1.SaveID32.Hint:=TranslateText('HLPID3SaveAEx',Lang);
                        end
                   else
if Form='SkinW' then begin
                     SkinW.Label3.Caption:=TranslateText('MSGCurrentSkinName',Lang);
                     SkinW.Label7.Caption:=TranslateText('MSGSelectSkin',Lang);
                     SkinW.Label1.Caption:=TranslateText('MSGBGColor',Lang);
                     SkinW.Label2.Caption:=TranslateText('MSGBGImg',Lang);
                     SkinW.Label4.Caption:=TranslateText('MSGFontColor1',Lang);
                     SkinW.Label5.Caption:=TranslateText('MSGFontColor2',Lang);
                     SkinW.Label8.Caption:=TranslateText('MSGFontColor3',Lang);
                     SkinW.Label6.Caption:=TranslateText('MSGTrackListBGColor',Lang);
                     SkinW.BGColor.Hint:=TranslateText('HLPBGColor1',Lang);
                     SkinW.SetBGColor.Hint:=TranslateText('HLPBGColor2',Lang);
                     SkinW.BGImage.Hint:=TranslateText('HLPBGImage1',Lang);
                     SkinW.SetBGPicture.Hint:=TranslateText('HLPBGImage2',Lang);
                     SkinW.FontColor1.Hint:=TranslateText('HLPFontColor11',Lang);
                     SkinW.SetFontColor1.Hint:=TranslateText('HLPFontColor12',Lang);
                     SkinW.FontColor2.Hint:=TranslateText('HLPFontColor21',Lang);
                     SkinW.SetFontColor2.Hint:=TranslateText('HLPFontColor22',Lang);
                     SkinW.FontColor3.Hint:=TranslateText('HLPFontColor31',Lang);
                     SkinW.SetFontColor3.Hint:=TranslateText('HLPFontColor32',Lang);
                     SkinW.TrackBGColor.Hint:=TranslateText('HLPTrackBGColor1',Lang);
                     SkinW.SetTrackBGColor.Hint:=TranslateText('HLPTrackBGColor2',Lang);
                     SkinW.OpenPictureDialog1.Title:=TranslateText('MSGOpenImgBG',Lang);
                     SkinW.SetB.Caption:=TranslateText('MSGSet',Lang);
                     SkinW.CloseB.Caption:=TranslateText('MSGClose',Lang);
                     end
                else
if Form='SettingsW' then begin
                        SettingsW.Caption:=TranslateText('MSGSettingsTitle',Lang);
                        SettingsW.GroupBox4.Caption:=TranslateText('MSGMP3OptTitle',Lang);
                        SettingsW.GroupBox1.Caption:=TranslateText('MSGPlayerOptTitle',Lang);
                        SettingsW.GroupBox5.Caption:=TranslateText('MSGID3TagsTitle',Lang);
                        SettingsW.GroupBox7.Caption:=TranslateText('MSGBehaviourTitle',Lang);
                        SettingsW.ARewind.Caption:=TranslateText('MSGAutoRewind',Lang);
                        SettingsW.GroupBox6.Caption:=TranslateText('MSGAppearanceTitle',Lang);
                        SettingsW.GroupBox2.Caption:=TranslateText('MSGGenericBGTitle',Lang);
                        SettingsW.GroupBox3.Caption:=TranslateText('MSGBehaviourTitle',Lang);
                        SettingsW.Label4.Caption:=TranslateText('MSGWorkWith',Lang);
                        SettingsW.OptID3v1.Caption:=TranslateText('MSGID3v1',Lang);
                        SettingsW.OptID3v2.Caption:=TranslateText('MSGID3v2',Lang);
                        SettingsW.ConvertTags.Caption:=TranslateText('MSGAutoConvert',Lang);
                        SettingsW.KillTags.Caption:=TranslateText('MSGAutoKill',Lang);
                        SettingsW.GroupBox8.Caption:=TranslateText('MSGOnStartup',Lang);
                        SettingsW.StartOpt1.Caption:=TranslateText('MSGBlankCol',Lang);
                        SettingsW.StartOpt2.Caption:=TranslateText('MSGLastCol',Lang);
                        SettingsW.GroupBox11.Caption:=TranslateText('MSGPathToCol',Lang);
                        SettingsW.GroupBox9.Caption:=TranslateText('MSGAutoDel',Lang);
                        SettingsW.FileOpt1.Caption:=TranslateText('MSGAutoDelFalse',Lang);
                        SettingsW.FileOpt2.Caption:=TranslateText('MSGAutoDelTrue',Lang);
                        SettingsW.GroupBox12.Caption:=TranslateText('MSGCommonValues',Lang);
                        SettingsW.ASetOpt1.Caption:=TranslateText('MSGAutoSetCVTrue',Lang);
                        SettingsW.ASetOpt2.Caption:=TranslateText('MSGAutoSetCVFalse',Lang);
                        SettingsW.ACTrOpt1.Caption:=TranslateText('MSGAutoSetTrackNumber',Lang);
                        SettingsW.GroupBox10.Caption:=TranslateText('MSGFileSize',Lang);
                        SettingsW.Label1.Caption:=TranslateText('MSGAppSkin',Lang);
                        SettingsW.Label2.Caption:=TranslateText('MSGAppRes',Lang);
                        SettingsW.Label3.Caption:=TranslateText('MSGAppLang',Lang);
                        SettingsW.OkB.Caption:=TranslateText('MSGSet',Lang);
                        SettingsW.OkB2.Caption:=SettingsW.OkB.Caption; // a bit faster since it is the the same value for both...
                        SettingsW.CloseB.Caption:=TranslateText('MSGClose',Lang);

                        SettingsW.OptID3v1.Hint:=TranslateText('HLPOptID3v1',Lang);
                        SettingsW.OptID3v2.Hint:=TranslateText('HLPOptID3v2',Lang);
                        SettingsW.ConvertTags.Hint:=TranslateText('HLPConvertTags',Lang);
                        SettingsW.KillTags.Hint:=TranslateText('HLPKillTags',Lang);
                        SettingsW.StartOpt1.Hint:=TranslateText('HLPStartOpt1',Lang);
                        SettingsW.StartOpt2.Hint:=TranslateText('HLPStartOpt2',Lang);
                        SettingsW.WDirPath.Hint:=TranslateText('HLPWDirPath',Lang);
                        SettingsW.FileOpt1.Hint:=TranslateText('HLPFileOpt1',Lang);
                        SettingsW.FileOpt2.Hint:=TranslateText('HLPFileOpt2',Lang);
                        SettingsW.ASetOpt2.Hint:=TranslateText('HLPASetOpt1',Lang); // this is not mistake
                        SettingsW.ASetOpt1.Hint:=TranslateText('HLPASetOpt2',Lang); // this is not mistake
                        SettingsW.ACTrOpt1.Hint:=TranslateText('HLPAutoSetTrackNumberEx',Lang);
                        SettingsW.SizeOpt1.Hint:=TranslateText('HLPSizeOpt1',Lang);
                        SettingsW.SizeOpt2.Hint:=TranslateText('HLPSizeOpt2',Lang);
                        SettingsW.SizeOpt3.Hint:=TranslateText('HLPSizeOpt3',Lang);
                        SettingsW.MP3Skin.Hint:=TranslateText('HLPMP3Skin1',Lang);
                        SettingsW.OwnSkin.Hint:=TranslateText('HLPMP3Skin2',Lang);
                        SettingsW.MP3Res.Hint:=TranslateText('HLPMP3Res',Lang);
                        SettingsW.MP3Lang.Hint:=TranslateText('HLPMP3Lang',Lang);
                        SettingsW.BGOpt1.Hint:=TranslateText('HLPBGOpt1',Lang);
                        SettingsW.BGOpt2.Hint:=TranslateText('HLPBGOpt2',Lang);
                        SettingsW.BGOpt3.Hint:=TranslateText('HLPBGOpt3',Lang);
                        SettingsW.BGOpt4.Hint:=TranslateText('HLPBGOpt4',Lang);
                        SettingsW.ARewind.Hint:=TranslateText('HLPARewind',Lang);

                        SettingsW.MP3Lang.Tag:=SettingsW.MP3Lang.ItemIndex;
                        SettingsW.MP3Lang.Items.Clear;
                        SettingsW.MP3Lang.Items.Add(TranslateText('MSGLangEng',Lang));
                        SettingsW.MP3Lang.Items.Add(TranslateText('MSGLangCze',Lang));
                        SettingsW.MP3Lang.ItemIndex:=SettingsW.MP3Lang.Tag;
                        end
                   else
if Form='CollectionW' then begin
                        CollectionW.MainBox.Caption:=TranslateText('MSGCollectionInfo',Lang);
                        CollectionW.Label1.Caption:=TranslateText('MSGName',Lang);
                        CollectionW.Label2.Caption:=TranslateText('MSGDesc',Lang);
                        CollectionW.Label3.Caption:=TranslateText('MSGPath',Lang);
                        CollectionW.CancelB.Caption:=TranslateText('MSGCancel',Lang);
                        CollectionW.Cancel2B.Caption:=TranslateText('MSGCancel',Lang);
                        CollectionW.CollName.Hint:=TranslateText('HLPCollName',Lang);
                        CollectionW.CollDesc.Hint:=TranslateText('HLPCollDesc',Lang);
                        CollectionW.CollPath.Hint:=TranslateText('HLPCollPath',Lang);
                        end
                      else
if Form='AlbumW' then begin
                        AlbumW.MainBox.Caption:=TranslateText('MSGAlbInfo',Lang);
                        AlbumW.Label1.Caption:=TranslateText('MSGName',Lang);
                        AlbumW.Label2.Caption:=TranslateText('MSGDesc',Lang);
                        AlbumW.Label3.Caption:=TranslateText('MSGOrder',Lang);
                        AlbumW.Label4.Caption:=TranslateText('MSGImage',Lang);
                        AlbumW.AlbName.Hint:=TranslateText('HLPAlbName',Lang);
                        AlbumW.AlbDesc.Hint:=TranslateText('HLPAlbDesc',Lang);
                        AlbumW.AlbImage.Hint:=TranslateText('HLPAlbImage1',Lang);
                        AlbumW.Button1.Hint:=TranslateText('HLPAlbImage2',Lang);
                        AlbumW.AlbOrder.Hint:=TranslateText('HLPAlbOrder',Lang);
                        AlbumW.UpDown1.Hint:=TranslateText('HLPAlbOrder',Lang);
                        AlbumW.OpenPictureDialog1.Title:=TranslateText('MSGOpenImgThumb',Lang);
                        AlbumW.CancelB.Caption:=TranslateText('MSGCancel',Lang);
                        end
                      else
if Form='MP3W' then begin
                        MP3W.MainBox.Caption:=TranslateText('MSGMP3Info',Lang);
                        MP3W.Label1.Caption:=TranslateText('MSGName',Lang);
                        MP3W.Label2.Caption:=TranslateText('MSGPath',Lang);
                        MP3W.Label4.Caption:=TranslateText('MSGAlbum',Lang);
                        MP3W.Label3.Caption:=TranslateText('MSGOrder',Lang);
                        MP3W.Label5.Caption:=TranslateText('MSGImage',Lang);
                        MP3W.MP3Name.Hint:=TranslateText('HLPMP3Name',Lang);
                        MP3W.MP3Path.Hint:=TranslateText('HLPMP3Path',Lang);
                        MP3W.Button1.Hint:=TranslateText('HLPMP3Path',Lang);
                        MP3W.MP3Album.Hint:=TranslateText('HLPMP3Album',Lang);
                        MP3W.MP3Image.Hint:=TranslateText('HLPMP3Image1',Lang);
                        MP3W.Button2.Hint:=TranslateText('HLPMP3Image2',Lang);
                        MP3W.MP3Order.Hint:=TranslateText('HLPMP3Order',Lang);
                        MP3W.UpDown1.Hint:=TranslateText('HLPMP3Order',Lang);
                        MP3W.OpenPictureDialog1.Title:=TranslateText('MSGOpenImgThumb',Lang);
                        MP3W.CancelB.Caption:=TranslateText('MSGCancel',Lang);
                    end
                  else
if Form='ImportW' then begin
                        ImportW.Label1.Caption:=TranslateText('MSGImport',Lang);
                        end
                  else      
if Form='Misc' then     begin
                        Form1.OpenMP3.Title:=TranslateText('MSGOpen',Lang);
                        //Form1.OpenCollection.Title:=TranslateText('MSGOpenColl',Lang);
                        end;
end;

procedure RepaintForm(Form: string);
// applies the current color settings onto selected form
begin
if Form='SkinW' then begin
                     SkinW.Color:=Main.Settings.Skin.BGColor;
                     SkinW.GroupBox1.Color:=Main.Settings.Skin.BGColor;
                     SkinW.GroupBox1.Font.Color:=Main.Settings.Skin.FontColor2;
                     SkinW.Label1.Font.Color:=Main.Settings.Skin.FontColor1;
                     SkinW.Label2.Font.Color:=Main.Settings.Skin.FontColor1;
                     SkinW.Label3.Font.Color:=Main.Settings.Skin.FontColor1;
                     SkinW.Label4.Font.Color:=Main.Settings.Skin.FontColor1;
                     SkinW.Label5.Font.Color:=Main.Settings.Skin.FontColor1;
                     SkinW.Label6.Font.Color:=Main.Settings.Skin.FontColor1;
                     SkinW.Label7.Font.Color:=Main.Settings.Skin.FontColor1;
                     SkinW.Label8.Font.Color:=Main.Settings.Skin.FontColor1;
                     SkinW.AlignLabels;
                     end
                else
if Form='AboutW' then begin
                     AboutW.Color:=Settings.Skin.BGColor;
                     end
                else
if Form='ImportW' then begin
                     ImportW.Color:=Main.Settings.Skin.BGColor;
                     ImportW.Label1.Font.Color:=Main.Settings.Skin.FontColor1;
                     end
                  else
if Form='MP3W' then begin
                     MP3W.Color:=Main.Settings.Skin.BGColor;
                     MP3W.MainBox.Color:=Main.Settings.Skin.BGColor;
                     MP3W.MainBox.Font.Color:=Main.Settings.Skin.FontColor1;
                     MP3W.AlignLabels;
                     end
                else
if Form='AlbumW' then begin
                     AlbumW.Color:=Main.Settings.Skin.BGColor;
                     AlbumW.MainBox.Color:=Main.Settings.Skin.BGColor;
                     AlbumW.MainBox.Font.Color:=Main.Settings.Skin.FontColor1;
                     AlbumW.AlignLabels;
                     end
                else
if Form='CollectionW' then begin
                     CollectionW.Color:=Main.Settings.Skin.BGColor;
                     CollectionW.MainBox.Color:=Main.Settings.Skin.BGColor;
                     CollectionW.MainBox.Font.Color:=Main.Settings.Skin.FontColor1;
                     CollectionW.AlignLabels;
                     end
                else
if Form='SettingsW' then begin
                     SettingsW.Color:=Main.Settings.Skin.BGColor;
                     SettingsW.GroupBox1.Color:=Main.Settings.Skin.BGColor;
                     SettingsW.GroupBox4.Color:=Main.Settings.Skin.BGColor;
                     SettingsW.GroupBox1.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.GroupBox4.Font.Color:=Main.Settings.Skin.FontColor1;
                     try
                     SettingsW.BGImage.Picture.LoadFromFile(Main.Settings.Skin.BGImage);
                     except
                     // error in image loading - loading the default one
                      try
                       SettingsW.BGImage.Picture.LoadFromFile(InitDir+'Skins\Default\background.jpg');
                       Main.Settings.Skin.BGImage:=InitDir+'Skins\Default\background.jpg';
                       ShowMessage(TranslateText('ECorruptedImageBG',Settings.Lang));
                      except
                       // if this failes, the whole program is about to crash
                       ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'Skins\Default\background.jpg'+TranslateText('FEMissingFile2',Settings.Lang));
                       CrucialE:=true; // the program must be terminated with no asking
                       SettingsW.Close;
                       Form1.Close;
                      end;
                     end;
                     SettingsW.GroupBox2.Font.Color:=Main.Settings.Skin.FontColor2;
                     SettingsW.GroupBox3.Font.Color:=Main.Settings.Skin.FontColor2;
                     SettingsW.GroupBox5.Font.Color:=Main.Settings.Skin.FontColor2;
                     SettingsW.GroupBox6.Font.Color:=Main.Settings.Skin.FontColor2;
                     SettingsW.GroupBox7.Font.Color:=Main.Settings.Skin.FontColor2;
                     SettingsW.BGOpt1.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.BGOpt2.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.BGOpt3.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.BGOpt4.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.ARewind.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.Label4.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.ConvertTags.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.KillTags.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.GroupBox8.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.GroupBox9.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.GroupBox10.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.GroupBox11.Font.Color:=Main.Settings.Skin.FontColor1;
                     SettingsW.GroupBox12.Font.Color:=Main.Settings.Skin.FontColor1;
                     end
                else
if Form='Main' then  begin
                     // * componens using BGColor and BGImage parameters * //
                     Form1.Color:=Main.Settings.Skin.BGColor;
                     Form1.SmallIconsPanel.Color:=Main.Settings.Skin.BGColor;
                     // BG Image
                     try
                     Form1.BGImage.Picture.LoadFromFile(Main.Settings.Skin.BGImage);
                     except
                     // error in image loading - loading the default one
                      try
                       Form1.BGImage.Picture.LoadFromFile(InitDir+'Skins\Default\background.jpg');
                       Main.Settings.Skin.BGImage:=InitDir+'Skins\Default\background.jpg';
                       ShowMessage(TranslateText('ECorruptedImageBG',Settings.Lang));
                      except
                       // if this failes, the whole program is about to crash
                       ShowMessage(TranslateText('FEMissingFile1',Settings.Lang)+'Skins\Default\background.jpg'+TranslateText('FEMissingFile2',Settings.Lang));
                       CrucialE:=true; // the program must be terminated with no asking
                       Form1.Close;
                      end;
                     end;
                     // * componens using FontColor1 parameter * //
                     // Player tab
                     Form1.Label1.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label2.Font.Color:=Main.Settings.Skin.FontColor1;
                     // Collection tab
                     Form1.Label3.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label4.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label5.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.CollName.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.CollPath.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label10.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label13.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label15.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label16.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Size1.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.CollStatsAlb.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.CollStatsMP3.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.CollStatsSize.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.CollStatsDuration.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.CollStatsLastEdit.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label6.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label7.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Size2.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.AlbName.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.AlbMP3Count.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.AlbSize.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.AlbDuration.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label9.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label12.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Size3.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.MP3Name.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.MP3Album.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.MP3Size.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.MP3Duration.Font.Color:=Main.Settings.Skin.FontColor1;
                     // Album tab
                     Form1.Label18.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.CurrentAlbumName.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label26.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label27.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label28.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label29.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label30.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label31.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label32.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label34.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.AutoSetTrackNumber.Font.Color:=Main.Settings.Skin.FontColor1;
                     // MP3 tab
                     Form1.Label8.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label11.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.CurrentMP3Name.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label14.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label17.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label19.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label20.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label21.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label22.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label23.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label24.Font.Color:=Main.Settings.Skin.FontColor1;
                     Form1.Label25.Font.Color:=Main.Settings.Skin.FontColor1;
                     // other
                     Form1.PlayTrackSmall.Font.Color:=Main.Settings.Skin.FontColor1;
                     // * componens using FontColor2 parameter * //
                     Form1.PlayTrack.Font.Color:=Main.Settings.Skin.FontColor2;
                     Form1.GroupBox1.Font.Color:=Main.Settings.Skin.FontColor2;
                     Form1.GroupBox2.Font.Color:=Main.Settings.Skin.FontColor2;
                     Form1.GroupBox3.Font.Color:=Main.Settings.Skin.FontColor2;
                     Form1.GroupBox4.Font.Color:=Main.Settings.Skin.FontColor2;
                     Form1.GroupBox5.Font.Color:=Main.Settings.Skin.FontColor2;
                     Form1.GroupBox6.Font.Color:=Main.Settings.Skin.FontColor2;
                     Form1.GroupBox7.Font.Color:=Main.Settings.Skin.FontColor2;
                     Form1.GroupBox8.Font.Color:=Main.Settings.Skin.FontColor2;
                     // other than Boxes
                     Form1.Label33.Font.Color:=Main.Settings.Skin.FontColor2;
                     // * componens using FontColor3 parameter * //
                     Form1.PlayTime.Font.Color:=Main.Settings.Skin.FontColor3;
                     Form1.PlayTimeSmall.Font.Color:=Main.Settings.Skin.FontColor3;
                     // * componens using TrackBG parameter * //
                     Form1.TrackQuery.Color:=Main.Settings.Skin.TrackBG;
                     // realign the labels
                     Form1.AlignLabels;
                     end

end;

procedure CutBlankSpaces(var Text: string);
// some ID3 tags has many blank spaces at the end (no 00h spacer present)
// we dont want to have them displayed
// this procedure cuts them off from the strings readed from file
var deleted: boolean;
begin
repeat
deleted:=false;
if ((Text[length(Text)]=' ')or(ord(Text[length(Text)])=0)) then begin
                                                               delete(Text,length(Text),1);
                                                               deleted:=true;
                                                               end;
until (deleted=false){no blank space anymore}or(length(Text)<1){the string was full of blank spaces};
end;

procedure CutEOL(var Text: string);
// EOL - End Of Line
// if the last char of the string is Return (13), deletes it
// it looks better in ReadOnly Memos
begin
if ord(Text[length(Text)])=13 then Delete(Text,length(Text),1);
end;

procedure CutPath(var Text: string);
// keeps only file name - w/o path and extension
begin
while pos('\',Text)>0 do delete(Text,1,pos('\',Text)); // cut the path
delete(Text,length(Text)-3,4);                         // cut the extension
end;

function CheckForSpace(DynArray: string): integer;
// controls if still enough space in dynamic arrays - or if it is necessary to add new space (10 new at once)
// it spares memory
// returns the index of first free index in the array
var i,i2: integer;
begin
if DynArray='Albums' then begin // works with Albums array
                          // special case when Album array empty
                          if high(Main.MP3Collection.Albums)=-1  then begin
                                                                      result:=0; // new item will be add on the first place
                                                                      SetLength(Main.MP3Collection.Albums,high(Main.MP3Collection.Albums)+11); // adds 10 new "slots"
                                                                      for i:=0 to high(Main.MP3Collection.Albums) do Main.MP3Collection.Albums[i].Name:='_Empty'; // indicates, that this newly added slot is free for writing
                                                                      end
                          //
                          else
                          begin
                          i:=-1;
                          repeat // quite uneffective but currently have no idea how to make it better
                                 // and there will be not too much records in one array
                          i:=i+1;
                          until (Main.MP3Collection.Albums[i].Name='_Empty') // "_Empty" indicates free slot
                              or(i>=high(Main.MP3Collection.Albums));        // this indicates array´s out of bounds - we need to add new
                          if i>=high(Main.MP3Collection.Albums) then begin
                                                                     result:=high(Main.MP3Collection.Albums)+1; // new item will be add on the first place of newly added
                                                                     SetLength(Main.MP3Collection.Albums,high(Main.MP3Collection.Albums)+11); // adds 10 new "slots"
                                                                     for i2:=i+1 to high(Main.MP3Collection.Albums) do Main.MP3Collection.Albums[i2].Name:='_Empty'; // indicates, that this newly added slot is free for writing
                                                                     end
                                                                else result:=i; // new item will be add on the first free place

                          end
                          end
                     else
  if DynArray='MP3s' then begin // works with MP3s array
                          // special case when MP3 array empty
                          if high(Main.MP3Collection.MP3s)=-1 then begin
                                                                   result:=0; // new item will be add on the first place
                                                                   SetLength(Main.MP3Collection.MP3s,high(Main.MP3Collection.MP3s)+11); // adds 10 new "slots"
                                                                   for i:=0 to high(Main.MP3Collection.MP3s) do Main.MP3Collection.MP3s[i].Name:='_Empty'; // indicates, that this newly added slot is free for writing
                                                                   end
                          //
                          else
                          begin
                          i:=-1;
                          repeat // quite uneffective but currently have no idea how to make it better
                                 // and there will be not too much records in one array
                          i:=i+1;
                          until (Main.MP3Collection.MP3s[i].Name='_Empty') // "_Empty" indicates free slot
                              or(i>=high(Main.MP3Collection.MP3s));        // this indicates array´s out of bounds - we need to add new
                          if i>=high(Main.MP3Collection.MP3s) then begin
                                                                   result:=high(Main.MP3Collection.MP3s)+1; // new item will be add on the first place of newly added
                                                                   SetLength(Main.MP3Collection.MP3s,high(Main.MP3Collection.MP3s)+11); // adds 10 new "slots"
                                                                   for i2:=i+1 to high(Main.MP3Collection.MP3s) do Main.MP3Collection.MP3s[i2].Name:='_Empty'; // indicates, that this newly added slot is free for writing
                                                                   end
                                                              else result:=i; // new item will be add on the first free place
                         end
                         end
                    else result:=0; // to make compiler satisfied and prevent "Warning" hints :D
end;

procedure CheckLastBackslash(var Text: string);
// we always want to have "\" on the last place of the path string
// user doesnt have to write it here
// so we check and add automaticaly if necessary
begin
Text:=' '+Text; // empty string cause errors - now it is surely not empty
if Text[length(Text)]<>'\' then text:=Text+'\';
Delete(Text,1,1); // delete again the " " we add on the first row
end;

function CheckName(Text: string): byte;
// will search string for invalid characters
begin
if pos('\',Text)>0 then CheckName:=1 else // exitcode 1 - invalid char
if pos(':',Text)>0 then CheckName:=1 else // exitcode 1 - invalid char
if Text[1]='_'     then CheckName:=2 else // exitcode 2 - char not allowed
                        CheckName:=0;     // exitcode 0 - all ok
end;

procedure OptimalizeAlbumOrder(old,new: word);
// updates the order of the rest of the albums in collection if order is changed by Wizard
// old - the order album previously had
// new - the new value of album order
var i: integer;
begin
if old>new then begin // the album moved up in the list
                for i:=0 to high(Main.MP3Collection.Albums) do // go through whole array
                  if Main.MP3Collection.Albums[i].Order<old then // only smaller than old value are accused for change :)
                   if Main.MP3Collection.Albums[i].Order>=new then // for all those we raise their order by one - the updated goes before them
                      begin
                      SetAlbumFolderNumber(i,Main.MP3Collection.Albums[i].Order,Main.MP3Collection.Albums[i].Order+1,false);
                      CheckMP3sInQuery(i); // in PlayerU.dcu
                      Main.MP3Collection.Albums[i].Order:=Main.MP3Collection.Albums[i].Order+1;
                      end;
                end
           else
if new>old then begin // the album moved down in the list
                for i:=0 to high(Main.MP3Collection.Albums) do // go through whole array
                  if Main.MP3Collection.Albums[i].Order>old then // only higher than old value are accused for change :)
                   if Main.MP3Collection.Albums[i].Order<=new then // for all those we lower their order by one - the updated goes after them
                      begin
                      SetAlbumFolderNumber(i,Main.MP3Collection.Albums[i].Order,Main.MP3Collection.Albums[i].Order-1,false);
                      CheckMP3sInQuery(i); // in PlayerU.dcu
                      Main.MP3Collection.Albums[i].Order:=Main.MP3Collection.Albums[i].Order-1;
                      end;

                end;
// the case old=new means - nothing to change
end;

procedure OptimalizeMP3Order(old,new: word);
// updates the order of the rest of the mp3s in album if order is changed by Wizard
var i: integer;
begin
if old>new then begin // the mp3 moved up in the list
                for i:=0 to high(Main.MP3Collection.MP3s) do // go through whole array
                  if Main.MP3Collection.MP3s[i].Order<old then // only smaller than old value are accused for change :)
                   if Main.MP3Collection.MP3s[i].Order>=new then // for all those we raise their order by one - the updated goes before them
                     begin
                      SetMP3FileNumber(i,Main.MP3Collection.MP3s[MP3ID].Order,Main.MP3Collection.MP3s[i].Order+1,false);
                      Main.MP3Collection.MP3s[i].Order:=Main.MP3Collection.MP3s[i].Order+1;
                      end;
                end
           else
if new>old then begin // the mp3 moved down in the list
                for i:=0 to high(Main.MP3Collection.MP3s) do // go through whole array
                  if Main.MP3Collection.MP3s[i].Order>old then // only higher than old value are accused for change :)
                   if Main.MP3Collection.MP3s[i].Order<=new then // for all those we lower their order by one - the updated goes after them
                      begin
                      SetMP3FileNumber(i,Main.MP3Collection.MP3s[i].Order,Main.MP3Collection.MP3s[i].Order-1,false);
                      Main.MP3Collection.MP3s[i].Order:=Main.MP3Collection.MP3s[i].Order-1;
                      end;
                end;
// the case old=new means - nothing to change
end;

procedure SetAlbumFolderNumber(album, oldpos, newpos: word; init: boolean);
// updates the physical name of folder according to the order in album
var OldAlb,NewAlb: string;
begin
if init then begin // it is the new album
             OldAlb:=Main.MP3Collection.Path+'_root\'+Main.MP3Collection.Albums[album].Name; // after initialization - the folder is only with plain name
             NewAlb:=Main.MP3Collection.Path+'_root\'+inttostr(newpos)+' - '+Main.MP3Collection.Albums[album].Name; // same for both situations

             MkDir(NewAlb);
             MoveMP3s(AlbumID); // in MP3Utilities.dcu
             CheckMP3sInQuery(AlbumID); // in PlayerU.dcu
             RmDir(OldAlb); // if possible

             //CopyDir(OldAlb,NewAlb);
             //DelDir(OldAlb);
             end
        else
if oldpos<>newpos then begin // the order has changed
                       // we know we arent updating "root" album
                       OldAlb:=Main.MP3Collection.Path+'_root\'+inttostr(oldpos)+' - '+Main.MP3Collection.Albums[album].Name; // existing album - the folder has its number already
                       NewAlb:=Main.MP3Collection.Path+'_root\'+inttostr(newpos)+' - '+Main.MP3Collection.Albums[album].Name; // same for both situations

                       MkDir(NewAlb);
                       MoveMP3s(AlbumID); // in MP3Utilities.dcu
                       CheckMP3sInQuery(AlbumID); // in PlayerU.dcu
                       RmDir(OldAlb); // if possible

                       //CopyDir(OldAlb,NewAlb);
                       //DelDir(OldAlb);
                       end;
end;

procedure SetMP3FileNumber(mp3, oldpos, newpos: word; init: boolean);
// the same with MP3s
var OldMP3,NewMP3,helpString: string;
    APIFrom,APITo: PChar;
begin
if init then begin // it is the new mp3
             OldMP3:=Main.MP3Collection.MP3s[mp3].Path;
             NewMP3:=Main.MP3Collection.MP3s[mp3].Path;
             // we will use a little help variable
             helpString:=Main.MP3Collection.MP3s[mp3].Path;
             CutPath(helpString); // we need this to get the place where to put the number
             insert(inttostr(newpos)+' - ',NewMP3,length(NewMP3)-(length(helpString)+3));

             APIFrom:=PChar(OldMP3);
             APITo:=PChar(NewMP3);
             CopyFile(APIFrom,APITo,false);
             DeleteFile(APIFrom);

             Main.MP3Collection.MP3s[mp3].Path:=NewMP3;
             end
        else
if oldpos<>newpos then begin // the order has changed
                       OldMP3:=Main.MP3Collection.MP3s[mp3].Path;
                       NewMP3:=Main.MP3Collection.MP3s[mp3].Path;
                       // here will be a bit more complicated with help variable
                       helpString:=Main.MP3Collection.MP3s[mp3].Path;
                       CutPath(helpString); // now we get the name, lets alter the included number
                       delete(NewMP3,length(NewMP3)-(length(helpString)+3),length(NewMP3)); // we will keep only path, lets the file name for a moment
                       delete(helpString,1,pos('-',helpString)+1);  // delete old number
                       insert(inttostr(newpos)+' - ',helpString,1); // update new
                       NewMP3:=NewMP3+helpString+'.mp3'; // now rebuild the new nanme

                       APIFrom:=PChar(OldMP3);
                       APITo:=PChar(NewMP3);
                       CopyFile(APIFrom,APITo,false);
                       DeleteFile(APIFrom);

                       Main.MP3Collection.MP3s[mp3].Path:=NewMP3;
                       end;
end;

function GetFileSize(MP3Path: string): integer;
// checks for file size of imported/edited mp3
var MP3: file of byte;
begin
try // may cause errors
AssignFile(MP3,MP3Path);
Reset(MP3);
result:=FileSize(MP3);
CloseFile(MP3);
except
result:=0;

try // if error occured after opening - this file will be used later in program...
CloseFile(MP3);
except
end;

end;
end;

function RoundSize(FileSize: integer): real;
// returns file size rounded according to the representation
// in Bytes, KiloBytes or MegaBytes
begin
{
// Bytes
if Main.Settings.FSiz=1 then result:=FileSize else
// KiloBytes
if Main.Settings.FSiz=1000 then result:=FileSize / 1000;
// MegaBytes
                           else result:=FileSize / 1000000;
}
result:=FileSize / Main.Settings.FSiz;
end;

procedure OptimalizeFileSizes;
// recounts total file sizes for albums and for collection
//var i,i2: integer;
begin
{
// collection
Main.MP3Collection.Size:=0; // reseting
for i:=0 to high(Main.MP3Collection.MP3s) do Main.MP3Collection.Size:=Main.MP3Collection.Size+Main.MP3Collection.MP3s[i].Size;
// albums
for i:=0 to high(Main.MP3Collection.Albums) do begin
                                               Main.MP3Collection.Albums[i].Size:=0; // reseting
                                               for i2:=0 to high(Main.MP3Collection.MP3s) do
                                                 if Main.MP3Collection.MP3s[i2].Album=i then
                                                   Main.MP3Collection.Albums[i].Size:=Main.MP3Collection.Albums[i].Size+Main.MP3Collection.MP3s[i2].Size;
                                               end;
}
end;

procedure UpdateLastChangeDate;
// acctual value of date and time
begin
// when something updated, the last opened collection cannot be opened anymore
Form1.PrgOpt4.Enabled:=false;
//
Main.MP3Collection.LastEdit:=DateToStr(Now)+' '+TimeToStr(Now);
Form1.CollStatsLastEdit.Caption:=Main.MP3Collection.LastEdit; // visualization
end;

procedure CreateConfigFile;
// writes down into file actual settings
var Config: textfile;
begin
try
AssignFile(Config,InitDir+'Config.ini');
Rewrite(Config);
Write(Config,'ResH = ');
Writeln(Config,Settings.ResH);
Write(Config,'ResW = ');
Writeln(Config,Settings.ResW);
Write(Config,'Lang = ');
Writeln(Config,Settings.Lang);
Write(Config,'PVol = ');
Writeln(Config,Settings.PVol);
Write(Config,'Bckg = ');
Writeln(Config,Settings.Bckg);
Write(Config,'ARwd = ');
if Settings.ARwd then Writeln(Config,'1')
                 else Writeln(Config,'0');
Write(Config,'ID3V = ');
if Settings.ID3V then Writeln(Config,'1')
                 else Writeln(Config,'0');
Write(Config,'CTgs = ');
if Settings.CTgs then Writeln(Config,'1')
                 else Writeln(Config,'0');
Write(Config,'DID3 = ');
if Settings.DID3 then Writeln(Config,'1')
                 else Writeln(Config,'0');
Write(Config,'WDir = ');
Writeln(Config,Settings.WDir);
Write(Config,'ALod = ');
if Settings.ALod then Writeln(Config,'1')
                 else Writeln(Config,'0');
Write(Config,'ADel = ');
if Settings.ALod then Writeln(Config,'1')
                 else Writeln(Config,'0');
Write(Config,'ASet = ');
if Settings.ASet then Writeln(Config,'1')
                 else Writeln(Config,'0');
Write(Config,'ACTr = ');
if Settings.ACTr then Writeln(Config,'1')
                 else Writeln(Config,'0');
Write(Config,'Last = ');
Writeln(Config,Settings.Last);
Write(Config,'LDir = ');
Writeln(Config,Settings.LDir);
Write(Config,'FSiz = ');
Writeln(Config,Settings.FSiz);
Write(Config,'SkNa = ');
Writeln(Config,Settings.Skin.SkinName);
Write(Config,'SkIm = ');
Writeln(Config,Settings.Skin.BGImage);
Write(Config,'SkBc = ');
Writeln(Config,Settings.Skin.BGColor);
Write(Config,'SkF1 = ');
Writeln(Config,Settings.Skin.FontColor1);
Write(Config,'SkF2 = ');
Writeln(Config,Settings.Skin.FontColor2);
Write(Config,'SkF3 = ');
Writeln(Config,Settings.Skin.FontColor3);
Write(Config,'SkTr = ');
Writeln(Config,Settings.Skin.TrackBG);
CloseFile(Config);
except
 try
  CloseFile(Config);
 except
  // maybe will work, maybe not, but it is good to try it and dont let it open
 end;
ShowMessage(TranslateText('ECannotSaveSettings',Main.Settings.Lang));
end;
end;

function VolumeInPercents(volume: byte): byte;
// simply transforms 0-255 values to 0-100% scale
begin
result:=(volume*100)div 255;
end;

function DurationInTime(duration: longint; shortformat: boolean): string;
// will interpret longint time info as mins and secs
var mins,secs,hours: integer;
begin
// counting values
hours:=duration div 3600000;
duration:=duration-(hours*3600000);
mins:=duration div 60000;
duration:=duration-(mins*60000);
secs:=(duration div 1000);
if duration<>0 then secs:=secs+1;
// interpreting result
result:='';
if shortformat then begin
                    if hours>0 then result:=inttostr(hours)+':';
                    if mins<10 then result:=result+'0'+inttostr(mins)
                               else result:=result+inttostr(mins);
                    if secs<10 then result:=result+':0'+inttostr(secs)
                               else result:=result+':'+inttostr(secs);
                    end
               else begin
                    if hours>0 then result:=inttostr(hours)+' h';
                    if mins<10 then result:=result+' 0'+inttostr(mins)
                               else result:=result+' '+inttostr(mins);
                    if secs<10 then result:=result+' m 0'+inttostr(secs)+' s'
                               else result:=result+' m '+inttostr(secs)+' s';
                    end;
end;

function GetMP3Bitrate(source: string): word;
// this will get bitrate of MP3 from its header
// the bitrate is saved in header in the first four bits of 3d byte
// it's values are coded in a table
var MP3Source: file of byte;
    data: byte;
begin
// reading data
AssignFile(MP3Source,source);
Reset(MP3Source);
read(MP3Source,data); // 1st byte
read(MP3Source,data); // 2nd byte
read(MP3Source,data); // 3rd byte - this we want
CloseFile(MP3Source);
// decoding data
GetMP3Bitrate:=0;
end;

procedure CreateWarnFile(path: string);
// create "warning" files
var WFile: textfile;
begin
AssignFile(WFile,path);
try
Rewrite(WFile);
WriteLn(WFile,'WARNING : Do not rename files in this directory in any case !!!');
WriteLn(WFile);
WriteLn(WFile,'If you alter any file name other way than via MP3xtreme, the references will be automatically removed from your collection !!!');
CloseFile(WFile);
except
on EInOutError do begin
                  ShowMessage(TranslateText('FECannotOpenFile',Settings.Lang));
                  CrucialE:=true; // the program must be terminated with no asking
                  Form1.Close;
                  end;
end;
end;

function CheckExistence(MP3Name: string; Album: integer): integer;
// checks if MP3 with same name doesnt already exist in current album
var i: integer;
    match: boolean;
begin
match:=false;
i:=-1;
repeat
i:=i+1;
if (Main.MP3Collection.MP3s[i].Album=Album)and(Main.MP3Collection.MP3s[i].Name=MP3Name) then match:=true;
until (match)or(i>=high(Main.MP3Collection.MP3s));
if match then CheckExistence:=i
         else CheckExistence:=-1;
end;

procedure MoveMP3s(Album: integer);
// when changing album name, it is necessary to move MP3 files too and update their paths
var i,matches: integer;
    APIFrom,APITo: PChar;
    text: string;
begin
i:=-1;
matches:=0;
repeat
i:=i+1;
if (Main.MP3Collection.MP3s[i].Album=Album) then begin
                                                 matches:=matches+1;
                                                 text:=Main.MP3Collection.MP3s[i].Path;
                                                 APIFrom:=PChar(text);
                                                 APITo:=PChar(Main.MP3Collection.Path+'_root\'+inttostr(Main.MP3Collection.Albums[AlbumID].Order)+'\'+Main.MP3Collection.Albums[AlbumID].Name+'\'+inttostr(Main.MP3Collection.MP3s[i].Order)+' - '+Main.MP3Collection.MP3s[i].Name+'.mp3');
                                                 CopyFile(APIFrom,APITo,false);
                                                 Main.MP3Collection.MP3s[i].Path:=Main.MP3Collection.Path+'_root\'+inttostr(Main.MP3Collection.Albums[AlbumID].Order)+'\'+Main.MP3Collection.Albums[AlbumID].Name+'\'+inttostr(Main.MP3Collection.MP3s[i].Order)+' - '+Main.MP3Collection.MP3s[i].Name+'.mp3';
                                                 end;
until (i>=high(Main.MP3Collection.MP3s))or(matches=Main.MP3Collection.Albums[Album].MP3No);
end;

end.
