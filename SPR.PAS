procedure PutSprite(SpritePtr : Pointer; X, Y, XLen, YLen : Word);
var
   SprSeg, SprOfs, ScrOfs, XCount, YCount :Word;
   Pixel                                  :Byte;
begin
     ScrOfs := Y*320+X;
     SprSeg := Seg(SpritePtr);
     SprOfs := 0;
     for YCount := Y to Y+YLen-1 do
     begin
          for XCount := X to X+XLen-1 do
          begin
               Pixel := Mem[SprSeg:SprOfs];
               SprOfs := SprOfs + 1;
               if Pixel<>0 then Mem[$A000:ScrOfs] := Pixel;
               ScrOfs := ScrOfs + 1;
          end;
          ScrOfs := ScrOfs-XLen+320;
     end;
end;
