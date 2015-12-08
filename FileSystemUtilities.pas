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
// *  Author:         *  Various authors                         * //
// *  Homepage:       *  -                                       * //
// *  File:           *  FileSystemUtilities.pas                 * //
// *  Purpose:        *  For moving/removing directories         * //
// *  System Version: *  1.0                                     * //
// *  Last Modified:  *  2008-02-27 1300 GMT+1                   * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
/////////////////////////////////////////////////////////////////////

unit FileSystemUtilities;

interface

uses Windows,ShellApi;

// functions by Rainer Kümmerle (http://www.thinklazy.de)
// as presented on http://www.swissdelphicenter.ch/en/showcode.php?id=152
function CopyDir(const fromDir, toDir: string): Boolean;
function MoveDir(fromDir, toDir: string): Boolean;
function DelDir(dir: string): Boolean;
//

implementation

function CopyDir(const fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_COPY;
    fFlags := FOF_FILESONLY;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;


function MoveDir(fromDir, toDir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_MOVE;
    fFlags := FOF_FILESONLY;
    pFrom  := PChar(fromDir + #0);
    pTo    := PChar(toDir)
  end;
  Result := (0 = ShFileOperation(fos));
end;

function DelDir(dir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc  := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom  := PChar(dir + #0);
  end;
  Result := (0 = ShFileOperation(fos));
end;

end.
 