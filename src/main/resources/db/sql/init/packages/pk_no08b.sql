CREATE OR REPLACE PACKAGE ARTHUS.pk_no08b AS
--
PROCEDURE P_no08b(
		 I_numporte	IN  	param_tiers_payant.numporte%Type 	default NULL,
		 I_deb_numgar	IN  	porte_contrat.numgar%TYPE		default NULL,
		 I_fin_numgar	IN  	porte_contrat.numgar%TYPE		default NULL,
		 I_date_attest	IN	VARCHAR2				default NULL,
		 I_param1	IN	param_batch.param1%type			default NULL,
		 I_session	IN	NUMBER					Default 1,
		 I_niv_msg	IN	NUMBER					Default 1,
		 I_pause	IN	NUMBER					Default 0,
		 O_found	OUT	NUMBER,
		 O_erreur	OUT	VARCHAR2
		);
--

--
-- Chaine de reconnaissance SCCS
-- %W%	%E%

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
-- Aucune
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_no08b AS
-- Chaine de reconnaissance SCCS
-- %W%	%E%

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
--
PROCEDURE P_CORPS_traitement;
--
PROCEDURE P_INS_journal;
--
-- ----------------------------- Fin des declarations des procedures privees --

-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
-- Aucune
-- ---------------------------------- Fin des corps des procedures publiques --
--
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --

-- Variables de sortie
--

--
-- Variables globales priv‚es
--
G_comm_numedit		file_edition.numedit%type;
--
G_etendue		number;
--
-- parametres du traitement
G_numporte		param_tiers_payant.numporte%type;
G_numgar_deb	        porte_contrat.numgar%Type;
G_numgar_fin	        porte_contrat.numgar%Type;
G_date_attest		DATE;
--
-- Flag de commit ou rollback a retourner a Forms
G_commit		Boolean := FALSE;
G_rollback		Boolean := FALSE;
G_auto_valide		Boolean := FALSE;
--
G_flag_test		NUMBER;
G_proc			VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%Type default 'pk_NO08B';
G_msg_adm		journal_adm.msg_adm%Type;
G_session		journal_adm.id_session%Type default 1;
G_niv_msg		journal_adm.niv_msg%TYPE := 1;
G_max_msg		journal_adm.niv_msg%TYPE := 1;
G_idligne		journal_adm.idligne%TYPE := 0;
G_erreur		journal_adm.msg_adm%Type;
G_nb_demande number;
-- G_niv_msg prend les Valeurs :
--	0 --> Message d'erreurs (Erreur ORACLE)
--	1 --> Message informatif(tout se passe bien)
--	2 et + Niveau de detail
---------------------- Fin des variables globales privees --
----------------------------------------------------------------------------
--
-- DEFINITION DES CURSEURS PRIVES ------------------------------------------
--@curs
--
----------------------------------------------------------------------------
--
--
------------------------------------------------------------------
--
-- Le corps des diff‚rentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_no08b 	(
			I_numporte	IN  	param_tiers_payant.numporte%Type 	default NULL,
			I_deb_numgar	IN  	porte_contrat.numgar%TYPE		default NULL,
			I_fin_numgar	IN  	porte_contrat.numgar%TYPE		default NULL,
			I_date_attest	IN	VARCHAR2				default NULL,
			I_param1	IN	param_batch.param1%type			default NULL,
			I_session	IN	NUMBER					Default 1,
			I_niv_msg	IN	NUMBER					Default 1,
			I_pause		IN	NUMBER					Default 0,
			O_found		OUT	NUMBER,
			O_erreur	OUT	VARCHAR2
			)
IS

BEGIN
	--
	O_found		:= 1;
	G_erreur	:= Null;
	--
	G_numporte	:= I_numporte;
	G_numgar_deb	:= I_deb_numgar;
	G_numgar_fin	:= I_fin_numgar;
	G_date_attest	:= NVL(e2d(I_date_attest), trunc(Sysdate));
	--
	G_etendue	:= I_param1;
	--
	G_max_msg	:= I_niv_msg;
	G_session	:= I_session;
	--G_idligne     := F_max_idligne(I_session => G_session);
	--
--
	G_comm_numedit	:= I_session;
--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Debut de traitement le ' ||
			TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
--
--
	P_CORPS_traitement;
--
--
	O_found	:= 0;
--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Fin Normale du traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
--
	O_erreur	:= G_erreur;
--
EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_NO08B - '||SUBSTR(SQLERRM(SQLCODE),1,128);
		O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;
END;
--
--
-- -----------------------------
PROCEDURE P_CORPS_traitement IS
BEGIN
--
G_proc := 'P_CORPS_traitement';


IF G_etendue = 1 THEN
	BEGIN
		pk_porte.P_DMNDE_contrat (
			I_numporte      => G_numporte,
			I_numgar        => G_numgar_deb,
			I_debut		=> G_date_attest,
			O_nb_demande =>	G_nb_demande);
	END;
ELSE
	BEGIN
		pk_porte.P_DMNDE_renouv (
			I_numporte      => G_numporte,
			I_deb_contrat   => G_numgar_deb,
			I_fin_contrat	=> G_numgar_fin,
			O_nb_demande    => G_nb_demande);
	END;
END IF;
--
Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;
--
END;
--
--
----------------------- Fin des procedures publiques ------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
Procedure P_INS_journal
IS
L_idligne	Number;
BEGIN
If ( G_niv_msg <= G_max_msg ) then
	G_idligne := G_idligne + 1;
	If ( G_niv_msg = 0 ) then
		L_idligne := -1 * G_idligne;
	Else
		L_idligne := G_idligne;
	End If;
	PK_trace.P_INS_journal_adm (
		I_nom_traitement => G_nom_traitement,
		I_session	 => G_session,
		I_niv_msg	 => G_niv_msg,
		I_msg_adm	 => G_msg_adm,
		I_idligne	 => L_idligne);
End If;
END P_INS_journal;
---------------- Fin des corps des procedures privees --
END;
/
