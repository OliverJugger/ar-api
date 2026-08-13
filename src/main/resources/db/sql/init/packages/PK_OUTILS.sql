CREATE OR REPLACE PACKAGE ARTHUS.PK_OUTILS AS


/* LECTURE D UN FICHER
I_Repertoire     DIRECTORY ou se trouve le fichier
I_Fichier           Nom du fichier à lire
I_Nb_Lignes    Nombre de lignes à lire  (default 0 pour toutes)
I_IdSession     Si >0 sortie dans la table TRAV_LECTURE_FICHIER  avec idsession =I_IdSession
                           Si =0 sortie  en DBMS_OUTPUT  (set serveroutput on size 1000000)
		      Default 0
*/
PROCEDURE P_LECTURE_FICHIER(I_Repertoire Varchar2,
							I_Fichier Varchar2,
							I_Nb_Lignes number default 0,
							I_IdSession  Number default 0);

/* LECTURE D UN FICHER LOG généré par un traitement PROC
	et insertion dans JOURNAL_ADM
I_traitement	Nom du traitement PROC
I_Repertoire	DIRECTORY ou se trouve le fichier
I_Fichier		Nom du fichier log à lire
I_Nb_Lignes	Nombre de lignes à lire  (default 0 pour toutes)
I_Nb_Lignes_journal	Nombre de lignes déjà insérées dans journal_adm avant de rentrer dans la procédure P_LOG_DLL
I_IdSession	Numedit du traitement
			Default 0
O_nbre_lignes	Nombre de lignes insérées dans journal_adm à la fin de P_LOG_DLL
*/
PROCEDURE P_LOG_DLL(
					I_traitement	IN		Varchar2,
					I_Repertoire	IN 		Varchar2,
					I_Fichier		IN		Varchar2,
					I_Nb_Lignes    	IN		Number default 0,
					I_Nb_Lignes_journal	IN	Number default 1,
					I_IdSession    	IN		Number default 0,
					O_nbre_lignes	OUT		Number);

/* SUPPRESSION D UN FICHER
I_Repertoire	DIRECTORY ou se trouve le fichier
I_Fichier		Nom du fichier à supprimer
*/
PROCEDURE P_SUPP_FICHIER (I_Repertoire	IN Varchar2,
						  I_Fichier		IN Varchar2,
						  O_removed		 OUT NUMBER);

END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_OUTILS AS

-- -- EXCEPTIONS PRIVEES ------------------------------------------------------
--
E_PAR_REPERTOIRE_ABSENT	EXCEPTION;
E_PAR_FICHIER_ABSENT	EXCEPTION;
E_FICHIER_DESTRUCT		EXCEPTION;
--  Fin des exceptions privees --

G_msg_adm		journal_adm.msg_adm%Type;
G_idsession		journal_adm.id_session%Type := 0;
G_idligne		journal_adm.idligne%TYPE := 0;
G_NumUtil       number(3);

G_sql_notfound 	boolean:=false;

G_compteur_ligne number:=0;

edatejours		Varchar2(8);

nom_rep			varchar2(128) := 'UTL_FILE_DIR';
nom_fic			varchar2(128) := 'TEST.txt';
f_entree		UTL_FILE.FILE_TYPE;
buffer			varchar2(32767);

-- Insertion dans journal_adm
Procedure P_INS_journal
IS
BEGIN
	G_idligne := G_idligne + 1;
	PK_trace.P_INS_journal_adm (
		I_nom_traitement => 'PK_OUTILS',
		I_session	 => G_idsession,
		I_niv_msg	 => 0,
		I_msg_adm	 => G_msg_adm,
		I_idligne	 => G_idligne);
END P_INS_journal;


-- formatage des numériques
Function format_nb( nbre Number, taille Number) return Varchar2 IS
	retour Varchar2(25);
Begin
	retour := substr('0000000000000000000000000', 1, taille);
	if nbre is not null then
		retour := ltrim( to_char(nbre, retour) );
	end if;
	return retour;
End;



PROCEDURE P_LECTURE_FICHIER(I_Repertoire   Varchar2,
							I_Fichier      Varchar2,
							I_Nb_Lignes    Number default 0,
							I_IdSession    Number default 0)
IS
BEGIN

	G_idsession 	:= G_idsession + 1;
	G_idligne 		:= 0;
	G_compteur_ligne :=0;

	G_NumUtil := f_numutil;

	nom_rep := I_Repertoire;
	nom_fic := I_Fichier;


	if I_IdSession > 0 then
		DELETE TRAV_LECTURE_FICHIER WHERE ID_SESSION = I_IdSession or NUMUTIL= G_NumUtil;
		COMMIT;
	end if;

	/*G_msg_adm    := 'paramètres lecture fichier : '||nom_rep||' '||nom_fic;
	P_INS_journal;
	commit;*/

	f_entree := UTL_FILE.FOPEN( nom_rep, nom_fic, 'R',32767);

	edatejours	:= to_char(sysdate,'DDMMYYYY');

if  I_IdSession = 0 then

			DBMS_OUTPUT.PUT_LINE('-----Lecture du fichier : '||nom_rep||'\'||nom_fic);

			LOOP

					buffer := '';
					UTL_FILE.GET_LINE( f_entree, buffer,32767);
					G_compteur_ligne := G_compteur_ligne + 1;

					DBMS_OUTPUT.PUT_LINE(substr(buffer,1,255));

					EXIT WHEN I_Nb_Lignes >0 and G_compteur_ligne = I_Nb_Lignes;

			END LOOP;

			G_msg_adm    := '-----Fin de fichier non atteinte - Nombre de lignes lues = '||to_char(G_compteur_ligne);
			DBMS_OUTPUT.PUT_LINE(G_msg_adm);

else

			LOOP

					buffer := '';
					UTL_FILE.GET_LINE( f_entree, buffer,32767);
					G_compteur_ligne := G_compteur_ligne + 1;

					insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
					values (I_IdSession, G_compteur_ligne, substr(buffer,1,255), trunc(sysdate), G_NumUtil );

					EXIT WHEN I_Nb_Lignes >0 and G_compteur_ligne = I_Nb_Lignes;

			END LOOP;

			insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
					values (I_IdSession, G_compteur_ligne+1, '-----Fin de fichier non atteinte - Nombre de lignes lues = '||to_char(G_compteur_ligne), trunc(sysdate), G_NumUtil );
			commit;
end if;

	UTL_FILE.FCLOSE(f_entree);


EXCEPTION
  WHEN NO_DATA_FOUND then
    UTL_FILE.FCLOSE(f_entree);
    G_msg_adm    := '-----Fin de fichier atteinte. Nombre de lignes = '||to_char(G_compteur_ligne);
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);

	if I_IdSession > 0 then
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;

  WHEN E_PAR_REPERTOIRE_ABSENT then
	G_msg_adm    := 'Nom du répertoire de sortie manquant';
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);

	if I_IdSession > 0 then
--	    G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
		G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+2, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;

  WHEN E_PAR_FICHIER_ABSENT Then
	G_msg_adm    := 'Nom du fichier de sortie manquant';
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);

	if I_IdSession > 0 then
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
		G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+2, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;


  WHEN E_FICHIER_DESTRUCT Then
	G_msg_adm    := 'Structure du fichier '||I_Fichier||' invalide';
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);

	if I_IdSession > 0 then
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
		G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+2, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;


  WHEN UTL_FILE.INTERNAL_ERROR THEN
	--Rollback;
	G_msg_adm    := 'UTL_FILE.INTERNAL_ERROR';
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);
	UTL_FILE.FCLOSE(f_entree);

	if I_IdSession > 0 then
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
        G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+2, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;


  WHEN UTL_FILE.INVALID_FILEHANDLE THEN
	--Rollback;
	G_msg_adm    := 'UTL_FILE.INVALID_FILEHANDLE';
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);
	UTL_FILE.FCLOSE(f_entree);

	if I_IdSession > 0 then
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
        G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+2, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;


  WHEN UTL_FILE.INVALID_MODE THEN
	G_msg_adm    := 'UTL_FILE.INVALID_MODE';
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);
	UTL_FILE.FCLOSE(f_entree);

	if I_IdSession > 0 then
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
        G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+2, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;


  WHEN UTL_FILE.INVALID_OPERATION THEN
	G_msg_adm    := 'UTL_FILE.INVALID_OPERATION';
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);
	UTL_FILE.FCLOSE(f_entree);

	if I_IdSession > 0 then
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
        G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+2, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;


  WHEN UTL_FILE.INVALID_PATH THEN
	G_msg_adm    := 'UTL_FILE.INVALID_PATH';
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);
	UTL_FILE.FCLOSE(f_entree);

	if I_IdSession > 0 then
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
		G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+2, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;


  WHEN UTL_FILE.READ_ERROR THEN
	G_msg_adm    := 'UTL_FILE.READ_ERROR';
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);
	UTL_FILE.FCLOSE(f_entree);

	if I_IdSession > 0 then
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
		G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+2, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;


  WHEN UTL_FILE.WRITE_ERROR THEN
	G_msg_adm    := 'UTL_FILE.WRITE_ERROR';
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);
	UTL_FILE.FCLOSE(f_entree);

	if I_IdSession > 0 then
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
		G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+2, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;


  WHEN OTHERS THEN
	G_msg_adm    := SUBSTR(SQLERRM(SQLCODE),1,128);
--	Insertion dans journal_adm du message d'erreur
--	P_INS_journal;
	DBMS_OUTPUT.PUT_LINE('erreur !!!');
	DBMS_OUTPUT.PUT_LINE(G_msg_adm);
	if UTL_FILE.IS_OPEN(f_entree) then
		UTL_FILE.FCLOSE(f_entree);
	end if;

	if I_IdSession > 0 then
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+1, G_msg_adm, trunc(sysdate), G_NumUtil );
		G_msg_adm:=substr(sqlerrm(sqlcode),1,255);
		insert into TRAV_LECTURE_FICHIER ( ID_SESSION, IDLIGNE, LIGNE, DATE_LECTURE, NUMUTIL)
		values (I_IdSession, G_compteur_ligne+2, G_msg_adm, trunc(sysdate), G_NumUtil );
		commit;
	end if;


END P_LECTURE_FICHIER;


PROCEDURE P_LOG_DLL(
					I_traitement	IN		Varchar2,
					I_Repertoire	IN 		Varchar2,
					I_Fichier		IN		Varchar2,
					I_Nb_Lignes    	IN		Number default 0,
					I_Nb_Lignes_journal	IN	Number default 1,
					I_IdSession    	IN		Number default 0,
					O_nbre_lignes	OUT		Number)
IS
BEGIN
	--
	G_idligne 			:= I_Nb_Lignes_journal;
	G_compteur_ligne 	:= 0;

	nom_rep := I_Repertoire;
	nom_fic := I_Fichier;

	/*G_msg_adm    := 'paramètres lecture fichier : '||nom_rep||' '||nom_fic;
	P_INS_journal;
	commit;*/

	f_entree := UTL_FILE.FOPEN( nom_rep, nom_fic, 'R',32767);

	edatejours	:= to_char(sysdate,'DDMMYYYY');

	LOOP

		buffer := '';
		UTL_FILE.GET_LINE( f_entree, buffer,32767);
		G_compteur_ligne := G_compteur_ligne + 1;
		G_idligne := G_idligne + 1;

		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, substr(buffer,1,132), 3, trunc(sysdate), G_idligne);

		EXIT WHEN I_Nb_Lignes >0 and G_compteur_ligne = I_Nb_Lignes;

	END LOOP;

		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, '-----Fin de fichier non atteinte - Nombre de lignes lues = '||to_char(G_compteur_ligne), 3, trunc(sysdate), G_idligne+1);
		commit;

	UTL_FILE.FCLOSE(f_entree);

-- Nbre de lignes déjà insérées dans journal_adm
O_nbre_lignes := G_idligne+1;


EXCEPTION
  WHEN NO_DATA_FOUND then
    UTL_FILE.FCLOSE(f_entree);
    G_msg_adm    := '-----Fin de fichier atteinte. Nombre de lignes = '||to_char(G_compteur_ligne);
--	Insertion dans journal_adm du message d'erreur
	insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
	values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
	commit;

	O_nbre_lignes := G_idligne+1;

  WHEN E_PAR_REPERTOIRE_ABSENT then
	G_msg_adm    := 'PK_OUTILS - Nom du répertoire de sortie manquant';
--	Insertion dans journal_adm du message d'erreur
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
		G_msg_adm:=substr(sqlerrm(sqlcode),1,132);
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+2);
		commit;

		O_nbre_lignes := G_idligne+2;

  WHEN E_PAR_FICHIER_ABSENT Then
	G_msg_adm    := 'PK_OUTILS - Nom du fichier de sortie manquant';
--	Insertion dans journal_adm du message d'erreur
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
		G_msg_adm:=substr(sqlerrm(sqlcode),1,132);
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+2);
		commit;

		O_nbre_lignes := G_idligne+2;

  WHEN E_FICHIER_DESTRUCT Then
	G_msg_adm    := 'PK_OUTILS - Structure du fichier '||I_Fichier||' invalide';
--	Insertion dans journal_adm du message d'erreur
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
		G_msg_adm:=substr(sqlerrm(sqlcode),1,132);
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+2);
		commit;

		O_nbre_lignes := G_idligne+2;

  WHEN UTL_FILE.INTERNAL_ERROR THEN
	--Rollback;
	G_msg_adm    := 'PK_OUTILS - UTL_FILE.INTERNAL_ERROR';
	UTL_FILE.FCLOSE(f_entree);

--	Insertion dans journal_adm du message d'erreur
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
		G_msg_adm:=substr(sqlerrm(sqlcode),1,132);
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+2);
		commit;

		O_nbre_lignes := G_idligne+2;

  WHEN UTL_FILE.INVALID_FILEHANDLE THEN
	--Rollback;
	G_msg_adm    := 'PK_OUTILS - UTL_FILE.INVALID_FILEHANDLE';
	UTL_FILE.FCLOSE(f_entree);

--	Insertion dans journal_adm du message d'erreur
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
		G_msg_adm:=substr(sqlerrm(sqlcode),1,132);
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+2);
		commit;

		O_nbre_lignes := G_idligne+2;

  WHEN UTL_FILE.INVALID_MODE THEN
	G_msg_adm    := 'PK_OUTILS - UTL_FILE.INVALID_MODE';
	UTL_FILE.FCLOSE(f_entree);

--	Insertion dans journal_adm du message d'erreur
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
		G_msg_adm:=substr(sqlerrm(sqlcode),1,132);
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+2);
		commit;

		O_nbre_lignes := G_idligne+2;

  WHEN UTL_FILE.INVALID_OPERATION THEN
	G_msg_adm    := 'PK_OUTILS - UTL_FILE.INVALID_OPERATION';
	UTL_FILE.FCLOSE(f_entree);

--	Insertion dans journal_adm du message d'erreur
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
		G_msg_adm:=substr(sqlerrm(sqlcode),1,132);
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+2);
		commit;

		O_nbre_lignes := G_idligne+2;

  WHEN UTL_FILE.INVALID_PATH THEN
	G_msg_adm    := 'PK_OUTILS - UTL_FILE.INVALID_PATH';
	UTL_FILE.FCLOSE(f_entree);

--	Insertion dans journal_adm du message d'erreur
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
		G_msg_adm:=substr(sqlerrm(sqlcode),1,132);
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+2);
		commit;

		O_nbre_lignes := G_idligne+2;

  WHEN UTL_FILE.READ_ERROR THEN
	G_msg_adm    := 'PK_OUTILS - UTL_FILE.READ_ERROR';
	UTL_FILE.FCLOSE(f_entree);

--	Insertion dans journal_adm du message d'erreur
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
		G_msg_adm:=substr(sqlerrm(sqlcode),1,132);
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+2);
		commit;

		O_nbre_lignes := G_idligne+2;

  WHEN UTL_FILE.WRITE_ERROR THEN
	G_msg_adm    := 'PK_OUTILS - UTL_FILE.WRITE_ERROR';
	UTL_FILE.FCLOSE(f_entree);

--	Insertion dans journal_adm du message d'erreur
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
		G_msg_adm:=substr(sqlerrm(sqlcode),1,132);
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+2);
		commit;

		O_nbre_lignes := G_idligne+2;

  WHEN OTHERS THEN
	G_msg_adm    := 'PK_OUTILS - Erreur lors du chargement du fichier PDF à partir du LOG';
	if UTL_FILE.IS_OPEN(f_entree) then
		UTL_FILE.FCLOSE(f_entree);
	end if;

--	Insertion dans journal_adm du message d'erreur
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+1);
		G_msg_adm:=substr(sqlerrm(sqlcode),1,132);
		insert into JOURNAL_ADM (NOM_TRAITEMENT, ID_SESSION, MSG_ADM, NIV_MSG, DATE_ADM, IDLIGNE)
		values (I_TRAITEMENT, I_IdSession, G_msg_adm, 3, trunc(sysdate), G_idligne+2);
		commit;

		O_nbre_lignes := G_idligne+2;

END P_LOG_DLL;
--
PROCEDURE P_SUPP_FICHIER (I_Repertoire	IN Varchar2,
						  I_Fichier		IN Varchar2,
						  O_removed OUT NUMBER)
IS
 vexists    	BOOLEAN;
 vfile_length  	NUMBER;
 vblocksize		NUMBER;
BEGIN
	O_removed := 1;

    UTL_FILE.FGETATTR(I_Repertoire,I_Fichier,vexists,vfile_length,vblocksize);

    IF vexists THEN

      UTL_FILE.FREMOVE (I_Repertoire,I_Fichier);

    END IF;

	UTL_FILE.FGETATTR(I_Repertoire,I_Fichier,vexists,vfile_length,vblocksize);

    IF vexists THEN

      O_removed := 0;

    END IF;
EXCEPTION
  WHEN UTL_FILE.INVALID_OPERATION THEN
	G_msg_adm    := 'PK_OUTILS - P_SUPP_FICHIER - UTL_FILE.INVALID_OPERATION';
--
	O_removed := 0;
--
  WHEN OTHERS THEN
	G_msg_adm    := 'PK_OUTILS - P_SUPP_FICHIER - Exception OTHERS';
--
	O_removed := 0;
--
END P_SUPP_FICHIER;

END;
/
