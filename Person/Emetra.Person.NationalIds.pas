unit Emetra.Person.NationalIds;

interface

uses
  System.SysUtils;

type
  EInvalidNationalId = Exception;

  TNorwegianNationalId = class
  public
    class var RetryCount: integer;
    class function Generate( ): string; overload;
    class function Generate( const ADOB: TDateTime; const AGenderId: integer; ASeed: integer = 0 ): string; overload;
    class function GenderId( const s: string ): integer;
    class function MaskLastFive( const s: string ): string;
    class function Parse( const s: string; out ADOB: TDateTime; out AGenderId, ANumber: integer ): boolean;
    class function Valid( const s: string ): boolean; overload;
    class function PossibleDNumber( const s: string ): boolean;
    class function PossibleHNumber( const s: string ): boolean;
    class function PossibleFHNumber( const s: string ): boolean;
    class function Valid( const ADOB: TDateTime; const ANumber: variant; out ANumberAsInt, ASex: integer ): boolean; overload;
    class function StableIdentifier( const s: string ): boolean;
  end;

const

  { GenderId constants, see also Emetra.Person.Interfaces.pas }
  GENDER_UNKNOWN = 0;
  GENDER_MALE    = 1;
  GENDER_FEMALE  = 2;

  { Default number of retries when generating NationalIds }
  DEFAULT_RETRIES = 5;

implementation

uses
  System.DateUtils, System.Variants, System.Math;

const
  WEIGHT1: array [1 .. 11] of integer = ( 3, 7, 6, 1, 8, 9, 4, 5, 2, 1, 0 );
  WEIGHT2: array [1 .. 11] of integer = ( 5, 4, 3, 2, 7, 6, 5, 4, 3, 2, 1 );

class function TNorwegianNationalId.GenderId( const s: string ): integer;
begin
  if not Valid( s ) then
    Result := 0
  else
    Result := 2 - StrToInt( s[9] ) mod 2;
end;

class function TNorwegianNationalId.Generate( const ADOB: TDateTime; const AGenderId: integer; ASeed: integer = 0 ): string;
var
  firstSix: string;
  nextThree: integer;
  retryCounter: integer;
  d1, d2, m1, m2, y1, y2, i1, i2, i3, k1, k2: integer;
begin
  Result := EmptyStr;
  retryCounter := -1;

  { Create DOB variables }
  firstSix := FormatDateTime( 'ddmmyy', ADOB );
  d1 := StrToInt( firstSix[1] );
  d2 := StrToInt( firstSix[2] );
  m1 := StrToInt( firstSix[3] );
  m2 := StrToInt( firstSix[4] );
  y1 := StrToInt( firstSix[5] );
  y2 := StrToInt( firstSix[6] );

  repeat
    if ASeed = 0 then
    begin
      { Generate numbers randomly, but observe certain rules for centuries }
      if InRange( YearOf( ADOB ), 1854, 1899 ) then
        nextThree := 500 + Random( 250 )
      else if InRange( YearOf( ADOB ), 2000, 2039 ) then
        nextThree := 500 + Random( 500 )
      else
        nextThree := Random( 500 );
      { Observe even/odd rule for gender by adding one if not matching already }
      if ( nextThree mod 2 ) <> ( AGenderId mod 2 ) then
        inc( nextThree );
    end
    else
    begin
      { Use seed to create a predictable number }
      ASeed := ASeed mod 250;
      nextThree := 2 * ASeed + AGenderId;
      { Mimic certain rules for centuries }
      if ( ( YearOf( ADOB ) div 100 ) mod 2 = 0 ) then
        nextThree := nextThree + 500;
    end;

    i1 := nextThree div 100;
    i2 := nextThree mod 100 div 10;
    i3 := nextThree mod 10;

    { Generate k1 and k2 based on weights, see also WEIGHT1 and WEIGHT2 above }

    k1 := 11 - ( ( 3 * d1 + 7 * d2 + 6 * m1 + 1 * m2 + 8 * y1 + 9 * y2 + 4 * i1 + 5 * i2 + 2 * i3 ) mod 11 );
    k2 := 11 - ( ( 5 * d1 + 4 * d2 + 3 * m1 + 2 * m2 + 7 * y1 + 6 * y2 + 5 * i1 + 4 * i2 + 3 * i3 + 2 * k1 ) mod 11 );

    { The numbers k1 and/or k2 may be 10 or 11, in which case the number created here will not be valid }
    Result := firstSix + Format( '%.3d', [nextThree] ) + Format( '%d%d', [k1 mod 10, k2 mod 10] );

    { We may have to retry several times to get a valid number }
    inc( retryCounter );

  until Valid( Result ) or ( retryCounter >= RetryCount );

end;

class function TNorwegianNationalId.MaskLastFive( const s: string ): string;
begin
  Result := s.Substring( 0, 6 ) + '00000';
end;

class function TNorwegianNationalId.Generate( ): string;
begin
  Result := Generate( Now - Random( 365 * 110 ), 1 + Random( 2 ) );
end;

class function TNorwegianNationalId.Valid( const s: string ): boolean;
var
  i, n: integer;
  iCheck1, iCheck2: integer;
begin
  Result := false;
  if Length( s ) <> 11 then
    exit;
  try
    iCheck1 := 0;
    iCheck2 := 0;
    for i := 1 to 11 do
    begin
      n := StrToIntDef( s[i], -1 );
      if n = -1 then
        exit;
      iCheck1 := iCheck1 + n * WEIGHT1[i];
      iCheck2 := iCheck2 + n * WEIGHT2[i];
    end;
    Result := ( iCheck1 mod 11 = 0 ) and ( iCheck2 mod 11 = 0 );
  except
    on Exception do
  end;
end;

class function TNorwegianNationalId.Valid( const ADOB: TDateTime; const ANumber: variant; out ANumberAsInt, ASex: integer ): boolean;
var
  strNum: string;
begin
  Result := false;
  try
    ANumberAsInt := 0;
    ASex := 0;
    strNum := FormatDateTime( 'ddmmyy', ADOB ) + Trim( VarToStr( ANumber ) );
    if Valid( strNum ) then
    begin
      ASex := GenderId( strNum );
      ANumberAsInt := StrToInt( Copy( strNum, 7, 5 ) );
      Result := true;
    end;
  except
    on Exception do
      Result := false;
  end;
end;

class function TNorwegianNationalId.Parse( const s: string; out ADOB: TDateTime; out AGenderId, ANumber: integer ): boolean;
var
  iYear, iMonth, iDate, iCentury: integer;
begin
  Result := Valid( s );
  if Result then
    try
      iYear := StrToInt( Copy( s, 5, 2 ) );
      iMonth := StrToInt( Copy( s, 3, 2 ) );
      iDate := StrToInt( Copy( s, 1, 2 ) );
      { Allow D-number }
      if iDate > 40 then
        iDate := iDate - 40;
      { Allow H-number }
      if iMonth > 40 then
        iMonth := iMonth - 40;
      iCentury := StrToInt( Copy( s, 7, 1 ) ) div 5;
      if InRange( iYear, 40, 99 ) and ( iCentury = 1 ) then
        iCentury := 0;
      AGenderId := 2 - StrToInt( Copy( s, 9, 1 ) ) mod 2;
      ADOB := EncodeDate( iYear + 1900 + iCentury * 100, iMonth, iDate );
      ANumber := StrToInt( Copy( s, 7, 5 ) );
    except
      on Exception do
        Result := false;
    end;
end;

class function TNorwegianNationalId.PossibleDNumber( const s: string ): boolean;
begin
  Result := ( Length( s ) = 11 ) and CharInSet( s[1], ['4', '5', '6', '7'] );
end;

class function TNorwegianNationalId.PossibleHNumber( const s: string ): boolean;
begin
  Result := ( Length( s ) = 11 ) and CharInSet( s[3], ['4', '5'] );
end;

class function TNorwegianNationalId.StableIdentifier( const s: string ): boolean;
begin
  Result := Valid( s ) and not( PossibleFHNumber( s ) or PossibleHNumber( s ) );
end;

class function TNorwegianNationalId.PossibleFHNumber( const s: string ): boolean;
begin
  Result := ( Length( s ) = 11 ) and CharInSet( s[1], ['8', '9'] );
end;

initialization

TNorwegianNationalId.RetryCount := DEFAULT_RETRIES;

end.
