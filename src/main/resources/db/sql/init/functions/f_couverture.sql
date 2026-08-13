CREATE function ARTHUS.f_couverture	(
							a_numindiv 		IN NUMBER,
							a_idadhesion	IN NUMBER,
							a_numfor		IN NUMBER,
							a_date		IN DATE,
							a_type 		IN NUMBER default 1
							)
RETURN NUMBER
AS
loc_retour	number default 1;

cursor C_couv is
select	adhesion.etat,
		d2j(adhesion.datapli) 	datapli,
		d2j(adhesion.datper)	datper
from		adhesion
where		adhesion.idadhesion 	= a_idadhesion
And		adhesion.numindiv		= a_numindiv
and		adhesion.numfor		= a_numfor
and		a_date 			between adhesion.datapli and nvl(greatest(adhesion.datper,a_date),a_date)
and		adhesion.typfor		= 1
union
select	adhesion.etat,
		d2j(adhesion.datapli) 	datapli,
		d2j(adhesion.datper)	datper
from		adhesion,
		grp_gar_def
where		adhesion.idadhesion 	= a_idadhesion
And		adhesion.numindiv 	= a_numindiv
and		adhesion.numfor 		= grp_gar_def.numgrpgar
and		grp_gar_def.numfor 	= a_numfor
and		a_date 			between adhesion.datapli and nvl(greatest(adhesion.datper,a_date),a_date)
and		adhesion.typfor		= 3
and		grp_gar_def.typfor	= 1
;

Rec_C_couv	C_couv%Rowtype;

BEGIN

   begin

	Open C_couv;
	fetch C_couv into Rec_C_couv;
	If (C_couv%Found) then
		If (a_type=1) Then
			loc_retour := Rec_C_couv.etat;
		Elsif (a_type=2) Then
			loc_retour := Rec_C_couv.datapli;
		Elsif (a_type=3) Then
			loc_retour := Rec_C_couv.datper;
		End if;

	Else
		If (a_type=1) Then
			loc_retour := 0;
		Elsif (a_type=2) Then
			loc_retour := null;
		Elsif (a_type=3) Then
			loc_retour := null;
		End if;

	end if;
	close C_couv;
   end;

return loc_retour;

END f_couverture;
