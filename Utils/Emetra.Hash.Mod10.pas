///<summary>
/// An implementation of the Luhn Algorithm, also called Mod10.  See https://en.wikipedia.org/wiki/Luhn_algorithm.
///</summary>
unit Emetra.Hash.Mod10;

interface

function Mod10( const AValue: string ): Integer;

implementation

uses
  System.SysUtils;

function Mod10( const AValue: string ): Integer;
var
  i, intOdd, intEven: Integer;
begin
  { add all odd seq numbers }
  intOdd := 0;
  i := 1;
  while ( i <= Length( AValue ) ) do
  begin
    Inc( intOdd, StrToIntDef( AValue[i], 0 ) );
    Inc( i, 2 );
  end;

  { add all even seq numbers }
  intEven := 0;
  i := 2;
  while ( i <= Length( AValue ) ) do
  begin
    Inc( intEven, StrToIntDef( AValue[i], 0 ) );
    Inc( i, 2 );
  end;

  Result := 3 * intOdd + intEven;
  { modulus by 10 to get }
  Result := Result mod 10;
  if Result <> 0 then
    Result := 10 - Result
end;

end.
