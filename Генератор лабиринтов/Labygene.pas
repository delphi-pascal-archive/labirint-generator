unit Labygene;  (* Générateur de labyrinthe *)

interface

type
  tlab = array[1..23,1..33] of byte;

var
  laby : tlab;

procedure Genere;

implementation

const
  xmax = 16;
  ymax = 11;

type
  pvp = ^piece;
  piece = record
            prec : pvp;
            x,y,r : byte;
          end;
  duo = record
          car,
          att : byte;
        end;
var
  lab : array[0..3999] of byte;
  tab : array[1..25,1..80] of duo absolute lab;
  debl,ptr1,ptr2 : pvp;
  r,d,moy : byte;
  dx,dy : integer;

procedure Direction(dr : byte; var sx,sy : integer);
begin
  sx := ((2*dr+1) div 3)-1;
  sy := ((2*dr+1) mod 3)-1;
end;

function Trace(mr,mx,my : byte) : boolean;
var  vx,vy : integer;
begin
  Direction(mr,vx,vy);
  if lab[320*(my+vy)+4*(mx+vx)] = 32 then Trace := false
  else Trace := true;
end;

procedure Enlever_mur(our,ox,oy : byte);
var  odx,ody : integer;
begin
  Direction(our,odx,ody);
  lab[160*(2*oy+ody)+2*(2*ox+odx)] := 32;
end;

function Distance(drr,dix,diy : byte) : byte;
begin
  case drr of
    0 : Distance := dix-1;
    1 : Distance := diy-1;
    2 : Distance := ymax-diy;
    3 : Distance := xmax-dix;
  end;
end;

function Possible_avancer(pr,a,b : byte) : boolean;
var  vx,vy : integer;
begin
  Direction(pr,vx,vy);
  if (Trace(pr,a,b)) and (lab[160*(b*2+vy)+2*(a*2+vx)] <> 32)
  then Possible_avancer := false
  else Possible_avancer := true;
end;

procedure Remplissage;
var  d,i,exp2,n,x,y,rx,ry : byte;
     vx,vy : integer;
begin
  for x := 0 to xmax do
  begin
    for y := 0 to ymax do
    begin
      rx := 2*x+1;
      ry := 2*y+1;
      n := 0;
      exp2 := 1;
      for i := 0 to 3 do
      begin
        Direction(i,vx,vy);
        if lab[160*(ry+vy)+2*(rx+vx)] <> 32 then n := n+exp2;
        exp2 := exp2*2;
      end;
      if n = 0 then d := 32
      else d := 255;
      lab[160*ry+2*rx] := d;
    end;
  end
end;

function Sens_interdit(r,x,y : byte) : boolean;
var  ax,ay : integer;
begin
  Direction(r,ax,ay);
  if (lab[160*(2*y+ay)+2*(2*x+ax)] <> 32)
  or (lab[320*(y+ay)+4*(x+ax)] <> 32)
  then Sens_interdit := true
  else Sens_interdit := false;
end;

procedure Transfert;
var  x,y : byte;
begin
  for y := 2 to 34 do
    for x := 2 to 34 do
      laby[y-1,x-1] := tab[y,x].car;
  laby[1,2] := 0;
  laby[2,2] := 90;     // entrée
  laby[22,33] := 99;   // sortie
end;

procedure Genere;
var  i,x,y,xp,yp : integer;
begin
  dx := 0;
  repeat
    lab[dx] := 32;
    lab[dx+1] := 0;
    inc(dx,2);
  until dx > 3998;
  for y := 0 to ymax do
    for x := 1 to xmax do
    begin
      lab[320*y+4*x+160] := 255;
    end;
  for y := 1  to ymax do
    for x := 0 to xmax do
    begin
      lab[320*y+4*x+2] := 255;
    end;
  lab[324] := 31;
  lab[320*ymax+4*xmax+2] := 32;
  moy := (xmax+ymax)*2;
  for yp := 1 to ymax do
  begin
    for xp :=1 to xmax do
    begin
      if lab[320*yp+4*xp] = 32 then
      begin
        r := random(4);
        while (not Trace(r,xp,yp)) or (Distance(r,xp,yp) = 0) do
          r := (r+1) mod 4;
        Enlever_mur(r,xp,yp);
        x := xp;
        y := yp;
        for i := 1 to moy do
        begin
          r := random(4);
          while Distance(r,x,y) = 0 do r := (r+1) mod 4;
          Direction(r,dx,dy);
          d := random(Distance(r,x,y)) mod 3 + 1;
          while Possible_avancer(r,x,y) and (d > 0) do
          begin
            Enlever_mur(r,x,y);
            lab[160*2*y+2*2*x] := 176;
            x := x+dx;
            y := y+dy;
            lab[160*2*y+2*2*x] := 255;
            d := d-1;
          end;
        end;
        lab[160*2*y+2*2*x] := 254;
      end;
    end;
  end;
  Remplissage;
  for y := 1 to ymax do
    for x := 1 to xmax do lab[320*y+4*x] := 32;
  New(debl);
  with debl^ do
  begin
    prec := nil;
    x := 1;
    y := 1;
    r := 0;
  end;
  ptr1 := debl;
  x := 1; y := 1; r := 0;
  repeat
    while (Sens_interdit(r,x,y)) and (r<4) do inc(r);
    if r = 4 then
    begin
      ptr2 := ptr1^.prec;
      r := ptr2^.r;
      x := ptr2^.x;
      y := ptr2^.y;
      Direction(r,dx,dy);
      lab[160*(2*y+dy)+2*(2*x+dx)] := 32;
      lab[320*(y+dy)+4*(x+dx)] := 32;
      Dispose(ptr1);
      ptr1 := ptr2;
      inc(r);
    end
    else begin
           new(ptr2);
           ptr2^.prec := ptr1;
           ptr1^.r := r;
           Direction(r,dx,dy);
           if (r = 0) or (r = 3) then
              lab[160*(2*y+dy)+2*(2*x+dx)] := 90
           else lab[160*(2*y+dy)+2*(2*x+dx)] := 90;
           x := x+dx;
           y := y+dy;
           lab[320*y+4*x] := 90;
           ptr2^.x := x;
           ptr2^.y := y;
           ptr2^.r := 0;
           r := 0;
           ptr1 := ptr2;
         end;
  until (x=xmax) and (y=ymax);
  Transfert;
end;

end.
