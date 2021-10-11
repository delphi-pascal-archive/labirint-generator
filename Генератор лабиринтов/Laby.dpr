program Laby;

uses
  Forms,
  Laby01 in 'Laby01.pas' {Form1},
  Labygene in 'Labygene.pas',
  Laby03 in 'Laby03.pas' {Images};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TImages, Images);
  Application.Run;
end.
