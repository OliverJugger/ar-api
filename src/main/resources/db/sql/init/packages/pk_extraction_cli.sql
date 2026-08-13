CREATE OR REPLACE PACKAGE ARTHUS.pk_extraction_cli AS
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
/* Parametres du compte_tiers*/
G_deb_origine 	encaismt.codope%Type;
G_fin_origine 	encaismt.codope%Type;
G_deb_modpmt 	encaismt.modpmt%Type;
G_fin_modpmt 	encaismt.modpmt%Type;
G_deb_numcli 	encaismt.numcli%Type;
G_fin_numcli 	encaismt.numcli%Type;
G_datope  	compte_client.datope%Type;
-- @global
G_nom_traitement  Constant journal_adm.nom_traitement%Type default 'pk_extraction_cli';
G_id_session    journal_adm.id_session%Type  default 1;
G_msg_adm       journal_adm.msg_adm%Type;
G_session       journal_adm.id_session%Type default 1;
G_flag_test    	number;
--
G_niv_msg        journal_adm.niv_msg%TYPE;
G_idligne        journal_adm.idligne%TYPE ;
-- --------------------------------------------- Fin des variables publiques --
-- -- PROCEDURES PUBLIQUES ----------------------------------------------------
Procedure P_SEL_compte_attente(
		I_deb_origine 	IN encaismt.codope%Type,
		I_fin_origine 	IN encaismt.codope%Type,
		I_deb_modpmt 	IN encaismt.modpmt%Type,
		I_fin_modpmt 	IN encaismt.modpmt%Type,
		I_deb_numcli 	IN encaismt.numcli%Type,
		I_fin_numcli 	IN encaismt.numcli%Type,
		I_datope  	IN encaismt.datpay%Type,
		I_session       IN Number,
       	        I_flag_test     IN Number,
		O_ligne   	OUT VARCHAR
		);
-- -------------------------------------------- Fin des procedures publiques --
-- -- PROCEDURES PRIVEES ----------------------------------------------------
Procedure P_INS_journal;
-- --------------------------------------------- Fin des variables publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_extraction_cli AS
-- Chaine de reconnaissance SCCS
-- %W% Extractions comptables %E%
-- CURSEURS PRIVEES-------------------------------------------------------
Cursor C_SEL_compte_attente IS
Select 	compte_client.idaffec,
	compte_client.codope,
	encaismt.numcli,
	encaismt.numencaismt,
	encaismt.datpay,
	encaismt.montant,
	compte_client.monnaie,
	compte_client.montant 	mt_attente,
	encaismt.modpmt,
	encaismt.refpmt,
	compte_client.numfact,
	compte_client.idcompta,
	compte_client.datope,
	indvs.nom,
	encaismt.codope 	origine
From 	indvs,
	encaismt,
	compte_client
Where 	indvs.numindiv = encaismt.numcli
and	compte_client.numencaismt = encaismt.numencaismt
and 	compte_client.codope = 8
and 	encaismt.codope between nvl(G_deb_origine, encaismt.codope)
			and nvl( G_fin_origine,
				nvl(G_deb_origine, encaismt.codope) )
and 	encaismt.modpmt between nvl(G_deb_modpmt, encaismt.modpmt)
			and nvl( G_fin_modpmt,
				nvl(G_deb_modpmt, encaismt.modpmt) )
and 	compte_client.numcli between nvl(G_deb_numcli,compte_client.numcli)
			and  nvl(G_fin_numcli, compte_client.numcli)
and   	compte_client.datope <= G_datope
and	not exists (
		select	1
		from	rbtcptcli,
			affectation
		where	rbtcptcli.idaffec = compte_client.idaffec
		and	affectation.codope = 8
		and	affectation.numaffec = rbtcptcli.numaffec
		and	affectation.dataffec <= G_datope)
 ;
Rec_C_attente	 C_SEL_compte_attente%Rowtype;
-- -------------------------------------------- Fin des curseurs privees --
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
-- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
-- Aucune
-- ----------------------------- Fin des declarations des procedures privees --
-- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
Procedure P_SEL_compte_attente (
		I_deb_origine 	IN encaismt.codope%Type,
		I_fin_origine 	IN encaismt.codope%Type,
		I_deb_modpmt 	IN encaismt.modpmt%Type,
		I_fin_modpmt 	IN encaismt.modpmt%Type,
		I_deb_numcli 	IN encaismt.numcli%Type,
		I_fin_numcli 	IN encaismt.numcli%Type,
		I_datope  	IN encaismt.datpay%Type,
		I_session       IN Number,
       	        I_flag_test     IN Number,
		O_ligne   	OUT VARCHAR
		)
IS
L_libelle	Varchar2(60);
BEGIN
G_deb_origine   := I_deb_origine;
G_fin_origine   := I_fin_origine;
G_deb_modpmt   := I_deb_modpmt;
G_fin_modpmt   := I_fin_modpmt;
G_deb_numcli   := I_deb_numcli;
G_fin_numcli   := I_fin_numcli;
G_datope       := I_datope;
--
G_session        := I_session;
G_flag_test	:= I_flag_test;
--
G_niv_msg := 1;
--
If Not C_SEL_compte_attente%ISOPEN then
	Open C_SEL_compte_attente;
	--
	G_msg_adm := 'Début du traitement le ' ||
			to_char(sysdate,'dd/mm/yyyy HH24:MI:SS');
	P_INS_journal;
	--
End if;
--
Fetch C_SEL_compte_attente Into Rec_C_attente;
--
If ( C_SEL_compte_attente%NotFound ) then
	Close C_SEL_compte_attente;
	Raise No_Data_Found;
End if;
--
If ( Rec_C_attente.codope = 10 ) then
	L_libelle := 'Encaissement fournisseur n° ' ||
		Rec_C_attente.numencaismt;
Else
	L_libelle := f_lib_attente( Rec_C_attente.idaffec );
End if;
O_ligne  :=     pk_libelle.f_lib('OPE', Rec_C_attente.origine) || ';' ||
		to_char(Rec_C_attente.numencaismt) || ';' ||
		d2e(Rec_C_attente.datpay) || ';' ||
		pk_libelle.f_lib('MREGL', Rec_C_attente.modpmt) || ';' ||
		Rec_C_attente.refpmt || ';' ||
		to_char(Rec_C_attente.numcli) || ';' ||
		pk_personne.f_nom(Rec_C_attente.numcli) || ';' ||
		L_libelle || ';' ||
		to_char(Rec_C_attente.montant) || ';' ||
		to_char(Rec_C_attente.mt_attente);
--
EXCEPTION
When No_Data_Found then Raise No_Data_Found;
WHEN OTHERS THEN
	ROLLBACK;
	G_msg_adm    := SUBSTR(SQLERRM(SQLCODE),1,128);
	G_niv_msg    := 2;
	--
	-- Insertion dans journal_adm du message d'erreur
	--
    	P_INS_journal;
    	--
    	COMMIT;
    	--
    	RAISE;
END P_SEL_compte_attente;
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--
Procedure P_INS_journal
IS
BEGIN
G_idligne := G_idligne + 1;
PK_trace.P_INS_journal_adm (
	I_nom_traitement => G_nom_traitement,
	I_session        => G_session,
	I_niv_msg        => G_niv_msg,
	I_msg_adm        => G_msg_adm,
	I_idligne        => G_idligne);
										END;
--										------------------------------------ Fin des corps des procedures privees --
END;
/
