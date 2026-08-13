CREATE function ARTHUS.f_convert_montant (
				a_montant in number,
				a_monnaie in number,
				a_monnaie_convert in number,
				a_debut in date default sysdate
				)
Return number
as
loc_montant	number;
loc_datcours    change%Rowtype;
BEGIN
	For loc_datcours in
	(
		Select datcours
		From change
		Where codmon=a_monnaie_convert
		And codmon_ref=a_monnaie
		And datcours<=a_debut
		Order by datcours desc
	)
	Loop
	Select round(a_montant/(change.valeur*change.base),2)
	Into loc_montant
	From change
	Where codmon=a_monnaie_convert
	And codmon_ref=a_monnaie
	And datcours=loc_datcours.datcours;
	End loop;
	Return(loc_montant);
	Exception
			When no_data_found then
				loc_montant:=a_montant;
			Return(loc_montant);
END;
