CREATE OR REPLACE PACKAGE ARTHUS.pk_fn01b AS
--
PROCEDURE P_fn01b(
		 I_deb_numorg	IN	sinistre_sante.numorg%type default NULL,
		 --I_fin_numorg	IN	sinistre_sante.numorg%type default NULL,
		 I_session	IN	NUMBER			   Default 1,
		 I_niv_msg	IN	NUMBER			   Default 1,
		 I_pause	IN	NUMBER			   Default 0,
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

CREATE OR REPLACE PACKAGE BODY ARTHUS.pk_fn01b AS
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

-- Variables globales privees
--
G_num_bord		remise_prest.num_bord%type;
G_datrem		remise_prest.datrem%type;
G_nombre		remise_prest.nombre%type;
G_montant               sinistre_sante.mtremb%type;
--
-- parametres du traitement
G_numorg_deb	sinistre_sante.numorg%type;
G_numorg_fin	sinistre_sante.numorg%type;
G_numorg	sinistre_sante.numorg%type;
G_numenvoi      sinistre_sante.numenvoi%type;
--
-- Flag de commit ou rollback a retourner a Forms
G_commit		Boolean := FALSE;
G_rollback		Boolean := FALSE;
G_auto_valide		Boolean := FALSE;
--
G_flag_test		NUMBER;
G_proc			VARCHAR2(80);
-- Variables de P_INS_journal
G_nom_traitement	Constant journal_adm.nom_traitement%Type default 'pk_FN01B';
G_msg_adm		journal_adm.msg_adm%Type;
G_session		journal_adm.id_session%Type default 1;
G_niv_msg		journal_adm.niv_msg%TYPE := 1;
G_max_msg		journal_adm.niv_msg%TYPE := 1;
G_idligne		journal_adm.idligne%TYPE := 0;
G_erreur		journal_adm.msg_adm%Type;

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
CURSOR C_sel_ssante is
	SELECT  numorg,sum(mtremb)
	FROM	sinistre_sante,dossier_sante
	WHERE	sinistre_sante.numorg=G_numorg_deb
        AND     sinistre_sante.numorg Is Not Null
        AND     sinistre_sante.num_bord Is Null
        AND     sinistre_sante.numfact Is Null
        AND    	sinistre_sante.num_dossier=dossier_sante.num_dossier
        AND    	dossier_sante.type_doss<> 4
	GROUP By sinistre_sante.numorg;


CURSOR C_sel_ssante_numenvoie is
	SELECT  sinistre_sante.num_dossier   --, sinistre_sante.numligne
	FROM	sinistre_sante,dossier_sante
	WHERE	sinistre_sante.numorg=G_numorg_deb
        AND     sinistre_sante.numorg Is Not Null
        AND     sinistre_sante.num_bord Is Null
        AND     sinistre_sante.numfact Is Null
        AND    	sinistre_sante.num_dossier=dossier_sante.num_dossier
        AND    	dossier_sante.type_doss<> 4
        GROUP By sinistre_sante.num_dossier;
------------------------------------------------------------------
--
-- Le corps des differentes procedures
--
------------------------------------------------------------------
--
--
PROCEDURE P_fn01b(
		 I_deb_numorg	IN	sinistre_sante.numorg%type default NULL,
		 --I_fin_numorg	IN	sinistre_sante.numorg%type default NULL,
		 I_session	IN	NUMBER			Default 1,
		 I_niv_msg	IN	NUMBER			Default 1,
		 I_pause	IN	NUMBER			Default 0,
		 O_found	OUT	NUMBER,
		 O_erreur	OUT	VARCHAR2
		)
IS
R_sel_ssante 	C_sel_ssante%ROWTYPE;
R_sel_ssante_numenvoie 	C_sel_ssante_numenvoie%ROWTYPE;
BEGIN
	--
	O_found		:= 1;
	G_erreur	:= Null;
	--
	G_numorg_deb	:= I_deb_numorg;
	--G_numorg_fin	:= I_fin_numorg;
	--
	G_max_msg	:= I_niv_msg;
	G_session	:= I_session;
	--G_idligne     := F_max_idligne(I_session => G_session);

-- OUVERTURE du Curseur
--

	IF NOT C_sel_ssante%ISOPEN THEN
	   --
	   G_niv_msg	:= 1;
	   G_msg_adm	:= 'Debut de traitement le ' ||TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	   P_INS_journal;
  	   -- Fin ecriture dans le Journal
	   OPEN C_sel_ssante;
	   --
	END IF;
   --
   -- LECTURE D'1 Ligne dans la table principale
   --

	FETCH C_sel_ssante INTO R_sel_ssante;
	--
	IF C_sel_ssante%NOTFOUND THEN
		O_found	:= 0;
		-- FERMETURE du Curseur
        	P_fin_traitement;
	ELSE
		O_found	:= 1;
		G_numorg	:= R_sel_ssante.numorg;
--
--*debogage debut
	G_niv_msg	:= 3;
	G_msg_adm	:= 'Organisme assureur n° '||to_char(G_numorg);
	P_INS_journal;
--*debogage fin
--
               SELECT	nvl(max(num_bord),0) + 1
		       INTO	G_num_bord
		       FROM	remise_prest;

               SELECT	nvl(max(numenvoi),0) + 1
		       INTO	G_numenvoi
		       FROM	sinistre_sante;

               INSERT INTO remise_prest(num_bord,
					numorg,
					nombre,
					montant,
                                        monnaie,
                                        monnaie_d,
                                        datrem,
                                        numutil_rem
					)
				SELECT	G_num_bord,
					G_numorg,
                                        count(distinct sinistre_sante.num_dossier),
                                        Sum(sinistre_sante.mtremb),
                                        pk_devise.devise_ref,
                                        pk_devise.devise_ref,
                                        sysdate,
                                        f_numutil
				FROM	sinistre_sante,dossier_sante
                                Where   sinistre_sante.numorg=G_numorg
                                AND     sinistre_sante.num_bord Is Null
                                AND     sinistre_sante.numfact Is Null
                                AND    	sinistre_sante.num_dossier=dossier_sante.num_dossier
                                AND    	dossier_sante.type_doss<> 4
				GROUP
				BY	G_num_bord,
                                        G_numorg;


                       UPDATE REMISE_PREST
                       SET    REMISE_PREST.montant_d=pk_devise.f_conv_mt(pk_devise.devise_ref,
                                                                         pk_devise.devise_ref,
                                                                         remise_prest.montant,
                                                                         sysdate)
                       WHERE REMISE_PREST.NUM_BORD=G_num_bord;

                       OPEN C_sel_ssante_numenvoie;

                       LOOP
                       FETCH C_sel_ssante_numenvoie INTO R_sel_ssante_numenvoie;
							--
							IF C_sel_ssante_numenvoie%NOTFOUND THEN
							    CLOSE C_sel_ssante_numenvoie;
								exit;
							ELSE


		                       UPDATE SINISTRE_SANTE
		                       SET    SINISTRE_SANTE.NUM_BORD=G_num_bord,
		                              SINISTRE_SANTE.NUMENVOI=G_numenvoi
		                       WHERE  SINISTRE_SANTE.NUM_DOSSIER=R_sel_ssante_numenvoie.num_dossier  -- JPF 09/05/05Suite Rajoutée
							    AND     sinistre_sante.numorg=G_numorg
								AND     sinistre_sante.numorg Is Not Null
								AND     sinistre_sante.num_bord Is Null
								AND     sinistre_sante.numfact Is Null
								AND     sinistre_sante.numenvoi is null;

		                       --AND    SINISTRE_SANTE.NUMLIGNE =R_sel_ssante_numenvoie.numligne;

		                       G_numenvoi:=G_numenvoi+1;
							END IF;
                       END LOOP;
--
	END IF;
        --
	O_erreur	:= G_erreur;

EXCEPTION WHEN OTHERS THEN
		G_niv_msg	:= 0;
		G_msg_adm	:= 'PK_FN01B - '||SUBSTR(SQLERRM(SQLCODE),1,128);
		O_erreur	:= SUBSTR(SQLERRM(SQLCODE),1,128);
		P_INS_journal;
		Close C_sel_ssante;
END;
--
--------------------------
PROCEDURE P_fin_traitement IS
BEGIN
--
G_proc := 'P_fin_traitement';
--
	G_niv_msg	:= 1;
	G_msg_adm	:= 'Fin Normale du traitement le ' ||
				TO_CHAR(Sysdate, 'DD/MM/YYYY hh24:mi');
	P_INS_journal;
	-- Fin ecriture dans le Journal
	CLOSE C_sel_ssante;
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
