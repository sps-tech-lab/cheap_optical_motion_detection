program Stend_Terminal;

uses
  Forms,
  StendTerminal in 'StendTerminal.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
