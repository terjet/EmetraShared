unit Emetra.Utils.FileSearch;

{$HINTS OFF}

interface

uses
  Classes;

type
  TFileList = class(TStringList)
  public
    procedure Populate(const APathName, AFileMask: string; const AIncludeSubdirs: boolean );
    class procedure SetFileDate( const AFileName: string; const ADate: TDateTime );
    function ContainsFileName( const AFileNameWithoutPath: string ): boolean;
  end;

implementation

uses
  SysUtils;

class procedure TFileList.SetFileDate ( const AFileName: string; const ADate: TDateTime );
begin
  SysUtils.FileSetDate ( AFileName, DateTimeToFileDate (ADate ) );
end;

function TFileList.ContainsFileName(const AFileNameWithoutPath: string): boolean;
var
  n: integer;
begin
  Result := false;
  n := 0;
  while n < Count do
  begin
    Result := SameText( AFileNameWithoutPath, ExtractFileName( Self[n] ) );
    if Result then
      break
    else
      inc( n );
  end;
end;

procedure TFileList.Populate(const APathName, AFileMask: string; const AIncludeSubdirs: boolean );
var
  Rec: TSearchRec;
  Path: string;
begin
  Path := IncludeTrailingPathDelimiter(APathName);
  if FindFirst(Path + AFileMask, faAnyFile - faDirectory, Rec) = 0 then
    try
      repeat
        Add(Path + Rec.Name);
      until FindNext(Rec) <> 0;
    finally
      FindClose(Rec);
    end;

  If not AIncludeSubdirs then
    Exit;

  if FindFirst(Path + '*.*', faDirectory, Rec) = 0 then
    try
      repeat
        if ((Rec.Attr and faDirectory) <> 0) and (Rec.Name <> '.') and (Rec.Name <> '..') then
          Populate(Path + Rec.Name, AFileMask, True);
      until FindNext(Rec) <> 0;
    finally
      FindClose(Rec);
    end;
end;

end.
