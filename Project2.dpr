program Project2;

uses
  Forms,
  Unit2 in 'Unit2.pas' {frmLFSR};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLFSR, frmLFSR);
  Application.Run;
end.
