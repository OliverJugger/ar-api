CREATE OR REPLACE PACKAGE ARTHUS.pk_vire AS
--
PROCEDURE P_vire(
		 I_numremise	IN	remise_vire.numremise%type	default NULL,
		 I_session	IN	NUMBER		Default 1,
		 I_niv_msg	IN	NUMBER		Default 1,
		 I_pause	IN	NUMBER		Default 0,
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

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_vire AS
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
PROCEDURE P_ENTETE_info;
--
PROCEDURE P_CORPS_info;
--
PROCEDURE P_TOTAL_info;
--
PROCEDURE P_select_reference;
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

G_date                  VArchar2(6);
G_heure                 VArchar2(8);
--
G_emetteur		compte.emetteur%type;
G_lemetteur		VARCHAR2(6);
--
G_numremise		remise_vire.numremise%type;
G_lnumremise		VARCHAR2(10);
G_refsoc		VARCHAR2(30);
--
G_numcpte		compte.numcpte%type;
G_codbque_soc		VARCHAR2(5);
G_guichet_soc		VARCHAR2(5);
G_compte_soc		VARCHAR2(11);
G_rib_soc		VARCHAR2(2);
--
Ed_parenthese		VARCHAR2(1);
--
G_ident			NUMBER(2);
Ed_ident		VARCHAR2(1);
--
G_identifiant		compte.identifiant%type;
Ed_identifiant		VARCHAR2(14);
--
G_rais_soc		compte.rais_soc%type;
G_numvirement		remise_vire_detail.numvirement%type;
G_codbque		remise_vire_detail.codbque%type;
G_guichet		remise_vire_detail.guichet%type;
G_compte		remise_vire_detail.compte%type;
G_clerib		remise_vire_detail.clerib%type;
G_intitule		remise_vire_detail.intitule%type;
G_montant		remise_vire_detail.montant%type;
G_numdecaismt		remise_vire_detail.numdecaismt%type;
--
G_beneficiaire		VARCHAR2(18);
Ed_beneficiaire		VARCHAR2(18);
--
G_montant_total		NUMBER(15);
G_datejour		VARCHAR2(6);
G_monnaie		remise_vire_detail.monnaie%type;
G_trait_entete		VARCHAR2(1);
G_symbole		VARCHAR2(3);
--

-- Variables globales priv¿es
--
G_typbene		decaismt.typbene%type;
G_numbene		decaismt.numbene%type;
--
G_numbene_trouve	VARCHAR2(1);
--

-- Variables d'écriture de fichier
--
VIREMENT		UTL_FILE.FILE_TYPE;
--
G_suffixe_fich_vire	Varchar2(10);
Nom_fich_vire	        Varchar2(40);
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
G_nom_traitement	Constant journal_adm.nom_traitement%TYPE default 'pk_vr01B';
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
CURSOR C_select_reference is
	SELECT 	societe.refsoc,
		compte.numcpte,
		compte.codbque,
             	compte.guichet,
             	compte.compte,
             	compte.clerib,
             	compte.emetteur,
		nvl(compte.type_ident,0)		ident,
		rpad(compte.identifiant,14)		identifiant,
		compte.rais_soc
	FROM	remise_vire,compte,societe
	WHERE	remise_vire.numremise = G_numremise
	AND	remise_vire.numcpte = compte.numcpte
	AND	compte.numsoc = societe.numsoc;
--
CURSOR C_select_info is
	SELECT	numvirement,
		codbque,
		guichet,
		compte,
		clerib,
            	rpad(intitule,24,' ')		intitule,
		sum(montant_d*100)		montant,
                monnaie_d                       monnaie,
                Substr(pk_devise.symbole(monnaie_d),1,3) symbole,
		min(numdecaismt)		numdecaismt,
		numremise
	FROM	remise_vire_detail
	WHERE	numremise = G_numremise
	GROUP
	BY	numvirement,
		codbque,
		guichet,
		compte,
		clerib,
		intitule,
		numremise,
                monnaie_d;
--


------------------------------------------------------------------
--
-- Le corps des diff¿rentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_vire	(
		 I_numremise	IN	remise_vire.numremise%type	Default NULL,
		 I_session	IN	NUMBER				Default 1,
		 I_niv_msg	IN	NUMBER				Default 1,
		 I_pause	IN	NUMBER				Default 0,
		 O_found	OUT	NUMBER,
		 O_erreur	OUT	VARCHAR2
			)
IS
R_select_info 	C_select_info%ROWTYPE;

BEGIN
	--
	O_found         := 1;
	G_erreur        := Null;
        G_date          := To_Char(sysdate,'DDMMYY');
        Select replace(to_char(sysdate,'fmHH24:MI:SS'),':','_')
        Into G_heure
        From dual;

	G_numremise	:= I_numremise;
	--
	G_max_msg       := I_niv_msg;
	G_session       := I_session;
	--G_idligne     := F_max_idligne(I_session => G_session);
	--
	-- OUVERTURE du Curseur
	--
	IF NOT C_select_info%ISOPEN
   	   THEN
		P_debut_traitement;
--*
----debut-debogage
G_niv_msg     := 3;
G_msg_adm     := 'G_trait_entete 1 ? : '||G_trait_entete;
P_INS_journal;
----fin-debogage
--*
	END IF;
	--
	-- LECTURE D'1 Ligne dans la table principale
	--
	FETCH C_select_info INTO R_select_info;
	IF C_select_info%NOTFOUND THEN
		O_found	:= 0;
 		P_fin_traitement;
	ELSE
		O_found	:= 1;
		G_numvirement	:= R_select_info.numvirement;
		G_codbque	:= R_select_info.codbque;
		G_guichet	:= R_select_info.guichet;
		G_compte	:= R_select_info.compte;
		G_clerib	:= R_select_info.clerib;
		G_intitule	:= R_select_info.intitule;
		G_montant	:= R_select_info.montant;
                G_monnaie       := R_select_info.monnaie;
                G_symbole	:= R_select_info.symbole;
		G_numdecaismt	:= R_select_info.numdecaismt;
		G_numremise	:= R_select_info.numremise;
		--
		P_traitement_principal;
	END IF;
        --
	O_erreur	:= G_erreur;
	--
EXCEPTION
          WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_VIRE - '||SUBSTR(SQLERRM(SQLCODE),1,128);
		O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;

        Close C_select_info;
--
END;
--
-- -----------------------------
PROCEDURE P_traitement_principal
IS
BEGIN
--
G_proc := 'P_traitement_principal';
--
--*
----debut-debogage
G_niv_msg     := 3;
G_msg_adm     := 'G_trait_entete 2 ? : '||G_trait_entete;
P_INS_journal;
----fin-debogage
--*
	IF G_trait_entete IS NULL
		THEN
--*
----debut-debogage
G_niv_msg     := 3;
G_msg_adm     := 'Trt Entete';
P_INS_journal;
----fin-debogage
--*
		--
		P_select_reference;
		--
		G_lemetteur 	:= lpad(nvl(to_char(G_emetteur),'0'), 6, '0');
		G_lnumremise	:= lpad(nvl(to_char(G_numremise),'0'), 7, '0');
		G_datejour	:= To_char(Sysdate, 'DDMMY');
		--
		G_montant_total	:= 0;
		--
		-- ouverture du fichier à écrire
		--
        	G_suffixe_fich_vire	:= nvl(to_char(G_numremise),'0');
        	--Nom_fich_vire		:= 'VIREMENT_'||G_suffixe_fich_vire||'.txt';
                Nom_fich_vire		:= 'VIREMENT_'||G_suffixe_fich_vire||'_'||G_date||'_'||G_heure||'.txt';
		--
		-- EXPORT est le nom d'une Directory definie dans Oracle
		--
	        VIREMENT		:= UTL_FILE.FOPEN('EXPORT',Nom_fich_vire,'W');
		--
  		P_ENTETE_info;
		--
		G_trait_entete  := '1';
		--
	END IF;
--
  	P_CORPS_info;
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
PROCEDURE P_ENTETE_info
IS
BEGIN
--
G_proc := 'P_ENTETE_info';
--
/*
	G_niv_msg  := 1;
		G_msg_adm	:= '02 '||G_emetteur||' '||'0'||' '||G_datejour||G_rais_soc||G_numremise;
	P_INS_journal;
	-- Fin ecriture dans le Journal
	--
	IF G_ident is NULL or G_ident = '0'
	   THEN
	  	G_msg_adm	:= G_monnaie||'     '||G_guichet_soc||G_compte_soc||
					 G_ident||G_identifiant||G_codbque_soc;
	ELSE
		G_msg_adm	:= G_monnaie||'     '||G_guichet_soc||G_compte_soc||G_codbque_soc;
	END IF;
	--
	G_niv_msg	:= 1;
	P_INS_journal;
	-- Fin ecriture dans le Journal
*/
--
	If G_ident = 0 Then
		Ed_parenthese  := rpad(' ',1,' ');
		Ed_ident       := rpad(' ',1,' ');
		Ed_identifiant := rpad(' ',14,' ');
	Else
		Ed_parenthese  := ')';
		Ed_ident       := to_char(G_ident);
		Ed_identifiant := rpad(nvl(G_identifiant,' '),14,' ');
	End if;
--
        Ligne_1         := Null;
--
        Ligne_1         := '03';
        Ligne_1         := Ligne_1||'02';
        Ligne_1         := Ligne_1||rpad(' ',8,' ');
        Ligne_1         := Ligne_1||G_lemetteur;
        Ligne_1         := Ligne_1||rpad(' ',1,' ');
        Ligne_1         := Ligne_1||'0';
        Ligne_1         := Ligne_1||rpad(' ',5,' ');
        Ligne_1         := Ligne_1||G_datejour;
        Ligne_1         := Ligne_1||rpad(nvl(G_rais_soc,' '),24,' ');
        Ligne_1         := Ligne_1||G_lnumremise;
        Ligne_1         := Ligne_1||rpad(' ',19,' ');
        Ligne_1         := Ligne_1||G_symbole;
        Ligne_1         := Ligne_1||rpad(' ',3,' ');
        Ligne_1         := Ligne_1||G_guichet_soc;
        Ligne_1         := Ligne_1||G_compte_soc;
        Ligne_1         := Ligne_1||Ed_parenthese;
        Ligne_1         := Ligne_1||Ed_ident;
        Ligne_1         := Ligne_1||Ed_identifiant;
        Ligne_1         := Ligne_1||rpad(' ',31,' ');
        Ligne_1         := Ligne_1||G_codbque_soc;
        Ligne_1         := Ligne_1||rpad(' ',6,' ');
--
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 1 - a : '||Substr(Ligne_1,1,80);
                P_INS_journal;
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 1 - b : '||Substr(Ligne_1,81,80);
                P_INS_journal;
--
        UTL_FILE.PUT_LINE(VIREMENT,Ligne_1);
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
PROCEDURE P_CORPS_info
IS
BEGIN
--
G_proc := 'P_CORPS_info';
--
	--
	G_numbene_trouve	:= 'O';
	--
	Begin
		Select numbene, typbene
		Into G_numbene, G_typbene
		From decaismt
		Where numdecaismt=G_numdecaismt;
	Exception when no_data_found Then
		G_numbene_trouve	:= 'N';
		G_numbene		:= Null;
	End;
	--
	If G_numbene_trouve = 'O' Then
	  Begin
		SELECT 	f_bene_virement(G_numbene,G_typbene,G_numdecaismt,1)
		INTO 	G_beneficiaire
		FROM 	decaismt
		WHERE 	numdecaismt=G_numdecaismt
		AND 	codope=1;
	  Exception when no_data_found Then
		G_beneficiaire		:= Null;
	  End;
	Else
		G_beneficiaire		:= Null;
	End if;
	--
	Ed_beneficiaire		:= rpad(nvl(G_beneficiaire,' '),18,' ');
	--
/*
	G_niv_msg	:= 2;
	G_msg_adm	:= '02 '||G_lemetteur||G_numbene||G_intitule||'   '||G_guichet
		||G_compte||G_montant||') VIR='||G_numvirement||Ed_beneficiaire||G_codbque;
	P_INS_journal;
	-- Fin ecriture dans le Journal
*/
--
                Ligne_2         := Null;
--
                Ligne_2         := '06';
                Ligne_2         := Ligne_2||'02';
                Ligne_2         := Ligne_2||rpad(' ',8,' ');
                Ligne_2         := Ligne_2||G_lemetteur;
                Ligne_2         := Ligne_2||rpad(nvl(to_char(G_numbene),' '),12,' ');
                Ligne_2         := Ligne_2||rpad(nvl(G_intitule,' '),24,' ');
                Ligne_2         := Ligne_2||rpad(' ',20,' ');
                Ligne_2         := Ligne_2||rpad(' ',4,' ');
                Ligne_2         := Ligne_2||rpad(' ',8,' ');
                Ligne_2         := Ligne_2||G_guichet;
                Ligne_2         := Ligne_2||rpad(nvl(G_compte,' '),11,' ');
                Ligne_2         := Ligne_2||lpad(nvl(to_char(G_montant),'0'),16,'0');
                Ligne_2         := Ligne_2||')';
                Ligne_2         := Ligne_2||'VIR=';
                Ligne_2         := Ligne_2||rpad(nvl(to_char(G_numvirement),' '),8,' ');
                Ligne_2         := Ligne_2||Ed_beneficiaire;
                Ligne_2         := Ligne_2||G_codbque;
                Ligne_2         := Ligne_2||rpad(' ',6,' ');
--
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 2 - a : '||Substr(Ligne_2,1,80);
                P_INS_journal;
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 2 - b : '||Substr(Ligne_2,81,80);
                P_INS_journal;
--
--
                  UTL_FILE.PUT_LINE(VIREMENT,Ligne_2);
--
	G_montant_total := G_montant_total + G_montant;
	--
	UPDATE	decaismt
        SET	refpmt = G_numvirement,
		datpay = trunc(sysdate),
		numchq = 0
        WHERE	numdecaismt in (
				select numdecaismt
				from	remise_vire_detail
				where	numvirement = G_numvirement
							);
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
PROCEDURE P_TOTAL_info
IS
BEGIN
--
G_proc := 'P_TOTAL_info';
--
   	--
/*
	G_niv_msg	:= 1;
	G_msg_adm	:= '08 '||G_lemetteur||'      '||G_montant_total;
	P_INS_journal;
	-- Fin ecriture dans le Journal
*/
--
                Ligne_3         := Null;
--
                Ligne_3         := '08';
                Ligne_3         := Ligne_3||'02';
                Ligne_3         := Ligne_3||rpad(' ',8,' ');
                Ligne_3         := Ligne_3||G_lemetteur;
                Ligne_3         := Ligne_3||rpad(' ',84,' ');
                Ligne_3         := Ligne_3||lpad(nvl(to_char(G_montant_total),'0'),16,'0');
                Ligne_3         := Ligne_3||rpad(' ',31,' ');
                Ligne_3         := Ligne_3||rpad(' ',5,' ');
                Ligne_3         := Ligne_3||rpad(' ',6,' ');
--
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 3 - a : '||Substr(Ligne_3,1,80);
                P_INS_journal;
                G_niv_msg     := 3;
                G_msg_adm     := 'Ligne 3 - b : '||Substr(Ligne_3,81,80);
                P_INS_journal;
--
--
                UTL_FILE.PUT_LINE(VIREMENT,Ligne_3);
--
   	G_montant_total := 0;
	--
	UPDATE	remise_vire
	SET	datdisk = trunc(sysdate)
	WHERE	numremise = G_lnumremise;
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
-- -------------------------
PROCEDURE P_select_reference
IS
R_select_reference	C_select_reference%ROWTYPE;
BEGIN
--
G_proc := 'P_select_reference';
--
	OPEN C_select_reference;
	FETCH C_select_reference INTO R_select_reference;
	IF C_select_reference%FOUND Then
	  	G_refsoc	:= R_select_reference.refsoc;
	  	G_numcpte	:= R_select_reference.numcpte;
	  	G_codbque_soc	:= R_select_reference.codbque;
	  	G_guichet_soc	:= R_select_reference.guichet;
	  	G_compte_soc	:= R_select_reference.compte;
	  	G_rib_soc	:= R_select_reference.clerib;
	  	G_emetteur	:= R_select_reference.emetteur;
	  	G_ident		:= R_select_reference.ident;
	  	G_identifiant	:= R_select_reference.identifiant;
	  	G_rais_soc	:= R_select_reference.rais_soc;
	END IF;
	CLOSE C_select_reference;
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
	G_msg_adm	:= 'Debut de traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	-- Fin ecriture dans le Journal
	OPEN C_select_info;
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
  		P_TOTAL_info;
--
------------
        G_niv_msg     := 3;
        G_msg_adm     := 'fermeture fichier';
        P_INS_journal;
------------
		-- fermeture du fichier à écrire
		--
		UTL_FILE.FCLOSE(VIREMENT);
		--
	END IF;
	--
	-- FERMETURE du Curseur
	--
	CLOSE C_select_info;
	--
	INSERT	INTO 	lib_edition	(numedit, editlib)
		VALUES			(G_session, ('Generation fichier de virements'||G_numremise));
	--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Fin Normale du traitement le '||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
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
--
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
