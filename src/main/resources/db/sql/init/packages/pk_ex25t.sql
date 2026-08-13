CREATE OR REPLACE PACKAGE ARTHUS.pk_ex25t AS
--
PROCEDURE P_ex25t(
					I_deb_numgar	IN  contrat.numgar%Type,
					I_fin_numgar	IN  contrat.numgar%Type,
					I_refcie		IN  contrat.refcie%Type,
					I_session		IN	NUMBER		Default 1,
					I_niv_msg		IN	NUMBER		Default 1,
					I_pause			IN	NUMBER		Default 0,
					O_found			OUT	NUMBER,
					O_erreur		OUT	VARCHAR2
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

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_ex25t AS
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
G_deb_numgar 	contrat.numgar%Type;
G_fin_numgar 	contrat.numgar%Type;
G_refcie		contrat.refcie%Type;
G_attest			Varchar2(3500);
--
G_trouve			NUMBER;
G_datejour			VARCHAR2(8);
--
-- Variables globales priv‚es
--
-- Variables d'écriture de fichier
--
F_TXT		UTL_FILE.FILE_TYPE;
--
G_suffixe_fich_ex25t		Varchar2(10);
Nom_fich_ex25t   			Varchar2(30);
--
ex25_ligne			        Varchar2(3500);
--
G_proc						VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%TYPE default 'pk_ex25t';
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
--
------------------------------------------------------------------
--
-- Le corps des différentes procedures
--
------------------------------------------------------------------
--
PROCEDURE P_ex25t	(
					I_deb_numgar	IN  contrat.numgar%Type,
					I_fin_numgar	IN  contrat.numgar%Type,
					I_refcie		IN  contrat.refcie%Type,
					I_session		IN	NUMBER		Default 1,
					I_niv_msg		IN	NUMBER		Default 1,
					I_pause			IN	NUMBER		Default 0,
					O_found			OUT	NUMBER,
					O_erreur		OUT	VARCHAR2
					)
IS
BEGIN
	--
	O_found         := 1;
	G_erreur        := Null;
	--
	G_deb_numgar	:= I_deb_numgar;
	G_fin_numgar	:= I_fin_numgar;
	G_refcie		:= I_refcie;
	G_max_msg       := I_niv_msg;
	G_session       := I_session;
	--
	-- OUVERTURE du fichier
	--
	IF NOT UTL_FILE.IS_OPEN(F_TXT) THEN
		P_debut_traitement;
	END IF;
	--
	-- Ouverture du package PK_santeclair.sql
	--
	G_trouve	:= 0;
	--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'N° Contrat de<'||G_deb_numgar||'>à<'||G_fin_numgar||'> Ref<'||G_refcie||'>';
	P_INS_journal;
	--
	LOOP
		pk_santeclair.P_TRAITE_adhesion (
										I_deb_numgar	=>  G_deb_numgar,
										I_fin_numgar	=>	G_fin_numgar,
										I_refcie		=>	G_refcie,
										I_session		=>	G_session,
										I_niv_msg		=>	G_max_msg,
										O_attest		=>	G_attest
										);
		EXIT WHEN G_attest IS NULL;
		IF G_attest is not NULL then
				G_trouve := G_trouve + 1;
				P_traitement_principal;
		End if;
	END LOOP;
	P_fin_traitement;
--
	O_found	:= 0;
	O_erreur	:= G_erreur;
	--
EXCEPTION
		WHEN NO_DATA_FOUND THEN
			IF G_trouve > 0 THEN
				P_fin_traitement;
				O_found	:= 0;
				O_erreur	:= G_erreur;
			ELSE
				G_niv_msg	:= 0;
				G_msg_adm	:= 'PK_EX25T - '||SUBSTR(SQLERRM(SQLCODE),1,128);
				O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
				P_INS_journal;
				P_fin_traitement;
			END IF;
		WHEN OTHERS THEN
			G_niv_msg	:= 0;
			G_msg_adm	:= 'PK_EX25T - '||SUBSTR(SQLERRM(SQLCODE),1,128);
			O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
			P_INS_journal;
			P_fin_traitement;

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
	-- conception de l'enregistrement
--
                ex25_ligne         := null;
--
                ex25_ligne        := G_attest;
--
	-- ecriture de l'enregistrement
--
                g_niv_msg     := 3;
                g_msg_adm     := 'ligne ex25 - '||'G_attest : ';
                p_ins_journal;
--
				UTL_FILE.PUT_LINE(F_TXT,ex25_ligne);
--
Exception
		WHEN UTL_FILE.INVALID_FILEHANDLE THEN
			G_niv_msg	:= 0;
			G_msg_adm    := 'UTL_FILE.INVALID_FILEHANDLE';
			G_erreur := G_msg_adm;
			P_INS_journal;
			UTL_FILE.FCLOSE(F_TXT);
		WHEN UTL_FILE.INVALID_OPERATION THEN
			G_niv_msg	:= 0;
			G_msg_adm    := 'UTL_FILE.INVALID_OPERATION';
			G_erreur := G_msg_adm;
			P_INS_journal;
			UTL_FILE.FCLOSE(F_TXT);
		WHEN UTL_FILE.WRITE_ERROR THEN
			G_niv_msg	:= 0;
			G_msg_adm    := 'UTL_FILE.WRITE_ERROR';
			G_erreur := G_msg_adm;
			P_INS_journal;
			UTL_FILE.FCLOSE(F_TXT);
		When Others then
			G_niv_msg := 0;
			G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
			P_INS_journal;
			G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
			G_erreur := G_msg_adm;
			P_INS_journal;
			P_fin_traitement;
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
	--
	-- ouverture du fichier à écrire
	--
		G_datejour	:= To_char(Sysdate, 'DDMMYYYY');
       	G_suffixe_fich_ex25t	:= nvl(to_char(G_datejour),'0');
        Nom_fich_ex25t			:= 'EX25T_'||G_suffixe_fich_ex25t||'.txt';
		--
		-- EXPORT est le nom d'une Directory definie dans Oracle
		--
		F_TXT					:= UTL_FILE.FOPEN('EXPORT',Nom_fich_ex25t,'W',32767);
	--
Exception
		WHEN UTL_FILE.INVALID_MODE THEN
			G_niv_msg := 0;
			G_msg_adm    := 'UTL_FILE.INVALID_MODE';
	        G_erreur := G_msg_adm;
	        P_INS_journal;
			UTL_FILE.FCLOSE(F_TXT);
		WHEN UTL_FILE.INVALID_OPERATION THEN
			G_niv_msg := 0;
			G_msg_adm    := 'UTL_FILE.INVALID_OPERATION';
	        G_erreur := G_msg_adm;
	        P_INS_journal;
			UTL_FILE.FCLOSE(F_TXT);
		WHEN UTL_FILE.INVALID_PATH THEN
			G_niv_msg := 0;
			G_msg_adm    := 'UTL_FILE.INVALID_PATH';
	        G_erreur := G_msg_adm;
	        P_INS_journal;
			UTL_FILE.FCLOSE(F_TXT);
		WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
			G_niv_msg := 0;
			G_msg_adm    := 'UTL_FILE.INVALID_MAXLINESIZE';
	        G_erreur := G_msg_adm;
	        P_INS_journal;
			UTL_FILE.FCLOSE(F_TXT);
		When Others then
			G_niv_msg := 0;
			G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
			P_INS_journal;
			G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
			G_erreur := G_msg_adm;
			P_INS_journal;
			P_fin_traitement;
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
------------
        G_niv_msg     := 3;
        G_msg_adm     := 'fermeture fichier';
        P_INS_journal;
------------
		-- fermeture du fichier à écrire
		--
		UTL_FILE.FCLOSE(F_TXT);
		--
	INSERT	INTO 	lib_edition	(numedit, editlib)
		VALUES			(G_session, ('Generation fichier EX25T'||G_datejour));
--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Fin Normale du traitement le '||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	-- Fin ecriture dans le Journal
--
Exception
		WHEN UTL_FILE.INVALID_FILEHANDLE THEN
			G_niv_msg := 0;
			G_msg_adm    := 'UTL_FILE.INVALID_FILEHANDLE';
			G_erreur := G_msg_adm;
			P_INS_journal;
			UTL_FILE.FCLOSE(F_TXT);
		WHEN UTL_FILE.WRITE_ERROR THEN
			G_niv_msg := 0;
			G_msg_adm    := 'UTL_FILE.WRITE_ERROR';
			G_erreur := G_msg_adm;
			P_INS_journal;
			UTL_FILE.FCLOSE(F_TXT);
		When Others then
	        G_niv_msg := 0;
	        G_Msg_adm := F_centre( 'Erreur procedure ' || G_proc || ' : ', 78 );
	        P_INS_journal;
	        G_msg_adm := to_char(sqlcode) || '-' || Substr(SQLERRM(SQLCODE),1,128);
	        G_erreur := G_msg_adm;
	        P_INS_journal;
			IF UTL_FILE.IS_OPEN(F_TXT) THEN
				UTL_FILE.FCLOSE(F_TXT);
			END IF;
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
