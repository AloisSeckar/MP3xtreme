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
// *  File:           *  ID3Utilities.pas                        * //
// *  Purpose:        *  Functions and procedures for ID3 tags   * //
// *  System Version: *  1.0                                     * //
// *  Last Modified:  *  2008-03-10 1000 GMT+1                   * //
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
/////////////////////////////////////////////////////////////////////

unit ID3Utilities;

interface

uses Main, MP3Utilities, Dialogs, SysUtils, id3v2 {by James Webb};

function ReadID3v1Tags(MP3: string): TID3v1;
procedure WriteID3v1Tags(MP3: string);
function ReadID3v2Tags(MP3: string): TID3v2;
procedure WriteID3v2Tags(MP3: string; ID: integer);
procedure ConvertID3v2ToID3v1(MP3ID: word);
procedure AutoSetTags(MP3ID,AlbumID: word);

function GetValueFromGenresTable(ID3v2Genre: byte): string;
function GetIndexFromGenresTable(ID3v2Genre: string): byte;

implementation

// * ID3v1 TAGS *

function ReadID3v1Tags(MP3: string): TID3v1;
var MP3Source: file of byte;
    i: integer;
    t,a,g,data: byte;
    notag: boolean;
    text: string;
begin
notag:=false;
AssignFile(MP3Source,MP3);
try
reset(MP3Source);
if (filesize(MP3Source)<128) then notag:=true; // ID3 tag has 128 bytes...the file must be that big or bigger
seek(MP3Source, filesize(MP3Source)-128);  // go to the presumed ID3 tag begining
read(MP3Source, t, a, g);  // check for ID3 tag header
if ((upcase(chr(t))='T') and (upcase(chr(a))='A') and (upcase(chr(g))='G')) then // do nothing
                                                                            else notag:=true; // no tag header - no tag...
if notag=false then begin // read the tag
                    // ID3 tag - Title
                    seek(MP3Source, filesize(MP3Source)-125); // jump to position (-128+3)
                    result.Title:=''; // reset the result
                    i:=0;
                    repeat
                    i:=i+1;
                    read(MP3Source, data);  // read byte from the file
                    result.Title:=result.Title+chr(data);  // add to the result
                    until (data=0){00h = spacer} or (i>=30){00h = no spacer present};
                    text:=result.Title;
                    CutBlankSpaces(text);
                    result.Title:=text;
                    if result.Title='' then result.Title:='Unknown Track';
                    // ID3 tag - Artist
                    seek(MP3Source, filesize(MP3Source)-95); // jump to position (-128+33)
                    result.Artist:=''; // reset the result
                    i:=0;
                    repeat
                    i:=i+1;
                    read(MP3Source, data);  // read byte from the file
                    result.Artist:=result.Artist+chr(data);  // add to the result
                    until (data=0){00h = spacer} or (i>=30){00h = no spacer present};
                    text:=result.Artist;
                    CutBlankSpaces(text);
                    result.Artist:=text;
                    if result.Artist='' then result.Artist:='Unknown Artist';
                    // ID3 tag - Album
                    seek(MP3Source, filesize(MP3Source)-65); // jump to position (-128+63)
                    result.Album:=''; // reset the result
                    i:=0;
                    repeat
                    i:=i+1;
                    read(MP3Source, data);  // read byte from the file
                    result.Album:=result.Album+chr(data);  // add to the result
                    until (data=0){00h = spacer} or (i>=30){00h = no spacer present};
                    text:=result.Album;
                    CutBlankSpaces(text);
                    result.Album:=text;
                    if result.Album='' then result.Album:='Unknown Album';
                    // ID3 tag - Year
                    seek(MP3Source, filesize(MP3Source)-35); // jump to position (-128+93)
                    result.Year:=''; // reset the result
                    i:=0;
                    repeat
                    i:=i+1;
                    read(MP3Source, data);  // read byte from the file
                    result.Year:=result.Year+chr(data);  // add to the result
                    until (data=0){00h = spacer} or (i>=4){00h = no spacer present};
                    // ID3 tag - Comment
                    seek(MP3Source, filesize(MP3Source)-31); // jump to position (-128+97)
                    result.Comment:=''; // reset the result
                    i:=0;
                    repeat
                    i:=i+1;
                    read(MP3Source, data);  // read byte from the file
                    result.Comment:=result.Comment+chr(data);  // add to the result
                    until (data=0){00h = spacer} or (i>=29){00h = no spacer present};
                    text:=result.Comment;
                    CutBlankSpaces(text);
                    result.Comment:=text;
                    // ID3 tag - Track
                    result.Track:=0;
                    if (length(result.Comment)<29) then begin // only if the track number is present (comment is 28 chars long instead of 3O)
                                                        seek(MP3Source, filesize(MP3Source)-2); // jump to position (-128+126)
                                                        read(MP3Source, result.Track);  // read byte from the file
                                                        end;
                    // ID3 tag - Genre
                    result.Genre:=12;  // value for "Other"
                    seek(MP3Source, filesize(MP3Source)-1); // jump to position (-128+127)
                    read(MP3Source, result.Genre);  // read byte from the file
                    //
                    end
               else begin // fill the result with default values
                    result.Title:='Unknown Track';
                    result.Artist:='Unknown Artist';
                    result.Album:='Unknown Album';
                    result.Year:='2008';
                    result.Comment:='';
                    result.Track:=0;
                    result.Genre:=12;  // value for "Other"
                    end;
except
result.Title:='Unknown Track';
result.Artist:='Unknown Artist';
result.Album:='Unknown Album';
result.Year:='2008';
result.Comment:='';
result.Track:=0;
result.Genre:=12;  // value for "Other"
end;

try // maybe wont work...
CloseFile(MP3Source);
except
end;

end;

procedure WriteID3v1Tags(MP3: string);
// writes edited ID3v1 tags into mp3 file
var MP3Source: file of byte;
    i,i2: integer;
    t,a,g,data: byte;
begin
AssignFile(MP3Source,MP3);
try
reset(MP3Source);
seek(MP3Source, filesize(MP3Source)-128);  // go to the presumed ID3 tag begining
read(MP3Source, t, a, g);  // check for ID3 tag header
if ((upcase(chr(t))='T') and (upcase(chr(a))='A') and (upcase(chr(g))='G')) then begin
                                                                                 // cuts whole tag section
                                                                                 seek(MP3Source, filesize(MP3Source)-129);
                                                                                 truncate(MP3Source);
                                                                                 end;



// WRITING HEADER
seek(MP3Source, filesize(MP3Source));
data:=ord('t');
write(MP3Source,data);
data:=ord('a');
write(MP3Source,data);
data:=ord('g');
write(MP3Source,data);
// WRITING TAGS
// ID3 tag - Title
for i:=1 to length(MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Title) do begin
                                                                        data:=ord(MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Title[i]);
                                                                        write(MP3Source,data);
                                                                        end;
data:=0;
write(MP3Source,data); {writing 00h = spacer}
for i2:=i+1 to 30 do begin // filling the rest
                     data:=32; // blank space
                     write(MP3Source,data);
                     end;

// ID3 tag - Artist
for i:=1 to length(MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Artist) do begin
                                                                         data:=ord(MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Artist[i]);
                                                                         write(MP3Source,data);
                                                                         end;
data:=0;
write(MP3Source,data); {writing 00h = spacer}
for i2:=i+1 to 30 do begin // filling the rest
                     data:=32; // blank space
                     write(MP3Source,data);
                     end;
// ID3 tag - Album
for i:=1 to length(MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Album) do begin
                                                                         data:=ord(MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Album[i]);
                                                                         write(MP3Source,data);
                                                                         end;
data:=0;
write(MP3Source,data); {writing 00h = spacer}
for i2:=i+1 to 30 do begin // filling the rest
                     data:=32; // blank space
                     write(MP3Source,data);
                     end;
// ID3 tag - Year
for i:=1 to 4 do begin
                 data:=ord(MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Year[i]);
                 write(MP3Source,data);
                 end;
// no spacer and rest here
// ID3 tag - Comment
for i:=1 to length(MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Comment) do begin
                                                                          data:=ord(MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Comment[i]);
                                                                          write(MP3Source,data);
                                                                          end;
data:=0;
write(MP3Source,data); {writing 00h = spacer}
for i2:=i+1 to 29 do begin // filling the rest
                     data:=32; // blank space
                     write(MP3Source,data);
                     end;
// ID3 tag - Track
data:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Track;
 write(MP3Source,data);
// ID3 tag - Genre
data:=MP3Collection.MP3s[CurrentActiveMP3].ID3v1.Genre;
write(MP3Source,data); 
except
ShowMessage(TranslateText('ECannotSaveTags',Settings.Lang));
end;

try // maybe wont work...
CloseFile(MP3Source);
except
end;

end;

// * ID3v1 TAGS *

// * ID3v2 TAGS *

function ReadID3v2Tags(MP3: string): TID3v2;
// reading ID3v2 tags from file
// using ID3v2 reading technology by James Webb
// the source code taken from Delphi tutorial by Vaclav Kadlec - http://www.zive.cz/default.aspx?textart=1&article=124265
// i made only a few changes here to fit it to my program
var Container: Tid3v2Tag;
    //notag: boolean;
    tempStr : string;
    tempInt : word;
    myCOMM : COMM;
begin

Container:= Tid3v2Tag.Create; // assigning component

try
tempInt := Container.loadFromFile(MP3, 0);

if (tempInt > 255) then begin
                        // some error occurs
                        result.Title:='Unknown Track';
                        result.Artist:='Unknown Artist';
                        result.Album:='Unknown Album';
                        result.Year:='2008';
                        result.Comment:='';
                        result.Track:='0';
                        result.Genre:='Other';
                        end
                   else begin
                        // standard reading procedure
                        Container.getAsciiText('TIT2', tempStr); //Get Song Title
                        if tempStr='' then result.Title := 'Unknown Track'
                                      else result.Title := tempStr;

                        Container.getAsciiText('TPE1', tempStr); //Get Artist Name
                        if tempStr='' then result.Artist := 'Unknown Artist'
                                      else result.Artist := tempStr;

                        Container.getAsciiText('TALB', tempStr); //Get Album Name
                        if tempStr='' then result.Album := 'Unknown Album'
                                      else result.Album := tempStr;

                        Container.getAsciiText('TYER', tempStr); //Get Release Year
                        if tempStr='' then result.Year := '2008'
                                      else result.Year := tempStr;

                        Container.getAsciiText('TCON', tempStr); //Get Genre
                        if tempStr='' then result.Genre := 'Other'
                                      else begin
                                            // eliminating known problematic characters in genre expression
                                            // so far i encountered " 'number' " and " (number) "
                                            // other similar can be added when i notice them
                                            while Pos('''',tempStr)>0 do delete(tempStr,Pos('''',tempStr),1);
                                            while Pos('(',tempStr)>0 do delete(tempStr,Pos('(',tempStr),1);
                                            while Pos(')',tempStr)>0 do delete(tempStr,Pos(')',tempStr),1);
                                            try
                                            result.Genre := GetValueFromGenresTable(strtoint(tempStr));
                                            except
                                            result.Genre := tempStr;
                                            end;
                                           end;

                        Container.getAsciiText('TRCK', tempStr); //Get Track #
                        if tempStr='' then result.Track := '0'
                                      else result.Track := tempStr;

                        Container.getCOMM(myCOMM, ''); //Get basic comment (no description)
                        if tempStr='' then result.Comment := ''
                                      else result.Comment := tempStr;
    end;
except
// some error occurs
result.Title:='Unknown Track';
result.Artist:='Unknown Artist';
result.Album:='Unknown Album';
result.Year:='2008';
result.Comment:='';
result.Track:='0';
result.Genre:='(12)';
end;

Container.Free; // releasing component
end;

procedure WriteID3v2Tags(MP3: string; ID: integer);
// reading ID3v2 tags from file
// using ID3v2 reading technology by James Webb
// the source code taken from Delphi tutorial by Vaclav Kadlec - http://www.zive.cz/default.aspx?textart=1&article=124265
// i made only a few changes here to fit it to my program
var Container: Tid3v2Tag;
    tempInt : word;
    myCOMM : COMM;
begin

Container:= Tid3v2Tag.Create; // assigning component

tempInt := Container.loadFromFile(MP3, 0);

if Main.Settings.DID3 then Container.kill; // auto-delete older ID3v2 tag (if option selected)

  Container.setAsciiText('TIT2', Main.MP3Collection.MP3s[ID].ID3v2.Title); //Set Song Title
  Container.setAsciiText('TPE1', Main.MP3Collection.MP3s[ID].ID3v2.Artist); //Set Artist Name
  Container.setAsciiText('TALB', Main.MP3Collection.MP3s[ID].ID3v2.Album); //Set Album Name
  Container.setAsciiText('TYER', Main.MP3Collection.MP3s[ID].ID3v2.Year); //Set Release Year
  Container.setAsciiText('TCON', Main.MP3Collection.MP3s[ID].ID3v2.Genre); //Set Genre
  Container.setAsciiText('TRCK', Main.MP3Collection.MP3s[ID].ID3v2.Track); //Set Track #


  myCOMM.encoding := etASCII;
  myCOMM.language := 'ENG';
  myCOMM.description := '';
  myCOMM.body := Main.MP3Collection.MP3s[ID].ID3v2.Comment;
  Container.setCOMM(myCOMM, myCOMM.description);

  tempInt := Container.saveToFile;
  if (tempInt > 255) then
    ShowMessage(TranslateText('ECannotSaveTags',Settings.Lang));

Container.Free; // releasing component

end;

// * ID3v2 TAGS *

// * OTHER UTILITIES *

procedure ConvertID3v2ToID3v1(MP3ID: word);
// will try to convert ID3v2 tags to ID3v1 for selected MP3
var text: string;
    tryGenre: byte;
begin
Main.MP3Collection.MP3s[MP3ID].ID3v1.Title:=copy(Main.MP3Collection.MP3s[MP3ID].ID3v2.Title,1,30);
Main.MP3Collection.MP3s[MP3ID].ID3v1.Artist:=copy(Main.MP3Collection.MP3s[MP3ID].ID3v2.Artist,1,30);
Main.MP3Collection.MP3s[MP3ID].ID3v1.Album:=copy(Main.MP3Collection.MP3s[MP3ID].ID3v2.Album,1,30);
Main.MP3Collection.MP3s[MP3ID].ID3v1.Comment:=copy(Main.MP3Collection.MP3s[MP3ID].ID3v2.Comment,1,29);
Main.MP3Collection.MP3s[MP3ID].ID3v1.Year:=copy(Main.MP3Collection.MP3s[MP3ID].ID3v2.Year,1,4);
// genre is a but harder
text:=MP3Collection.MP3s[MP3ID].ID3v2.Genre;
// eliminating known problematic characters in genre expression
// so far i encountered " 'number' " and " (number) "
// other similar can be added when i notice them
while Pos('''',text)>0 do delete(text,Pos('''',text),1);
while Pos('(',text)>0 do delete(text,Pos('(',text),1);
while Pos(')',text)>0 do delete(text,Pos(')',text),1);
// maybe in ID3v2 the tag is written as string
// so try to convert it into inreger
tryGenre:=GetIndexFromGenresTable(text);
if tryGenre=255 then try
                      Main.MP3Collection.MP3s[MP3ID].ID3v1.Genre:=strtoint(Main.MP3Collection.MP3s[MP3ID].ID3v2.Genre);
                     except
                      Main.MP3Collection.MP3s[MP3ID].ID3v1.Genre:=12;
                     end
                else Main.MP3Collection.MP3s[MP3ID].ID3v1.Genre:=tryGenre;     
//
try
 Main.MP3Collection.MP3s[MP3ID].ID3v1.Track:=strtoint(Main.MP3Collection.MP3s[MP3ID].ID3v2.Track);
 except
 Main.MP3Collection.MP3s[MP3ID].ID3v1.Track:=0;
end;
end;

procedure AutoSetTags(MP3ID,AlbumID: word);
// set common values of ID3 tags for specified MP3
begin
if Main.MP3Collection.Albums[AlbumID].CommonValuesID3v2.Artist<>'' then Main.MP3Collection.MP3s[MP3ID].ID3v2.Artist:=Main.MP3Collection.Albums[AlbumID].CommonValuesID3v2.Artist;
if Main.MP3Collection.Albums[AlbumID].CommonValuesID3v2.Album<>'' then Main.MP3Collection.MP3s[MP3ID].ID3v2.Album:=Main.MP3Collection.Albums[AlbumID].CommonValuesID3v2.Album;
if Main.MP3Collection.Albums[AlbumID].CommonValuesID3v2.Comment<>'' then Main.MP3Collection.MP3s[MP3ID].ID3v2.Comment:=Main.MP3Collection.Albums[AlbumID].CommonValuesID3v2.Comment;
if Main.MP3Collection.Albums[AlbumID].CommonValuesID3v2.Year<>'1' then Main.MP3Collection.MP3s[MP3ID].ID3v2.Year:=Main.MP3Collection.Albums[AlbumID].CommonValuesID3v2.Year;
if Main.MP3Collection.Albums[AlbumID].CommonValuesID3v2.Genre<>'255' then Main.MP3Collection.MP3s[MP3ID].ID3v2.Genre:=Main.MP3Collection.Albums[AlbumID].CommonValuesID3v2.Genre;
if Main.MP3Collection.Albums[AlbumID].CommonValuesID3v1.Artist<>'' then Main.MP3Collection.MP3s[MP3ID].ID3v1.Artist:=Main.MP3Collection.Albums[AlbumID].CommonValuesID3v1.Artist;
if Main.MP3Collection.Albums[AlbumID].CommonValuesID3v1.Album<>'' then Main.MP3Collection.MP3s[MP3ID].ID3v1.Album:=Main.MP3Collection.Albums[AlbumID].CommonValuesID3v1.Album;
if Main.MP3Collection.Albums[AlbumID].CommonValuesID3v1.Comment<>'' then Main.MP3Collection.MP3s[MP3ID].ID3v1.Comment:=Main.MP3Collection.Albums[AlbumID].CommonValuesID3v1.Comment;
if Main.MP3Collection.Albums[AlbumID].CommonValuesID3v1.Year<>1 then Main.MP3Collection.MP3s[MP3ID].ID3v1.Year:=Main.MP3Collection.Albums[AlbumID].CommonValuesID3v2.Year;
if Main.MP3Collection.Albums[AlbumID].CommonValuesID3v1.Genre<>255 then Main.MP3Collection.MP3s[MP3ID].ID3v1.Genre:=Main.MP3Collection.Albums[AlbumID].CommonValuesID3v1.Genre;
end;

function GetValueFromGenresTable(ID3v2Genre: byte): string;
// a little convertor between string and numerical values of genres
// MP3 is using both (strings are visible, but can numerical are also accepted and are auto-converted into strings)
// this function compares genre index with list of indexes

begin
case ID3v2Genre of

0 : result:='Blues';
1 : result:='Classic Rock';
2 : result:='Country';
3 : result:='Dance';
4 : result:='Disco';
5 : result:='Funk';
6 : result:='Grunge';
7 : result:='Hip-Hop';
8 : result:='Jazz';
9 : result:='Metal';
10 : result:='New Age';
11 : result:='Oldies';
12 : result:='Other';
13 : result:='Pop';
14 : result:='R&B';
15 : result:='Rap';
16 : result:='Reggae';
17 : result:='Rock';
18 : result:='Techno';
19 : result:='Industrial';
20 : result:='Alternative';
21 : result:='Ska';
22 : result:='Death Metal';
23 : result:='Pranks';
24 : result:='Soundtrack';
25 : result:='Euro-Techno';
26 : result:='Ambient';
27 : result:='Trip-Hop';
28 : result:='Vocal';
29 : result:='Jazz+Funk';
30 : result:='Fusion';
31 : result:='Trance';
32 : result:='Classical';
33 : result:='Instrumental';
34 : result:='Acid';
35 : result:='House';
36 : result:='Game';
37 : result:='Sound Clip';
38 : result:='Gospel';
39 : result:='Noise';
40 : result:='AlternRock';
41 : result:='Bass';
42 : result:='Soul';
43 : result:='Punk';
44 : result:='Space';
45 : result:='Meditative';
46 : result:='Instrumental Pop';
47 : result:='Instrumental Rock';
48 : result:='Ethnic';
49 : result:='Gothic';
50 : result:='Darkwave';
51 : result:='Techno-Industrial';
52 : result:='Electronic';
53 : result:='Pop-Folk';
54 : result:='Eurodance';
55 : result:='Dream';
56 : result:='Southern Rock';
57 : result:='Comedy';
58 : result:='Cult';
59 : result:='Gangsta';
60 : result:='Top 40';
61 : result:='Christian Rap';
62 : result:='Pop/Funk';
63 : result:='Jungle';
64 : result:='Native American';
65 : result:='Cabaret';
66 : result:='New Wave';
67 : result:='Psychadelic';
68 : result:='Rave';
69 : result:='Showtunes';
70 : result:='Trailer';
71 : result:='Lo-Fi';
72 : result:='Tribal';
73 : result:='Acid Punk';
74 : result:='Acid Jazz';
75 : result:='Polka';
76 : result:='Retro';
77 : result:='Musical';
78 : result:='Rock & Roll';
79 : result:='Hard Rock';
80 : result:='Folk';
81 : result:='Folk-Rock';
82 : result:='National Folk';
83 : result:='Swing';
84 : result:='Fast Fusion';
85 : result:='Bebob';
86 : result:='Latin';
87 : result:='Revival';
88 : result:='Celtic';
89 : result:='Bluegrass';
90 : result:='Avantgarde';
91 : result:='Gothic Rock';
92 : result:='Progressive Rock';
93 : result:='Psychedelic Rock';
94 : result:='Symphonic Rock';
95 : result:='Slow Rock';
96 : result:='Big Band';
97 : result:='Chorus';
98 : result:='Easy Listening';
99 : result:='Acoustic';
100 : result:='Humour';
101 : result:='Speech';
102 : result:='Chanson';
103 : result:='Opera';
104 : result:='Chamber Music';
105 : result:='Sonata';
106 : result:='Symphony';
107 : result:='Booty Bass';
108 : result:='Primus';
109 : result:='Porn Groove';
110 : result:='Satire';
111 : result:='Slow Jam';
112 : result:='Club';
113 : result:='Tango';
114 : result:='Samba';
115 : result:='Folklore';
116 : result:='Ballad';
117 : result:='Power Ballad';
118 : result:='Rhythmic Soul';
119 : result:='Freestyle';
120 : result:='Duet';
121 : result:='Punk Rock';
122 : result:='Drum Solo';
123 : result:='A Capella';
124 : result:='Euro-House';
125 : result:='Dance Hall';
else result:='Other';
end;

end;

function GetIndexFromGenresTable(ID3v2Genre: string): byte;
// a little convertor between string and numerical values of genres
// MP3 is using both (strings are visible, but can numerical are also accepted and are auto-converted into strings)
// this function compares genre name with list of names

begin
if ID3v2Genre='Blues' then result:=0 else
if ID3v2Genre='Classic Rock' then result:=1 else
if ID3v2Genre='Country' then result:=2 else
if ID3v2Genre='Dance' then result:=3 else
if ID3v2Genre='Disco' then result:=4 else
if ID3v2Genre='Funk' then result:=5 else
if ID3v2Genre='Grunge' then result:=6 else
if ID3v2Genre='Hip-Hop' then result:=7 else
if ID3v2Genre='Jazz' then result:=8 else
if ID3v2Genre='Metal' then result:=9 else
if ID3v2Genre='New Age' then result:=10 else
if ID3v2Genre='Oldies' then result:=11 else
if ID3v2Genre='Other' then result:=12 else
if ID3v2Genre='Pop' then result:=13 else
if ID3v2Genre='R&B' then result:=14 else
if ID3v2Genre='Rap' then result:=15 else
if ID3v2Genre='Reggae' then result:=16 else
if ID3v2Genre='Rock' then result:=17 else
if ID3v2Genre='Techno' then result:=18 else
if ID3v2Genre='Industrial' then result:=19 else
if ID3v2Genre='Alternative' then result:=20 else
if ID3v2Genre='Ska' then result:=21 else
if ID3v2Genre='Death Metal' then result:=22 else
if ID3v2Genre='Pranks' then result:=23 else
if ID3v2Genre='Soundtrack' then result:=24 else
if ID3v2Genre='Euro-Techno' then result:=25 else
if ID3v2Genre='Ambient' then result:=26 else
if ID3v2Genre='Trip-Hop' then result:=27 else
if ID3v2Genre='Vocal' then result:=28 else
if ID3v2Genre='Jazz+Funk' then result:=29 else
if ID3v2Genre='Fusion' then result:=30 else
if ID3v2Genre='Trance' then result:=31 else
if ID3v2Genre='Classical' then result:=32 else
if ID3v2Genre='Instrumental' then result:=33 else
if ID3v2Genre='Acid' then result:=34 else
if ID3v2Genre='House' then result:=35 else
if ID3v2Genre='Game' then result:=36 else
if ID3v2Genre='Sound Clip' then result:=37 else
if ID3v2Genre='Gospel' then result:=38 else
if ID3v2Genre='Noise' then result:=39 else
if ID3v2Genre='AlternRock' then result:=40 else
if ID3v2Genre='Bass' then result:=41 else
if ID3v2Genre='Soul' then result:=42 else
if ID3v2Genre='Punk' then result:=43 else
if ID3v2Genre='Space' then result:=44 else
if ID3v2Genre='Meditative' then result:=45 else
if ID3v2Genre='Instrumental Pop' then result:=46 else
if ID3v2Genre='Instrumental Rock' then result:=47 else
if ID3v2Genre='Ethnic' then result:=48 else
if ID3v2Genre='Gothic' then result:=49 else
if ID3v2Genre='Darkwave' then result:=50 else
if ID3v2Genre='Techno-Industrial' then result:=51 else
if ID3v2Genre='Electronic' then result:=52 else
if ID3v2Genre='Pop-Folk' then result:=53 else
if ID3v2Genre='Eurodance' then result:=54 else
if ID3v2Genre='Dream' then result:=55 else
if ID3v2Genre='Southern Rock' then result:=56 else
if ID3v2Genre='Comedy' then result:=57 else
if ID3v2Genre='Cult' then result:=58 else
if ID3v2Genre='Gangsta' then result:=59 else
if ID3v2Genre='Top 40' then result:=60 else
if ID3v2Genre='Christian Rap' then result:=61 else
if ID3v2Genre='Pop/Funk' then result:=62 else
if ID3v2Genre='Jungle' then result:=63 else
if ID3v2Genre='Native American' then result:=64 else
if ID3v2Genre='Cabaret' then result:=65 else
if ID3v2Genre='New Wave' then result:=66 else
if ID3v2Genre='Psychadelic' then result:=67 else
if ID3v2Genre='Rave' then result:=68 else
if ID3v2Genre='Showtunes' then result:=69 else
if ID3v2Genre='Trailer' then result:=70 else
if ID3v2Genre='Lo-Fi' then result:=71 else
if ID3v2Genre='Tribal' then result:=72 else
if ID3v2Genre='Acid Punk' then result:=73 else
if ID3v2Genre='Acid Jazz' then result:=74 else
if ID3v2Genre='Polka' then result:=75 else
if ID3v2Genre='Retro' then result:=76 else
if ID3v2Genre='Musical' then result:=77 else
if ID3v2Genre='Rock & Roll' then result:=78 else
if ID3v2Genre='Hard Rock' then result:=79 else
if ID3v2Genre='Folk' then result:=80 else
if ID3v2Genre='Folk-Rock' then result:=81 else
if ID3v2Genre='National Folk' then result:=82 else
if ID3v2Genre='Swing' then result:=83 else
if ID3v2Genre='Fast Fusion' then result:=84 else
if ID3v2Genre='Bebob' then result:=85 else
if ID3v2Genre='Latin' then result:=86 else
if ID3v2Genre='Revival' then result:=87 else
if ID3v2Genre='Celtic' then result:=88 else
if ID3v2Genre='Bluegrass' then result:=89 else
if ID3v2Genre='Avantgarde' then result:=90 else
if ID3v2Genre='Gothic Rock' then result:=91 else
if ID3v2Genre='Progressive Rock' then result:=92 else
if ID3v2Genre='Psychedelic Rock' then result:=93 else
if ID3v2Genre='Symphonic Rock' then result:=94 else
if ID3v2Genre='Slow Rock' then result:=95 else
if ID3v2Genre='Big Band' then result:=96 else
if ID3v2Genre='Chorus' then result:=97 else
if ID3v2Genre='Easy Listening' then result:=98 else
if ID3v2Genre='Acoustic' then result:=99 else
if ID3v2Genre='Humour' then result:=100 else
if ID3v2Genre='Speech' then result:=101 else
if ID3v2Genre='Chanson' then result:=102 else
if ID3v2Genre='Opera' then result:=103 else
if ID3v2Genre='Chamber Music' then result:=104 else
if ID3v2Genre='Sonata' then result:=105 else
if ID3v2Genre='Symphony' then result:=106 else
if ID3v2Genre='Booty Bass' then result:=107 else
if ID3v2Genre='Primus' then result:=108 else
if ID3v2Genre='Porn Groove' then result:=109 else
if ID3v2Genre='Satire' then result:=110 else
if ID3v2Genre='Slow Jam' then result:=111 else
if ID3v2Genre='Club' then result:=112 else
if ID3v2Genre='Tango' then result:=113 else
if ID3v2Genre='Samba' then result:=114 else
if ID3v2Genre='Folklore' then result:=115 else
if ID3v2Genre='Ballad' then result:=116 else
if ID3v2Genre='Power Ballad' then result:=117 else
if ID3v2Genre='Rhythmic Soul' then result:=118 else
if ID3v2Genre='Freestyle' then result:=119 else
if ID3v2Genre='Duet' then result:=120 else
if ID3v2Genre='Punk Rock' then result:=121 else
if ID3v2Genre='Drum Solo' then result:=122 else
if ID3v2Genre='A Capella' then result:=123 else
if ID3v2Genre='Euro-House' then result:=124 else
if ID3v2Genre='Dance Hall' then result:=125 else result:=255; // nothing found

end;


// * OTHER UTILITIES *

end.
