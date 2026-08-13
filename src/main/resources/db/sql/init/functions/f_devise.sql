CREATE function ARTHUS.f_devise (
				a_codmon in number)
Return varchar2
as
loc_symbole	varchar2(3);
BEGIN
	Select symbole
	Into loc_symbole
	From mone
	Where codmon=a_codmon;
	Return(loc_symbole);
	Exception
			When no_data_found then
				loc_symbole:='';
			Return(loc_symbole);
END;
