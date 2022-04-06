unit Emetra.Hash.Crypt;
{$R-}

interface

type
  THash = class( TObject )
  public
    class function Encrypt( const s: string ): string;
    class function TryDecrypt( const s: string; out AResult: string ): boolean;
    class function Decrypt( const s: string ): string;
  end;

implementation

uses
  Emetra.EncdDecd, System.SysUtils;

const
  c1          = 52845;
  c2          = 22719;
  TEST_STRING = ':*¶¿ùx6êËWö^D©23dô®aeC3!Äªa;;M8ß*CðRï#Öz³Ûü4l=]ÊÞÏÏ;Õë×¾¶ÔïØkø°î`ÎÓB©Äû{ñ1©{y6FS';

function Base64Decode( s: string ): string;
begin
  Result := DecodeString( s );
end;

function Base64Encode( s: string ): string;
begin
  Result := EncodeString( s );
end;

function HashStr( const s: string; Key: Word ): string;
var
  i: byte;
  ansiInput: AnsiString;
  ansiResult: AnsiString;
begin
  ansiInput := AnsiString( s );
  ansiResult := ansiInput;
  for i := 1 to Length( s ) do
  begin
    ansiResult[i] := AnsiChar( byte( ansiInput[i] ) xor ( Key shr 8 ) );
    Key := ( byte( ansiResult[i] ) + Key ) * c1 + c2
  end;
  Result := string( ansiResult );
end;

function UnhashStr( const s: string; Key: Word ): string;
var
  i: byte;
  ansiInput: AnsiString;
  ansiResult: AnsiString;
begin
  ansiInput := AnsiString( s );
  ansiResult := ansiInput;
  for i := 1 to Length( ansiInput ) do
  begin
    ansiResult[i] := AnsiChar( byte( ansiInput[i] ) xor ( Key shr 8 ) );
    Key := ( byte( ansiInput[i] ) + Key ) * c1 + c2
  end;
  Result := string( ansiResult );
end;

class function THash.Encrypt( const s: string ): string;
var
  Key: Word;
begin
  if Length( s ) < 1 then
    Result := s
  else
  begin
    Randomize;
    Key := Random( 255 );
    Result := Format( '%.2x', [Key] ) + Base64Encode( HashStr( s, Key ) );
  end;
end;

class function THash.TryDecrypt( const s: string; out AResult: string ): boolean;
var
  Key: Word;
begin
  Result := true;
  if Length( s ) < 2 then
    AResult := s
  else
    try
      Key := StrToInt( '$' + string( Copy( s, 1, 2 ) ) );
      AResult := UnhashStr( Base64Decode( Copy( s, 3, maxint ) ), Key );
    except
      on E: Exception do
      begin
        AResult := E.Message;
        Result := false;
      end;
    end;
end;

class function THash.Decrypt( const s: string ): string;
var
  Key: Word;
begin
  if Length( s ) < 2 then
    Result := s
  else
  begin
    Key := StrToInt( '$' + string( Copy( s, 1, 2 ) ) );
    Result := UnhashStr( Base64Decode( Copy( s, 3, maxint ) ), Key );
  end;
end;

procedure SelfTest;
var
  encodedString: string;
  decodedString: string;
  i: integer;
begin
  encodedString := Base64Encode( TEST_STRING );
  decodedString := Base64Decode( encodedString );
  Assert( decodedString = TEST_STRING, decodedString + ' <> ' + TEST_STRING );
  for i := 64 to 127 do
  begin
    Assert( HashStr( UnhashStr( TEST_STRING, i ), i ) = TEST_STRING );
    Assert( UnhashStr( HashStr( TEST_STRING, i ), i ) = TEST_STRING );
    Assert( THash.TryDecrypt( THash.Encrypt( TEST_STRING ), decodedString ) );
    Assert( TEST_STRING = decodedString );
  end;
end;

initialization

SelfTest;

end.
