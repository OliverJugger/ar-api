CREATE function ARTHUS.f_longueur(a_chaine In varchar2,a_longueur In Number)Return Varchar2
Is
	loc_chaine varchar2(80);
BEGIN
	Return(substr(a_chaine,1,a_longueur));
END;
