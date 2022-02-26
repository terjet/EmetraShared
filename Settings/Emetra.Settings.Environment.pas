unit Emetra.Settings.Environment;

interface

uses
  Emetra.Settings.Interfaces;

type
  TEnvironmentSettings = class( TInterfacedObject, ISettingsRead, IContextSettingsRead )
  strict private
    function Merge( const AContext, AKey: string ): string;
  private
    { ISettingsRead }
    function Exists( const AKey: string ): boolean; overload;
    function ReadBool( const AKey: string; const ADefault: boolean = false ): boolean; overload;
    function ReadDate( const AKey: string; const ADefault: TDateTime ): TDateTime; overload;
    function ReadInteger( const AKey: string; const ADefault: Integer = 0 ): Integer; overload;
    function ReadFloat( const AKey: string; const ADefault: double = 0 ): double; overload;
    function ReadString( const AKey: string; const ADefault: string = '' ): string; overload;
    { IContextSettingsRead }
    function Exists( const AContext, AKey: string ): boolean; overload;
    function ReadBool( const AContext, AKey: string; const ADefault: boolean = false ): boolean; overload;
    function ReadDate( const AContext, AKey: string; const ADefault: TDateTime ): TDateTime; overload;
    function ReadInteger( const AContext, AKey: string; const ADefault: Integer = 0 ): Integer; overload;
    function ReadFloat( const AContext, AKey: string; const ADefault: double = 0 ): double; overload;
    function ReadString( const AContext, AKey: string; const ADefault: string = '' ): string; overload;
  end;

implementation

uses
  System.SysUtils, System.StrUtils;

{ TEnviromentSettings }

function TEnvironmentSettings.Exists( const AKey: string ): boolean;
begin
  Result := Trim( GetEnvironmentVariable( AKey ) ) <> EmptyStr;
end;

function TEnvironmentSettings.ReadBool( const AKey: string; const ADefault: boolean ): boolean;
begin
  if not Exists( AKey ) then
    Result := ADefault
  else
    Result := StrToBoolDef( GetEnvironmentVariable( AKey ), ADefault );
end;

function TEnvironmentSettings.ReadDate( const AKey: string; const ADefault: TDateTime ): TDateTime;
begin
  if not Exists( AKey ) then
    Result := ADefault
  else
    Result := StrToDateTimeDef( GetEnvironmentVariable( AKey ), ADefault );

end;

function TEnvironmentSettings.ReadFloat( const AKey: string; const ADefault: double ): double;
begin
  if not Exists( AKey ) then
    Result := ADefault
  else
    Result := StrToFloatDef( GetEnvironmentVariable( AKey ), ADefault );
end;

function TEnvironmentSettings.ReadInteger( const AKey: string; const ADefault: Integer ): Integer;
begin
  if not Exists( AKey ) then
    Result := ADefault
  else
    Result := StrToIntDef( GetEnvironmentVariable( AKey ), ADefault );
end;

function TEnvironmentSettings.ReadString( const AKey, ADefault: string ): string;
begin
  if Exists( AKey ) then
    Result := GetEnvironmentVariable( AKey )
  else
    Result := ADefault;
end;

function TEnvironmentSettings.Exists( const AContext, AKey: string ): boolean;
begin
  Result := Exists( Merge( AContext, AKey ) );
end;

function TEnvironmentSettings.Merge( const AContext, AKey: string ): string;
begin
  Result := Format( '%s.%s', [AContext, AKey] );
end;

function TEnvironmentSettings.ReadBool( const AContext, AKey: string; const ADefault: boolean ): boolean;
begin
  Result := ReadBool( Merge( AContext, AKey ), ADefault );
end;

function TEnvironmentSettings.ReadDate( const AContext, AKey: string; const ADefault: TDateTime ): TDateTime;
begin
  Result := ReadDate( Merge( AContext, AKey ), ADefault );
end;

function TEnvironmentSettings.ReadFloat( const AContext, AKey: string; const ADefault: double ): double;
begin
  Result := ReadFloat( Merge( AContext, AKey ), ADefault );
end;

function TEnvironmentSettings.ReadInteger( const AContext, AKey: string; const ADefault: Integer ): Integer;
begin
  Result := ReadInteger( Merge( AContext, AKey ), ADefault );
end;

function TEnvironmentSettings.ReadString( const AContext, AKey, ADefault: string ): string;
begin
  if Exists( AContext, AKey ) then
    Result := GetEnvironmentVariable( Merge( AContext, AKey ) )
  else
    Result := ADefault;
end;

end.
