﻿unit TestCaseMathParser;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework,
  Bitsoft.MathParser,
  Bitsoft.MathParser.StdFunctions,
  {General classes, utilities}
  Emetra.Logging.Interfaces,
  {Standard}
  System.SysUtils, System.Math;

type
  // Test methods for class TMathParser

  TestTMathParser = class( TTestCase )
  strict private
    fMathParser: TMathParser;
  public
    procedure HandleGetVar( Sender: TObject; AVarName: string; var Value: Extended; var Found: Boolean );
    procedure HandleParseError( Sender: TMathParser; const AParseError: Integer );
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestInvalidInput;
    procedure TestIsNull;
    procedure TestSignum;
    procedure TestUnknownVariables;
    procedure TestYeafOf;
  end;

implementation

uses
  System.DateUtils;

const
  TXT_SHOULD_BE_ONE       = 'The expression shold evaluate to 1.';
  TXT_SHOULD_BE_ZERO      = 'The expression should evaluate to 0.';
  TXT_SHOULD_BE_MINUS_ONE = 'The expression should evaluate to -1.';
  TXT_SHOULD_BE_INTEGER   = 'The expression should evaluate to %d.';

procedure TestTMathParser.HandleGetVar( Sender: TObject; AVarName: string; var Value: Extended; var Found: Boolean );
begin
  GlobalLog.Event( 'Asked for %s', [AVarName] );
  Value := 1;
  Found := true;
end;

procedure TestTMathParser.HandleParseError( Sender: TMathParser; const AParseError: Integer );
begin
  GlobalLog.SilentWarning( Format( 'Error=%d %s', [AParseError, Sender.LogText] ) );
end;

procedure TestTMathParser.SetUp;
begin
  fMathParser := TMathParser.Create;
  fMathParser.OnGetVar := Self.HandleGetVar;
  fMathParser.OnParseError := Self.HandleParseError;
end;

procedure TestTMathParser.TearDown;
begin
  fMathParser.Free;
end;

procedure TestTMathParser.TestInvalidInput;
begin
  try
    fMathParser.ParseString := 'THIS IS #ONE TEST';
    fMathParser.Parse;
    CheckEquals( true, false, 'This code should never be reached' );
  except
    on Exception do
      CheckEquals( true, true, 'But this code should always be reached' );
  end;
end;

procedure TestTMathParser.TestIsNull;
begin
  fMathParser.ParseString := 'ISNULL(0)';
  CheckEquals( 1, fMathParser.Parse, TXT_SHOULD_BE_ONE );
  fMathParser.ParseString := 'ISNULL(1)';
  CheckEquals( 0, fMathParser.Parse, TXT_SHOULD_BE_ZERO );
  fMathParser.ParseString := 'ISNULL(-1)';
  CheckEquals( 0, fMathParser.Parse, TXT_SHOULD_BE_ZERO );
end;

procedure TestTMathParser.TestSignum;
begin
  fMathParser.ParseString := 'SIGN(2)';
  CheckEquals( 1, fMathParser.Parse, TXT_SHOULD_BE_ONE );
  fMathParser.ParseString := 'SIGN(-1)';
  CheckEquals( -1, fMathParser.Parse, TXT_SHOULD_BE_MINUS_ONE );
  fMathParser.ParseString := 'SIGN(0)';
  CheckEquals( 0, fMathParser.Parse, TXT_SHOULD_BE_ZERO );
end;

procedure TestTMathParser.TestUnknownVariables;
const
  TEST_EXPR =
  { } '(0.5*(ISNULL(MNA_K1-1) + ' + sLineBreak +
  { } 'ISNULL(MNA_K2-1) + ' + sLineBreak +
  { } 'ISNULL(MNA_K3-1))-0.5) * (1-ISNEG(( ISNULL( MNA_K1-1 ) + ' + sLineBreak +
  { } 'ISNULL(MNA_K2-1) + ISNULL(MNA_K3-1))-0.5))';

begin
  fMathParser.ParseString := TEST_EXPR;
  CheckEquals( 1, fMathParser.Parse, TXT_SHOULD_BE_ONE );
end;

procedure TestTMathParser.TestYeafOf;
begin
  fMathParser.ParseString := 'YEAROF(NOW)';
  CheckEquals( YearOf( Now ), fMathParser.Parse, Format( TXT_SHOULD_BE_INTEGER, [YearOf( Now )] ) );
end;

initialization

// Register any test cases with the test runner
RegisterTest( TestTMathParser.Suite );

end.
