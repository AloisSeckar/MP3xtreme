/////////////////////////////////////////////////////////////////////
//                                                                 //
//                   MP3 - Master Player 3xtreme                   //
//                     mp3 player and organizer                    //
//                                                                 //
//                    Copyright © Ellrohir 2008                    //
//                                                                 //
//                                                                 //
//    Page Info                                                    //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
// *  Author:         *  Ferdabasek                              * //
// *  Homepage:       *  http://www.sweb.cz/ferdabasek           * //
// *  File:           *  MixerU.pas                              * //
// *  Purpose:        *  Volume Editing Control                  * //
// *  System Version: *  1.0                                     * //
// *  Last Modified:  *  2008-01-12 2115 GMT+1                   * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
/////////////////////////////////////////////////////////////////////

unit MixerU;

// unit created by Ferdabasek
// i have copied the source code from open web location - http://forum.builder.cz/read.php?18,2212142,2216723

interface

uses
SysUtils, Classes, Controls, MMSystem, Windows;

type

TIMixer = (Wave, Midi, CDAudio, Line, Vystup);

Volume = 0..255;

TLineInfo = class (TPersistent)
private
fKanalu : Integer;
fJmeno : String;
fZarizeni : String;
fSNic : String;
fNNic : Integer;
published
Property Kanalu : Integer Read fKanalu Write fNNic;
Property Jmeno : String Read fJmeno Write fSNic;
Property Zarizeni : String Read fZarizeni Write fSNic;
End;

TMixer = class(TComponent)
private
fMixerInfo : TIMixer;
fInfo : TLineInfo;
fCaps : Integer;
fAutor : String;
fMixerTyp : String;
fSNic : String;
protected
Procedure SetMixerInfo (Value : TIMixer);
Procedure SetVolume (Value : Volume);
Function GetVolume : Volume;
public
Constructor Create (AOwner : TComponent); Override;
Destructor Destroy; Override;
published
Property Autor : String Read fAutor Write fSNic;
Property Smesovac : String Read fMixerTyp Write fSNic;
Property InfoLine : TLineInfo Read fInfo Write fInfo;
Property MixerInfo : TIMixer Read fMixerInfo Write SetMixerInfo;
Property Hlasitost : Volume Read GetVolume Write SetVolume;
end;

procedure Register;

implementation

Var
TypMixer : Array [TIMixer] of Integer = (
MIXER_OBJECTF_WAVEOUT,
MIXER_OBJECTF_MIDIOUT,
0, 0, 0);

AutorString : Array [0..16] of Char =
('(', 'c', ')', ' ', 'M', 'i', 'r', 'o', 's',
'l', 'a', 'v', 'V', 'í', 't', ',', 'P');

PoradiAutor : Array [0..21] of Word =
( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 3,
12, 13, 14, 15, 3, 16, 11, 11, 8);

procedure Register;
begin
RegisterComponents('System', [TMixer]);
end;

Constructor TMixer.Create (AOwner : TComponent);
Var
A : Integer;
MixerC : PMixerCaps;
Begin
Inherited Create (AOwner);
fInfo := TLineInfo.Create;
fAutor := '';
fMixerInfo := Midi;
SetMixerInfo (Wave);
For A := 0 To 21 Do fAutor := fAutor + AutorString [PoradiAutor [A]];
New (MixerC);
If MixerGetDevCaps (0, MixerC, SizeOf (TMixerCaps)) = 0 Then
fMixerTyp := StrPas (MixerC^.szPname) Else fMixerTyp := 'Není k dispozici';
Dispose (MixerC);
End;

Destructor TMixer.Destroy;
Begin
fInfo.Destroy;
Inherited Destroy;
End;

Procedure TMixer.SetMixerInfo (Value : TIMixer);
Var
MixerLine : PMixerLine;
AuxLine : PAuxCaps;
A, B : Integer;
Begin
If Value <> fMixerInfo Then Begin
fMixerInfo := Value;
If (fMixerInfo = Wave) or (fMixerInfo = Midi) Then Begin
New (MixerLine);
MixerLine.cbStruct := SizeOf (TMixerLine);
If MixerGetLineInfo (0, MixerLine, TypMixer [Value]) = 0 Then Begin
fInfo.fKanalu := MixerLine^.cChannels;
fInfo.fJmeno := StrPas (Mixerline^.szName);
fInfo.fZarizeni := StrPas (MixerLine^.Target.szPname);
End Else Begin
fInfo.fKanalu := 0;
fInfo.fJmeno := '';
fInfo.fZarizeni := 'Není k dispozici';
End;
End Else Begin
B := 0;
For A := 0 To AuxGetNumDevs - 1 Do Begin
New (AuxLine);
If AuxGetDevCaps (A, AuxLine, SizeOf (TAuxCaps)) = 0 Then Begin
If (B = 0) and (fMixerInfo = CDAudio) Then Begin
If AuxLine^.wTechnology = AUXCAPS_CDAUDIO Then Begin
fCaps := A;
B := 1;
fInfo.fKanalu := 2;
fInfo.fJmeno := 'CDAudio';
fInfo.fZarizeni := StrPas (AuxLine^.szPname);
End;
End;
If (B = 0) and (fMixerInfo = Line) Then Begin
If AuxLine^.wTechnology = AUXCAPS_AUXIN Then Begin
fCaps := A;
B := 1;
fInfo.fKanalu := 2;
fInfo.fJmeno := 'Line';
fInfo.fZarizeni := StrPas (AuxLine^.szPname);
End;
End;
If (B = 0) and (fMixerInfo = Vystup) Then Begin
New (MixerLine);
MixerLine.cbStruct := SizeOf (TMixerLine);
If MixerGetLineInfo (A, MixerLine, MIXER_OBJECTF_AUX) = 0 Then
If MixerLine^.dwComponentType = MIXERLINE_COMPONENTTYPE_SRC_ANALOG Then Begin
fCaps := A;
B := 1;
fInfo.fKanalu := MixerLine^.cChannels;
fInfo.fJmeno := StrPas (MixerLine^.szName);
fInfo.fZarizeni := StrPas (MixerLine^.Target.szPname);
End;
Dispose (MixerLine);
End;
End;
Dispose (AuxLine);
End;
If B = 0 Then Begin
fInfo.fKanalu := 0;
fInfo.fJmeno := '-';
fInfo.fZarizeni := 'Není k dispozici';
End;
End;
End;
End;

Function TMixer.GetVolume : Volume;
Var
Hlasitost : DWord;
Begin
Result := 0;
If fMixerInfo = Wave Then Begin
WaveOutGetVolume (0, @Hlasitost);
Result := StrToInt ('$' + Copy (IntToHex (Hlasitost, 8), 0, 2));
End;
If fMixerInfo = Midi Then Begin
MidiOutGetVolume (0, @Hlasitost);
Result := StrToInt ('$' + Copy (IntToHex (Hlasitost, 8), 0, 2));
End;
If (fMixerInfo <> Wave) and (fMixerInfo <> Midi) Then Begin
AuxGetVolume (fCaps, @Hlasitost);
Result := StrToInt ('$' + Copy (IntToHex (Hlasitost, 8), 0, 2));
End;
End;

Procedure TMixer.SetVolume (Value : Volume);
Var
Hlasitost : DWord;
Begin
Hlasitost := StrToInt ('$' + IntToHex (Value, 2) + IntToHex (Value, 2) + IntToHex (Value, 2) + IntToHex (Value, 2));
If fMixerInfo = Wave Then WaveOutSetVolume (0, Hlasitost);
If fMixerInfo = Midi Then MidiOutSetVolume (0, Hlasitost);
If (fMixerInfo <> Wave) and (fMixerInfo <> Midi) Then AuxSetVolume (fCaps, Hlasitost);
End;


end.
