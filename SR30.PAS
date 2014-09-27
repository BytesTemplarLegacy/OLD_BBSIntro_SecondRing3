{Started Fri-6-3-94  :: Ended Tues-6-7-94  :: NonSequential}

{Updates:
         þ 8-4-94 --Looked like trash on Pentium/90. Fixing Delays.}

(*   Welcome to v3.0 of the SR.COM lame-o loader program...this time
     it will be totally optimized and FLICKER-FREE.  Lets move on.*)

{M 64000,200000,655350}
{$G+,A+,D-}
Program SRCOM_v3_0;    {** NOTE THIS WILL ONLY WORK ON 386+ **}
Uses HSD, SR30_1, SR30_2, CRT;
Type
    Colors      =Record
                  r,g,b :byte;
                 end;
Const
     seed1	:word=	$1234;
     seed2	:word=	$5678;
     seed3	:word=	$1234;
     seed4	:word=	$5678;
Var
   pages             :Array[1..3] of Pointer;
   txtpage           :Pointer;
   uhfpage           :Pointer;
   foo               :Word;
   srspr             :array[0..179, 0..45] of byte;
   entspr            :array[0..195, 0..40] of byte;
   trekspr           :array[0..58, 0..112] of byte;
   a,b,d             :word;
   c                 :integer;
   curpal            :array[0..255] of Colors;
   curx, cury        :byte;
   blackpal,whitepal :array[0..768] of byte;

 Procedure SRTXT; External; {$L SR31TXT.OBJ}  {Ending ANSI}
(* Procedure SR;    External; {$L SR.OBJ}*)


{ษอMATH ASSOCIATED FUNCTIONSอออออออออออออออออออออออออออออออออออออออออออป}
  Function Rand:word; Assembler;
  Asm
        push bx
        push cx
        push dx
	mov ax,ds:seed1
	mov bx,ds:seed2
	mov cx,ds:seed3
	mov dx,ds:seed4
	add ax,bx
	rol ax,cl
	xor ax,dx
	xchg cl,ch
	add bx,cx
	add dx,bx
	add cx,ax
	ror bx,1
	sbb ax,dx
	mov ds:seed4,dx
	mov ds:seed3,dx
	mov ds:seed2,dx
	mov ds:seed1,ax
        cmp ax, 16
  @L2:  cmp ax, 16
        jbe @boo;
        shr ax, 4;
        jmp @L2
  @boo: add ax, 16
        pop dx
        pop cx
        pop bx
  End;

  Procedure Reseed; Assembler;
  Asm
        mov ax, $40;
        mov es, ax;
        mov di, $6C;
        mov cx, [es:di]
        mov word ptr [seed1+1],cx;
        mov cx, [es:di]
        mov word ptr [seed2+1],cx;
        mov cx, [es:di]
        mov word ptr [seed3+1],cx;
        mov cx, [es:di]
        mov word ptr [seed4+1],cx;
  End;
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}
{ษอVGA GRAPHIC RELATED ROUTINESอออออออออออออออออออออออออออออออออออออป}
  Procedure VSinc; Assembler;
  Asm    mov dx, 3DAh;
   @L1:  In Al,Dx;
         Test Al,8;
         Jnz @L1;
   @L2:  In Al,Dx;
         Test Al,8;
         Jz @L2;
   End;

  PROCEDURE GetPalette(index2get:Byte; VAR r, g, b:Byte);
  BEGIN
    Port[$3C7] := index2get;
    r := Port[$3C9];
    g := Port[$3C9];
    b := Port[$3C9];
  END;

  Procedure OpenMode; Assembler;
  Asm
   mov ax, $13;
   int $10;
  End;

  Procedure CloseMode; Assembler;
  Asm
   mov ax, 3;
   int $10;
  End;

  Procedure SetColor(index:word; r,g,b :byte);
  Begin
     VSinc;
      Port[$3C8] := index;
      Port[$3C9] := r;
      Port[$3C9] := g;
      Port[$3C9] := b;
  End;

  procedure FadeColors(FromColors, ToColors : Pointer;
                     StartCol, NoColors, NoSteps : byte); assembler;
label
  Start, DummyPalette, NoColorsX3,
  DummySub, StepLoop, ColorLoop,
        SubLoop, RetrLoop1, RetrLoop2, Over1, Over2;
asm
        jmp        Start
 DummyPalette:
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 DummySub:
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 NoColorsX3 :
  dw          0
 Start:
        push ds

        lds         si, ToColors
  les         di, FromColors
  xor  ch, ch
  mov         cl, NoColors
  shl         cx, 1
  add         cl, NoColors
  adc  ch, 0
  mov         word ptr cs:[NoColorsX3], cx
  mov         bx, 0
  push di
 SubLoop:
        lodsb
        sub         al, byte ptr es:di
        mov         byte ptr cs:[DummySub+bx], al
  inc         di
  inc         bx
        loop SubLoop
  pop         di

  push cs
  pop         ds
        mov         dh, 0
  mov  dl, NoSteps
 StepLoop:
  push di
  mov         cx, word ptr cs:[NoColorsX3]
  mov         bx, 0
 ColorLoop:
  xor         ah, ah
        mov         al, byte ptr cs:[DummySub+bx]
  or         al, al
  jns         over1
  neg         al
 over1:
  mul         dh
  div         dl
  cmp  byte ptr cs:[DummySub+bx], 0
  jge         over2
  neg         al
 over2:
  mov         ah, byte ptr es:[di]
  add         ah, al
  mov         byte ptr cs:[DummyPalette+bx], ah
  inc         bx
  inc         di
  loop ColorLoop

  push dx
  mov  si, offset DummyPalette
  mov  cx, word ptr cs:[NoColorsX3]

  mov  dx, 03DAh
 retrloop1:
  in          al, dx
  test al, 8
  jnz  retrloop1
 retrloop2:
  in          al, dx
  test al, 8
  jz   retrloop2

  mov  dx, 03C8h
  mov  al, StartCol
  out  dx, al
  inc  dx
  rep         outsb
  pop         dx
  pop         di
  inc         dh
  cmp         dh, dl
  jbe         StepLoop

  pop         ds
 end;

 Procedure GrabCurPal;
  Var
     z:byte;
  Begin
   For z:=0 to 255 do GetPalette(z,curpal[z].r, curpal[z].g, curpal[z].b);
  End;

 Procedure EngineWarpUp(sp:word);
  var
     z                  :byte;
     red,green,blue     :byte;
  Begin
     red:=0;
     blue:=0;
     green:=0;
     While (red<61) and (blue<61) do
                               Begin
                                 GetPalette(153,red,green,blue);
                                 SetColor(153,red+1,green+1,blue);
                               {  Delay(sp);} VSinc;
                               End;
  End;

  Procedure VgaBase(Xscroll,Yscroll:Integer);
  Var
     dum       :Byte;
     t,slide   :Word;
  Begin
    Dec(SLIDE,(Xscroll+320*Yscroll));
    Port[$03d4]:=13;
    Port[$03d5]:=(SLIDE shr 2) and $FF;
    Port[$03d4]:=12;
    Port[$03d5]:= SLIDE shr 10;
    Dum:=Port[$03DA];
    Port[$03C0]:=$20 or $13;
    Port[$03C0]:=(SLIDE and 3) Shl 1;
  End;

PROCEDURE Split(Row:Integer);
BEGIN
     ASM
        mov dx,$3d4
        mov ax,row
        mov bh,ah
        mov bl,ah
        and bx,201h
        mov cl,4
        shl bx,cl
        mov ah,al
        mov al,18h
        out dx,ax
        mov al,7
        cli
        out dx,al
        inc dx
        in al,dx
        sti
        dec dx
        mov ah,al
        and ah,0efh
        or ah,bl
        mov al,7
        out dx,ax
        mov al,9
        cli
        out dx,al
        inc dx
        in al,dx
        sti
        dec dx
        mov ah,al
        and ah,0bfh
        shl bh,1
        shl bh,1
        or ah,bh
        mov al,9
        out dx,ax
     END;
END;

  Procedure PlotPage(pag:byte; x,y :word; c:byte);
  Begin
     Mem[Seg(pages[pag]^):Ofs(pages[pag]^)+(320*y+x)]:=c;
  End;
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}
{ษอMISC. SUPPORT ROUTINESอออออออออออออออออออออออออออออออออออออออออออป}
  Function KeyPressed : Boolean; Assembler;
  Asm
    Mov Ah,0Bh
    Int 21h
  End;

  Procedure MoveDW(var z, x; siz:word); Assembler; {32-Bit Data Move 386+}
  Asm
     push ds
     {xor    ecx,ecx}         db $66,$33,$C9
      mov    cx,[bp+04];
      shr    cx,02;
      les    di,[bp+06];
      lds    si,[bp+$0A];
      cld;
{     rep movsd} db $F3, $66, $A5;
      pop ds
  End;

  Procedure CopyPage(s,d:byte);
  Begin
     moveDW(pages[s]^,pages[d]^,64000);
  End;
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

{ษอ UHF FUZZ ROUTINESออออออออออออออออออออออออออออออออออออออออออออออออป}
  Procedure InitUHF;
  Var
   uhfs,uhfo    :word;
  Begin
   uhfs:=seg(uhfpage^);
   uhfo:=ofs(uhfpage^);
   asm
    mov cx, 64000;
    mov ax, uhfs;
    mov es, ax;
    mov di, uhfo;
  @@St:
    call rand;
{   mov [es:di], ax;
    inc di}
    mov [es:di], ax;
    inc di
    loop @@st;
   end;
 End;

  Procedure Fuzz(count:longint);
  Var
     y:word;
     x:byte;
  Begin
     VSinc;
     MoveDW(mem[seg(uhfpage^):ofs(uhfpage^)], pages[1]^, 64000);
     For y:=0 to count do VGABase(random(255),random(255));
     asm mov ax, $13; int $10; end;
  End;
{ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

{ษอINITIALIZATION ROUTINESอออออออออออออออออออออออออออออออออออออออออป}
  PROCEDURE InitPages;
  Begin
    pages[1]:=Ptr($A000,0000);
    GetMem(pages[2],64000);
    FillChar(pages[2]^,64000, #0);
    GetMem(pages[3],64000);
    FillChar(pages[3]^,64000, #0);
   End;

  PROCEDURE DeInitPages;
  Begin
     Pages[1]:=nil;
     FreeMem(pages[2], 64000);
     FreeMem(pages[3], 64000);
     FreeMem(uhfpage, 64000);
  End;
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

{ษอGENERAL INITIALIZATION ROUTINESออออออออออออออออออออออออออออออออออป}
   Procedure InitializeVideo;
   Begin
     OpenMode;
     InitPages;
     SetupPal;
   End;


   Procedure DeInitializeVideo;
   Begin
     DeInitPages;
     CloseMode;
   End;
{ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

{ษอPALETTE ROUTINESออออออออออออออออออออออออออออออออออออออออออออออออออป}
  PROCEDURE SetDPPal;Assembler;
  ASM
        mov dx, $3C8;
        xor al,al;
        out dx,al;
        xor cx, cx;
  @@St: mov dx, $3C9;
        mov ax, seg dp;
        mov es, ax;
        mov ax, offset dp;
        add ax, cx;
        mov di, ax;
        mov ax, [es:di];
        out dx, ax;
        add di, cx;
        inc cx;
        cmp cx, 768;
        jnz @@st;
  End;

  Procedure ZDC; Assembler;
  Asm
       mov cx, 768;
       mov dx, $3C9;
       mov ax, 0;
  @@St:
       out dx, ax;
       loop @@st;
  End;
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

Procedure EatupText; Assembler;
Asm
      mov ax,0100h;                         {Turn Cursor Off...}
      mov cx,2000h;
      int 10h;
      mov cx, 13;
@@ST: mov dx, 3D4h;
      mov al, 9;
      out dx, al;
      mov dx, 3D5h;
      mov ax, cx;
      out dx, ax;
      call VSinc;
      loop @@st
      Mov Ax,0100h;
      Mov Cx,0607h;
      Int 10h;
End;

Procedure EatDownText; Assembler;
Asm   mov ax,0100h;                         {Turn Cursor Off...}
      mov cx,2000h;
      int 10h;
      mov cx, 0;
@@ST: mov dx, 3D4h;
      mov al, 9;
      out dx, al;
      mov dx, 3D5h;
      mov ax, cx;
      out dx, ax;
      call VSinc;
      cmp cx, 15;
      inc cx;
      jb @@ST;
      Mov Ax,0100h;
      Mov Cx,0607h;
      Int 10h;
End;
{ษอSPRITE HANDLING ROUTINESออออออออออออออออออออออออออออออออออออออออออออออป}
  Procedure GrabSpr;
  Begin
   For b:=0 to 45 do        {This grabs SR Logo}
     for a:=0 to 179 do move(mem[$A000:320*b+a], srspr[a,b], 1);

   For b:=0 to 40 do        {This grabs starship.}
     for a:=0 to 195 do move(mem[$A000:320*(b+47)+a], entspr[a,b] ,1);

   For b:=0 to 112 do        {This grabs insignia}
     for a:=0 to 58 do move(mem[$A000:320*b+(a+203)], trekspr[a,b] ,1);

  End;

  Procedure PutTitle(x,y:word; p:byte);
  Begin
     For b:=0 to 45 do
            For a:=0 to 179 do
                if srspr[a,b]>0 then plotpage(p,a+x,b+y,srspr[a,b]);
  End;

  Procedure PutEnt(x,y:word; p:byte);
  Begin
     For b:=0 to 40 do
            For a:=0 to 195 do
                if entspr[a,b]>0 then plotpage(p,a+x,b+y,entspr[a,b]);
  End;

  Procedure PutTrek(x,y:word; p:byte);
  Begin
     For b:=0 to 112 do
            For a:=0 to 58 do
                if trekspr[a,b]>0 then plotpage(p,a+x,b+y,trekspr[a,b]);
  End;

(*  Procedure EraseTitleSpr(x,y:word; p:byte);
  Begin
     For b:=0 to 45 do
            For a:=0 to 179 do
                if srspr[a,b]>0 then plotpage(p,a+x,b+y,0);
  End;

  Procedure EraseEntSpr(x,y:word; p:byte);
  Begin
     For b:=0 to 40 do
            For a:=0 to 195 do
                if entspr[a,b]>0 then plotpage(p,a+x,b+y,0);
  End;*)
{ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}
Procedure ExitANSI;
var
   y,x  :word;
Begin
     Asm   mov ax, $3; int $10; mov ax,0100h; mov cx,2000h; int 10h; end;
     GrabCurPal;
     ZDC;
     Split(399);
     Move(@SRTXT^,  Mem[$B800:0000],4000);
     Asm
        Mov ah,5
        mov al,1
        int $10
     end;
     FadeColors(@BlackPal, @CurPal, 0, 255, 10);
     y:=399;
          While y>0 do                       {For y:=0 to}
              Begin
                   Split(y);
                   VSinc;
                   Dec(y,1);
              End;
     Repeat Until Keypressed;                {Wait for keypress}
     FadeColors(@CurPal, @WhitePal, 0, 255, 10);
     FadeColors(@WhitePal, @BlackPal ,0, 255, 10);
     asm mov ax, 3; int $10; end;
(*     Asm  Mov ah, 5; mov al,0; int $10; end; {Return to main page}*)
End;

{ึฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤMAIN HERE!!!!!!!!!!!ฤฤฤฤฤฤฤฤฤฤท}
Procedure MainProgram;
Begin

     ZDC;
     FillChar(WhitePal, 768, 63);
     FillChar(BlackPal, 768, 0);
     movedw(@srl^,pages[1]^,64000);
     movedw(@space^,pages[3]^,64000);
     grabspr;
     FillChar(mem[$A000:0], 64000, 0);
     SetDPPal;
     c:=0;
     While c<100 do Begin
                          CopyPage(3,2);
                           Vsinc;
                           PutEnt(c,100,2);
                          CopyPage(2,1);
                          Inc(c,5);
                        End;
     EngineWarpUp(0);
     FadeColors(@DP, @WhitePal, 0, 255, 20);
     CopyPage(3,2);
     PutTitle(70,20,2);
     PutTrek(125,75,2);
     CopyPage(2,1);
     FadeColors(@WhitePal,@Dp, 0, 255, 100);
     c:=0;
     Repeat
            SetColor(31, abs(c),abs(c),abs(c));
            inc(c);
            if c=63 then c:=-c;
     Until Keypressed; ReadKey;
     FadeColors(@Dp, @BlackPal, 0,255,25);
     FillChar(mem[$A000:0000], 64000, 0);
     SetDPPAl;
End;
{ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ}
Begin
 curx:=wherex;
 cury:=wherey;
 GetMem(txtpage, 4000);
 Move(mem[$B800:0000], txtpage^, 4000);
 GetMem(uhfpage,64000);
 FillChar(uhfpage^,64000,0);
 Reseed;
 InitUHF;
 EatupText;
 InitializeVideo;
        Fuzz(60000);
        MainProgram;
        Fuzz(60000);
 DeInitializeVideo;
 ExitAnsi;
 Move(txtpage^, mem[$B800:0000], 4000);
 EatDownText;
 FreeMem(txtpage,4000);
 GotoXY(curx,cury);
 ReadKey;
End.