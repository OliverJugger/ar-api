CREATE OR REPLACE PACKAGE ARTHUS.pk_dev_pv01b AS
--
PROCEDURE P_dev_pv01b(
		 I_numremise	IN	remise_prelev.numremise%type	default NULL,
		 I_session	IN	NUMBER				Default 1,
		 I_niv_msg	IN	NUMBER				Default 1,
		 I_pause	IN	NUMBER				Default 0,
		 I_Repertoire 	IN	Varchar2 default null,
		 I_Fichier 		IN 	Varchar2 default null,
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

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_dev_pv01b AS
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
PROCEDURE p_nom_fichier;
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
G_date                  VArchar2(8);
G_heure                 VArchar2(8);
G_BDX					Varchar2(10);
G_BQE					NUMBER(3);
--
G_montant_d			NUMBER(15);
G_montant_total_d	NUMBER(15);
G_codbquedesti		VARCHAR2(5);
G_guichetdesti		VARCHAR2(5);
G_comptedesti		VARCHAR2(11);
G_nomprenom		VARCHAR2(30);
-- G_date			VARCHAR2(6);
G_codbque		VARCHAR2(5);
G_guichet		VARCHAR2(5);
G_compte		VARCHAR2(11);
--
G_emetteur		NUMBER(6);
G_lemetteur		VARCHAR2(6);
--
G_numremise		NUMBER(7);
G_lnumremise	VARCHAR2(7);
--
G_numprelev		NUMBER(7);
G_identifiant	VARCHAR2(14);
G_type_ident	NUMBER(1);
G_rais_soc		VARCHAR2(24);
G_ref_prelev	VARCHAR2(18);
G_numencaismt	NUMBER(9);
--G_devise_ref		NUMBER(1);
G_monnaie_d		NUMBER(3);
G_symbole		VARCHAR2(1);
--G_devise_franc		NUMBER(1);
--G_devise_euro		NUMBER(1);
--G_monnaie		VARCHAR2(1);
G_datejours		VARCHAR2(5);
G_trait_entete	VARCHAR2(1);
G_eche_prelev	VARCHAR2(4);
--

-- Variables globales privees
--
G_numbene		qttc_global.numquerable%type;
--
G_numbene_trouve	VARCHAR2(1);
--

-- Variables d'écriture de fichier
--
PRELEV			UTL_FILE.FILE_TYPE;
G_repertoire   	typ_batch.REPERTOIRE%TYPE;
G_fichier		VARCHAR2(200);
--
Ligne_1                 Varchar2(160);
Ligne_2                 Varchar2(160);
Ligne_3                 Varchar2(160);
--

-- Flag de commit ou rollback a retourner a Forms
G_commit		Boolean := FALSE;
G_rollback		Boolean := FALSE;
G_auto_valide	Boolean := FALSE;
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
/*
	NS le 17-11-2005 Spécif.processus de génération des fichiers de prélèvement
	Chargement de la zone contenant la date du prélévement avec remise_prelev.eche_prelev
*/
CURSOR C_select_prelev IS
	SELECT	compte.emetteur,
		compte.guichet,
		compte.codbque,
		compte.compte,
		remise_prelev.numremise,
		remise_prelev.eche_prelev,
		prelevement.numprelev,
		prelevement.intitule 		nomprenom,
		prelevement.codbque  		codbquedesti,
		prelevement.guichet  		guichetdesti,
		prelevement.compte   		comptedesti,
		prelevement.montant_d*100 	montant_d,
                prelevement.monnaie_d,
		Substr(pk_devise.symbole(prelevement.monnaie_d),1,1) symbole,
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
--
/* VCR 30/01/2007
Ajout du curseur pour récupérer la valeur "Numcpte" de la remise
à intégrer dans le nom du fichier
*/
CURSOR C_remise_prelev IS
	select remise_prelev.numcpte from remise_prelev
	where remise_prelev.numremise = G_numremise;
--
------------------------------------------------------------------
--
-- Le corps des differentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_dev_pv01b(
		 I_numremise	IN	remise_prelev.numremise%type	default NULL,
		 I_session	IN	NUMBER				Default 1,
		 I_niv_msg	IN	NUMBER				Default 1,
		 I_pause	IN	NUMBER				Default 0,
		 I_Repertoire 	IN	Varchar2 default null,
		 I_Fichier 		IN 	Varchar2 default null,
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
	G_numremise		:= I_numremise;
	G_repertoire 	:= I_Repertoire;
	G_fichier 		:= I_Fichier;
	--G_monnaie	:= 'E';
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
		G_emetteur		:= R_select_prelev.emetteur;
		G_guichet		:= R_select_prelev.guichet;
		G_codbque		:= R_select_prelev.codbque;
		G_compte		:= R_select_prelev.compte;
		G_numremise		:= R_select_prelev.numremise;
		G_numprelev		:= R_select_prelev.numprelev;
		G_nomprenom		:= R_select_prelev.nomprenom;
		G_codbquedesti	:= R_select_prelev.codbquedesti;
		G_guichetdesti	:= R_select_prelev.guichetdesti;
		G_comptedesti	:= R_select_prelev.comptedesti;
		G_montant_d		:= R_select_prelev.montant_d;
        G_monnaie_d		:= R_select_prelev.monnaie_d;
		G_symbole		:= R_select_prelev.symbole;
        G_type_ident	:= R_select_prelev.type_ident;
		G_identifiant	:= R_select_prelev.identifiant;
		G_rais_soc		:= R_select_prelev.rais_soc;
		G_eche_prelev 	:= R_select_prelev.eche_prelev;
		--
		P_traitement_principal;
	END IF;
        --
	O_erreur	:= G_erreur;
	--
EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_DEv_PV01B - '||SUBSTR(SQLERRM(SQLCODE),1,128);
		O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;
		Close C_select_prelev;
END;
--
-- -----------------------------
PROCEDURE P_traitement_principal
IS
	Loc_Y VARCHAR2(1);
	LOC_MM_Eche_Prelev VARCHAR2(2);
	LOC_MM   VARCHAR2(2);
BEGIN
--
G_proc := 'P_traitement_principal';
--
	IF G_trait_entete IS NULL
	   THEN
		--
		G_lemetteur 	:= lpad(nvl(to_char(G_emetteur),'0'), 6, '0');
		G_lnumremise	:= lpad(nvl(to_char(G_numremise),'0'), 7, '0');
		/*
		Début NS 17-11-2005
		-- G_datejours		:= To_char(Sysdate, 'ddmmy');
		G_datejours		:= NVL( (G_eche_prelev||To_Char(Sysdate, 'Y')), To_Char(Sysdate, 'DDMMY') );
		*/
		LOC_MM_Eche_Prelev 	:= Substr(G_eche_prelev, 3, 2);
		LOC_MM 				:= To_Char(Sysdate, 'MM');
		LOC_Y 				:= To_Char(Sysdate, 'Y');
		IF LOC_MM_Eche_Prelev < LOC_MM 		THEN
			LOC_Y := (To_Number (LOC_Y) + 1);
		END IF;
		G_datejours		:= NVL( G_eche_prelev||LOC_Y, To_Char(Sysdate, 'DDMMY') );
		/*
		Fin NS 17-11-2005
		*/
		--
		--G_montant_total	  := 0;
        G_montant_total_d := 0;
		--
		-- ouverture du fichier à écrire
		--
/*		 G_suffixe_fich_prelev	:= nvl(to_char(G_numremise),'0');
		Nom_fich_prelev		:= 'PRELEV-'||G_datej||'-'||G_suffixe_fich_prelev||'-'||G_heure||'.txt';
*/
		-- Formatage du nom de fichier
		p_nom_fichier;
		--
		-- Ouverture du fichier d'export
		--
	    PRELEV			:= UTL_FILE.FOPEN(G_Repertoire,G_Fichier,'W');
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
	G_msg_adm	:= G_monnaie_d||'    '||G_guichet||G_compte
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
        Ligne_1         := Ligne_1||G_symbole;
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
	--G_montant_total	   := G_montant_total + G_montant;
    G_montant_total_d  := G_montant_total_d + G_montant_d;
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
                Ligne_2         := Ligne_2||lpad(nvl(to_char(G_montant_d),'0'),16,'0');
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
                Ligne_3         := Ligne_3||lpad(nvl(to_char(G_montant_total_d),'0'),16,'0');
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
	Select 	distinct(numquerable)
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
-- Formatage du nom de fichier (variable G_fichier)
--
-- ----------------------------------------------------------------------------------------
procedure p_nom_fichier
is
begin
--
g_proc := 'p_nom_fichier';
--
	--
	G_date := To_Char(sysdate,'YYYYMMDD');
	--
    Select replace(to_char(sysdate,'fmHH24:MI:SS'),':','-')
	Into G_heure
    From dual;
	--
	G_BDX			:= nvl(to_char(G_numremise),'0');
	--
	OPEN C_remise_prelev;
	Fetch C_remise_prelev into G_BQE;
	Close C_remise_prelev;
	--
	select 	Replace(
			Replace(
			Replace(
			Replace(G_Fichier	,'#DT', G_date)
								,'#HR', G_heure)
								,'#BQE', to_char(G_BQE))
								,'#BDX', G_BDX)
	into G_fichier
	from dual;
--
exception when others then
        g_niv_msg := 0;
        g_msg_adm := f_centre( 'erreur procedure ' || g_proc || ' : ', 78 );
        p_ins_journal;
        g_msg_adm := to_char(sqlcode) || '-' || substr(sqlerrm(sqlcode),1,128);
        g_erreur := g_msg_adm;
        p_ins_journal;
--
end;
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
	G_trait_entete	  := NULL;
	G_montant_total_d := 0;
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
