unit Laby01;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, MPlayer, Menus;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Plan: TPaintBox;
    Label1: TLabel;
    Panel2: TPanel;
    Vue: TImage;
    SBG: TSpeedButton;
    SBF: TSpeedButton;
    SBD: TSpeedButton;
    Pmes: TPanel;
    Psens: TPanel;
    SBR: TSpeedButton;
    Pnum: TPanel;
    Ppas: TPanel;
    MainMenu1: TMainMenu;
    Labyrinthe2: TMenuItem;
    Nouveau2: TMenuItem;
    Afficher1: TMenuItem;
    Solution2: TMenuItem;
    Quitter1: TMenuItem;
    LbNom: TLabel;
    function  Couleur(n : byte) : TColor;
    procedure IncPas;
    procedure AffichePlot(x,y : integer; col : TColor);
    procedure AfficheRond(x,y : integer; col : TColor);
    procedure AffichePlan;
    procedure AfficheVue;
    procedure Collision;
    procedure SBFClick(Sender: TObject);
    procedure SBGClick(Sender: TObject);
    procedure SBDClick(Sender: TObject);
    procedure SBRClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Initialise;
    procedure Nouveau2Click(Sender: TObject);
    procedure Afficher1Click(Sender: TObject);
    procedure Solution2Click(Sender: TObject);
    procedure Quitter1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses Labygene, Laby03;

type
  tsens = (nord,est,sud,ouest);

const
  tbsens : array[nord..ouest] of string
         = ('NORD','EST','SUD','OUEST');
var
  sens : tsens;
  px,py : byte;
  ok : boolean;
  seed : longint;
  fin : boolean;
  situ : array[0..3,0..2] of byte;
  pas : integer;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
  seed := Random(65000)+1;
end;

function TForm1.Couleur(n : byte) : TColor;
begin
  Result := clWhite;
  case n of
    0   : Result := clSilver;   // chemin
    99  : Result := clYellow;   // sortie
    255 : Result := clGray;     // murs
  end;
end;

procedure TForm1.IncPas;
begin
  Inc(pas);
  Ppas.Caption := IntToStr(pas)+' pas';
end;

procedure TForm1.AffichePlot(x,y : integer; col : TColor);
begin
  Plan.Canvas.Brush.Color := col;
  Plan.Canvas.FillRect(Rect(x,y,x+10,y+10));
end;

procedure TForm1.AfficheRond(x,y : integer; col : TColor);
begin
  Plan.Canvas.Brush.Color := col;
  Plan.Canvas.Ellipse(x+1,y+1,x+9,y+9)
end;

procedure Tform1.AffichePlan;
var  x,y : integer;
     ix,iy : byte;
begin
  Fillchar(laby[1,1],759,' ');
  for x := 3 to 33 do laby[1,x] := 255;
  for x := 2 to 33 do laby[23,x] := 255;
  for y := 1 to 23 do laby[y,1] := 255;
  for y := 2 to 21 do laby[y,33] := 255;
  laby[1,2] := 0;
  laby[22,33] := 98;
  y := 0;
  for iy := 1 to 23 do
  begin
    x := 0;
    for ix := 1 to 33 do
    begin
      AffichePlot(x,y,Couleur(laby[iy,ix]));
      inc(x,10);
    end;
    inc(y,10);
  end;
  Pmes.Caption := 'A toi de jouer ';
end;

procedure TForm1.Solution2Click(Sender: TObject);
var  x,y : integer;
     ix,iy : byte;
begin
  y := 0;
  for iy := 1 to 23 do
  begin
    x := 0;
    for ix := 1 to 33 do
    begin
      if laby[iy,ix] = 90 then
        AfficheRond(x,y,clRed)
      else
        AffichePlot(x,y,Couleur(laby[iy,ix]));
      inc(x,10);
    end;
    inc(y,10);
  end;
end;

procedure TForm1.Afficher1Click(Sender: TObject);
var  x,y : integer;
     ix,iy : byte;
begin
  y := 0;
  for iy := 1 to 23 do
  begin
    x := 0;
    for ix := 1 to 33 do
    begin
      if laby[iy,ix] = 90 then
        AffichePlot(x,y,clWhite)
      else
        AffichePlot(x,y,Couleur(laby[iy,ix]));
      inc(x,10);
    end;
    inc(y,10);
  end;
end;

procedure TForm1.Initialise;
begin
  RandSeed := seed;
  AffichePlan;
  Genere;
  sens := sud;
  Psens.Caption := 'SUD';
  px := 2;
  py := 1;
  fin := false;
  pas := 0;
  AfficheVue;
end;

procedure TForm1.Nouveau2Click(Sender: TObject);
begin
  seed := seed+1;
  Pnum.Caption := 'N° '+IntToStr(seed);
  Initialise;
end;

procedure CalculVue;
var  n : byte;
begin
  Fillchar(situ[0,0],12,#255);
  Case sens of
    nord  : begin
              for n := 0 to 3 do
                if py-n > 0 then
                begin
                  situ[n,0] := laby[py-n,px-1];
                  situ[n,1] := laby[py-n,px];
                  situ[n,2] := laby[py-n,px+1];
                end;
            end;
    est   : begin
              for n := 0 to 3 do
                if px+n < 34 then
                begin
                  situ[n,0] := laby[py-1,px+n];
                  situ[n,1] := laby[py,px+n];
                  situ[n,2] := laby[py+1,px+n];
                end;
            end;
    sud   : begin
              for n := 0 to 3 do
                if py+n < 24 then
                begin
                  situ[n,0] := laby[py+n,px+1];
                  situ[n,1] := laby[py+n,px];
                  situ[n,2] := laby[py+n,px-1];
                end;
            end;
    ouest : begin
              for n := 0 to 3 do
                if px-n > 0 then
                begin
                  situ[n,0] := laby[py+1,px-n];
                  situ[n,1] := laby[py,px-n];
                  situ[n,2] := laby[py-1,px-n];
                end;
            end;
  end;
end;

procedure TForm1.AfficheVue;
begin
  CalculVue;
  Vue.Canvas.Draw(0,0,Images.Im1f.Picture.bitmap);
  if situ[0,1] = 99 then
    Vue.Canvas.Draw(41,41,Images.Im1por.Picture.bitmap);
  if situ[0,0] < 255 then
    Vue.Canvas.Draw(0,0,Images.Im1g.Picture.bitmap);
  if situ[0,2] < 255 then
    Vue.Canvas.Draw(180,0,Images.Im1d.Picture.bitmap);
  if situ[1,1] < 255 then
  begin
    Vue.Canvas.Draw(41,41,Images.Im2f.Picture.bitmap);
    if situ[1,1] = 99 then
      Vue.Canvas.Draw(69,69,Images.Im2por.Picture.bitmap);
    if situ[1,0] < 255 then
      Vue.Canvas.Draw(41,41,Images.Im2g.Picture.bitmap);
    if situ[1,2] < 255 then
      Vue.Canvas.Draw(152,41,Images.Im2d.Picture.bitmap);
    if situ[2,1] < 255 then
    begin
      Vue.Canvas.Draw(69,69,Images.Im3f.Picture.bitmap);
      if situ[2,1] = 99 then
        Vue.Canvas.Draw(83,83,Images.Im3por.Picture.bitmap);
      if situ[2,0] < 255 then
        Vue.Canvas.Draw(69,69,Images.Im3g.Picture.bitmap);
      if situ[2,2] < 255 then
        Vue.Canvas.Draw(138,69,Images.Im3d.Picture.bitmap);
      if situ[3,1] < 255 then
        Vue.Canvas.Draw(83,83,Images.Im3fon.Picture.bitmap);
    end;
  end;
end;

procedure Tform1.Collision;
begin
  Pmes.Caption := 'Aïe!';
  Pmes.Color := clYellow;
  Pmes.Repaint;
  Vue.Canvas.Draw(0,0,Images.Im0mur.Picture.bitmap);
  Vue.Repaint;
  sleep(500);
  Pmes.Color := clBtnFace;
  Pmes.Caption := '';
  Pmes.Repaint;
  AfficheVue;
end;

procedure TForm1.SBFClick(Sender: TObject);  // Avance
begin
  if fin then exit;
  ok := true;
  Pmes.Caption := '';
  AfficheRond((px-1)*10,(py-1)*10,clFuchsia);
  if laby[py,px] = 99 then
  begin
    Vue.Canvas.Draw(0,0,Images.Im0por.Picture.bitmap);
    Vue.Repaint;
    Pmes.Caption := 'Bravo, c''est gagné!';
    Exit;
  end;
  case sens of
    nord : begin
             if (py-1 = 0)
             or (laby[py-1,px] > 250) then ok := false
             else dec(py);
          end;
    est : begin
            if laby[py,px+1] > 250 then ok := false
            else Inc(px);
          end;
    sud : begin
            if laby[py+1,px] > 250 then ok := false
            else Inc(py);
          end;
    ouest : begin
              if laby[py,px-1] > 250 then ok := false
              else dec(px);
            end;
  end;
  if not ok then Collision
  else begin
         IncPas;
         AfficheVue;
         AfficheRond((px-1)*10,(py-1)*10,clBlue);
       end;
end;

procedure TForm1.SBGClick(Sender: TObject);  // à gauche
begin
  if fin then exit;
  Pmes.Caption := '';
  ok := false;
  AfficheRond((px-1)*10,(py-1)*10,clFuchsia);
  case sens of
    nord  : begin
              if laby[py,px-1] < 251 then
              begin
                dec(px);
                sens := ouest;
                ok := true;
              end
            end;
    est   : begin
              if laby[py-1,px] < 251 then
              begin
                dec(py);
                sens := nord;
                ok := true;
              end;
            end;
    sud   : begin
              if laby[py,px+1] < 251 then
              begin
                inc(px);
                sens := est;
                ok := true;
              end;
            end;
    ouest : begin
              if laby[py+1,px] < 251 then
              begin
                inc(py);
                sens := sud;
                ok := true;
              end;
            end;
  end;
  if not ok then Collision
  else begin
         IncPas;
         Psens.Caption := tbsens[sens];
         AfficheVue;
         AfficheRond((px-1)*10,(py-1)*10,clBlue);
       end;
end;

procedure TForm1.SBDClick(Sender: TObject); // à droite
begin
  if fin then exit;
  Pmes.Caption := '';
  ok := false;
  AfficheRond((px-1)*10,(py-1)*10,clFuchsia);
  case sens of
    nord  : begin
              if laby[py,px+1] < 251 then
              begin
                inc(px);
                sens := est;
                ok := true;
              end;
            end;
    est   : begin
              if laby[py+1,px] < 251 then
              begin
                inc(py);
                sens := sud;
                ok := true;
              end;
            end;
    sud   : begin
              if laby[py,px-1] < 251 then
              begin
                dec(px);
                sens := ouest;
                ok := true;
              end;
            end;
    ouest : begin
              if laby[py-1,px] < 251 then
              begin
                dec(py);
                sens := nord;
                ok := true;
              end;
            end;
  end;
  if not ok then Collision
  else begin
         IncPas;
         Psens.Caption := tbsens[sens];
         AfficheVue;
         AfficheRond((px-1)*10,(py-1)*10,clBlue);
       end;
end;

procedure TForm1.SBRClick(Sender: TObject); // demi-tour
begin
  if fin then exit;
  case sens of
    nord  : sens := sud;
    est   : sens := ouest;
    sud   : sens := nord;
    ouest : sens := est;
  end;
  IncPas;
  Psens.Caption := tbsens[sens];
  AfficheVue;
  AfficheRond((px-1)*10,(py-1)*10,clBlue);
end;

procedure TForm1.Quitter1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    vk_Up : SBFClick(Self);
    vk_Down : SBRClick(Self);
    vk_Right : SBDClick(Self);
    vk_Left : SBGClick(Self);
  end;
end;

end.
