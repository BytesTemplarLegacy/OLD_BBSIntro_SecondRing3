Const
     seed1	:word=	$1234;
     seed2	:word=	$5678;
     seed3	:word=	$1234;
     seed4	:word=	$5678;

Function Random:Byte; Assembler;
Asm
        push bx
        push cx
        push dx
	mov	ax,ds:seed1
	mov	bx,ds:seed2
	mov	cx,ds:seed3
	mov	dx,ds:seed4
	add	ax,bx
	rol	ax,cl
	xor	ax,dx
	xchg	cl,ch
	add	bx,cx
	add	dx,bx
	add	cx,ax
	ror	bx,1
	sbb	ax,dx
	mov	ds:seed4,dx
	mov	ds:seed3,dx
	mov	ds:seed2,dx
	mov	ds:seed1,ax
@L2:    cmp     ax, 16
        jb     @boo;
        shr ax, 5;
        jmp @L2
@boo:
        add ax, 16;
        pop dx
        pop cx
        pop bx
End;
Var
   z:byte;
Begin
     Repeat
      z:=random;
      if (z<16) or (z>32) then WriteLn(^G);
      if z=16 then writeln(^G,^G);
      WriteLn(z);
     Until False;
End.