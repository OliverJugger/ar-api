CREATE FUNCTION ARTHUS.f_param_devise(
			a_numsoc in number,
			a_numgar in number default 0,
			a_idadhesion in number default 0,
			a_debut in date)
RETURN number
AS
	loc_devise	number 	default 0;
	loc_debut	date;
BEGIN
	/* Parametrage global adhesion	*/
	Begin
	Select max(debut)
	Into loc_debut
	From param_devise
	Where param_devise.numsoc=a_numsoc
	And param_devise.numgar=a_numgar
	And param_devise.idadhesion=a_idadhesion
	And nvl(a_debut,param_devise.debut)>=param_devise.debut;
	End;
	Begin
	Select codmon
	Into loc_devise
	From param_devise
	Where param_devise.numsoc=a_numsoc
	And param_devise.numgar=a_numgar
	And param_devise.idadhesion=a_idadhesion
	And param_devise.debut=loc_debut;
	Exception when no_data_found then
	Begin
	Select max(debut)
	Into loc_debut
	From param_devise
	Where param_devise.numsoc=a_numsoc
	And param_devise.numgar=a_numgar
	And param_devise.idadhesion=0
	And nvl(a_debut,param_devise.debut)>=param_devise.debut;
	End;
	Begin
	Select codmon
	Into loc_devise
	From param_devise
	Where param_devise.numsoc=a_numsoc
	And param_devise.numgar=a_numgar
	And param_devise.idadhesion=0
	And param_devise.debut=loc_debut;
	Exception when no_data_found then
	/* Parametrage global societe	*/
	Begin
	Select max(debut)
	Into loc_debut
	From param_devise
	Where param_devise.numsoc=a_numsoc
	And param_devise.numgar=0
	And param_devise.idadhesion=0
	And nvl(a_debut,param_devise.debut)>=param_devise.debut;
	End;
	Begin
	Select codmon
	Into loc_devise
	From param_devise
	Where param_devise.numsoc=a_numsoc
	And param_devise.numgar=0
	And param_devise.idadhesion=0
	And param_devise.debut=loc_debut;
	End;
	End;
	End;
return(loc_devise);
END;
