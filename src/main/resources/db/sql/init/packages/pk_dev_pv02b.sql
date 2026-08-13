CREATE OR REPLACE PACKAGE ARTHUS.pk_dev_pv02b AS
--
PROCEDURE P_dev_pv02b(
		 I_numremise	IN	remise_prelev.numremise%type	default NULL,
		 I_date_prelev	IN	VARCHAR2			default NULL,
		 I_date_valeur	IN	VARCHAR2			default NULL,
		 I_param2	IN	param_batch.param2%type		default NULL,
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

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_DEV_PV02B" AS
-- $Rev:: 795                                    $:  Revision du dernier commit
-- $Author:: s.calvez                            $:  Auteur du dernier commit
-- $Date: 2023-09-07 17:31:39 +0200 (jeu., 07 sept. 2023) $:  Date du dernier commit
-- $HeadURL: svn://svn2019/arthus/GEREP/trunk/dbschema/ARTHUS/PACKAGE_BODIES/PK_DEV_PV02B.pkb $:  Chemin

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
   PROCEDURE p_fin_traitement;

--
   PROCEDURE p_corps_prelev;

--
   PROCEDURE p_piece;

--
   PROCEDURE p_ins_journal;

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

--
-- Variables globales privees
--
   g_comm_numedit              file_edition.numedit%TYPE;
--
   g_numutil                   util.numutil%TYPE;
--
   g_user_trouve               VARCHAR2 (1);
--
   g_bdx_traite                VARCHAR2 (1);
--
   g_prelev_numprelev          prelevement.numprelev%TYPE;
   g_prelev_numcpte            remise_prelev.numcpte%TYPE;
   g_prelev_codope             prelevement_detail.codope%TYPE;
   g_prelev_numcli             facture.numcli%TYPE;
   g_prelev_montant            prelevement_detail.montant%TYPE;
   g_prelev_monnaie            prelevement_detail.monnaie%TYPE;
   g_prelev_montant_d          prelevement_detail.montant_d%TYPE;
   g_prelev_monnaie_d          prelevement_detail.monnaie_d%TYPE;
--
   g_comm_numencaismt          encaismt.numencaismt%TYPE;
--
   g_comm_codope               prelevement_detail.codope%TYPE;
   g_comm_numfact              prelevement_detail.numfact%TYPE;
   g_comm_numcli               facture.numcli%TYPE;
   g_comm_idaffec              prelevement_detail.idaffec%TYPE;
   g_comm_mt_affec             prelevement_detail.montant%TYPE;
   g_comm_monnaie              prelevement_detail.monnaie%TYPE;
   g_comm_mt_affec_d           prelevement_detail.montant_d%TYPE;
   g_comm_monnaie_d            prelevement_detail.monnaie_d%TYPE;
--
/*
G_monnaie		compte_client.monnaie%type;
G_datope		compte_client.datope%type;
G_idcompta		compte_client.idcompta%type;
G_datrem		remise_prelev.datrem%type;
G_nombre		remise_prelev.nombre%type;
G_valide		remise_prelev.valide%type;
*/
--
-- parametres du traitement
   g_numremise                 remise_prelev.numremise%TYPE;
   g_date_prelev               encaismt.datpay%TYPE;
   g_date_valeur               remise_prelev.datope%TYPE;
--
-- Flag de commit ou rollback a retourner a Forms
   g_commit                    BOOLEAN                             := FALSE;
   g_rollback                  BOOLEAN                             := FALSE;
   g_auto_valide               BOOLEAN                             := FALSE;
--
   g_flag_test                 NUMBER;
   g_proc                      VARCHAR2 (80);
-- Variables de P_INS_journal
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                       DEFAULT 'PV02T';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE         DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE            := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE            := 1;
   g_idligne                   journal_adm.idligne%TYPE            := 0;
   g_erreur                    journal_adm.msg_adm%TYPE;

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
   CURSOR c_prelev
   IS
      SELECT   prelevement.numprelev, remise_prelev.numcpte,
               prelevement_detail.codope, MIN (facture.numcli) numcli,
               SUM (prelevement_detail.montant) montant,
        prelevement_detail.monnaie,
               SUM (prelevement_detail.montant_d) montant_d,
        prelevement_detail.monnaie_d
          FROM remise_prelev, prelevement, prelevement_detail, facture
         WHERE remise_prelev.numremise = g_numremise
	AND	prelevement.numremise = remise_prelev.numremise
           AND prelevement.numencaismt IS NULL
	AND	prelevement_detail.numprelev = prelevement.numprelev
	AND	facture.codope  = prelevement_detail.codope
	AND	facture.numfact = prelevement_detail.numfact
      GROUP BY prelevement.numprelev,
		remise_prelev.numcpte,
		prelevement_detail.codope,
        prelevement_detail.monnaie,
               prelevement_detail.monnaie_d;

--
   CURSOR c_piece
   IS
      SELECT   prelevement_detail.codope, prelevement_detail.numfact,
               facture.numcli, prelevement_detail.idaffec,
               prelevement_detail.montant, prelevement_detail.monnaie,
               prelevement_detail.montant_d, prelevement_detail.monnaie_d,
               qttc_global.numgar, qttc_global.idadhesion
          FROM prelevement_detail, facture, qttc_global
         WHERE prelevement_detail.numprelev = g_prelev_numprelev
	AND	facture.codope  = prelevement_detail.codope
	AND	facture.numfact = prelevement_detail.numfact
           AND facture.numfact = qttc_global.numquit
      ORDER BY prelevement_detail.codope, prelevement_detail.numfact;

--
------------------------------------------------------------------
--
-- Le corps des differentes procedures
--
------------------------------------------------------------------
--
--
   PROCEDURE p_dev_pv02b (
      i_numremise     IN       remise_prelev.numremise%TYPE DEFAULT NULL,
      i_date_prelev   IN       VARCHAR2 DEFAULT NULL,
      i_date_valeur   IN       VARCHAR2 DEFAULT NULL,
      i_param2        IN       param_batch.param2%TYPE DEFAULT NULL,
      i_session       IN       NUMBER DEFAULT 1,
      i_niv_msg       IN       NUMBER DEFAULT 1,
      i_pause         IN       NUMBER DEFAULT 0,
      o_found         OUT      NUMBER,
      o_erreur        OUT      VARCHAR2
			)
IS
      r_prelev   c_prelev%ROWTYPE;
      loc_delai  NUMBER;
      loc_date_min DATE;
      --SDA M4333
      exc_fin_traitement EXCEPTION;
BEGIN
	--
      o_found := 1;
      g_erreur := NULL;
	--
      g_numremise := i_numremise;
      g_date_prelev := e2d (i_date_prelev);
      g_date_valeur := NVL (e2d (i_date_valeur), g_date_prelev);
	--
      g_max_msg := i_niv_msg;
      g_session := i_session;
      
      
	--G_idligne     := F_max_idligne(I_session => G_session);
	--
--
      g_comm_numedit := i_session;
--
      g_niv_msg := 1;
      g_msg_adm :=
         'Debut de traitement le ' || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;

  	-- Fin ecriture dans le Journal
--
      BEGIN
         SELECT util.numutil
           INTO g_numutil
           FROM util, file_edition
          WHERE util.nom = file_edition.userid
            AND file_edition.numedit = g_comm_numedit;

         g_user_trouve := 'O';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            g_user_trouve := 'N';
            g_numutil := NULL;
      END;

      BEGIN
         loc_delai := 0;
         SELECT TO_NUMBER(NVL(TRIM(pb.param1),'0'))
         INTO loc_delai
         FROM param_batch pb
         WHERE pb.numbatch = g_nom_traitement;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            loc_delai := 0;
      END;


      --SDA M4333
      loc_date_min := TRUNC(sysdate) - loc_delai ;
      IF g_date_prelev <= loc_date_min
      or g_date_valeur <= loc_date_min THEN
         Raise exc_fin_traitement;
      END IF;
      

--
-- OUVERTURE du Curseur
--
      OPEN c_prelev;

--
--
      IF g_user_trouve = 'N'
      THEN
         o_found := 0;
	--
         g_niv_msg := 1;
         g_msg_adm :=
               'User non trouve - Pas de traitement pour le numedit '
            || TO_CHAR (g_comm_numedit);
         p_ins_journal;
	--
         p_fin_traitement;
	--
   ELSE
--
         g_bdx_traite := 'N';

--
     LOOP
--
	--
	-- LECTURE D'1 Ligne dans la table principale
	--
            FETCH c_prelev
             INTO r_prelev;

	--
            IF c_prelev%NOTFOUND
            THEN
               o_found := 0;
		-- FERMETURE du Curseur
               p_fin_traitement;

		--
               IF g_bdx_traite = 'O'
               THEN
			UPDATE	remise_prelev
                     SET dataccuse = TRUNC (SYSDATE),
                         numutil_accuse = g_numutil,
                         datope = g_date_valeur
                   WHERE remise_prelev.numremise = g_numremise;
               END IF;

		--
		EXIT;
	ELSE
               g_bdx_traite := 'O';
               o_found := 1;
               g_prelev_numprelev := r_prelev.numprelev;
               g_prelev_numcpte := r_prelev.numcpte;
               g_prelev_codope := r_prelev.codope;
               g_prelev_numcli := r_prelev.numcli;
               g_prelev_montant := r_prelev.montant;
               g_prelev_monnaie := r_prelev.monnaie;
               g_prelev_montant_d := r_prelev.montant_d;
               g_prelev_monnaie_d := r_prelev.monnaie_d;
--
--*debogage debut
               g_niv_msg := 3;
               g_msg_adm :=
                     'prelev nÂ° '
                  || TO_CHAR (g_prelev_numprelev)
                  || ' - '
                  || 'compte nÂ° '
                  || TO_CHAR (g_prelev_numcpte);
               p_ins_journal;
--*debogage fin
--
               p_corps_prelev;
	END IF;
	--
     END LOOP;

        --
         o_erreur := g_erreur;
	--
   END IF;
	--
   EXCEPTION
      WHEN exc_fin_traitement
      THEN
        g_niv_msg := 1;
         g_msg_adm :=
               'Impossible d''affecter des prÃ©lÃ¨vements Ã  une date antÃ©rieure Ã  '
            || TO_CHAR(loc_date_min,'DD/MM/YYYY');
         p_ins_journal;
         --
         p_fin_traitement;

      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := 'PK_DEV_PV02B - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         o_erreur := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;

         CLOSE c_prelev;
END;

--
-- --------------------------
   PROCEDURE p_fin_traitement
   IS
BEGIN
--
      g_proc := 'P_fin_traitement';

--
      IF c_prelev%ISOPEN THEN
        CLOSE c_prelev;
      END IF;

--
      g_niv_msg := 1;
      g_msg_adm :=
            'Fin Normale du traitement le '
         || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;
	-- Fin ecriture dans le Journal
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
END;

--
-- -----------------------------
   PROCEDURE p_corps_prelev
   IS
BEGIN
--
      g_proc := 'P_CORPS_prelev';

--
-- JPF 14/02/2006
 /*  	SELECT	nvl(max(numencaismt),0) + 1
   	INTO	G_comm_numencaismt
   	FROM	encaismt; */
      SELECT numencaismt.NEXTVAL
        INTO g_comm_numencaismt
        FROM DUAL;

      INSERT INTO encaismt
                  (codope, numencaismt, numcli,
                   numcpte, modpmt, montant, monnaie,
                   montant_d, monnaie_d,
                   refpmt, datpay, numutil
				)
		--
      VALUES      (g_prelev_codope, g_comm_numencaismt, g_prelev_numcli,
                   g_prelev_numcpte, 2, g_prelev_montant, g_prelev_monnaie,
                   g_prelev_montant_d, g_prelev_monnaie_d,
                   g_prelev_numprelev, g_date_prelev, g_numutil
                  );

--
	UPDATE 	prelevement
         SET prelevement.numencaismt = g_comm_numencaismt
       WHERE prelevement.numprelev = g_prelev_numprelev;

--
	UPDATE	remise_prelev
         SET date_prelev = g_date_prelev
       WHERE remise_prelev.numremise = g_numremise;

--
      p_piece;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
END;

--
-- ----------------------------
   PROCEDURE p_piece
   IS
      r_piece   c_piece%ROWTYPE;
      loc_niv_relance param_relance.niveau%TYPE;
      loc_date_resil DATE;
BEGIN
--
      g_proc := 'P_piece';

--
      OPEN c_piece;

LOOP
         FETCH c_piece
          INTO r_piece;

         EXIT WHEN c_piece%NOTFOUND;
         g_comm_codope := r_piece.codope;
         g_comm_numfact := r_piece.numfact;
         g_comm_numcli := r_piece.numcli;
         g_comm_idaffec := r_piece.idaffec;
         g_comm_mt_affec := r_piece.montant;
         g_comm_monnaie := r_piece.monnaie;
         g_comm_mt_affec_d := r_piece.montant_d;
         g_comm_monnaie_d := r_piece.monnaie_d;

   --
   DELETE	compte_client
               WHERE codope = g_comm_codope
                 AND numfact = g_comm_numfact
                 AND numencaismt = 0;

   --
         BEGIN
            pk_treso.p_affecte (i_idaffec          => g_comm_idaffec,
                                i_codope           => g_comm_codope,
                                i_numfact          => g_comm_numfact,
                                i_numcli           => g_comm_numcli,
                                i_numencaismt      => g_comm_numencaismt,
                                i_montant          => g_comm_mt_affec,
                                i_monnaie          => g_comm_monnaie,
                                i_montant_d        => g_comm_mt_affec_d,
                                i_monnaie_d        => g_comm_monnaie_d,
                                i_datope           => g_date_valeur
				);
         END;

         --annulation des Ã©missions liÃ©es aux relances de cotisations uniquement si restant du = 0
         IF g_comm_codope = 4 THEN
            loc_niv_relance := pk_relance.f_niv_relance(g_comm_numfact);
            IF f_montant_du(g_comm_numfact,g_comm_codope, loc_niv_relance) = 0 THEN
  	            pk_relance.p_annul_emission_qttc(g_comm_numfact);

               -- communiquer si etat adhesion/contrat = rÃ©siliÃ© ou suspendu ( 2 ou 3 )
               loc_date_resil :=  pk_relance.f_date_relance(i_niveau    => 30, --rÃ©siliation
                                                            i_numfact   => r_piece.numfact,
                                                            i_numgar    => r_piece.numgar,
                                                            i_dateMED   => NULL );
               IF r_piece.idadhesion > 0 THEN
                  IF f_etat_adhe(r_piece.idadhesion, loc_date_resil ) IN (2, 3) THEN
                     g_niv_msg := 1;
                     g_msg_adm := 'VÃ©rifier l''adhÃ©sion ' || r_piece.idadhesion || ' suspendue ou rÃ©siliÃ©e'
                                   || ' au ' || TO_CHAR(loc_date_resil,'DD/MM/YYYY');
                     p_ins_journal;
                  END IF;
               ELSIF pk_histo_contrat.f_sel_etat (r_piece.numgar, loc_date_resil) IN (2, 3) THEN
                     g_niv_msg := 1;
                     g_msg_adm := 'VÃ©rifier le contrat ' || r_piece.numgar || ' suspendu ou rÃ©siliÃ©'
                                  || ' au ' || TO_CHAR(loc_date_resil,'DD/MM/YYYY');
                     p_ins_journal;
               END IF;
            END IF;
         END IF;

   --
         BEGIN
            qttc_ventil (g_comm_numfact);
         END;
   --
END LOOP;

      CLOSE c_piece;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('Erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         g_erreur := g_msg_adm;
         p_ins_journal;
--
END;

--
--
----------------------- Fin des procedures publiques ------------------

-- -- CORPS DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@corpriv
-- Insertion dans journal_adm
   PROCEDURE p_ins_journal
IS
      l_idligne   NUMBER;
BEGIN
      IF (g_niv_msg <= g_max_msg)
      THEN
         g_idligne := g_idligne + 1;

         IF (g_niv_msg = 0)
         THEN
            l_idligne := -1 * g_idligne;
         ELSE
            l_idligne := g_idligne;
         END IF;

         pk_trace.p_ins_journal_adm (i_nom_traitement      => g_nom_traitement,
                                     i_session             => g_session,
                                     i_niv_msg             => g_niv_msg,
                                     i_msg_adm             => g_msg_adm,
                                     i_idligne             => l_idligne
                                    );
      END IF;
   END p_ins_journal;
---------------- Fin des corps des procedures privees --
END;
/
