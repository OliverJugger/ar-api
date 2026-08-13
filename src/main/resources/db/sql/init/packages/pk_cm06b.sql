CREATE OR REPLACE PACKAGE ARTHUS.pk_cm06b AS
--
PROCEDURE P_cm06b	(
					 I_valdeb1 IN param_batch.VALDEB1%TYPE default null,
					 I_valfin1 IN param_batch.VALFIN1%TYPE default null,
					 I_valdeb2 IN param_batch.VALDEB2%TYPE default null,
					 I_valfin2 IN param_batch.VALFIN2%TYPE default null,
					 I_valdeb3 IN param_batch.VALDEB3%TYPE default null,
					 I_valfin3 IN param_batch.VALFIN3%TYPE default null,
					 I_valdeb4 IN param_batch.VALDEB4%TYPE default null,
					 I_valfin4 IN param_batch.VALFIN4%TYPE default null,
					 I_valdeb5 IN param_batch.VALDEB5%TYPE default null,
					 I_valfin5 IN param_batch.VALFIN5%TYPE default null,
					 I_valdeb6 IN param_batch.VALDEB6%TYPE default null,
					 I_valfin6 IN param_batch.VALFIN6%TYPE default null,
					 I_valdeb7 IN param_batch.VALDEB7%TYPE default null,
					 I_valfin7 IN param_batch.VALFIN7%TYPE default null,
					 I_valdeb8 IN param_batch.VALDEB8%TYPE default null,
					 I_session		IN	NUMBER				Default 1,
					 I_param1		IN	param_batch.param1%type	Default NULL,
					 I_param5		IN	param_batch.param5%type	Default NULL,
					 I_niv_msg		IN	NUMBER				Default 1,
					 I_Repertoire 	IN	Varchar2 default null,
					 I_Fichier 		IN 	Varchar2 default null,
					 O_found		OUT	NUMBER,
					 O_erreur		OUT	VARCHAR2
					);
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

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_cm06b AS
-- Chaine de reconnaissance SCCS
-- %W%	%E%

-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --
-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
--
E_PAR_REPERTOIRE_VIDE	EXCEPTION;
E_PAR_FICHIER_VIDE		EXCEPTION;
-- ---------------------------------------------- Fin des exceptions privees --

-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --

-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
-- Aucune
-- -------------------------------------- Fin des variables globales privees --

-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
PROCEDURE P_traitement_principal;
--
PROCEDURE P_enreg;
--
FUNCTION f_sel_trav_treso return number;
--
PROCEDURE p_nom_fichier;
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
--
-- Variables de sortie
G_date                  VArchar2(8);
G_heure                 VArchar2(8);
--
G_valdeb1				param_batch.VALDEB1%TYPE;
G_valfin1				param_batch.VALFIN1%TYPE;
G_valdeb2				param_batch.VALDEB2%TYPE;
G_valfin2				param_batch.VALFIN2%TYPE;
G_valdeb3				param_batch.VALDEB3%TYPE;
G_valfin3				param_batch.VALFIN3%TYPE;
G_valdeb4				param_batch.VALDEB4%TYPE;
G_valfin4				param_batch.VALFIN4%TYPE;
G_valdeb5				param_batch.VALDEB5%TYPE;
G_valfin5				param_batch.VALFIN5%TYPE;
G_valdeb6				param_batch.VALDEB6%TYPE;
G_valfin6				param_batch.VALFIN6%TYPE;
G_valdeb7				param_batch.VALDEB7%TYPE;
G_valfin7				param_batch.VALFIN7%TYPE;
G_valdeb8				param_batch.VALDEB8%TYPE;
G_trace					param_batch.param5%TYPE;
--
G_numedit				NUMBER(14);
G_etendue				NUMBER(10);
l_flag_retro			NUMBER(2);
l_numencaismt			NUMBER(10);
l_numdecaismt			NUMBER(10);
--
G_flag_test				NUMBER;
G_flag_export			NUMBER;
-- Variables d'écriture de fichier
--
fsortie					UTL_FILE.FILE_TYPE;
Ligne_f                 Varchar2(32767);
G_repertoire   			typ_batch.REPERTOIRE%TYPE;
G_fichier				VARCHAR2(200);
nb_lignes				NUMBER;

--
G_proc					VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement		Constant journal_adm.nom_traitement%TYPE default 'pk_cm06B';
G_msg_adm				journal_adm.msg_adm%TYPE;
G_session				journal_adm.id_session%TYPE default 1;
G_niv_msg				journal_adm.niv_msg%TYPE := 1;
G_max_msg				journal_adm.niv_msg%TYPE := 1;
G_idligne				journal_adm.idligne%TYPE := 0;
G_erreur				journal_adm.msg_adm%TYPE;
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
-- Le corps des différentes procedures
--
------------------------------------------------------------------
--
PROCEDURE P_cm06b	(
					 I_valdeb1 IN param_batch.VALDEB1%TYPE default null,
					 I_valfin1 IN param_batch.VALFIN1%TYPE default null,
					 I_valdeb2 IN param_batch.VALDEB2%TYPE default null,
					 I_valfin2 IN param_batch.VALFIN2%TYPE default null,
					 I_valdeb3 IN param_batch.VALDEB3%TYPE default null,
					 I_valfin3 IN param_batch.VALFIN3%TYPE default null,
					 I_valdeb4 IN param_batch.VALDEB4%TYPE default null,
					 I_valfin4 IN param_batch.VALFIN4%TYPE default null,
					 I_valdeb5 IN param_batch.VALDEB5%TYPE default null,
					 I_valfin5 IN param_batch.VALFIN5%TYPE default null,
					 I_valdeb6 IN param_batch.VALDEB6%TYPE default null,
					 I_valfin6 IN param_batch.VALFIN6%TYPE default null,
					 I_valdeb7 IN param_batch.VALDEB7%TYPE default null,
					 I_valfin7 IN param_batch.VALFIN7%TYPE default null,
					 I_valdeb8 IN param_batch.VALDEB8%TYPE default null,
					 I_session		IN	NUMBER				Default 1,
					 I_param1		IN	param_batch.param1%type	Default NULL,
					 I_param5		IN	param_batch.param5%type	Default NULL,
					 I_niv_msg		IN	NUMBER				Default 1,
					 I_Repertoire 	IN	Varchar2 default null,
					 I_Fichier 		IN 	Varchar2 default null,
					 O_found		OUT	NUMBER,
					 O_erreur		OUT	VARCHAR2
					)
IS
BEGIN
	--
	G_max_msg       := I_niv_msg;
	G_session       := I_session;
	--
	g_niv_msg	:= 1;
	g_msg_adm	:= 'Début de traitement le ' ||to_char(sysdate, 'dd/mm/yyyy hh24:mi');
	p_ins_journal;
	--
	O_found         := 1;
	G_erreur        := Null;
	--
	-- Variables en entrée
	--
	G_valdeb1		:= I_valdeb1;
	G_valfin1		:= I_valfin1;
	G_valdeb2		:= I_valdeb2;
	G_valfin2		:= I_valfin2;
	G_valdeb3		:= I_valdeb3;
	G_valfin3		:= I_valfin3;
	G_valdeb4		:= I_valdeb4;
	G_valfin4		:= I_valfin4;
	G_valdeb5		:= I_valdeb5;
	G_valfin5		:= I_valfin5;
	G_valdeb6		:= I_valdeb6;
	G_valfin6		:= I_valfin6;
	G_valdeb7		:= I_valdeb7;
	G_valfin7		:= I_valfin7;
	G_valdeb8		:= I_valdeb8;
	--
	G_numedit		:= I_session;
	G_etendue		:= to_number(I_param1);
	G_repertoire 	:= I_Repertoire;
	G_fichier 		:= I_Fichier;
	--
	G_trace			:= I_param5;
	G_flag_test		:= 0;
	G_flag_export	:= 1;
	l_flag_retro 	:= 0;
	--
	nb_lignes := 0;
	--

-- paramètres en entrée :
    g_niv_msg     := 3;
    g_msg_adm     := 'G_numedit : '||to_char(G_numedit)||'Etendue : '||to_char(G_etendue);
    p_ins_journal;
	--
	g_niv_msg     := 3;
    g_msg_adm     := 'Repertoire : '||G_repertoire||'Fichier : '||G_fichier;
    p_ins_journal;
-->>
    g_niv_msg     := 3;
    g_msg_adm     := 'G_valdeb1 : '||to_char(G_valdeb1)||'G_valfin1 : '||to_char(G_valfin1);
    p_ins_journal;
	--
    g_niv_msg     := 3;
    g_msg_adm     := 'G_valdeb2 : '||to_char(G_valdeb2)||'G_valfin2 : '||to_char(G_valfin2);
    p_ins_journal;
	--
    g_niv_msg     := 3;
    g_msg_adm     := 'G_valdeb3 : '||to_char(G_valdeb3)||'G_valfin3 : '||to_char(G_valfin3);
    p_ins_journal;
	--
    g_niv_msg     := 3;
    g_msg_adm     := 'G_valdeb4 : '||to_char(G_valdeb4)||'G_valfin4 : '||to_char(G_valfin4);
    p_ins_journal;
	--
    g_niv_msg     := 3;
    g_msg_adm     := 'G_valdeb5 : '||to_char(G_valdeb5)||'G_valfin5 : '||to_char(G_valfin5);
    p_ins_journal;
	--
    g_niv_msg     := 3;
    g_msg_adm     := 'G_valdeb6 : '||to_char(G_valdeb6)||'G_valfin6 : '||to_char(G_valfin6);
    p_ins_journal;
	--
    g_niv_msg     := 3;
    g_msg_adm     := 'G_valdeb7 : '||to_char(G_valdeb7)||'G_valfin7 : '||to_char(G_valfin7);
    p_ins_journal;
	--
    g_niv_msg     := 3;
    g_msg_adm     := 'G_valdeb8 : '||to_char(G_valdeb8);
    p_ins_journal;
	--
	P_traitement_principal;
	--
	O_found	:= 0;
	--
	g_niv_msg	:= 1;
	g_msg_adm	:= nb_lignes||' lignes enregistrées dans le fichier '||G_fichier;
	p_ins_journal;
	--
	g_niv_msg	:= 1;
	g_msg_adm	:= 'fin normale du traitement le ' ||to_char(sysdate, 'dd/mm/yyyy hh24:mi');
	p_ins_journal;
	--
	O_erreur	:= G_erreur;
	--
--
EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_CM06B - '||SUBSTR(SQLERRM(SQLCODE),1,128);
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
-- Détermination de G_etendue
if (G_etendue = 4) then
--
	G_etendue := 2;
	G_flag_export := 0;
--
elsif (G_etendue = 5) then
--
	G_etendue := 3;
	G_flag_export := 0;
--
elsif (G_etendue = 6) then
--
	G_etendue := 3;
	l_flag_retro := 1;
--
elsif (G_etendue = 1) then
--
	l_numencaismt := to_number(G_valdeb5);
--
elsif (G_etendue = 2) then
--
	l_numencaismt := to_number(G_valdeb8);
--
end if;
--
-- P_enreg : Lancement de pk_extraction en fonction de la variable G_etendue
-- écriture dans le fichier fsortie ou fsortie pour la fonction f_sel_trav_treso
	P_enreg;
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
procedure P_enreg
is

begin
--
g_proc := 'P_enreg';
--
	-- Formatage du nom de fichier
	--
	p_nom_fichier;
--
--
g_proc := 'P_enreg';
--
	--
	g_niv_msg     := 3;
    g_msg_adm     := 'Repertoire : '||G_repertoire||' Nom Fichier formaté : '||G_fichier;
    p_ins_journal;
	--
	--
	If G_Repertoire is null Then
		Raise E_PAR_REPERTOIRE_VIDE;
	End If;
	--
	If G_Fichier is null or G_Fichier = '' Then
		Raise E_PAR_FICHIER_VIDE;
	End If;
	--
	fsortie := UTL_FILE.FOPEN( G_Repertoire, G_Fichier, 'W', 32767);
--
if (G_etendue = 1) then
--
	LOOP
	-- conception de l'enregistrement
	--
		ligne_f := null;
	--
		Begin
		pk_extraction.P_SEL_compte_attente(
               	I_deb_origine   => G_valdeb1,
               	I_fin_origine   => G_valfin1,
               	I_deb_modpmt    => G_valdeb2,
               	I_fin_modpmt    => G_valfin2,
               	I_deb_numcli    => G_valdeb3,
               	I_fin_numcli    => G_valfin3,
               	I_datope        => e2d(G_valdeb4),
				I_numencaismt	=> l_numencaismt,
               	I_session       => G_numedit,
               	I_flag_test     => G_flag_test,
               	O_ligne         => ligne_f
               	);
		Exception
			when no_data_found then
				exit;
		End;
	--
		UTL_FILE.PUT_LINE(fsortie,ligne_f);
	--
		nb_lignes := nb_lignes + 1 ;
	--
	END LOOP;
	--
elsif (G_etendue = 2 ) then
--
	EXECUTE IMMEDIATE 'TRUNCATE table trav_treso';
--
-- 	ctt 24/04/07 : Juste pour extraction des encaissements : on positionne G_flag_test à 1 si le param5 de param_batch est différent de 'notest';
	if (G_trace <> 'notest' and G_trace is not null) then
		G_flag_test := 1;
	else
		G_flag_test := 0;
	end if;

	pk_extraction.P_SEL_encaismt(
								I_deb_codope   		=> G_valdeb1,
								I_fin_codope   		=> G_valfin1,
								I_deb_modpmt    	=> G_valdeb2,
								I_fin_modpmt    	=> G_valfin2,
								I_deb_type_contrat	=> G_valdeb3,
								I_fin_type_contrat	=> G_valfin3,
								I_deb_risque		=> G_valdeb4,
								I_fin_risque		=> G_valfin4,
				               	I_debut        		=> e2d(G_valdeb5),
				               	I_fin        		=> e2d(G_valfin5),
				               	I_deb_eche     		=> e2d(G_valdeb6),
				               	I_fin_eche     		=> e2d(G_valfin6),
				               	I_deb_numcli    	=> G_valdeb7,
				               	I_fin_numcli    	=> G_valfin7,
								I_numencaismt		=> l_numencaismt,
				               	I_session       	=> G_numedit,
				               	I_flag_test     	=> G_flag_test
				               	);
	--
	commit;
	--
	if (G_flag_export = 1) then
	--
		if (f_sel_trav_treso() = 1) then --goto errexit;
			--
			g_niv_msg     := 3;
			g_msg_adm     := 'Erreur : '||to_char(sqlcode) || '-' || substr(sqlerrm(sqlcode),1,128);
			p_ins_journal;
			--
			ROLLBACK WORK;
			--
		end if;
	--
	end if;
--
elsif (G_etendue = 3 ) then
--
	EXECUTE IMMEDIATE 'TRUNCATE table trav_treso';
	--
	pk_extraction.P_SEL_decaismt(
				               	I_deb_codope   		=> G_valdeb1,
				               	I_fin_codope   		=> G_valfin1,
				               	I_deb_modpmt    	=> G_valdeb2,
				               	I_fin_modpmt    	=> G_valfin2,
								I_deb_type_contrat	=> G_valdeb3,
								I_fin_type_contrat	=> G_valfin3,
								I_deb_risque		=> G_valdeb4,
								I_fin_risque		=> G_valfin4,
				               	I_debut        		=> e2d(G_valdeb5),
				               	I_fin        		=> e2d(G_valfin5),
				               	I_deb_numcli    	=> G_valdeb6,
				               	I_fin_numcli    	=> G_valfin6,
				               	I_session       	=> G_numedit,
				               	I_flag_test     	=> G_flag_test,
								I_flag_retro		=> l_flag_retro
				               	);
	--
	COMMIT;
	--
	if (G_flag_export = 1) then
	--
		if (f_sel_trav_treso() = 1) then --goto errexit;
			--
			g_niv_msg     := 3;
			g_msg_adm     := 'Erreur : '||to_char(sqlcode) || '-' || substr(sqlerrm(sqlcode),1,128);
			p_ins_journal;
			--
			ROLLBACK WORK;
			--
		end if;
	--
	end if;
	--
elsif (G_etendue = 7 ) then
--
	EXECUTE IMMEDIATE 'TRUNCATE table trav_treso';
	--
	pk_extraction.P_SEL_emission(
				               	I_debut        		=> e2d(G_valdeb1),
				               	I_fin        		=> e2d(G_valfin1),
				               	I_deb_eche     		=> e2d(G_valdeb2),
				               	I_fin_eche     		=> e2d(G_valfin2),
								I_deb_type_contrat	=> G_valdeb3,
								I_fin_type_contrat	=> G_valfin3,
								I_deb_risque		=> G_valdeb4,
								I_fin_risque		=> G_valfin4,
				               	I_deb_numcli    	=> G_valdeb5,
				               	I_fin_numcli    	=> G_valfin5,
				               	I_session       	=> G_numedit,
				               	I_flag_test     	=> G_flag_test
				               	);
	--
	COMMIT;
	--
	if (G_flag_export = 1) then
	--
		if (f_sel_trav_treso() = 1) then --goto errexit;
			--
			g_niv_msg     := 3;
			g_msg_adm     := 'Erreur : '||to_char(sqlcode) || '-' || substr(sqlerrm(sqlcode),1,128);
			p_ins_journal;
			--
			ROLLBACK WORK;
			--
		end if;
	--
	end if;
	--
end if;
--
	--
	-- fermeture du fichier à écrire
	--
	UTL_FILE.FCLOSE(fsortie);
--
exception
  WHEN E_PAR_REPERTOIRE_VIDE then
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'Nom du répertoire de sortie manquant';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;

  WHEN E_PAR_FICHIER_VIDE Then
	G_niv_msg := 0;
	G_msg_adm    := g_proc||'Nom du fichier de sortie manquant';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;

  WHEN UTL_FILE.INTERNAL_ERROR THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.INTERNAL_ERROR';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);

  WHEN UTL_FILE.INVALID_FILEHANDLE THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.INVALID_FILEHANDLE';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);

  WHEN UTL_FILE.INVALID_MODE THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.INVALID_MODE';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);

  WHEN UTL_FILE.INVALID_OPERATION THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.INVALID_OPERATION';
--	Insertion dans journal_adm du message d'erreur
	UTL_FILE.FCLOSE(fsortie);

  WHEN UTL_FILE.INVALID_PATH THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.INVALID_PATH';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);

  WHEN UTL_FILE.READ_ERROR THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.READ_ERROR';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);

  WHEN UTL_FILE.WRITE_ERROR THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.WRITE_ERROR';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);

  WHEN VALUE_ERROR THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'VALUE_ERROR'||SUBSTR(SQLERRM(SQLCODE),1,128);
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);

  when others then
        g_niv_msg := 0;
        g_msg_adm := f_centre( 'erreur procedure ' || g_proc || ' : ', 78 );
        p_ins_journal;
        g_msg_adm := to_char(sqlcode) || '-' || substr(sqlerrm(sqlcode),1,128);
        g_erreur := g_msg_adm;
        p_ins_journal;
		--
		UTL_FILE.FCLOSE(fsortie);
--
end P_enreg;
--
-- -----------------------
function f_sel_trav_treso
return number
is
begin
--
g_proc := 'f_sel_trav_treso';

--
	LOOP
	-- conception de l'enregistrement
	--
		ligne_f := null;
	--
		begin
			pk_extraction.P_SEL_trav_treso	(
										I_etendue		=> G_etendue,
										O_ligne         => ligne_f
										);
		exception
			when no_data_found then
				exit;
		end;
	--
		UTL_FILE.PUT_LINE(fsortie,ligne_f);
	--
		nb_lignes := nb_lignes + 1 ;
	--
	END LOOP;
	--
return(0);
--
exception
  WHEN E_PAR_REPERTOIRE_VIDE then
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'Nom du répertoire de sortie manquant';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	return(1);

  WHEN E_PAR_FICHIER_VIDE Then
	G_niv_msg := 0;
	G_msg_adm    := g_proc||'Nom du fichier de sortie manquant';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	return(1);

  WHEN UTL_FILE.INTERNAL_ERROR THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.INTERNAL_ERROR';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);
	return(1);

  WHEN UTL_FILE.INVALID_FILEHANDLE THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.INVALID_FILEHANDLE';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);
	return(1);

  WHEN UTL_FILE.INVALID_MODE THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.INVALID_MODE';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);
	return(1);

  WHEN UTL_FILE.INVALID_OPERATION THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.INVALID_OPERATION';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);
	return(1);

  WHEN UTL_FILE.INVALID_PATH THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.INVALID_PATH';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);
	return(1);

  WHEN UTL_FILE.READ_ERROR THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.READ_ERROR';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);
	return(1);

  WHEN UTL_FILE.WRITE_ERROR THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'UTL_FILE.WRITE_ERROR';
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);
	return(1);

  WHEN VALUE_ERROR THEN
--	Rollback;
    G_niv_msg := 0;
	G_msg_adm    := g_proc||'VALUE_ERROR'||SUBSTR(SQLERRM(SQLCODE),1,128);
--	Insertion dans journal_adm du message d'erreur
    P_INS_journal;
	UTL_FILE.FCLOSE(fsortie);
	return(1);
	--
  when others then
        g_niv_msg := 0;
        g_msg_adm := f_centre( 'erreur procedure ' || g_proc || ' : ', 78 );
        p_ins_journal;
        g_msg_adm := to_char(sqlcode) || '-' || substr(sqlerrm(sqlcode),1,128);
        g_erreur := g_msg_adm;
        p_ins_journal;
		--
		UTL_FILE.FCLOSE(fsortie);
		return(1);
--
end f_sel_trav_treso;
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
end p_nom_fichier;
--
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
