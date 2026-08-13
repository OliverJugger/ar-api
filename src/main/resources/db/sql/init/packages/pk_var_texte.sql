CREATE OR REPLACE package ARTHUS.pk_var_texte IS
Procedure charge_contexte(	a_contexte in number,
				a_cle in number
				);
PRAGMA RESTRICT_REFERENCES(charge_contexte, WNDS);
Function f_eval_variable(
			a_contexte in number,
			a_cle in number
			)
Return	number;
PRAGMA RESTRICT_REFERENCES(f_eval_variable, WNDS);
comm_numindiv	number default 0;	/* Contexte 0 - Personne, Assure */
comm_numgar	number default 0;	/* Contexte 2 - Contrat */
comm_numcli	number default 0;	/* Contexte 3 - Souscripteur */
comm_numassu	number default 0;	/* Contexte 4 - Assure Principal */
comm_numorg	number default 0;	/* Contexte 5 - Organisme assureur */
comm_numprod	number default 0;	/* Contexte 7 - Produit */
comm_apporteur	number default 0;	/* Contexte 8 - Apporteur */
comm_numsoc	number default 0;	/* Contexte 9 - Societe */
comm_idadhesion	number default 0;	/* Contexte 13 - Adhesion */
comm_apporteur	number default 0;	/* Contexte 14 - Prospect */
comm_nosin	number default 0;	/* Contexte 15 - Sinistre Prev */
comm_numbene	number default 0;	/* Contexte 16 - Beneficiaire Prev */
comm_debut	date default trunc(sysdate);	/* Date de debut */
comm_fin	date default trunc(sysdate);	/* Date de fin */
type t_cle_contexte is table of number index by binary_integer;
end pk_var_texte;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_VAR_TEXTE" IS
/*	Recherche des cles principales selon l'operation de gestion */
Procedure charge_contexte(
			a_contexte in number,
			a_cle in number
			)
IS
loc_variable	number := 0;
loc_retour	number default 0;
BEGIN
If ( a_contexte in (1, 12) ) then
	Begin
	Select	numgar,
		idadhesion,
		numindiv,
		debut,
		fin
	Into	comm_numgar,
		comm_idadhesion,
		comm_numindiv,
		comm_debut,
		comm_fin
	From	qttc_global
	Where	numquit = a_cle;
	End;
End if;
If ( a_contexte in (2, 17, 18, 19, 20) ) then
	Begin
	Select	repartition.idadhesion,
		sin.nosin,
		sin.numindiv,
		sin.datesurv,
		null
	Into	comm_idadhesion,
		comm_nosin,
		comm_numindiv,
		comm_debut,
		comm_fin
	From	sin_prev sin,
		repartition
	Where	sin.nosin = repartition.nosin
	and	repartition.idrepartition = a_cle;
	End;
End if;
If ( a_contexte = 9 ) then
	Begin
	Select	pricharge.numgar,
		0,
		pricharge.numindiv,
		pricharge.numassu,
		pricharge.datehospi
	Into	comm_numgar,
		comm_idadhesion,
		comm_numindiv,
		comm_numassu,
		comm_debut
	From	pricharge
	Where	pricharge.numpc = a_cle
	;
	End;
End if;
If ( a_contexte = 13 ) then
	comm_idadhesion := a_cle;
End if;
If ( comm_idadhesion != 0 ) then
	Begin
	Select	numgar
	Into	comm_numgar
	From	adhe_cntrt
	Where	idadhesion = comm_idadhesion
	;
	Exception When No_data_found then comm_numgar := 0;
	End;
End if;
If ( a_contexte = 2 ) then
	comm_numgar := a_cle;
End if;
If ( comm_numgar != 0 ) then
	Begin
	Select	contrat.numprod,
		contrat.numcli,
		contrat.numorg,
		contrat.numinterm
	Into	comm_numprod,
		comm_numcli,
		comm_numorg,
		comm_numsoc
	From	contrat
	Where	numgar = comm_numgar
	;
	End;
End if;
If ( comm_numindiv != 0 ) then
	Begin
	Select	indvs.numassu
	Into	comm_numassu
	From	indvs
	Where	numindiv = comm_numindiv
	;
	Exception When No_data_found then comm_numassu := 0;
	End;
End if;
END charge_contexte;
/*	Recherche de la valeur de la variable	*/
FUNCTION f_eval_variable(
			a_contexte in number,
			a_cle in number
			)
RETURN 	number
AS
loc_variable	number := 0;
loc_retour	number default 0;
BEGIN
charge_contexte(a_contexte, a_cle);
loc_retour := comm_numgar;
return(loc_retour);
END f_eval_variable;
End pk_var_texte;
/
