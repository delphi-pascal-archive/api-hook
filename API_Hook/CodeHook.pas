unit CodeHook;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils;

function Initialize(LibraryName: WideString): DWORD;
function HookFunction(ModuleName: WideString; FunctionName: WideString; var FunctionAddress: PVOID; NewFunctionAddress: PVOID): DWORD;
function UnHookFunction(FunctionAddress: PVOID): DWORD;
function IsFunctionHooked(FunctionAddress: PVOID): DWORD;

implementation

type
  THookFunction = function(var OriginalFunction: PVOID; NewFunction: PVOID): UINT; cdecl;
  TUnHookFunction = function(var OriginalFunction: PVOID): UINT; cdecl;
  TIsFunctionHooked = function(var OriginalFunction: PVOID): UINT; cdecl;

var
  CodeHookLibrary: HMODULE = 0;
  _HookFunction: THookFunction = nil;
  _UnHookFunction: TUnHookFunction = nil;
  _IsFunctionHooked: TIsFunctionHooked = nil;

function HookFunction(ModuleName: WideString; FunctionName: WideString; var FunctionAddress: PVOID; NewFunctionAddress: PVOID): DWORD;
var
  ModuleHandle: HMODULE;
begin
  ModuleHandle := 0;
  ModuleHandle := GetModuleHandleW(PWideChar(ModuleName));
  if ModuleHandle = 0 then
  begin
    Result := ERROR_MOD_NOT_FOUND;
    Exit;
  end;
  FunctionAddress := nil;
  FunctionAddress := GetProcAddress(ModuleHandle, PWideChar(FunctionName));
  if FunctionAddress = nil then
  begin
    Result := ERROR_PROC_NOT_FOUND;
    Exit;
  end;
  Result := _HookFunction(FunctionAddress, NewFunctionAddress);
end;

function UnHookFunction(FunctionAddress: PVOID): DWORD;
begin
  if IsFunctionHooked(FunctionAddress) = ERROR_SUCCESS then
    Result := _UnHookFunction(FunctionAddress);
end;

function IsFunctionHooked(FunctionAddress: PVOID): DWORD;
begin
  Result := _IsFunctionHooked(FunctionAddress);
end;

function Initialize(LibraryName: WideString): DWORD;
begin
  CodeHookLibrary := 0;
  CodeHookLibrary := LoadLibraryW(PWideChar(LibraryName));
  if CodeHookLibrary = 0 then
  begin
    Result := GetLastError;
  end
  else
  begin
    @_HookFunction := GetProcAddress(CodeHookLibrary, 'HookFunction');
    @_UnHookFunction := GetProcAddress(CodeHookLibrary, 'UnHookFunction');
    @_IsFunctionHooked := GetProcAddress(CodeHookLibrary, 'IsFunctionHooked');
    if (@_HookFunction <> nil) and (@_UnHookFunction <> nil) and (@_IsFunctionHooked <> nil) then
      Result := ERROR_SUCCESS;
  end;
end;

end.
