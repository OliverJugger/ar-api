CREATE OR REPLACE PACKAGE ARTHUS.pk_sp02b AS
--
PROCEDURE P_sp02b(
		 I_numremise	IN	remise_externe.numremise%type	default NULL,
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

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_sp02b AS
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
PROCEDURE P_CORPS;
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
--
G_attest_prec		VARCHAR2(550);
G_entete		VARCHAR2(550);
G_expedition		VARCHAR2(256);
G_attest_1		VARCHAR2(2300);
G_attest_2		VARCHAR2(2300);
G_attest_3		VARCHAR2(2300);
--
G_numremise		NUMBER(9);
G_lnumremise		VARCHAR2(9);
--
-- Variables globales priv‚es
--
--
--
-- Variables d'écriture de fichier
--
RUWA			UTL_FILE.FILE_TYPE;
G_repertoire   	typ_batch.REPERTOIRE%TYPE;
G_fichier		VARCHAR2(200);
--
Ligne_f                 Varchar2(2300);
--

-- Flag de commit ou rollback a retourner a Forms
G_commit		Boolean := FALSE;
G_rollback		Boolean := FALSE;
G_auto_valide		Boolean := FALSE;
--
G_flag_test		NUMBER;
G_proc			VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%TYPE default 'pk_sp02B';
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
--
----------------------------------------------------------------------------
--
-- Le corps des diff‚rentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_sp02b	(
		 I_numremise	IN	remise_externe.numremise%type	default NULL,
		 I_session	IN	NUMBER				Default 1,
		 I_niv_msg	IN	NUMBER				Default 1,
		 I_pause	IN	NUMBER				Default 0,
		 I_Repertoire 	IN	Varchar2 default null,
		 I_Fichier 		IN 	Varchar2 default null,
		 O_found	OUT	NUMBER,
		 O_erreur	OUT	VARCHAR2
			)
IS
BEGIN
	--
	O_found         := 1;
	G_erreur        := Null;
	--
	G_numremise	:= I_numremise;
	G_repertoire 	:= I_Repertoire;
	G_fichier 		:= I_Fichier;
	--
	G_max_msg       := I_niv_msg;
	G_session       := I_session;
	--G_idligne     := F_max_idligne(I_session => G_session);

-->>
                g_niv_msg     := 3;
                g_msg_adm     := 'G_numremise : '||to_char(G_numremise)
				||' G_session : '||to_char(G_session);
                p_ins_journal;
-->>
	--
	O_found	:= 1;
	--
	P_debut_traitement;
	--
	--
	IF G_numremise is not null
	THEN
		P_traitement_principal;
	ELSE
                g_niv_msg     := 1;
                g_msg_adm     := 'Numéro de remise non renseigné';
                p_ins_journal;
	END IF;
	--
	--
	O_found	:= 0;
	P_fin_traitement;
	--
	O_erreur	:= G_erreur;
	--
--
EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_SP02B - '||SUBSTR(SQLERRM(SQLCODE),1,128);
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
	--
	G_attest_prec	:= Null;
	G_entete	:= Null;
	G_expedition	:= Null;
	G_attest_1	:= Null;
	G_attest_2	:= Null;
	G_attest_3	:= Null;
	--
	BEGIN
	pk_ruwa.P_TRAITE_remise 	(
			I_numremise	=>  G_numremise,
			O_attest_prec	=>  G_attest_prec,
			O_entete	=>  G_entete,
			O_expedition	=>  G_expedition,
			O_attest_1	=>  G_attest_1,
			O_attest_2	=>  G_attest_2,
			O_attest_3	=>  G_attest_3
					);
	END;
	--

-->>
                g_niv_msg     := 3;
                g_msg_adm     := 'G_attest_prec : '||substr(G_attest_prec,1,100);
                p_ins_journal;
                g_niv_msg     := 3;
                g_msg_adm     := 'G_entete : '||substr(G_entete,1,100);
                p_ins_journal;
                g_niv_msg     := 3;
                g_msg_adm     := 'G_expedition : '||substr(G_expedition,1,100);
                p_ins_journal;
                g_niv_msg     := 3;
                g_msg_adm     := 'G_attest_1 : '||substr(G_attest_1,1,100);
                p_ins_journal;
                g_niv_msg     := 3;
                g_msg_adm     := 'G_attest_2 : '||substr(G_attest_2,1,100);
                p_ins_journal;
                g_niv_msg     := 3;
                g_msg_adm     := 'G_attest_3 : '||substr(G_attest_3,1,100);
                p_ins_journal;
-->>

	--
  	P_CORPS;
	--
	--
	BEGIN
	pk_ruwa.P_MAJ_remise_externe 	(
			I_numremise	=>  G_numremise
					);
	END;
	--
--
EXCEPTION when others then
        g_niv_msg := 0;
        g_msg_adm := f_centre( 'erreur procedure ' || g_proc || ' : ', 78 );
        p_ins_journal;
        g_msg_adm := to_char(sqlcode) || '-' || substr(sqlerrm(sqlcode),1,128);
        g_erreur := g_msg_adm;
        p_ins_journal;
--
END;
--
-- -----------------------
procedure P_CORPS
is
begin
--
g_proc := 'P_CORPS';
--
---
---
	IF G_attest_prec is not null
	THEN
	-- conception de l'enregistrement
--
                ligne_f         := null;
--
                ligne_f         := G_attest_prec;
--
	-- ecriture de l'enregistrement
--
                g_niv_msg     := 3;
                g_msg_adm     := 'ligne f - '||'G_attest_prec : ';
                p_ins_journal;
--
                UTL_FILE.PUT_LINE(RUWA,ligne_f);
--
	END IF;
---
---
	IF G_entete is not null
	THEN
	-- conception de l'enregistrement
--
                ligne_f         := null;
--
                ligne_f         := G_entete;
--
	-- ecriture de l'enregistrement
--
                g_niv_msg     := 3;
                g_msg_adm     := 'ligne f - '||'G_entete : ';
                p_ins_journal;
--
                UTL_FILE.PUT_LINE(RUWA,ligne_f);
--
	END IF;
---
---
	IF G_expedition is not null
	THEN
	-- conception de l'enregistrement
--
                ligne_f         := null;
--
                ligne_f         := G_expedition;
--
	-- ecriture de l'enregistrement
--
                g_niv_msg     := 3;
                g_msg_adm     := 'ligne f - '||'G_expedition : ';
                p_ins_journal;
--
                UTL_FILE.PUT_LINE(RUWA,ligne_f);
--
	END IF;
---
---
	IF G_attest_1 is not null
	THEN
	-- conception de l'enregistrement
--
                ligne_f         := null;
--
                ligne_f         := G_attest_1;
--
	-- ecriture de l'enregistrement
--
                g_niv_msg     := 3;
                g_msg_adm     := 'ligne f - '||'G_attest_1 : ';
                p_ins_journal;
--
                UTL_FILE.PUT_LINE(RUWA,ligne_f);
--
	END IF;
---
---
	IF G_attest_2 is not null
	THEN
	-- conception de l'enregistrement
--
                ligne_f         := null;
--
                ligne_f         := G_attest_2;
--
	-- ecriture de l'enregistrement
--
                g_niv_msg     := 3;
                g_msg_adm     := 'ligne f - '||'G_attest_2 : ';
                p_ins_journal;
--
                UTL_FILE.PUT_LINE(RUWA,ligne_f);
--
	END IF;
---
---
	IF G_attest_3 is not null
	THEN
	-- conception de l'enregistrement
--
                ligne_f         := null;
--
                ligne_f         := G_attest_3;
--
	-- ecriture de l'enregistrement
--
                g_niv_msg     := 3;
                g_msg_adm     := 'ligne f - '||'G_attest_3 : ';
                p_ins_journal;
--
                UTL_FILE.PUT_LINE(RUWA,ligne_f);
--
	END IF;
---
---
	-- conception de l'enregistrement fin
--
                ligne_f         := null;
                ligne_f         := '99';
--
	-- ecriture de l'enregistrement fin
---------------
                g_niv_msg     := 3;
                g_msg_adm     := 'ligne f - '||' fin : ';
                p_ins_journal;
---------------
	--
                UTL_FILE.PUT_LINE(ruwa,ligne_f);
	--
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
	select 	Replace(
			Replace(G_Fichier	,'#DT', G_date)
								,'#HR', G_heure)
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
-- debut et fin du traitement
--
-- ----------------------------------------------------------------------------------------
procedure p_debut_traitement
is
begin
--
g_proc := 'p_debut_traitement';
--
	--
	g_niv_msg	:= 1;
	g_msg_adm	:= 'debut de traitement le ' ||
				to_char(sysdate, 'dd/mm/yyyy hh24:mi');
	p_ins_journal;
	--
	G_lnumremise	:= lpad(nvl(to_char(G_numremise),'0'), 9, '0');
	--
	-- Formatage du nom de fichier
	p_nom_fichier;
	--
	-- Ouverture du fichier d'export
	--
        RUWA			:= UTL_FILE.FOPEN(G_Repertoire,G_Fichier,'W',32767);
	--
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
-- -----------------------
procedure p_fin_traitement
is
begin
--
g_proc := 'p_fin_traitement';
--
------------
        g_niv_msg     := 3;
        g_msg_adm     := 'fermeture fichier';
        p_ins_journal;
------------
	--
	-- fermeture du fichier à écrire
	--
	UTL_FILE.FCLOSE(RUWA);
	--
	Insert 	into 	lib_edition 	(numedit,
					 editlib
					)
		values			(g_session,
					 'generation fichier RUWA n° '||G_numremise
					);
	--
	g_niv_msg	:= 1;
	g_msg_adm	:= 'fin normale du traitement le ' ||
				to_char(sysdate, 'dd/mm/yyyy hh24:mi');
	p_ins_journal;
	--
--
exception when others then
        g_niv_msg := 0;
        g_msg_adm := f_centre( 'erreur procedure ' || g_proc || ' : ', 78 );
        p_ins_journal;
        g_msg_adm := to_char(sqlcode) || '-' || substr(sqlerrm(sqlcode),1,128);
        g_erreur := g_msg_adm;
        p_ins_journal;

end;
--
----------------------- fin des procedures publiques ------------------

-- -- corps des procedures et fonctions privees --------------------------
--@corpriv
-- insertion dans journal_adm
procedure p_ins_journal
is
l_idligne	number;
begin
if ( g_niv_msg <= g_max_msg ) then
	g_idligne := g_idligne + 1;
	if ( g_niv_msg = 0 ) then
		l_idligne := -1 * g_idligne;
	else
		l_idligne := g_idligne;
	end if;
	pk_trace.p_ins_journal_adm (
		i_nom_traitement => g_nom_traitement,
		i_session	 => g_session,
		i_niv_msg	 => g_niv_msg,
		i_msg_adm	 => g_msg_adm,
		i_idligne	 => l_idligne);
end if;
end p_ins_journal;
---------------- fin des corps des procedures privees --
end;
/
