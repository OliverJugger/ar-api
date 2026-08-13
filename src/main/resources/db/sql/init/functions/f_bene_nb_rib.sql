CREATE function ARTHUS.f_bene_nb_rib(
		a_numindiv	in number,
		a_codope	in number,
		a_numgar	in number,
		a_dec_enc	in number,
    a_date in date default sysdate)
	return NUMBER
as
/*===========================================================================*/
/* Fonction     : F_BENE_NB_RIB.sql                                          */
/* Domaine      : Personne                                                   */
/* Version      : V1.0                                                       */
/* Auteur       : ACA                                                        */
/* Création     : 02/03/2011                                                 */
/* Description  : Ce programme recherche le nombre de RIBs valides pour une  */
/*              : personne en fonction du code de l'opération concernée, du  */
/*              : numéro de contrat, du sens de l'opération et de la date de */
/*              : validité, le dernier paramètre étant optionnel.            */
/*              : Cette fonction est 'calquée' sur la fonction F_BENE_RIB et */
/*              : a été mise en place dans le cadre du projet d'évolution    */
/*              : des RIBs. Toute évolution de la fonction F_BENE_RIB doit   */
/*              : être reportée dans la fonction F_BENE_NB_RIB.              */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : PHA / 20/06/2013 / corr. boucle infinie sur loop           */
/*===========================================================================*/
	loc_nb_rib	number; -- début aca
	loc_numgar	number;
	loc_codope	number;
	loc_date	date;
begin
loc_nb_rib:=0;
loc_numgar:=a_numgar;
loc_codope:=a_codope;
loc_date:=trunc(a_date);
<<Debut>>
While (loc_nb_rib = 0)
Loop
	begin
	select	count(distinct rib.devise_compte)
	into	loc_nb_rib
	from	rib
	where	rib.numindiv	= a_numindiv
	and	rib.codope	    = loc_codope
	and	rib.numgar	    = loc_numgar
	and	rib.type	      = a_dec_enc
	and	loc_date	     >= rib.debut
  and ((rib.fin is null) or (loc_date	<= rib.fin))
  ;
	end;
	If ( loc_nb_rib = 0 ) then
		If ( loc_numgar != 0) then
			loc_numgar := 0;
			Goto debut;
		Elsif (loc_codope != 0) then
			loc_codope := 0;
			Goto debut;
		Elsif ( loc_date != to_date('3000', 'yyyy') ) then
			loc_date := to_date('3000', 'yyyy');
			Goto debut;
		Else
			loc_nb_rib := 0;
      Exit;
		End if;
	End if;
End loop;
return (loc_nb_rib);
end;
