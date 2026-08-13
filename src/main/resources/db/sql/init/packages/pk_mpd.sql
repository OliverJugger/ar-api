CREATE OR REPLACE PACKAGE ARTHUS.pk_mpd AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%
-- -- CONSTANTES PUBLIQUE -----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des constantes publiques --
-- -- EXCEPTIONS PUBLIQUES ----------------------------------------------------
-- Aucune
-- -------------------------------------------- Fin des exceptions publiques --
-- -- TYPES PUBLIQUES ---------------------------------------------------------
-- Aucun
-- ------------------------------------------------- Fin des types publiques --
-- -- VARIABLES PUBLIQUES -----------------------------------------------------
-- Aucune
-- --------------------------------------------- Fin des variables publiques --
-- -- PROCEDURES PUBLIQUES ----------------------------------------------------
-- Procedure Charge_entite;
Procedure P_MAJ_retrocession;
Procedure P_INS_facture_annul;
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_mpd AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%
-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --
-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --
-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --
-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
-- Aucune
-- -------------------------------------- Fin des variables globales privees --
-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
-- Aucune
-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
-- Aucune
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
/*
Procedure Charge_entite
Is
BEGIN
Insert into def_entite(codope,cle)
Select 	distinct
	old_sous_def_entite.codope,
	old_sous_def_entite.cle_possible
From	old_sous_def_entite
;
Update param_texte
set code=28,contexte=-99
where code=5;
Update param_texte
set code=28,contexte=-99
where code=99;
Update valide_texte set contexte=-99
where idtexte in(select idtexte from param_texte where nom_crrr in
		('CARENCE','FRCH1','FRCH2','PLF1','PLF2'));
END Charge_entite;
*/
Procedure P_MAJ_retrocession
IS
Cursor C_retrocession IS
	Select	numquit,
		numbene,
		type_comm
	From	qttc_retro
	Where	prelev_revers Is Null;
Cursor C_apporteur( P_numquit Number, P_numbene Number, P_type_comm Number ) IS
	Select	apporteur.mode_retro
	From	apporteur,
		qttc_global
	Where	apporteur.etendue = qttc_global.type_qttc *2
	and	apporteur.cle = decode( qttc_global.type_qttc,
				1, qttc_global.numgar,
				2, qttc_global.idadhesion)
	and	apporteur.type = P_type_comm
	and	apporteur.numindiv = P_numbene
	and	apporteur.debut != nvl( apporteur.fin, apporteur.debut + 1 )
	and	qttc_global.debut between apporteur.debut
			and nvl( apporteur.fin, qttc_global.debut )
	and	qttc_global.numquit = P_numquit;
Rec_C_retrocession 	C_retrocession%Rowtype;
Rec_C_apporteur		C_apporteur%Rowtype;
BEGIN
Open C_retrocession;
Loop
	Fetch C_retrocession Into Rec_C_retrocession;
	Exit When C_retrocession%NotFound;
	Open C_apporteur(
			Rec_C_retrocession.numquit,
			Rec_C_retrocession.numbene,
			Rec_C_retrocession.type_comm
			);
	Fetch C_apporteur Into Rec_C_apporteur;
	If C_apporteur%NotFound then
		Dbms_output.put_line( 'Apporteur non trouve pour numquit '
				|| Rec_C_retrocession.numquit );
	Else
		Update	qttc_retro
		Set	prelev_revers = Rec_C_apporteur.mode_retro
		Where	numquit = Rec_C_retrocession.numquit
		and	numbene = Rec_C_retrocession.numbene
		and	type_comm = Rec_C_retrocession.type_comm;
		If ( Rec_C_apporteur.mode_retro = 1 ) then
			Update	qttc_affec_tfc
			Set     prelev_revers = Rec_C_apporteur.mode_retro,
				idrevers = -1
			Where   numquit = Rec_C_retrocession.numquit
			and     numbene = Rec_C_retrocession.numbene
			and     type_tfc = Rec_C_retrocession.type_comm
			and	tfc = 5;
		Else
			Update	qttc_affec_tfc
			Set     prelev_revers = Rec_C_apporteur.mode_retro
			Where   numquit = Rec_C_retrocession.numquit
			and     numbene = Rec_C_retrocession.numbene
			and     type_tfc = Rec_C_retrocession.type_comm
			and	tfc = 5;
		End if;
	End if;
	Close C_apporteur;
End Loop;
Close C_retrocession;
END P_MAJ_retrocession;
Procedure P_INS_facture_annul
IS
Cursor C_emission IS
	Select 	codope,
		numfact,
		datemis
	From	emission
	Where	numrelance in (4, 99);
Rec_C_emission	C_emission%Rowtype;
BEGIN
Open C_emission;
Loop
	Fetch C_emission Into Rec_C_emission;
	Exit When C_emission%NotFound;
	Begin
	Insert into facture_annul (
		Codope,
		Numfact,
		Datope)
	Select	Rec_C_emission.codope,
		Rec_C_emission.numfact,
		Rec_C_emission.datemis
	From	Dual
	Where Not Exists (
		Select 	1
		From	facture_annul
		Where	facture_annul.codope = Rec_C_emission.codope
		and	facture_annul.numfact = Rec_C_emission.numfact);
	Update facture
	Set	idcompta = -1
	Where	codope = Rec_C_emission.codope
	and	numfact = Rec_C_emission.numfact
	and	idcompta + 0 = -2;
	End;
End Loop;
Close C_emission;
END P_INS_facture_annul;
END;
-- ------------------------------------ Fin des corps des procedures privees --;
/
