CREATE function ARTHUS.f_numgar(a_idadhesion in number)
return number
is
loc_numgar number;
begin
	Select numgar
	Into loc_numgar
	from adhe_cntrt
	Where idadhesion=a_idadhesion;
return(loc_numgar);
End;
