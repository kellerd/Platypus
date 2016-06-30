PLATYPUS
{
   FOR(I=-99999.0,I<99999.0,I=I+1.0) DO {
        IF(I<0) THEN
            {A=A+2;}
        ELSE
            {A=A+4;}
        WRITE(I);WRITE();
   }
}
