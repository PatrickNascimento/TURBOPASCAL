unit VGA;

Interface

procedure SetMode(mode: Integer);
procedure Clear;
procedure SetPixel(x, y: Integer; color: Byte);
function GetPixel(x, y: Integer): Byte;
procedure SetPalette(num,r,g,b: Byte);
procedure GetPalette(num: Byte; var r,g,b: Byte);
procedure WaitSync;
procedure DrawLine(x1,y1,x2,y2: Integer; col: Byte);

Implementation

procedure SetMode(mode: Integer); Assembler;
asm
  mov ax, mode
  int 10h
end;

procedure Clear; Assembler;
asm
  push 0A000h
  pop  es
  xor  di, di
  mov  cx, 16000
  db   66h
  xor  ax, ax
  db   66h
  rep  stosw
end;

procedure SetPixel(x, y: Integer; color: Byte); Assembler;
asm
  mov  di, y
  mov  bx, di
  shl  di, 6
  shl  bx, 8
  add  di, bx
  add  di, x
  mov  al, color
  push 0A000h
  pop  es
  stosb
end;

function GetPixel(x, y: Integer): Byte; Assembler;
asm
  mov  di, y
  mov  bx, di
  shl  di, 6
  shl  bx, 8
  add  di, bx
  add  di, x
  push 0A000h
  pop  es
  mov  al, es:[di]
end;

procedure SetPalette(num,r,g,b: Byte); Assembler;
asm
  mov dx,3C8h
  mov al,num
  out dx,al
  cli
  mov dx,3C9h
  mov al,r
  out dx,al
  mov al,g
  out dx,al
  mov al,b
  out dx,al
  sti
end;

procedure GetPalette(num: Byte; var r,g,b: Byte); Assembler;
asm
  mov dx,3C7h
  mov al,num
  out dx,al
  cli
  mov dx,3C9h
  in  al,dx
  les bx,r
  mov es:[bx],al
  in  al,dx
  les bx,g
  mov es:[bx],al
  in  al,dx
  les bx,b
  mov es:[bx],al
  sti
end;

procedure WaitSync; Assembler;
asm
  mov  dx,3DAh
@l1:
  in   al,dx
  test al,1
  jnz  @l1
@l2:
  in   al,dx
  test al,8
  jz   @l2
end;

procedure Swap(var x, y: Integer);
var t: Integer;
begin
  t := x;
  x := y;
  y := t;
end;

procedure DrawLine(x1, y1, x2, y2: Integer; col: Byte);
var dx, dy, dab, inca, incb, x, y, h1, h2: Integer;
begin
  if (x1 = x2) and (y1 = y2) then SetPixel(x1, y1, col) else begin
    if x1 > x2 then begin
      Swap(x1, x2);
      Swap(y1, y2);
    end;
    dx := x2 - x1;
    dy := y2 - y1;
    h1 := dx;
    h2 := dy;
    if (dx < -dy) and (dy < 0) then begin
      y1 := -y1;
      y2 := -y2;
      Swap(x1, y1);
      Swap(x2, y2);
    end;
    if (dx >= -dy) and (dy < 0) then begin
      y1 := -y1;
      y2 := -y2;
    end;
    if (dx <= dy) and (dy > 0) then begin
      Swap(x1, y1);
      Swap(x2, y2);
    end;
    dx := x2 - x1;
    dy := y2 - y1;
    dab := 2 * dy - dx;
    inca:=2 * (dy - dx);
    incb:=2 * dy;
    x := x1;
    y := y1;
    if (h1 < -h2) and (h2 < 0) then SetPixel(y, -x, col);
    if (h1 >= -h2) and (h2 < 0) then SetPixel(x, -y, col);
    if (h1 > h2) and (h2 >= 0) then SetPixel(x, y, col);
    if (h1 <= h2) and (h2 > 0) then SetPixel(y, x, col);
    for x:=x1 + 1 to x2 do begin
      if dab < 0 then Inc(dab, incb) else begin
        Inc(dab, inca);
        Inc(y);
      end;
      if (h1 < -h2) and (h2 < 0) then SetPixel(y, -x, col);
      if (h1 >= -h2) and (h2 < 0) then SetPixel(x, -y, col);
      if (h1 > h2) and (h2 >= 0) then SetPixel(x, y, col);
      if (h1 <= h2) and (h2 > 0) then SetPixel(y, x, col);
    end;
  end;
end;

end.
