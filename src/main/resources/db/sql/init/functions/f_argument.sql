CREATE function ARTHUS.f_argument (
				a_fonction 	in Varchar2,
				a_chaine 	in Varchar2
				)
Return Varchar2
As
loc_retour	varchar2(32);
Ouvert		Varchar2(1) := '(';
Ferme		Varchar2(1) := ')';
Deb_arg		Binary_integer;
Fin_arg		Binary_integer;
Deb_funct	Binary_integer;
BEGIN
Deb_funct := Instr( a_chaine, a_fonction );
Deb_arg := Instr( a_chaine, Ouvert, Deb_funct );
Fin_arg := Instr( a_chaine, Ferme, Deb_arg );
loc_retour := Substr( a_chaine, Deb_arg + 1, Fin_arg - Deb_arg - 1 );
Return ( loc_retour );
END	f_argument;
