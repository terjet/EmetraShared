unit TestCaseNationalIdsPerson;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework, Emetra.Person.NationalIds, System.SysUtils;

type
  // Test methods for class TNorwegianNationalId

  TestTNorwegianNationalId = class( TTestCase )
  published
    procedure TestGenerateUnconstrained;
    procedure TestGenerateConstrained;
    procedure TestGenderId;
    procedure TestParse;
    procedure TestValid;
    procedure TestPossibleDNumber;
  end;

implementation

const
  { H-Numbers }
  H_NUMBER1         = '20517836533';
  H_NUMBER1_INVALID = '20517836532';
  H_NUMBER2         = '01411077663';
  { F-Numbers }
  F_NUMBER         = '15076500565';
  F_NUMBER_INVALID = '15076500564';

procedure TestTNorwegianNationalId.TestGenerateUnconstrained;
var
  i: integer;
begin
  for i := 1 to 100 do
    CheckTrue( TNorwegianNationalId.Valid( TNorwegianNationalId.Generate ), Format( 'Unconstrained generate failed on #%d.', [i] ) );
end;

procedure TestTNorwegianNationalId.TestGenerateConstrained;
const
  LOG_FAILED = 'Constrained generate failed on #%d.';
var
  i: integer;
  ASeed: integer;
  AGenderId: integer;
  ADOB: TDateTime;
  generatedNumber: string;
begin
  for i := 1 to 50 do
  begin
    AGenderId := Random( 100 ) mod 2 + 1;
    ADOB := 5 + Random( trunc( Now ) - 10 );
    generatedNumber := TNorwegianNationalId.Generate( ADOB, AGenderId, ASeed );
    CheckTrue( TNorwegianNationalId.Valid( generatedNumber ), Format( LOG_FAILED, [i] ) );
    CheckEquals( AGenderId, TNorwegianNationalId.GenderId( generatedNumber ), Format( LOG_FAILED, [i] ) );
  end;
end;

procedure TestTNorwegianNationalId.TestGenderId;
begin
  CheckEquals( 1, TNorwegianNationalId.GenderId( H_NUMBER1 ) );
  CheckEquals( 2, TNorwegianNationalId.GenderId( H_NUMBER2 ) );
  CheckEquals( 1, TNorwegianNationalId.GenderId( F_NUMBER ) );
end;

procedure TestTNorwegianNationalId.TestParse;
var
  number: integer;
  GenderId: integer;
  dob: TDateTime;
begin
  CheckTrue( TNorwegianNationalId.Parse( H_NUMBER1, dob, GenderId, number ) );
  CheckEquals( EncodeDate( 1978, 11, 20 ), dob, 'Unexpected DOB for ' + H_NUMBER1 );
  CheckTrue( TNorwegianNationalId.Parse( F_NUMBER, dob, GenderId, number ) );
  CheckEquals( EncodeDate( 1965, 7, 15 ), dob, 'Unexpected DOB for ' + F_NUMBER );
end;

procedure TestTNorwegianNationalId.TestValid;
begin
  CheckTrue( TNorwegianNationalId.Valid( H_NUMBER1 ), 'Expected H-number to be valid.' );
  CheckFalse( TNorwegianNationalId.Valid( H_NUMBER1_INVALID ), 'Expected this H-number to be invalid.' );
  CheckTrue( TNorwegianNationalId.Valid( H_NUMBER2 ), 'Expected H-number to be valid.' );
  CheckTrue( TNorwegianNationalId.Valid( F_NUMBER ), 'Expected F-number to be valid.' );
  CheckFalse( TNorwegianNationalId.Valid( F_NUMBER_INVALID ), 'Expected F-number to be invalid.' );
end;

procedure TestTNorwegianNationalId.TestPossibleDNumber;
begin
  CheckFalse( TNorwegianNationalId.PossibleDNumber( H_NUMBER1 ) );
  CheckTrue( TNorwegianNationalId.PossibleHNumber( H_NUMBER1 ) );
  CheckFalse( TNorwegianNationalId.PossibleDNumber( F_NUMBER ) );
  CheckFalse( TNorwegianNationalId.PossibleHNumber( F_NUMBER ) );
end;

initialization

// Register any test cases with the test runner
RegisterTest( TestTNorwegianNationalId.Suite );

end.
