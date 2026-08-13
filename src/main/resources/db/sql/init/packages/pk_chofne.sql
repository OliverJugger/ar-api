CREATE OR REPLACE PACKAGE ARTHUS.pk_chofne AS
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
-- Aucune
-- --------------------------------------------- Fin des variables publiques --
-- -- PROCEDURES PUBLIQUES ----------------------------------------------------
--
PROCEDURE p_extract (	I_societe 	IN contrat.numinterm%TYPE 	DEFAULT null,
						I_contrat_1	IN adhe_cntrt.numgar%TYPE 	DEFAULT null,
						I_contrat_2	IN adhe_cntrt.numgar%TYPE 	DEFAULT null,
						I_variable 	IN VARCHAR2  				DEFAULT null,
						I_valeur_1	IN val_variable.valeur%TYPE DEFAULT null,
						I_valeur_2	IN val_variable.valeur%TYPE DEFAULT null,
						I_etatadhe	IN histo_adhesion.etat%TYPE ,
						I_Repertoire IN	VARCHAR2 				DEFAULT null,
						I_Fichier 	IN VARCHAR2 				DEFAULT null,
						I_session	IN NUMBER 					DEFAULT 1,
						I_niv_msg	IN NUMBER					DEFAULT 1
					);
END pk_chofne;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_chofne AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%
-- -- CONSTANTES PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des constantes privees --
-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
-- Aucune
-- ---------------------------------------------- Fin des exceptions privees --
-- -- TYPES PRIVEES -----------------------------------------------------------
-- Aucun
-- --------------------------------------------------- Fin des types privees --
-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
PROCEDURE p_debut_traitement;
--
PROCEDURE p_fin_traitement;
--
Procedure p_nom_fichier;
--
Procedure P_INS_journal;
--
-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
--
-- Variables d'écriture de fichier
--
FIC_OUT			UTL_FILE.FILE_TYPE;
G_repertoire   	typ_batch.REPERTOIRE%TYPE;
G_fichier		VARCHAR2(200);
G_record 		VARCHAR2(1024);
-- Variables de sortie
G_date          VARCHAR2(8);
G_heure         VARCHAR2(8);
--
-- Variables de P_INS_journal
--
G_prefixe			VARCHAR2(9) := 'pk_chofne';
G_nom_traitement  	journal_adm.nom_traitement%Type;
G_msg_adm       	journal_adm.msg_adm%Type;
G_session       	journal_adm.id_session%Type DEFAULT 1;
G_flag_test    		number;
G_niv_msg       	journal_adm.niv_msg%TYPE := 1;
G_max_msg       	journal_adm.niv_msg%TYPE := 1;
G_idligne       	journal_adm.idligne%TYPE := 0;
G_proc				VARCHAR2(80);
--
--
-- **************************************************************************************************************************
PROCEDURE p_extract (	I_societe 	IN contrat.numinterm%TYPE 	DEFAULT null,
						I_contrat_1	IN adhe_cntrt.numgar%TYPE 	DEFAULT null,
						I_contrat_2	IN adhe_cntrt.numgar%TYPE 	DEFAULT null,
						I_variable 	IN VARCHAR2  				DEFAULT null,
						I_valeur_1	IN val_variable.valeur%TYPE DEFAULT null,
						I_valeur_2	IN val_variable.valeur%TYPE DEFAULT null,
						I_etatadhe	IN histo_adhesion.etat%TYPE ,
						I_Repertoire IN	VARCHAR2 				DEFAULT null,
						I_Fichier 	IN VARCHAR2 				DEFAULT null,
						I_session	IN NUMBER 					DEFAULT 1,
						I_niv_msg	IN NUMBER					DEFAULT 1
					)
IS
CURSOR c_chofne IS
		SELECT
			adhe_cntrt.numadhe,
		    pk_libelle.f_lib('QLTE', individu.qualite) qualite,
			individu.nom,
		    individu.prenom,
			pk_personne.f_adresse(pk_personne.f_idadresse(adhe_cntrt.numadhe),1,adhe_cntrt.numadhe,0) adresse_1,
			pk_personne.f_adresse(pk_personne.f_idadresse(adhe_cntrt.numadhe),2,adhe_cntrt.numadhe,0) adresse_2,
			pk_personne.f_adresse(pk_personne.f_idadresse(adhe_cntrt.numadhe),3,adhe_cntrt.numadhe,0) adresse_3,
			pk_personne.f_adresse(pk_personne.f_idadresse(adhe_cntrt.numadhe),4,adhe_cntrt.numadhe,0) adresse_4,
		    to_char(individu.datnais, 'DD/MM/YYYY') datnais,
			adhe_cntrt.numgar
		FROM
			individu,
			histo_adhesion,
			adhe_cntrt,
			contrat
		WHERE
			contrat.numinterm 	between I_societe
								and nvl(I_societe,I_societe)
		AND contrat.numgar 		between nvl(I_contrat_1,contrat.numgar)
								and nvl(I_contrat_2, nvl(I_contrat_1,contrat.numgar))
		AND
		(
			(I_variable is not null
			AND EXISTS
				(select 1 from val_variable a
				where etendue=13
				and clef=adhe_cntrt.idadhesion
				and idvariable = f_idvariable(I_variable,1)
				and nvl(fin,debut+1)!=debut
				and nvl(fin,sysdate)>=sysdate
				and valeur between 	nvl(to_number(I_valeur_1),valeur)
						   and 		nvl(to_number(I_valeur_2),nvl(to_number(I_valeur_1),valeur))
				Union
				select 1 from val_variable a
				where etendue=4
				and clef=adhe_cntrt.numadhe
				and idvariable = f_idvariable(I_variable,1)
				and nvl(fin,debut+1)!=debut
				and nvl(fin,sysdate)>=sysdate
				and valeur between	nvl(to_number(I_valeur_1),valeur)
						   and 		nvl(to_number(I_valeur_2),nvl(to_number(I_valeur_1),valeur))
				)
			)
			or
			(I_variable is null)
		)
		AND adhe_cntrt.numadhe = individu.numindiv
		AND nvl(adhe_cntrt.date_fin_adhe,adhe_cntrt.date_adhe+1) !=	adhe_cntrt.date_adhe
		AND adhe_cntrt.numgar = contrat.numgar
		AND adhe_cntrt.idadhesion = histo_adhesion.idadhesion
		AND histo_adhesion.debut = (	select max(a.debut)
									from histo_adhesion a
									where a.idadhesion=adhe_cntrt.idadhesion
									and a.etat=histo_adhesion.etat
								  )
		AND histo_adhesion.etat = nvl(I_etatadhe,histo_adhesion.etat)
		AND exists(	select 1 from adhesion
					where adhesion.idadhesion=adhe_cntrt.idadhesion
					and adhesion.numindiv=adhe_cntrt.numadhe
					and nvl(adhesion.datper,sysdate)>=sysdate
					)
	order by adhe_cntrt.numadhe;
--
nb_rows number;
--
BEGIN

	G_repertoire 	:= I_Repertoire;
	G_fichier 		:= I_Fichier;
	--
	G_max_msg       := I_niv_msg;
	G_session       := I_session;
	--
	p_debut_traitement;
	--
	G_niv_msg	:= 1;
	G_proc 		:= '';
	G_msg_adm	:= 'Paramètres : Soc<'||I_societe||'> Cntrt de<'||I_contrat_1||'>à<'||I_contrat_2||'> Var<'||I_variable||'>de<'||I_valeur_1||'>à<'||I_valeur_2||'> Sit<'||I_etatadhe||'>';
	P_INS_journal;
	--
	nb_rows 	:= 0;

	FOR row_chofne in c_chofne
	LOOP
	  	G_record := '';
		G_record := G_record || row_chofne.numadhe   || ';';
		G_record := G_record || row_chofne.qualite 	 || ';';
		G_record := G_record || row_chofne.nom 		 || ';';
		G_record := G_record || row_chofne.prenom    || ';';
		G_record := G_record || row_chofne.adresse_1 || ';';
		G_record := G_record || row_chofne.adresse_2 || ';';
		G_record := G_record || row_chofne.adresse_3 || ';';
		G_record := G_record || row_chofne.adresse_4 || ';';
		G_record := G_record || row_chofne.datnais   || ';';
		G_record := G_record || row_chofne.numgar 	 || ';';

		UTL_FILE.PUT_LINE(FIC_OUT, G_record);
		nb_rows := nb_rows + 1;
	END LOOP;
	--
	G_niv_msg	:= 1;
	G_proc 		:= '';
	G_msg_adm	:= 'Nb de lignes traitées : ' || nb_rows;
	P_INS_journal;
	--
	P_fin_traitement;
	--
EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_chofne - '||SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;
END;

-- ----------------------------------------------------------------------------------------
--
-- debut et fin du traitement
--
-- ----------------------------------------------------------------------------------------
procedure p_debut_traitement
is
begin
--
G_proc := '.p_debut_traitement';
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
    FIC_OUT		:= UTL_FILE.FOPEN(G_repertoire,G_fichier,'W',32767);
	--
--
exception when others then
        g_niv_msg := 0;
        g_msg_adm := f_centre( 'erreur procedure ' || G_proc || ' : ', 78 );
        p_ins_journal;
        g_msg_adm := to_char(sqlcode) || '-' || substr(sqlerrm(sqlcode),1,128);
        p_ins_journal;
--
end;
--
-- -----------------------
procedure p_fin_traitement
is
begin
--
G_proc := '.p_fin_traitement';
--
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
        g_msg_adm := f_centre( 'erreur procedure ' || G_proc || ' : ', 78 );
        p_ins_journal;
        g_msg_adm := to_char(sqlcode) || '-' || substr(sqlerrm(sqlcode),1,128);
        p_ins_journal;

end;
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES
--------------------------------------------
--
-- Formatage du nom de fichier (variable G_fichier)
--
-- ----------------------------------------------------------------------------------------
procedure p_nom_fichier
is
begin
--
G_proc := '.p_nom_fichier';
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
        g_msg_adm := f_centre( 'erreur procedure ' || G_proc || ' : ', 78 );
        p_ins_journal;
        g_msg_adm := to_char(sqlcode) || '-' || substr(sqlerrm(sqlcode),1,128);
        p_ins_journal;
--
end;
--
-- ----------------------------------------------------------------
-- Insertion dans journal_adm
-- ----------------------------------------------------------------
Procedure P_INS_journal
IS
L_idligne 	Number;
BEGIN
--
If ( G_niv_msg <= G_max_msg ) then
	--
	G_idligne := G_idligne + 1;
	If ( G_niv_msg = 0 ) then
		L_idligne := -1 * G_idligne;
	Else
		L_idligne := G_idligne;
	End If;
	--
	G_nom_traitement := G_prefixe || G_proc;
	--
	PK_trace.P_INS_journal_adm (
		I_nom_traitement => G_nom_traitement,
		I_session        => G_session,
		I_niv_msg        => G_niv_msg,
		I_msg_adm        => G_msg_adm,
		I_idligne        => L_idligne);
	--
End If;
END P_INS_journal;
--
END pk_chofne;
/
