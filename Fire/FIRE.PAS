program firetest;

{ Classic fire animation using VGA mode 13h and colors 0 to 63... wee !!! }

uses Crt, VGA;

var i, heat: Integer;
    quit: Boolean;
    c: Char;

{ This procedure will run a convolution matrix over a screen
  rectangle specified by the caller.}

procedure Fire(x1, y1, x2, y2: Integer);
var x, y, z: Integer;
begin
  for y := y1 to y2 do begin
    for x := x1 to x2 do begin
      { Sum up four pixels, of which two are the same. }
      z := GetPixel(x, y+1) * 2 +
           GetPixel(x + 1, y) +
           GetPixel(x - 1, y);
      { Don't be mad because of the div 4, this is for a school project! }
      z := z div 4;
      { Add some random noise. }
      { ...but only if the pixel isn't plain black! }
      if z > 0 then z := z + Random(7) - 3;
      { Do some clipping }
      if z < 0 then z := 0;
      if z > 63 then z := 63;
      SetPixel(x, y, z);
    end;
  end;
end;

begin
  { Init VGA mode 13h, the best of the bunch! }
  SetMode($13);
  Clear;

  { Prepare the burn palette. }
  for i := 0 to 15 do begin
    { These are four gradients of 16 colors each
      which fit together nicely:
      - black to 50% red
      - 50% red to red
      - red to yellow
      - yellow to white }
    SetPalette(i, i * 2, 0, 0);
    SetPalette(i + 16, (i + 16) * 2, 0, 0);
    SetPalette(i + 32, 63, i * 4, 0);
    SetPalette(i + 48, 63, 63, i * 4);
  end;

  { The variable 'heat' is a number from 0 to 63 and it's
    the color of the bottom generator line. We're starting
    with low heat. }
  heat := 10;
  quit := false;
  repeat
    { Always draw a line at the bottom of the screen (y = 199)
      which serves as a kind of generator for the fire animation. }
    DrawLine(80, 199, 240, 199, heat);
    { Run the fire animation, but spare the bottom screen line
      so that the generator line is always left intact. }
    Fire(75, 100, 245, 198);

    if KeyPressed then begin
      c := ReadKey;
      case c of
        { Press Esc to exit the program. }
        #27: quit := true;
        { Use - and + to amplify / attenuate le feu. }
        '-': if heat > 0 then heat := heat - 1;
        '+': if heat < 63 then heat := heat + 1;
        { Or use 0 to 9 directly to control the heat! }
        { BTW what a coincidence that 9 * 7 = 63! }
        '0'..'9': heat := (ord(c) - ord('0')) * 7;
      end;
    end;
  until quit;
  { Return to text mode, THE END. }
  SetMode(3);
end.
