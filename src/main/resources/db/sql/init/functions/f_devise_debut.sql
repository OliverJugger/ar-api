CREATE FUNCTION ARTHUS.f_devise_debut(
			a_numsoc in number,
			a_numgar in number default 0,
			a_idadhesion in number default 0,
			a_codmon in number,
			a_debut in date)
RETURN date
AS
	loc_debut	date ;
BEGIN
	/* Parametrage global adhesion	*/
	Begin
	Select max(debut)
	Into loc_debut
	From param_devise
	Where param_devise.numsoc=a_numsoc
	And param_devise.codmon=a_codmon
	And param_devise.numgar=a_numgar
	And nvl(a_debut,param_devise.debut)>=param_devise.debut
	And param_devise.idadhesion=a_idadhesion;
	End;
	if (loc_debut is null) then
	/* Parametrage global contrat	*/
	Begin
	Select max(debut)
	Into loc_debut
	From param_devise
	Where param_devise.numsoc=a_numsoc
	And param_devise.codmon=a_codmon
	And param_devise.numgar=a_numgar
	And nvl(a_debut,param_devise.debut)>=param_devise.debut
	And param_devise.idadhesion=0;
	End;
	if (loc_debut is null) then
	/* Parametrage global societe	*/
	Begin
	Select max(debut)
	Into loc_debut
	From param_devise
	Where param_devise.numsoc=a_numsoc
	And param_devise.codmon=a_codmon
	And param_devise.numgar=0
	And nvl(a_debut,param_devise.debut)>=param_devise.debut
	And param_devise.idadhesion=0;
	End;
	end if;
	end if;
return(loc_debut);
END;
