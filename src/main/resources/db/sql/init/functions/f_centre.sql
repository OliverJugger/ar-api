CREATE function ARTHUS.f_centre (
				a_chaine in varchar2,
				a_longueur in number)
Return varchar2
As
BEGIN
	return ( lpad(' ',(a_longueur-length(a_chaine))/2)||a_chaine );
END;
