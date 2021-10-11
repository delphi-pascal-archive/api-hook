unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, CodeHook, Classes,
  Controls, StdCtrls;

type
  TForm1 = class(TForm)
    Button3: TButton;
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var
  PMessageBoxW: function(hWnd: hWnd; lpText, lpCaption: PWideChar; uType: UINT): Integer; stdcall;

function NewMessageBoxW(hWnd: hWnd; lpText, lpCaption: PWideChar; uType: UINT): Integer; stdcall;
begin
  MessageBeep(0);
  Result := PMessageBoxW(hWnd, 'Hooked MessageBoxW Text!!!', 'Hooked MessageBoxW Caption!!!', MB_OK);
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  Status: DWORD;
begin
  MessageBoxW(0, '', '', MB_OK);

  Status := HookFunction('user32.dll', 'MessageBoxW', @PMessageBoxW, @NewMessageBoxW);
  if Status <> ERROR_SUCCESS then
    Exit;

  MessageBoxW(0, '', '', MB_OK);
  UnHookFunction(@PMessageBoxW);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
{$IFDEF WIN64}
  Initialize('CodeHook64.dll');
{$ELSE}
  Initialize('CodeHook32.dll');
{$ENDIF}
end;

end.
