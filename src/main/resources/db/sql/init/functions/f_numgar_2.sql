CREATE function ARTHUS.f_numgar_2(a_numfor in number)
return number
is
loc_numgar number;
begin
	Select numgar
	Into loc_numgar
	from gar_cntrt
	Where numfor=a_numfor;
return(loc_numgar);
End;
