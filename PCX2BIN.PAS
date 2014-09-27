{$G+,A+,S-,R-,I-}
Program PCX2BIN1_1;
Uses VGAKern,Imaging,RawFunc;
Const
     makepal    :boolean=false;
Var
   binfile      :file;
   palfile      :file;
   x            :word;
Procedure Help;
Begin
     WriteLn('Useage: PCX2BIN pcx_filename bin_filename [pal_filename] <潰');
     WriteLn('様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様');
     WriteLn(' The third parameter is optional, and will only make the PAL');
     WriteLn(' file if it is specified!');
End;

Procedure ErrorControl;
Begin
   If ParamCount=0 then Begin Help; Halt(5); End;
   If ParamStr(1)='' then Begin
                           WriteLn('I need a frigg''n PCX file to convert!');
                           Halt(1);
                          End;
   If Not Exist(ParamStr(1)) then Begin
                                   writeln('File Doesn''t Exist. DooDooDooDoo!');
                                   Halt(3);
                                  End;
   If ParamStr(2)='' then Begin
                           WriteLn('...and what should I name the .BIN??');
                           Halt(2);
                          End;
   If ParamStr(3)<>'' then makepal:=true;
End;

Begin
   ErrorControl;
   OpenMode(1);
   LoadPCX(ParamStr(1));
   fSetColors(RGB256);
   Assign(binfile,paramstr(2));
   Rewrite(binfile,1);
   BlockWrite(binfile, mem[$A000:0], 64000);
   if makepal=true then begin
                          assign(palfile,paramstr(3));
                          rewrite(palfile,1);
                          blockwrite(palfile, rgb256, 768);
                          close(palfile);
                        end;
   Close(binfile);
   CloseMode;
End.