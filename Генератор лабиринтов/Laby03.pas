unit Laby03;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, MPlayer;

type
  TImages = class(TForm)
    Im1f: TImage;
    Im1g: TImage;
    Im1d: TImage;
    Im2f: TImage;
    Im2g: TImage;
    Im2d: TImage;
    Im3f: TImage;
    Im3g: TImage;
    Im3d: TImage;
    Im1por: TImage;
    Im2por: TImage;
    Im3por: TImage;
    Im0por: TImage;
    Im0mur: TImage;
    Im3fon: TImage;
  private
    { Déclarations privées }
  public
 
  end;

var
  Images: TImages;

implementation

{$R *.DFM}

end.
