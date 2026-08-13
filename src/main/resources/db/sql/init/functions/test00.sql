CREATE function ARTHUS.test00(x in number)
Return number
As
BEGIN
If ( x = 8 ) then
Return(1);
Elsif (x = 10) then
Return(2);
End If ;
Return(3);
END test00;
