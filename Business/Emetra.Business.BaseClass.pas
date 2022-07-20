unit Emetra.Business.BaseClass;

interface

uses
  {General interfaces}
  Emetra.Logging.Interfaces,
  {Standard}
  System.Classes, System.Generics.Collections;

type
  /// <summary>
  /// Business objects are lightweight objects that can be used as base classes
  /// for more complex objects that contain business logic. Typically they
  /// are not used for smaller data objects with limited scope. Data objects may not
  /// need a logger, and they usually don't need to implement interfaces. More
  /// complex data objects like <b>TPatient</b> in an EHR application may
  /// need both of these. Because TCustomBusiness inherits from <b>TInterfacedPersistent</b> (a
  /// standard RTL class) it is not reference counted and must be freed when
  /// it is no longer used. If it it is added to a <b>TBusinessObjectCatalog</b>,
  /// the lifetime and destruction is handled by the catalog.
  /// </summary>
  /// <remarks>
  /// All TCustomBusiness descendants need to have a logger injected upon
  /// construction.
  /// </remarks>
  /// <seealso cref="TBusinessObjectCatalog" />
  TCustomBusiness = class( TInterfacedPersistent )
  strict private
    fLog: ILog;
  protected
    procedure CheckAssigned( const AInterface: IInterface; const ANameOfInterface: string );
    procedure EnterMethod( const AProcName: string );
    procedure LeaveMethod( const AProcName: string );
    procedure VerifyConstructorParameters; dynamic;
  public
    { Initialization }
    constructor Create( const ALog: ILog ); reintroduce;
    { Properties }
    property Log: ILog read fLog;
  end;

{$TYPEINFO ON}

  /// <summary>
  /// This a reference counted version of TCustomBusiness.  It allows a descending class
  /// to check that it doesn't introduce visible members, which is an antipottern for reference
  /// counted objects in Delphi.
  /// </summary>
  /// <remarks>
  /// All TCustomBusinessReferenceCounted descendants need to have a logger injected upon
  /// construction.
  /// </remarks>
  /// <seealso cref="TCustomBusiness" />
  TCustomBusinessReferenceCounted = class( TInterfacedObject )
  strict private
    fLog: ILog;
  protected
    function MethodAllowed( const AMethodName: string ): boolean;
    procedure CheckAssigned( const AInterface: IInterface; const ANameOfInterface: string );
    procedure EnterMethod( const AProcName: string );
    procedure LeaveMethod( const AProcName: string );
    procedure VerifyConstructorParameters; dynamic;
    procedure VerifyVisibility( const ATypeInfo: Pointer );
    { Properties }
    property Log: ILog read fLog;
  public
    { Initialization }
    constructor Create( const ALog: ILog ); reintroduce;
    procedure BeforeDestruction; override;
  end;

implementation

uses
  System.SysUtils, System.Rtti, System.TypInfo;

var
  BaseMethods: TStringList;
  ctx: TRttiContext;

constructor TCustomBusiness.Create( const ALog: ILog );
begin
  inherited Create;
  fLog := ALog;
end;

procedure TCustomBusiness.EnterMethod( const AProcName: string );
begin
  fLog.EnterMethod( Self, AProcName );
end;

procedure TCustomBusiness.LeaveMethod( const AProcName: string );
begin
  fLog.LeaveMethod( Self, AProcName );
end;

procedure TCustomBusiness.VerifyConstructorParameters;
begin
  CheckAssigned( fLog, 'Log' );
end;

procedure TCustomBusiness.CheckAssigned( const AInterface: IInterface; const ANameOfInterface: string );
const
  PROC_NAME = 'CheckAssigned';
  ERR_MSG   = LOG_STUB_STRING + 'The interface is not assigned.';
var
  errorMessage: string;
begin
  if not Assigned( AInterface ) then
  begin
    errorMessage := Format( ERR_MSG, [ClassName, PROC_NAME, ANameOfInterface] );
    if Assigned( fLog ) then
      fLog.SilentError( errorMessage )
    else if Assigned( GlobalLog ) then
      GlobalLog.SilentError( errorMessage );
    raise EArgumentNilException.Create( errorMessage );
  end;
end;

{$ENDREGION}
{ TCustomBusinessReferenceCounted }

constructor TCustomBusinessReferenceCounted.Create( const ALog: ILog );
begin
  inherited Create;
  fLog := ALog;
end;

procedure TCustomBusinessReferenceCounted.EnterMethod( const AProcName: string );
begin
  fLog.EnterMethod( Self, AProcName );
end;

procedure TCustomBusinessReferenceCounted.LeaveMethod( const AProcName: string );
begin
  fLog.LeaveMethod( Self, AProcName );
end;

function TCustomBusinessReferenceCounted.MethodAllowed( const AMethodName: string ): boolean;
var
  foundAt: Integer;
begin
  Result := BaseMethods.Find( AMethodName, foundAt );
end;

procedure TCustomBusinessReferenceCounted.VerifyConstructorParameters;
begin
  CheckAssigned( fLog, 'Log' );
end;

procedure TCustomBusinessReferenceCounted.VerifyVisibility( const ATypeInfo: Pointer );
var
  baseTypeInfo: Pointer;
  ctx: TRttiContext;
  ourType: TRttiType;
  baseType: TRttiType;
  ourProperty: TRttiProperty;
  ourMethod: TRttiMethod;
begin
  { Get basic info }
  baseTypeInfo := TypeInfo( TCustomBusinessReferenceCounted );
  baseType := ctx.GetType( baseTypeInfo );
  { Get info for this type }
  ourType := ctx.GetType( ATypeInfo );
  { Check that now new methods are added }
  for ourMethod in ourType.GetMethods do
  begin
    if ( baseType.MethodAddress( ourMethod.Name ) = nil ) and ( not MethodAllowed( ourMethod.Name ) ) then
    begin
      if ourMethod.Visibility > mvProtected then
        Log.Event( '%s.%s: Visibility is too high for this method.', [ClassName, ourMethod.Name], ltError )
      else
        Log.SilentSuccess( '%s.%s: Visibility OK for this method.', [ClassName, ourMethod.Name] );
    end
    else
      Log.Event( '%s.%s: Method found in base class or in list of allowed methods.', [ClassName, ourMethod.Name], ltDebug );
  end;

  for ourProperty in ourType.GetProperties do
  begin
    if baseType.GetProperty( ourProperty.Name ) = nil then
    begin
      if ourProperty.Visibility > mvProtected then
        Log.Event( '%s.%s: Visibility too high', [ClassName, ourProperty.Name], ltError )
      else
        Log.SilentSuccess( '%s.%s: Visibility OK for this property.', [ClassName, ourProperty.Name] );
    end
    else
      Log.Event( '%s.%s: Property found in base class or in list of allowed properties.', [ClassName, ourProperty.Name], ltDebug );
  end;
end;

procedure TCustomBusinessReferenceCounted.BeforeDestruction;
begin
  Log.Event( '%s.BeforeDestruction(): Called.', [ClassName] );
  inherited;
end;

procedure TCustomBusinessReferenceCounted.CheckAssigned( const AInterface: IInterface; const ANameOfInterface: string );
const
  PROC_NAME = 'CheckAssigned';
  ERR_MSG   = LOG_STUB_STRING + 'The interface is not assigned.';
var
  errorMessage: string;
begin
  if not Assigned( AInterface ) then
  begin
    errorMessage := Format( ERR_MSG, [ClassName, PROC_NAME, ANameOfInterface] );
    if Assigned( fLog ) then
      fLog.SilentError( errorMessage )
    else if Assigned( GlobalLog ) then
      GlobalLog.SilentError( errorMessage );
    raise EArgumentNilException.Create( errorMessage );
  end;
end;

initialization

BaseMethods := TStringList.Create( TDuplicates.dupError, true, false );
with BaseMethods do
begin
  { These are the methods that are found in TInterfacedObject }
  Add( 'AfterConstruction' );
  Add( 'BeforeDestruction' );
  Add( 'ClassInfo' );
  Add( 'ClassName' );
  Add( 'ClassNameIs' );
  Add( 'ClassParent' );
  Add( 'ClassType' );
  Add( 'CleanupInstance' );
  Add( 'Create' );
  Add( 'DefaultHandler' );
  Add( 'Destroy' );
  Add( 'Dispatch' );
  Add( 'DisposeOf' );
  Add( 'Equals' );
  Add( 'FieldAddress' );
  Add( 'Free' );
  Add( 'FreeInstance' );
  Add( 'GetHashCode' );
  Add( 'GetInterface' );
  Add( 'GetInterfaceEntry' );
  Add( 'GetInterfaceTable' );
  Add( 'InheritsFrom' );
  Add( 'InitInstance' );
  Add( 'InstanceSize' );
  Add( 'MethodAddress' );
  Add( 'MethodName' );
  Add( 'NewInstance' );
  Add( 'QualifiedClassName' );
  Add( 'SafeCallException' );
  Add( 'ToString' );
  Add( 'UnitName' );
  Add( 'UnitScope' );
end;

ctx := TRttiContext.Create;

finalization

ctx.Free;

end.
