CREATE OR REPLACE PACKAGE ARTHUS.pk_ex98t AS
--
PROCEDURE P_ex98t(
		 I_date_couv_ad	IN	Varchar2 default null,
		 I_date_nais_ad	IN	Varchar2 default null,
		 I_session	IN	NUMBER			Default 1,
		 I_niv_msg	IN	NUMBER			Default 1,
		 I_Repertoire 	IN	Varchar2 default null,
		 I_Fichier 		IN 	Varchar2 default null,
		 O_found	OUT	NUMBER,
		 O_erreur	OUT	VARCHAR2
		);
--

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_ex98t AS
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
-- -------------------------------------- Fin des variables globales privees
-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
PROCEDURE p_debut_traitement;
--
PROCEDURE p_fin_traitement;
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

-- Variables de sortie
G_date              VArchar2(8);
G_heure             VArchar2(8);
--
-- Parametres de la demande
--
-- Variables globales priv‚es
--
G_adr		VARCHAR2(1024);
G_adr1		VARCHAR2(1024);
G_adr2		VARCHAR2(1024);
G_ville		VARCHAR2(1024);
G_codpos		VARCHAR2(1024);
G_cedex		VARCHAR2(1024);
G_pays		VARCHAR2(1024);
G_datapli	VARCHAR2(10);
G_datper		VARCHAR2(10);
G_ldatapli	VARCHAR2(10);
G_user		VARCHAR2(31);
G_nom_ad 	VARCHAR2(31);
G_prenom_ad 	VARCHAR2(31);

G_lu_numindiv	NUMBER default null;
G_numindiv_W	NUMBER default null;
G_typassu	 	NUMBER;
G_numedit	 	NUMBER;
G_numdmnde	 	NUMBER;
G_complete	 	NUMBER;
G_idadresse  	NUMBER;
flag_test	 	NUMBER;

--
--
-- Variables d'écriture de fichier
--
FIC_OUT			UTL_FILE.FILE_TYPE;
G_repertoire   	typ_batch.REPERTOIRE%TYPE;
G_fichier		VARCHAR2(200);
G_record 		VARCHAR2(1024);
--
--
G_flag_test		NUMBER;
G_proc			VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%TYPE default 'pk_ex98t';
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
CURSOR c_info (I_date_couv_ad varchar2, I_date_nais_ad varchar2) IS
	SELECT 	'"'|| indvs.numindiv||'";"'||
			substr(indvs.refcie,1,10)||'";"'||
			indvs.tel||'";"'||
			c.libelle||'";"'||
			indvs.nom||'";"'||
			indvs.prenom||'";"' ligne,
			'' ligne2,
			indvs.numindiv,
			adhe_cntrt.idadhesion
	FROM	indvs,libelle c,adhe_cntrt,adhe_cntrt_membre,adhesion,
			indvs indvs_ad
	WHERE 	adhe_cntrt.numadhe=indvs.numindiv
	AND		adhe_cntrt.numgar =1
	AND		nvl(adhe_cntrt.date_fin_adhe,
					e2d(I_date_couv_ad))>=
					e2d(I_date_couv_ad)
	AND		c.code(+)=indvs.qualite
	AND		c.mnemo(+)='QLTE'
	and 	adhe_cntrt_membre.idadhesion=adhe_cntrt.idadhesion
	and 	adhesion.idadhesion=adhe_cntrt.idadhesion
	and 	adhe_cntrt_membre.typadr in(4,8)
	and 	adhe_cntrt_membre.numindiv=adhesion.numindiv
	AND		nvl(adhesion.datper,
					e2d(I_date_couv_ad))>=
					e2d(I_date_couv_ad)
	and 	nvl(adhesion.datper,adhesion.datapli+1)!=adhesion.datapli
	and 	adhesion.etat in(select code from lble where mnemo='ETIN'
				and sens=0)
	and 	adhe_cntrt_membre.numindiv=indvs_ad.numindiv
	and 	indvs_ad.datnais<e2d(I_date_nais_ad)
	ORDER BY indvs.nom;
--
----------------------------------------------------------------------------
--
-- Le corps des différentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_ex98t	(
		 I_date_couv_ad	IN	Varchar2 default null,
		 I_date_nais_ad	IN	Varchar2 default null,
		 I_session	IN	NUMBER			Default 1,
		 I_niv_msg	IN	NUMBER			Default 1,
		 I_Repertoire 	IN	Varchar2 default null,
		 I_Fichier 		IN 	Varchar2 default null,
		 O_found	OUT	NUMBER,
		 O_erreur	OUT	VARCHAR2
			)
IS
first_row boolean;
BEGIN
	--
	-- ctt 03/09/2007 :
	-- Réinitialisation des variables (cas réutilisation immédiate du package...)
	first_row := TRUE;
	G_record  := '';
	--
	O_found         := 1;
	G_erreur        := Null;
	--
	G_repertoire 	:= I_Repertoire;
	G_fichier 		:= I_Fichier;
	--
	G_max_msg       := I_niv_msg;
	G_session       := I_session;
	--G_idligne     := F_max_idligne(I_session => G_session);

-->>
--
	O_found	:= 1;

	p_debut_traitement;
	--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Début traitement - ouverture du curseur'  ;
	P_INS_journal;
--
	FOR rec_info in c_info(I_date_couv_ad, I_date_nais_ad)
	LOOP

		Select pk_personne.f_idadresse(rec_info.numindiv,0,sysdate,'O',0)
		Into G_idadresse
		From dual;

		Select 	pers_adresse.comp_adresse||'";"',
			pk_personne.f_recompose(pers_adresse.no_voie,
			pers_adresse.bis,
			pers_adresse.type_voie,
			pers_adresse.nom_voie,
			32)||'";"',
			pers_adresse.adresse_2||'";"',
			pers_adresse.codpos||'";"',
			pers_adresse.ville||'";"',
			pers_adresse.no_cedex||'";"',
			decode(pers_adresse.codpays,
				prmt.dfpays,'',f_pays(pers_adresse.codpays))||'"'
		Into	G_adr,
				G_adr1,
				G_adr2,
				G_codpos,
				G_ville,
				G_cedex,
				G_pays
		From 	pers_adresse,prmt
		Where	idadresse=G_idadresse;

		if (first_row = TRUE) then
			G_lu_numindiv := rec_info.numindiv;
			G_record := G_record || rec_info.ligne;
			G_record := G_record || rec_info.ligne;
			G_record := G_record || G_adr;
			G_record := G_record || G_adr1;
			G_record := G_record || G_adr2;
			G_record := G_record || G_codpos;
			G_record := G_record || G_ville;
			G_record := G_record || G_cedex;
			G_record := G_record || G_pays;
			first_row := FALSE;
		else
			if (rec_info.numindiv != G_lu_numindiv) then
				UTL_FILE.PUT_LINE(FIC_OUT, G_record);
	  			G_record := '';
				G_record := G_record || rec_info.ligne;
				G_record := G_record || rec_info.ligne;
				G_record := G_record || G_adr;
				G_record := G_record || G_adr1;
				G_record := G_record || G_adr2;
				G_record := G_record || G_codpos;
				G_record := G_record || G_ville;
				G_record := G_record || G_cedex;
				G_record := G_record || G_pays;
				G_numindiv_W  := G_lu_numindiv;
				G_lu_numindiv := rec_info.numindiv;
			end if;
		end if;
	END LOOP;
	--
	O_found	:= 0;
	-- écriture du dernier enregistrement lu si rupture sur n° d'individu
	if (G_numindiv_W != G_lu_numindiv) then
		UTL_FILE.PUT_LINE(FIC_OUT, G_record);
	end if;
	P_fin_traitement;
	--
	O_erreur	:= G_erreur;
	--
EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_ex98t - '||SUBSTR(SQLERRM(SQLCODE),1,128);
		O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;
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
	Select 	Replace(Replace(G_Fichier,'#DT', G_date),'#HR', G_heure)
	Into G_fichier
	From dual;
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
	-- Formatage du nom de fichier
	p_nom_fichier;
	--
	-- Ouverture du fichier d'export
	--
        FIC_OUT			:= UTL_FILE.FOPEN(G_repertoire,G_fichier,'W',32767);
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
	UTL_FILE.FCLOSE(FIC_OUT);
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
