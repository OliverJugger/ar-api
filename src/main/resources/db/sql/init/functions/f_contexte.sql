CREATE function ARTHUS.f_contexte   (a_mnemo in varchar2,
					 a_code in number)
		RETURN	number
as
	loc_contexte number;
BEGIN
	Begin
	Select sens
	Into loc_contexte
	From lble
	Where mnemo=a_mnemo
	And code=a_code;
	Exception
	When no_data_found then loc_contexte:=-1;
	End;
return(loc_contexte);
END;
