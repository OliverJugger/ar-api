CREATE OR REPLACE PACKAGE ARTHUS.pk_pv01b AS
--
PROCEDURE P_pv01b(
		 I_numremise	IN	remise_prelev.numremise%type	default NULL,
		 I_session	IN	NUMBER				Default 1,
		 I_niv_msg	IN	NUMBER				Default 1,
		 I_pause	IN	NUMBER				Default 0,
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

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_pv01b AS
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
--
PROCEDURE P_traitement_principal;
--
PROCEDURE P_ENTETE_prelev;
--
PROCEDURE P_CORPS_prelev;
--
PROCEDURE P_TOTAL_prelev;
--
PROCEDURE P_select_bene;
--
PROCEDURE P_debut_traitement;
--
PROCEDURE P_fin_traitement;
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
G_montant		NUMBER(15);
G_montant_total		NUMBER(15);
G_codbquedesti		VARCHAR2(5);
G_guichetdesti		VARCHAR2(5);
G_comptedesti		VARCHAR2(11);
G_nomprenom		VARCHAR2(24);
G_date			VARCHAR2(6);
G_codbque		VARCHAR2(5);
G_guichet		VARCHAR2(5);
G_compte		VARCHAR2(11);
--
G_emetteur		NUMBER(6);
G_lemetteur		VARCHAR2(6);
--
G_numremise		NUMBER(5);
G_lnumremise		VARCHAR2(5);
--
G_numprelev		NUMBER(7);
G_identifiant		VARCHAR2(14);
G_type_ident		NUMBER(1);
G_rais_soc		VARCHAR2(24);
G_ref_prelev		VARCHAR2(18);
G_numencaismt		NUMBER(9);
G_devise_ref		NUMBER(1);
G_devise_franc		NUMBER(1);
G_devise_euro		NUMBER(1);
G_monnaie		VARCHAR2(1);
G_datejours		VARCHAR2(5);
G_trait_entete		VARCHAR2(1);
--

-- Variables globales priv¿es
--
G_numbene		qttc_global.numquerable%type;
--
G_numbene_trouve	VARCHAR2(1);
--

-- Variables d'écriture de fichier
--
PRELEV			UTL_FILE.FILE_TYPE;
--
G_suffixe_fich_prelev	Varchar2(10);
Nom_fich_prelev         Varchar2(30);
--
Ligne_1                 Varchar2(160);
Ligne_2                 Varchar2(160);
Ligne_3                 Varchar2(160);
--

-- Flag de commit ou rollback a retourner a Forms
G_commit		Boolean := FALSE;
G_rollback		Boolean := FALSE;
G_auto_valide		Boolean := FALSE;
--
G_flag_test		NUMBER;
G_proc			VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%TYPE default 'pk_pv01B';
G_msg_adm		journal_adm.msg_adm%TYPE;
G_session		journal_adm.id_session%TYPE default 1;
G_niv_msg		journal_adm.niv_msg%TYPE := 1;
G_max_msg		journal_adm.niv_msg%TYPE := 1;
G_idligne		journal_adm.idligne%TYPE := 0;
G_erreur		journal_adm.msg_adm%TYPE;

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

CURSOR C_select_prelev IS
	SELECT	compte.emetteur,
		compte.guichet,
		compte.codbque,
		compte.compte,
		remise_prelev.numremise,
		prelevement.numprelev,
		prelevement.intitule 		nomprenom,
		prelevement.codbque  		codbquedesti,
		prelevement.guichet  		guichetdesti,
		prelevement.compte   		comptedesti,
		prelevement.montant*100 	montant,
		compte.type_ident,
		compte.identifiant,
		compte.rais_soc
	FROM	compte,
		remise_prelev,
		prelevement
	WHERE	remise_prelev.numremise = G_numremise
	AND	compte.numcpte 		= remise_prelev.numcpte
	AND	prelevement.numremise 	= remise_prelev.numremise
	AND	not exists (select 1 	from 	annul_encais
			   		where 	annul_encais.numencaismt =
						prelevement.numencaismt)
	ORDER
	BY	remise_prelev.numremise,
		prelevement.numprelev;


------------------------------------------------------------------
--
-- Le corps des diff¿rentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_pv01b(
		 I_numremise	IN	remise_prelev.numremise%type	default NULL,
		 I_session	IN	NUMBER				Default 1,
		 I_niv_msg	IN	NUMBER				Default 1,
		 I_pause	IN	NUMBER				Default 0,
		 O_found	OUT	NUMBER,
		 O_erreur	OUT	VARCHAR2
		)
IS

R_select_prelev 	C_select_prelev%ROWTYPE;

BEGIN
	--
	O_found         := 1;
	G_erreur        := Null;
	--
	G_numremise	:= I_numremise;
	G_monnaie	:= 'E';
	--
	G_max_msg       := I_niv_msg;
	G_session       := I_session;
	--G_idligne     := F_max_idligne(I_session => G_session);

	--
	-- OUVERTURE du Curseur
	--
	IF NOT C_select_prelev%ISOPEN
   	   THEN
		P_debut_traitement;
	END IF;
	--
	-- LECTURE D'1 Ligne dans la table principale
	--

	FETCH C_select_prelev INTO R_select_prelev;
--
	IF C_select_prelev%NOTFOUND THEN
--
---------
		G_niv_msg	:= 3;
		G_msg_adm	:= 'Jalon 0';
		P_INS_journal;
---------
		O_found	:= 0;
		P_fin_traitement;
	ELSE
---------
		G_niv_msg	:= 3;
		G_msg_adm	:= 'Jalon 1';
		P_INS_journal;
---------
		O_found	:= 1;
		--
		G_emetteur	:= R_select_prelev.emetteur;
		G_guichet	:= R_select_prelev.guichet;
		G_codbque	:= R_select_prelev.codbque;
		G_compte	:= R_select_prelev.compte;
		G_numremise	:= R_select_prelev.numremise;
		G_numprelev	:= R_select_prelev.numprelev;
		G_nomprenom	:= R_select_prelev.nomprenom;
		G_codbquedesti	:= R_select_prelev.codbquedesti;
		G_guichetdesti	:= R_select_prelev.guichetdesti;
		G_comptedesti	:= R_select_prelev.comptedesti;
		G_montant	:= R_select_prelev.montant;
		G_type_ident	:= R_select_prelev.type_ident;
		G_identifiant	:= R_select_prelev.identifiant;
		G_rais_soc	:= R_select_prelev.rais_soc;
		--
		P_traitement_principal;
	END IF;
        --
	O_erreur	:= G_erreur;
	--
EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_PV01B - '||SUBSTR(SQLERRM(SQLCODE),1,128);
		O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;
END;
--
-- -----------------------------
PROCEDURE P_traitement_principal
IS
BEGIN
--
G_proc := 'P_traitement_principal';
--
	IF G_trait_entete IS NULL
	   THEN
		--
		G_lemetteur 	:= lpad(nvl(to_char(G_emetteur),'0'), 6, '0');
		G_lnumremise	:= lpad(nvl(to_char(G_numremise),'0'), 5, '0');
		G_datejours	:= To_char(Sysdate, 'ddmmy');
		--
		G_montant_total	:= 0;
		--
		-- ouverture du fichier à écrire
		--
        	G_suffixe_fich_prelev	:= nvl(to_char(G_numremise),'0');
        	Nom_fich_prelev		:= 'PRELEV_'||G_suffixe_fich_prelev||'.txt';
		--
		-- EXPORT est le nom d'une Directory definie dans Oracle
		--
	        PRELEV			:= UTL_FILE.FOPEN('EXPORT',Nom_fich_prelev,'W');
		--
  		P_ENTETE_prelev;
		--
		G_trait_entete  := '1';
		--
	END IF;
	--
  	P_CORPS_prelev;
	--
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
-- -----------------------
PROCEDURE P_ENTETE_prelev
IS
BEGIN
--
G_proc := 'P_ENTETE_prelev';
--
	--
	-- Alimentation de l'Enregistrement Entete
/*
	G_niv_msg	:= 1;
	G_msg_adm	:= '08 '||G_lemetteur||G_datejours||G_rais_soc||G_lnumremise;
	P_INS_journal;
	-- Fin ecriture dans le Journal
	G_niv_msg	:= 1;
	G_msg_adm	:= G_monnaie||'    '||G_guichet||G_compte
		||'                                               '||G_codbque;
	P_INS_journal;
*/
	-- Conception de l'Enregistrement Entete
--
        Ligne_1         := Null;
--
        Ligne_1         := '03';
        Ligne_1         := Ligne_1||'08';
        Ligne_1         := Ligne_1||rpad(' ',8,' ');
        Ligne_1         := Ligne_1||G_lemetteur;
        Ligne_1         := Ligne_1||rpad(' ',7,' ');
        Ligne_1         := Ligne_1||G_datejours;
        Ligne_1         := Ligne_1||rpad(nvl(G_rais_soc,' '),24,' ');
        Ligne_1         := Ligne_1||G_lnumremise;
        Ligne_1         := Ligne_1||rpad(' ',17,' ');
        Ligne_1         := Ligne_1||rpad(' ',2,' ');
        Ligne_1         := Ligne_1||G_monnaie;
        Ligne_1         := Ligne_1||rpad(' ',5,' ');
        Ligne_1         := Ligne_1||G_guichet;
        Ligne_1         := Ligne_1||G_compte;
        Ligne_1         := Ligne_1||rpad(' ',16,' ');
        Ligne_1         := Ligne_1||rpad(' ',31,' ');
        Ligne_1         := Ligne_1||G_codbque;
        Ligne_1         := Ligne_1||rpad(' ',6,' ');
--
	-- Ecriture de l'Enregistrement Entete
--
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 1 - a : '||Substr(Ligne_1,1,80);
                P_INS_journal;
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 1 - b : '||Substr(Ligne_1,81,80);
                P_INS_journal;
--
        UTL_FILE.PUT_LINE(PRELEV,Ligne_1);
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
-- ----------------------
PROCEDURE P_CORPS_prelev
IS
BEGIN
--
G_proc := 'P_CORPS_prelev';
--
	-- Alimentation de l'Enregistrement Detail
	G_montant_total	:= G_montant_total + G_montant;
--
	G_ref_prelev 	:= f_ref_prelevement(G_numprelev);
--
	P_select_bene;
	--
/*
	G_niv_msg	:= 1;
	G_msg_adm	:= '08 '||G_lemetteur||G_numbene||G_nomprenom|| '  '
			||G_guichetdesti||G_comptedesti||G_montant
			||'* REF'||G_numprelev||G_ref_prelev||G_codbquedesti;
	P_INS_journal;
	-- Fin ecriture dans le Journal
*/
	-- Conception de l'Enregistrement Detail
--
                Ligne_2         := Null;
--
                Ligne_2         := '06';
                Ligne_2         := Ligne_2||'08';
                Ligne_2         := Ligne_2||rpad(' ',8,' ');
                Ligne_2         := Ligne_2||G_lemetteur;
                Ligne_2         := Ligne_2||rpad(nvl(to_char(G_numbene),' '),12,' ');
                Ligne_2         := Ligne_2||rpad(nvl(G_nomprenom,' '),24,' ');
                Ligne_2         := Ligne_2||rpad(' ',24,' ');
                Ligne_2         := Ligne_2||rpad(' ',8,' ');
                Ligne_2         := Ligne_2||G_guichetdesti;
                Ligne_2         := Ligne_2||rpad(nvl(G_comptedesti,' '),11,' ');
                Ligne_2         := Ligne_2||lpad(nvl(to_char(G_montant),'0'),16,'0');
                Ligne_2         := Ligne_2||'*';
                Ligne_2         := Ligne_2||'REF= ';
                Ligne_2         := Ligne_2||lpad(nvl(to_char(G_numprelev),'0'),7,'0');
                Ligne_2         := Ligne_2||rpad(nvl(to_char(G_ref_prelev),' '),18,' ');
                Ligne_2         := Ligne_2||G_codbquedesti;
                Ligne_2         := Ligne_2||rpad(' ',6,' ');
--
	-- Ecriture de l'Enregistrement Detail
--
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 2 - a : '||Substr(Ligne_2,1,80);
                P_INS_journal;
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 2 - b : '||Substr(Ligne_2,81,80);
                P_INS_journal;
--
                UTL_FILE.PUT_LINE(PRELEV,Ligne_2);
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
-- ---------------------
PROCEDURE P_TOTAL_Prelev
IS
BEGIN
--
G_proc := 'P_TOTAL_Prelev';
--
	-- Alimentation de l'Enregistrement Fin
	--
	-- ( les variables necessaires sont alimentees)
	--
/*
   	--
	G_niv_msg	:= 1;
	G_msg_adm	:= '08 '||G_lemetteur||'      '||G_montant_total;
	P_INS_journal;
	-- Fin ecriture dans le Journal
   	G_montant_total := 0;
*/
	-- Conception de l'Enregistrement Fin
--
                Ligne_3         := Null;
--
                Ligne_3         := '08';
                Ligne_3         := Ligne_3||'08';
                Ligne_3         := Ligne_3||rpad(' ',8,' ');
                Ligne_3         := Ligne_3||G_lemetteur;
                Ligne_3         := Ligne_3||rpad(' ',12,' ');
                Ligne_3         := Ligne_3||rpad(' ',24,' ');
                Ligne_3         := Ligne_3||rpad(' ',24,' ');
                Ligne_3         := Ligne_3||rpad(' ',8,' ');
                Ligne_3         := Ligne_3||rpad(' ',5,' ');
                Ligne_3         := Ligne_3||rpad(' ',11,' ');
                Ligne_3         := Ligne_3||lpad(nvl(to_char(G_montant_total),'0'),16,'0');
                Ligne_3         := Ligne_3||rpad(' ',31,' ');
                Ligne_3         := Ligne_3||rpad(' ',5,' ');
                Ligne_3         := Ligne_3||rpad(' ',6,' ');
--
	-- Ecriture de l'Enregistrement Fin
--
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 3 - a : '||Substr(Ligne_3,1,80);
                P_INS_journal;
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 3 - b : '||Substr(Ligne_3,81,80);
                P_INS_journal;
--
                UTL_FILE.PUT_LINE(PRELEV,Ligne_3);
--
	--
	UPDATE	remise_prelev
	SET	datdisk = trunc(sysdate)
	WHERE	numremise = G_lnumremise;
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
-- ---------------------
PROCEDURE P_select_bene
IS
BEGIN
--
G_proc := 'P_select_bene';
--
	Select 	numquerable
	Into 	G_numbene
	From 	qttc_global,prelevement_detail
	Where 	numprelev 			= G_numprelev
	And 	prelevement_detail.numfact	= qttc_global.numquit;
--
Exception
	When no_data_found Then
		G_numbene		:= Null;
		G_numbene_trouve	:= 'N';
	When Others then
        	G_niv_msg := 0;
        	G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        	P_INS_journal;
        	G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        	G_erreur := G_msg_adm;
        	P_INS_journal;
--
END;
--
-- ----------------------------------------------------------------------------------------
--
-- DEBUT ET FIN DU TRAITEMENT
--
-- ----------------------------------------------------------------------------------------
PROCEDURE P_debut_traitement
IS
BEGIN
--
G_proc := 'P_debut_traitement';
--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Debut de traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	-- Fin ecriture dans le Journal
	OPEN C_select_prelev;
	G_trait_entete	:= NULL;
	G_montant_total := 0;
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
-- -----------------------
PROCEDURE P_fin_traitement
IS
BEGIN
--
G_proc := 'P_fin_traitement';
--
  	IF G_trait_entete IS NOT NULL
	   THEN
  		P_TOTAL_Prelev;
--
------------
        G_niv_msg     := 3;
        G_msg_adm     := 'fermeture fichier';
        P_INS_journal;
------------
		-- fermeture du fichier à écrire
		--
		UTL_FILE.FCLOSE(PRELEV);
		--
	END IF;
	--
	-- FERMETURE du Curseur
	--
	CLOSE C_select_prelev;
	--
	INSERT 	INTO 	lib_edition 	(numedit,
					 editlib
					)
		VALUES			(G_session,
					 'Generation fichier de prelevement n° '||G_numremise
					);
	--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Fin Normale du traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	-- Fin ecriture dans le Journal
--
Exception When Others then
        G_niv_msg := 0;
        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
        P_INS_journal;
        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
        G_erreur := G_msg_adm;
        P_INS_journal;

END;
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
