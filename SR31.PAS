{Started Fri-6-3-94  þ Ended Tues-6-7-94  :: NonSequential}
{Updated Mon-7-25-94 þ Added PCX support as opposed to raw binary.
                         ณ Although speed & size are maginally improved,
                         ณ the program doesn't require so much
                         ณ memory...(hey, it runs from IDE without
                         ณ LaMe-o external .TPU's...:)
 Updated Thu-8-4-1994 þ Worked quite poor on 586/90 system.
                         ณ Making changes.
                         ณ Fixed some timing problems.
                         ณ Assorted bug fixes.
 }

(*   Welcome to v3.1 of the SR.COM lame-o loader program...this time
     it will be totally optimized and FLICKER-FREE.  Lets move on.
*)
{$G+,A+,D-,S-,R-,I-,N-,E-}
Program SRCOM_v3_2;    {** NOTE THIS WILL ONLY WORK ON 386+ **}
Uses HSD, GR;
Type
  Colors      = Record
                  r, g, b : Byte;
                End;
Const
  seed1	: Word = 	$1234;
  seed2	: Word = 	$5678;
  seed3	: Word = 	$1234;
  seed4	: Word = 	$5678;
Var
  pages              :Array [1..3] Of Pointer;
  txtpage            :Pointer;
  uhfpage            :Pointer;
  foo                :Word;
  srspr              :Array [0..179, 0..45] Of Byte;
  entspr             :Array [0..195, 0..40] Of Byte;
  trekspr            :Array [0..58, 0..112] Of Byte;
  a, b, D            :Word;
  c                  :Integer;
  curpal             :Array [0..255] Of Colors;
  curx, cury         :Word;
  blackpal, whitepal :Array [0..768] Of Byte;

 Procedure Delay(ms : Word);   Forward;
 Function  Keypressed:Boolean; Forward;

 Procedure SRTXT; External; {$L SR31TXT.OBJ}  {Ending ANSI}
 Procedure Space; External; {$L Space.OBJ}    {Space Backdrop}
 Procedure SRL;   External; {$L SRL.OBJ}      {Ship/Text/Etc..Sprites}


{ษอMATH ASSOCIATED FUNCTIONSอออออออออออออออออออออออออออออออออออออออออออป}
  Function Rand: Word; Assembler;
  Asm
    push BX
    push CX
    push DX
    mov	AX, DS: seed1
    mov	BX, DS: seed2
    mov	CX, DS: seed3
    mov	DX, DS: seed4
    add	AX, BX
    rol	AX, CL
    XOr	AX, DX
    xchg CL, CH
    add	BX, CX
    add	DX, BX
    add	CX, AX
    ror	BX, 1
    sbb	AX, DX
    mov	DS: seed4, DX
    mov	DS: seed3, DX
    mov	DS: seed2, DX
    mov	DS: seed1, AX
    cmp AX, 16
@L2:
    cmp AX, 16
    jbe @boo;
    ShR AX, 4;
    jmp @L2
@boo:
    add AX, 16
    pop DX
    pop CX
    pop BX
End;

Procedure Reseed; Assembler;
Asm
  mov AX, $40;
  mov ES, AX;
  mov DI, $6C;
  mov CX, [ES: DI]
  mov Word Ptr [seed1 + 1], CX;
  mov CX, [ES: DI]
  mov Word Ptr [seed2 + 1], CX;
  mov CX, [ES: DI]
  mov Word Ptr [seed3 + 1], CX;
  mov CX, [ES: DI]
  mov Word Ptr [seed4 + 1], CX;
End;
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

{ษอVGA GRAPHIC RELATED ROUTINESอออออออออออออออออออออออออออออออออออออป}
Procedure VSinc; Assembler;
Asm
  mov DX, 3DAh;
@L1:
  In AL, DX;
  Test AL, 8;
  Jnz @L1;
@L2:
  In AL, DX;
  Test AL, 8;
  Jz @L2;
End;

Procedure GetPalette (index2get: Byte; Var r, g, b: Byte);
Begin
  Port [$3C7] := index2get;
  r := Port [$3C9];
  g := Port [$3C9];
  b := Port [$3C9];
End;

Procedure OpenMode; Assembler;
Asm
  mov AX, $13;
  Int $10;
End;

Procedure CloseMode; Assembler;
Asm
  mov AX, 3;
  Int $10;
End;

Procedure SetColor (index: Word; r, g, b : Byte);
Begin
  VSinc;
  Port [$3C8] := index;
  Port [$3C9] := r;
  Port [$3C9] := g;
  Port [$3C9] := b;
End;

Procedure FadeColors (FromColors, ToColors : Pointer;
                      StartCol, NoColors, NoSteps : Byte); Assembler;
Label
  Start, DummyPalette, NoColorsX3,
  DummySub, StepLoop, ColorLoop,
  SubLoop, RetrLoop1, RetrLoop2, Over1, Over2;
Asm
  jmp start
  DummyPalette:
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  DummySub:
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
NoColorsX3 :
  dw          0
Start:
  push DS
  
  lds SI, ToColors
  les DI, FromColors
  XOr CH, CH
  mov CL, NoColors
  ShL CX, 1
  add CL, NoColors
  adc CH, 0
  mov Word Ptr cs: [NoColorsX3], CX
  mov BX, 0
  push DI
SubLoop:
  lodsb
  sub AL, Byte Ptr ES: DI
  mov Byte Ptr cs: [DummySub + BX], AL
  Inc DI
  Inc BX
  loop SubLoop
  pop DI
  push cs
  pop DS
  mov DH, 0
  mov DL, NoSteps
StepLoop:
  push DI
  mov CX, Word Ptr cs: [NoColorsX3]
  mov BX, 0
ColorLoop:
  XOr AH, AH
  mov AL, Byte Ptr cs: [DummySub + BX]
  Or AL, AL
  jns over1
  neg AL
over1:
  mul DH
  Div DL
  cmp Byte Ptr cs: [DummySub + BX], 0
  jge over2
  neg AL
over2:
  mov AH, Byte Ptr ES: [DI]
  add AH, AL
  mov Byte Ptr cs: [DummyPalette + BX], AH
  Inc BX
  Inc DI
  loop ColorLoop
  push DX
  mov  SI, Offset DummyPalette
  mov  CX, Word Ptr cs: [NoColorsX3]
  mov DX, 03DAh
{retrloop1:
  In AL, DX
  Test AL, 8
  jnz retrloop1
retrloop2:
  In AL, DX
  Test AL, 8
  jz retrloop2}
  call VSinc;
  mov DX, 03C8h
  mov AL, StartCol
  out DX, AL
  Inc DX
  rep outsb
  pop DX
  pop DI
  Inc DH
  cmp DH, DL
  jbe StepLoop
  pop DS
End;

Procedure GrabCurPal;
Var
  z: Word;
Begin
  For z := 0 To 255 Do GetPalette (z, curpal [z].r, curpal [z].g,
                                                            curpal [z].b);
End;

Procedure EngineWarpUp;
Var
  z                  :Word;
  Red, Green, Blue   :Byte;
Begin
  Red   := 0;
  Blue  := 0;
  Green := 0;
  While (Red < 60) And (Blue < 60) Do
           Begin
              GetPalette (153, Red, Green, Blue);
              SetColor (153, Red + 1, Green + 1, Blue);
              VSinc;
           End;
  GrabCurPal;
End;

  Procedure VgaBase (Xscroll, Yscroll: Integer);
  Var
    dum       : Word;
    t, slide   : Word;
  Begin
    Dec (SLIDE, (Xscroll + 320 * Yscroll) );
    Port [$03D4] := 13;
    Port [$03D5] := (SLIDE ShR 2) And $FF;
    Port [$03D4] := 12;
    Port [$03D5] := SLIDE ShR 10;
    Dum := Port [$03DA];
    Port [$03C0] := $20 Or $13;
    Port [$03C0] := (SLIDE And 3) ShL 1;
  End;

Procedure Split (Row: Integer);
Begin
  Asm
    mov DX, $3D4
    mov AX, row
    mov BH, AH
    mov BL, AH
    And BX, 201h
    mov CL, 4
    ShL BX, CL
    mov AH, AL
    mov AL, 18h
    out DX, AX
    mov AL, 7
    cli
    out DX, AL
    Inc DX
    In AL, DX
    sti
    Dec DX
    mov AH, AL
    And AH, 0efh
    Or AH, BL
    mov AL, 7
    out DX, AX
    mov AL, 9
    cli
    out DX, AL
    Inc DX
    In AL, DX
    sti
    Dec DX
    mov AH, AL
    And AH, 0bfh
    ShL BH, 1
    ShL BH, 1
    Or AH, BH
    mov AL, 9
    out DX, AX
  End;
End;

  Procedure PlotPage (pag: Word; X, Y : Word; c: Word);
  Begin
    Mem [Seg (pages [pag]^): Ofs (pages [pag]^) + (320 * Y + X) ] := c;
  End;
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}
{ษอMISC. SUPPORT ROUTINESอออออออออออออออออออออออออออออออออออออออออออป}
  Function Wherey: Byte; Assembler;
  Asm
    mov AH, 3;
    mov BH, 0;
    Int $10;
    mov DL, Byte Ptr Wherey;
  End;

  Function Wherex: Byte; Assembler;
  Asm
    mov AH, 3;
    mov BH, 0;
    Int $10;
    mov DH, Byte Ptr Wherex;
  End;

  Procedure GotoXY (X, Y: Byte); Assembler;
  Asm
    mov AH, 2;
    mov BH, 0;
    mov DH, Byte Ptr Y;
    mov DL, Byte Ptr X;
    Int $10;
  End;

  Function KeyPressed : Boolean; Assembler;
  Asm
    Mov AH, 0BH
    Int 21h
  End;

  Procedure ReadKey; Assembler;
  Asm
    XOr AX, AX;
    Int 16h
    cmp AL, 0
    jz @fin
    Int 16h
    @fin:
  End;

  Procedure Delay (ms : Word); Assembler;
  {ms is the number of milliseconds to delay. 1000ms = 1second}
  Asm
    mov AX, 1000
    mul ms
    mov CX, DX
    mov DX, AX
    mov AH, $86
    Int $15
  End;

  Procedure MoveDW (Var z, X; siz: Word); Assembler; {32-Bit Data Move 386+}
  Asm
    push DS
    {xor    ecx,ecx}         db $66, $33, $C9
    mov    CX, [BP + 04];
    ShR    CX, 02;
    les    DI, [BP + 06];
    lds    SI, [BP + $0A];
    cld;
    {     rep movsd} db $F3, $66, $A5;
    pop DS
  End;

  Procedure CopyPage (s, D: Word);
  Begin
    moveDW (pages [s]^, pages [D]^, 64000);
  End;
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

{ษอ UHF FUZZ ROUTINESออออออออออออออออออออออออออออออออออออออออออออออออป}
  Procedure InitUHF;
  Var
    uhfs, uhfo    : Word;
  Begin
    uhfs := Seg (uhfpage^);
    uhfo := Ofs (uhfpage^);
    Asm
      mov CX, 64000;
      mov AX, uhfs;
      mov ES, AX;
      mov DI, uhfo;
      @@St:
      Call rand;
      mov [ES: DI], AX;
      Inc DI
      loop @@st;
    End;
  End;

  Procedure Fuzz (count: LongInt);
  Var
    Y: Word;
    X: Word;
  Begin
    VSinc;
    MoveDW (mem [Seg (uhfpage^): Ofs (uhfpage^) ], pages [1]^, 64000);
    For Y := 0 To count Do Begin
                              VSinc;
                              VGABase (Random (255), Random (255) );
                           End;
    Asm mov AX, $13; Int $10; End;
  End;
{ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}

{ษอINITIALIZATION ROUTINESอออออออออออออออออออออออออออออออออออออออออป}
  Procedure InitPages;
  Begin
    pages [1] := Ptr ($A000, 0000);
    GetMem (pages [2], 64000); FillChar (pages [2]^, 64000, #0);
    GetMem (pages [3], 64000); FillChar (pages [3]^, 64000, #0);
  End;

  Procedure DeInitPages;
  Begin
    Pages [1] := Nil;
    FreeMem (pages [2], 64000);
    FreeMem (pages [3], 64000);
    FreeMem (uhfpage, 64000);
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
  Procedure SetDPPal; Assembler;
  Asm
    mov DX, $3C8;
    XOr AL, AL;
    out DX, AL;
    XOr CX, CX;
    @@St: mov DX, $3C9;
    mov AX, Seg dp;
    mov ES, AX;
    mov AX, Offset dp;
    add AX, CX;
    mov DI, AX;
    mov AX, [ES: DI];
    out DX, AX;
    add DI, CX;
    Inc CX;
    cmp CX, 768;
    jnz @@st;
  End;

  Procedure ZDC; Assembler;
  Asm
    mov CX, 768;
    mov DX, $3C9;
    mov AX, 0;
    @@St:
    out DX, AX;
    loop @@st;
  End;
{ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}
Procedure EatupText; Assembler;
Asm
  mov AX, 0100h;                         {Turn Cursor Off...}
  mov CX, 2000h;
  Int 10h;
  mov CX, 13;
  @@ST: mov DX, 3D4h;
  mov AL, 9;
  out DX, AL;
  mov DX, 3D5h;
  mov AX, CX;
  out DX, AX;
  Call VSinc;
  loop @@st
  Mov AX, 0100h;
  Mov CX, 0607h;
  Int 10h;
End;

Procedure EatDownText; Assembler;
Asm   mov AX, 0100h;                         {Turn Cursor Off...}
  mov CX, 2000h;
  Int 10h;
  mov CX, 0;
  @@ST: mov DX, 3D4h;
  mov AL, 9;
  out DX, AL;
  mov DX, 3D5h;
  mov AX, CX;
  out DX, AX;
  Call VSinc;
  cmp CX, 15;
  Inc CX;
  jb @@ST;
  Mov AX, 0100h;
  Mov CX, 0607h;
  Int 10h;
End;

{ษอSPRITE HANDLING ROUTINESออออออออออออออออออออออออออออออออออออออออออออออป}
  Procedure GrabSpr;
  Begin
    For b := 0 To 45 Do        {This grabs SR Logo}
      For a := 0 To 179 Do Move (mem [$A000: 320 * b + a], srspr [a, b], 1);
    
    For b := 0 To 40 Do        {This grabs starship.}
      For a := 0 To 195 Do Move (mem [$A000: 320 * (b + 47) + a], entspr [a, b] , 1);
    
    For b := 0 To 112 Do        {This grabs insignia}
      For a := 0 To 58 Do Move (mem [$A000: 320 * b + (a + 203) ], trekspr [a, b] , 1);
    
  End;

  Procedure SprSetup;
   Begin
     ZDC;
     FillChar(WhitePal, 768, 63);
     FillChar(BlackPal, 768, 0);
     DrawPCX(40960, @SRL, 7769);
     DrawPCX(Seg(pages[3]^), @space, 5225);
     grabspr;
     FillChar(mem[$A000:0],64000,0);
     SetDpPal;
   End;

  Procedure PutTitle (X, Y: Word; p: Word);
   Begin
    For b := 0 To 45 Do
      For a := 0 To 179 Do
        If srspr [a, b] > 0 Then plotpage (p, a + X, b + Y, srspr [a, b] );
   End;

  Procedure PutEnt (X, Y: Word; p: Word);
   Begin
    For b := 0 To 40 Do
      For a := 0 To 195 Do
        If entspr [a, b] > 0 Then plotpage (p, a + X, b + Y, entspr [a, b] );
   End;

  Procedure PutTrek (X, Y: Word; p: Word);
  Begin
    For b := 0 To 112 Do
      For a := 0 To 58 Do
        If trekspr [a, b] > 0 Then plotpage (p, a + X, b + Y, trekspr [a, b] );
  End;
{ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ}
Procedure ExitANSI;
Var
  Y, X  : Word;
Begin
  Asm   mov AX, $3; Int $10; mov AX, 0100h; mov CX, 2000h; Int 10h; End;
  GrabCurPal;
  ZDC;
  Split (399);
  Move (@SRTXT^,  Mem [$B800: 0000], 4000);
  Asm
    Mov AH, 5
    mov AL, 1
    Int $10
  End;
  FadeColors (@BlackPal, @CurPal, 0, 255, 10);
  Y := 399;
  While Y > 0 Do                       {For y:=0 to}
  Begin
    Split (Y);
    VSinc;
    Dec (Y, 1);
  End;
  Repeat Until KeyPressed;                {Wait for keypress}
  FadeColors (@CurPal, @WhitePal, 0, 255, 10);
  FadeColors (@WhitePal, @BlackPal , 0, 255, 10);
  Asm mov AX, 3; Int $10; End;
End;

{ึฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤMAIN HERE!!!!!!!!!!!ฤฤฤฤฤฤฤฤฤฤท}
Procedure MainProgram;
Begin
  {Old Sprite Setup Goes Here}
  FillChar (mem [$A000: 0], 64000, 0);
  SetDPPal;
  c := 0;
  While c < 100 Do Begin
    CopyPage (3, 2);
    Vsinc;
    PutEnt (c, 100, 2);
    CopyPage (2, 1);
    Inc (c, 5);
  End;
  EngineWarpUp;
  FadeColors (@CurPal, @WhitePal, 0, 255, 15);
  CopyPage (3, 2);
  PutTitle (70, 20, 2);
  PutTrek (125, 75, 2);
  CopyPage (2, 1);
  FadeColors (@WhitePal, @Dp, 0, 255, 200);
  c := 0;
  Repeat
    SetColor (31, Abs (c), Abs (c), Abs (c) );
    Inc (c);
    If c = 63 Then c := - c;
  Until KeyPressed; ReadKey;
  FadeColors (@Dp, @BlackPal, 0, 255, 25);
  FillChar (mem [$A000: 0000], 64000, 0);
  SetDPPAl;
End;
{ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ ฤฤ}
Begin
  curx := WhereX;
  cury := WhereY;
  GetMem (txtpage, 4000);
  Move(mem[$B800:0000], txtpage^, 4000);
  GetMem(uhfpage, 64000);
  FillChar(uhfpage^, 64000, 0);
  Reseed;
  InitUHF;
  EatupText;
   InitializeVideo;
    SprSetup;
    Fuzz(50);
     MainProgram;
    Fuzz(50);
   DeInitializeVideo;
  ExitAnsi;
  Move (txtpage^, mem [$B800: 0000], 4000);
  EatDownText;
  FreeMem (txtpage, 4000);
  GotoXY (curx, cury);
  ReadKey;
End.