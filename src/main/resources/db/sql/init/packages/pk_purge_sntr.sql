CREATE OR REPLACE PACKAGE ARTHUS.pk_purge_sntr AS
-- Chaine de reconnaissance SCCS
-- %W% Purge des sinistres %E%
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
G_nom_traitement Varchar2(25) := 'Purge sntr';
G_session		Number := 0;
-- --------------------------------------------- Fin des variables publiques --
-- -- PROCEDURES PUBLIQUES ----------------------------------------------------
Procedure Purge ( I_date_butoir IN Date );
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_purge_sntr AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%
-- -- CONSTANTES PRIVEES ------------------------------------------------------
Cst_nb_commit	Number := 199;
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
Procedure Purge ( I_date_butoir IN Date )
IS
CURSOR C_decaismt IS
Select	numdecaismt,
	datpay
From	decaismt
Where	codope +0	= 1
and	flagpay		= 1
and	datpay		<= I_date_butoir
Order By
	flagpay,
	datpay;
CURSOR C_affectation ( P_numdecaismt decaismt.numdecaismt%type ) IS
Select	numaffec
From	affectation
Where	numdecaismt = P_numdecaismt;
CURSOR C_decompte ( P_numaffec affectation.numaffec%type ) IS
Select	numdec
From	decompte
Where	numdec = P_numaffec;
CURSOR C_sinistre ( P_numdec decompte.numdec%type ) IS
Select	numsin
From	sinistre
Where	numdec = P_numdec;
CURSOR C_sntr_ref ( P_numsin sinistre.numsin%type ) IS
Select	numremise,
	numsin_porte
From	sntr_ref
Where	numsin = P_numsin;
Rec_C_decaismt		C_decaismt%RowType;
Rec_C_affectation	C_affectation%RowType;
Rec_C_decompte		C_decompte%RowType;
Rec_C_sinistre		C_sinistre%RowType;
Rec_C_sntr_ref		C_sntr_ref%RowType;
Nb_purge		Number := 0;
Nb_tot_purge		Number := 0;
L_idsession		Number := 0;
BEGIN
Open C_decaismt;
Loop
	Fetch C_decaismt Into Rec_C_decaismt;
	Exit When C_decaismt%NotFound;
		Open C_affectation( Rec_C_decaismt.numdecaismt );
		Loop
			Fetch C_affectation Into Rec_C_affectation;
			Exit When C_affectation%NotFound;
			Open C_decompte( Rec_C_affectation.numaffec );
			Loop
				Fetch C_decompte Into Rec_C_decompte;
				Exit When C_decompte%NotFound;
				Open C_sinistre( Rec_C_decompte.numdec );
				Loop
					Fetch C_sinistre Into Rec_C_sinistre;
					Exit When C_sinistre%NotFound;
					Open C_sntr_ref( Rec_C_sinistre.numsin );
					Loop
						Fetch C_sntr_ref Into Rec_C_sntr_ref;
						Exit When C_sntr_ref%NotFound;
						Begin
						Delete	sinistre_porte
						Where	numremise	= Rec_C_sntr_ref.numremise
						and		numsin	= Rec_C_sntr_ref.numsin_porte;
						End;
					End Loop;
					Begin
					Delete	sntr_ref
					Where	numsin	= Rec_C_sinistre.numsin;
					End;
					Close C_sntr_ref;
					Begin
					Delete	forcage
					Where	numsin	= Rec_C_sinistre.numsin;
					End;
				End Loop;
				Begin
				Delete	sinistre
				Where	numdec	= Rec_C_decompte.numdec;
				End;
				Close C_sinistre;
				Begin
				Delete	courrier
				Where	numdec	= Rec_C_decompte.numdec;
				End;
			End Loop;
			Begin
			Delete	decompte
			Where	numdec	= Rec_C_affectation.numaffec;
			End;
			Close C_decompte;
		End Loop;
		Begin
		Delete	affectation
		Where	numdecaismt	= Rec_C_decaismt.numdecaismt;
		End;
		Close C_affectation;
		Begin
		Delete	decaismt
		Where	numdecaismt	= Rec_C_decaismt.numdecaismt;
		End;
Nb_purge := Nb_purge + 1;
If ( Nb_purge > Cst_nb_commit ) then
	Nb_tot_purge := Nb_tot_purge + Nb_purge;
	L_idsession := L_idsession + 1;
	Nb_purge := 0;
	pk_trace.P_INS_journal_adm
		    ( I_nom_traitement => G_nom_traitement,
			 I_session        => L_idsession,
			 I_niv_msg        => 1,
			 I_msg_adm        => 'Date = '|| to_char(Rec_C_decaismt.datpay, 'dd/mm/yyyy') ||' '|| to_char(Nb_tot_purge) || ' supprimés',
			 I_date           => Sysdate );
Commit;
End if;
End Loop;
Close C_decaismt;
END Purge;
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --
END;
/
