CREATE OR REPLACE PACKAGE ARTHUS.PK_DEV_VR03B
AS
/*============================================================================*/
/* PACKAGE      : PK_DEV_VR03B.sql                                            */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : ???                                                         */
/* Description  : Constitution d un bordereau de virement                     */
/*============================================================================*/
/* Evolution    : Mise en place de la fonction de validité d un rib avant le  */
/*                lancement de la constitution du bordereau (f_rib_valide)    */
/* Auteur       : JBO                                                         */
/* Date         : 04/10/2012                                                  */
/* Commentaire  : Dans le cadre du projet SEPA                                */
/*============================================================================*/
/* Evolution    : M0004376 : prise en compte date de valeur                   */
/* Auteur       : MUR                                                         */
/* Date         : 03/1007/2014                                                */
/* Commentaire  :                                                             */
/*============================================================================*/
   PROCEDURE p_dev_vr03b (
      i_deb_numcpte   IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_fin_numcpte   IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_deb_codope    IN       decaismt.codope%TYPE DEFAULT NULL,
      i_fin_codope    IN       decaismt.codope%TYPE DEFAULT NULL,
      i_date_valeur   IN       remise_vire.date_valeur%type DEFAULT NULL, -- M0004376
      i_session       IN       NUMBER DEFAULT 1,
      i_niv_msg       IN       NUMBER DEFAULT 1,
      i_pause         IN       NUMBER DEFAULT 0,
      o_found         OUT      NUMBER,
      o_erreur        OUT      VARCHAR2
   );
--

--
-- Chaine de reconnaissance SCCS
-- %W%   %E%

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

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_DEV_VR03B
AS
/*============================================================================*/
/* PACKAGE      : PK_DEV_VR03B.sql                                            */
/* Domaine      : Santé                                                       */
/* Version      : V1.0                                                        */
/* Auteur       : JBO                                                         */
/* Création     : ???                                                         */
/* Description  : Constitution d un bordereau de virement                     */
/*============================================================================*/
/* Evolution    : Mise en place de la fonction de validité d un rib avant le  */
/*                lancement de la constitution du bordereau (f_rib_valide)    */
/* Auteur       : JBO                                                         */
/* Date         : 04/10/2012                                                  */
/* Commentaire  : Dans le cadre du projet SEPA                                */
/*============================================================================*/
/* Correction   : Suite pb prod CAPRA sur un RIB Suisse en euros, on supprime */
/*				  la vérification entre g_rib_codpays <> pk_devise.pays_ref   */
/* Auteur       : TLE                                                         */
/* Date         : 01/07/2014                                                  */
/*============================================================================*/


-- Chaine de reconnaissance SCCS
-- %W%   %E%

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
   PROCEDURE p_fin_traitement;

--
   PROCEDURE p_corps_sel_numcpte;

--
   PROCEDURE p_sel_decaismt;

--
   PROCEDURE p_sel_piece_contrat;

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

   -- Variables globales priv¿es
   g_date_valeur               remise_vire.date_valeur%type; -- M0004376
--
   g_numcpte                   vs_compte.numcpte%TYPE;
   g_libcompte                 vs_compte.libcompte%TYPE;
   g_monnaiecompte             vs_compte.monnaie%TYPE;
--
   g_decaismt_numdecaismt      decaismt.numdecaismt%TYPE;
   g_decaismt_montant          decaismt.montant%TYPE;
   g_decaismt_monnaie          decaismt.monnaie%TYPE;
   g_decaismt_montant_d        decaismt.montant_d%TYPE;
   g_decaismt_monnaie_d        decaismt.monnaie_d%TYPE;
   g_decaismt_numbene          decaismt.numbene%TYPE;
   g_decaismt_numdest          decaismt.numdest%TYPE;
   g_decaismt_codope           decaismt.codope%TYPE;
   g_decaismt_modpmt           decaismt.modpmt%TYPE;
   g_decaismt_nombene          VARCHAR2 (60);
--
   g_min_numgar                contrat.numgar%TYPE;
   g_numgar_pie                contrat.numgar%TYPE;
   g_nb_numgar                 NUMBER (10);
--

   --G_monnaie    NUMBER(3);
   g_monnaie_old               NUMBER (3);
--G_monnaie_d     NUMBER(3);
   g_monnaie_old_d             NUMBER (3);
   g_idrib                     rib.idrib%TYPE;
   g_idrib_old                 rib.idrib%TYPE;              -- JPF 22/02/2005
--
   g_pie_contrat_trouve        VARCHAR2 (1);
   g_rib_existe                NUMBER(1);
   g_vire_detail_ins           VARCHAR2 (1);
--
   g_rib_codbque               rib.codbque%TYPE;
   g_rib_guichet               rib.guichet%TYPE;
   g_rib_compte                rib.compte%TYPE;
   g_rib_clerib                rib.clerib%TYPE;
   g_rib_intitule              rib.intitule%TYPE;
   g_rib_clef_iban             rib.clef_iban%TYPE;
   g_rib_bban                  rib.bban%TYPE;
   g_rib_bic                   rib.bic%TYPE;
   g_rib_codpays               rib.codpays%TYPE;
   g_rib_nature                rib.nature%TYPE;
   g_rib_devise                rib.devise_compte%TYPE;
   g_rib_numindiv                  rib.numindiv%TYPE;
--
   g_premier_virement          VARCHAR2 (1);
--
   g_rib_codbque_old           rib.codbque%TYPE;
   g_rib_guichet_old           rib.guichet%TYPE;
   g_rib_compte_old            rib.compte%TYPE;
   g_rib_clerib_old            rib.clerib%TYPE;
   g_rib_intitule_old          rib.intitule%TYPE;
   g_rib_clef_iban_old         rib.clef_iban%TYPE;
   g_rib_bban_old              rib.bban%TYPE;
   g_rib_bic_old               rib.bic%TYPE;
   g_rib_codpays_old           rib.codpays%TYPE;
--
   g_numremise                 remise_vire.numremise%TYPE;
   g_numremise_init            remise_vire.numremise%TYPE;
   g_numvirement               remise_vire_detail.numvirement%TYPE;
   g_datrem                    remise_vire.datrem%TYPE;
   g_nombre                    remise_vire.nombre%TYPE;
   g_valide                    remise_vire.valide%TYPE;
--
-- parametres du traitement
   g_numcpte_deb               vs_compte.numcpte%TYPE;
   g_numcpte_fin               vs_compte.numcpte%TYPE;
   g_codope_deb                decaismt.codope%TYPE;
   g_codope_fin                decaismt.codope%TYPE;
--
-- Flag de commit ou rollback a retourner a Forms
   g_commit                    BOOLEAN                               := FALSE;
   g_rollback                  BOOLEAN                               := FALSE;
   g_auto_valide               BOOLEAN                               := FALSE;
--
   g_flag_test                 NUMBER;
   g_proc                      VARCHAR2 (80);
-- Variables de P_INS_journal
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                       DEFAULT 'pk_dev_VR03B';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE          DEFAULT 1;
   g_niv_msg                   journal_adm.niv_msg%TYPE              := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE              := 1;
   g_idligne                   journal_adm.idligne%TYPE              := 0;
   g_erreur                    journal_adm.msg_adm%TYPE;

-- G_niv_msg prend les Valeurs :
-- 0 --> Message d'erreurs (Erreur ORACLE)
-- 1 --> Message informatif(tout se passe bien)
-- 2 et + Niveau de detail
---------------------- Fin des variables globales privees --
----------------------------------------------------------------------------
--
-- DEFINITION DES CURSEURS PRIVES ------------------------------------------
--@curs
--
----------------------------------------------------------------------------
   CURSOR c_sel_numcpte
   IS
      SELECT   vs_compte.numcpte, vs_compte.libcompte, vs_compte.monnaie
          FROM vs_compte
         WHERE vs_compte.numcpte BETWEEN NVL (g_numcpte_deb,
                                              vs_compte.numcpte
                                             )
                                     AND NVL (g_numcpte_fin,
                                              NVL (g_numcpte_deb,
                                                   vs_compte.numcpte
                                                  )
                                             )
      GROUP BY vs_compte.numcpte, vs_compte.libcompte, vs_compte.monnaie;

--
   CURSOR c_sel_decaismt
   IS
      SELECT   decaismt.numdecaismt, decaismt.montant, decaismt.monnaie,
               decaismt.montant_d, decaismt.monnaie_d,
               f_bene_rib	(decaismt.numdest,decaismt.codope,0, 1, decaismt.monnaie_d, sysdate	) idrib, /*jbn 24/03/11*/
               decaismt.numbene, decaismt.numdest, decaismt.codope,
               decaismt.modpmt, indvs.nom || indvs.prenom nombene
          FROM decaismt, indvs
         WHERE decaismt.flagpay = -1
           AND decaismt.numutil + 0 >= 0
           AND decaismt.montant + 0 > 0
           AND decaismt.modpmt = 2
           AND decaismt.monnaie = decaismt.monnaie_d
           AND decaismt.numcpte = g_numcpte
           AND decaismt.numbene = indvs.numindiv
           AND decaismt.codope BETWEEN NVL (g_codope_deb, decaismt.codope)
                                   AND NVL (g_codope_fin,
                                            NVL (g_codope_deb,
                                                 decaismt.codope)
                                           )
           AND NOT EXISTS (
                  SELECT 1
                    FROM remise_vire_detail
                   WHERE remise_vire_detail.numdecaismt = decaismt.numdecaismt
                  UNION
                  SELECT 1
                    FROM remise_op_detail
                   WHERE remise_op_detail.numdecaismt = decaismt.numdecaismt)
      ORDER BY monnaie_d, idrib;            -- JPF 22/02/2005 decaismt.numbene

--
---- Curseur - pièces affectées à un décaissement
--
   CURSOR c_pie_contrat (i_numdecaismt NUMBER)
   IS
      SELECT codope, numaffec
        FROM affectation
       WHERE affectation.numdecaismt = i_numdecaismt;

--
------------------------------------------------------------------
--
-- Le corps des diff¿rentes procedures
--
------------------------------------------------------------------
--
--
   PROCEDURE p_dev_vr03b (
      i_deb_numcpte   IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_fin_numcpte   IN       vs_compte.numcpte%TYPE DEFAULT NULL,
      i_deb_codope    IN       decaismt.codope%TYPE DEFAULT NULL,
      i_fin_codope    IN       decaismt.codope%TYPE DEFAULT NULL,
      i_date_valeur   IN       remise_vire.date_valeur%type DEFAULT NULL, -- M0004376
      i_session       IN       NUMBER DEFAULT 1,
      i_niv_msg       IN       NUMBER DEFAULT 1,
      i_pause         IN       NUMBER DEFAULT 0,
      o_found         OUT      NUMBER,
      o_erreur        OUT      VARCHAR2
   )
   IS
      r_sel_numcpte   c_sel_numcpte%ROWTYPE;
   BEGIN
      --
      o_found := 1;
      g_erreur := NULL;
      --
      g_numcpte_deb := i_deb_numcpte;
      g_numcpte_fin := i_fin_numcpte;
      g_codope_deb := i_deb_codope;
      g_codope_fin := i_fin_codope;
      --
      g_max_msg := i_niv_msg;
      g_session := i_session;

      g_date_valeur := nvl(i_date_valeur,sysdate) ; -- M0004376 : prise en compte date de valeur

   --G_idligne     := F_max_idligne(I_session => G_session);
   --
--
-- OUVERTURE du Curseur
--
      IF NOT c_sel_numcpte%ISOPEN
      THEN
         --
         g_niv_msg := 1;
         g_msg_adm :=
               'Debut de traitement le '
            || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
         p_ins_journal;

         -- Fin ecriture dans le Journal
         OPEN c_sel_numcpte;
      --
      END IF;

      --
      -- LECTURE D'1 Ligne dans la table principale
      --
      FETCH c_sel_numcpte
       INTO r_sel_numcpte;

      --
      IF c_sel_numcpte%NOTFOUND
      THEN
         o_found := 0;
         -- FERMETURE du Curseur
         p_fin_traitement;
      ELSE
         o_found := 1;
         g_numcpte := r_sel_numcpte.numcpte;
         g_libcompte := r_sel_numcpte.libcompte;
         g_monnaiecompte := r_sel_numcpte.monnaie;
--
--*debogage debut
         g_niv_msg := 3;
         g_msg_adm :=
               'compte treso n° '
            || TO_CHAR (g_numcpte)
            || ' - '
            || TO_CHAR (g_libcompte);
         p_ins_journal;
--*debogage fin
--
         p_corps_sel_numcpte;
--
      END IF;

      --
      o_erreur := g_erreur;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := 'PK_DEV_VR03B - ' || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         o_erreur := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;

         CLOSE c_sel_numcpte;
   END;

--
--------------------------
   PROCEDURE p_fin_traitement
   IS
   BEGIN
--
      g_proc := 'P_fin_traitement';
--
      g_niv_msg := 1;
      g_msg_adm :=
            'Fin Normale du traitement le '
         || TO_CHAR (SYSDATE, 'DD/MM/YYYY hh24:mi');
      p_ins_journal;

      -- Fin ecriture dans le Journal
      CLOSE c_sel_numcpte;
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
   PROCEDURE p_corps_sel_numcpte
   IS
   BEGIN
--
      g_proc := 'P_CORPS_sel_numcpte';

--
   --
      SELECT NVL (MAX (numremise), 0) + 1
        INTO g_numremise
        FROM remise_vire;

      g_numremise_init := g_numremise;
      --
      g_vire_detail_ins := 'N';
      --
      p_sel_decaismt;

      --
      -- test si virement détail insérés parmi les décaissements pour ce G_numcpte !
      IF g_vire_detail_ins = 'O'
      THEN
         --
         INSERT INTO remise_vire
                     (numremise, numcpte, datrem, nombre, montant, monnaie,
                      montant_d, monnaie_d, valide
                      , date_valeur) -- M0004376
            SELECT   numremise, numcpte, TRUNC (SYSDATE),
                     COUNT (DISTINCT numvirement), SUM (montant), monnaie,
                     SUM (montant_d), monnaie_d, 'N'
                     , g_date_valeur -- M0004376
                FROM remise_vire_detail
               WHERE remise_vire_detail.numremise BETWEEN g_numremise_init
                                                      AND g_numremise
            GROUP BY numremise, numcpte, monnaie_d, monnaie;
      END IF;
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
--------------------------
   PROCEDURE p_sel_piece_contrat
   IS
      r_piece_contrat   c_pie_contrat%ROWTYPE;
   BEGIN
--
      g_proc := 'P_sel_piece_contrat';

--
--
      OPEN c_pie_contrat (g_decaismt_numdecaismt);

--
      g_min_numgar := 0;
      g_numgar_pie := 0;
      g_nb_numgar := 0;
--
      g_pie_contrat_trouve := 'N';

--
      LOOP
         FETCH c_pie_contrat
          INTO r_piece_contrat;

         --
         IF c_pie_contrat%NOTFOUND
         THEN
            CLOSE c_pie_contrat;

            EXIT;
         ELSE
            --
            BEGIN
               g_numgar_pie :=
                  NVL
                     (pk_qttc.f_sel_numgar
                                    (f_piece_contrat (r_piece_contrat.codope,
                                                      r_piece_contrat.numaffec
                                                     )
                                    ),
                      0
                     );
               g_pie_contrat_trouve := 'O';

               --
               IF ((g_numgar_pie < g_min_numgar) AND g_numgar_pie <> 0)
               THEN
                  g_min_numgar := g_numgar_pie;
                  g_nb_numgar := g_nb_numgar + 1;
               ELSIF g_numgar_pie > g_min_numgar
               THEN
                  g_min_numgar := g_numgar_pie;
                  g_nb_numgar := g_nb_numgar + 1;
               END IF;
            --
            EXCEPTION
               WHEN OTHERS
               THEN
                  g_numgar_pie := 0;
                  g_pie_contrat_trouve := 'N';
                  --
                  --*msg debut
                  g_niv_msg := 2;
                  g_msg_adm :=
                        'Le decaismt n° '
                     || TO_CHAR (g_decaismt_numdecaismt)
                     || ' a un probleme de référence pièce - contrat ';
                  p_ins_journal;

                  --*msg fin
                  --
                  CLOSE c_pie_contrat;

                  EXIT;
            END;
         --
         END IF;
      --
      END LOOP;
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
   PROCEDURE p_sel_decaismt
   IS
      r_sel_decaismt   c_sel_decaismt%ROWTYPE;
   BEGIN
--
      g_proc := 'P_sel_decaismt';

--
--OPEN C_sel_decaismt;
      LOOP
         IF NOT c_sel_decaismt%ISOPEN
         THEN
            OPEN c_sel_decaismt;

            FETCH c_sel_decaismt
             INTO r_sel_decaismt;

            EXIT WHEN c_sel_decaismt%NOTFOUND;
            g_decaismt_numdecaismt := r_sel_decaismt.numdecaismt;
            g_decaismt_montant := r_sel_decaismt.montant;
            g_decaismt_monnaie := r_sel_decaismt.monnaie;
            g_decaismt_montant_d := r_sel_decaismt.montant_d;
            g_decaismt_monnaie_d := r_sel_decaismt.monnaie_d;
            g_decaismt_numbene := r_sel_decaismt.numbene;
            g_decaismt_numdest := r_sel_decaismt.numdest;
            g_decaismt_codope := r_sel_decaismt.codope;
            g_decaismt_modpmt := r_sel_decaismt.modpmt;
            g_decaismt_nombene := r_sel_decaismt.nombene;
            --G_monnaie_old_d:=G_decaismt_monnaie_d; --25/02/2005 David
            g_monnaie_old_d := 0;
            g_idrib_old := 0;
         ELSE
            g_monnaie_old_d := g_decaismt_monnaie_d;
            g_idrib_old := g_idrib;

            FETCH c_sel_decaismt
             INTO r_sel_decaismt;

            EXIT WHEN c_sel_decaismt%NOTFOUND;
            g_decaismt_numdecaismt := r_sel_decaismt.numdecaismt;
            g_decaismt_montant := r_sel_decaismt.montant;
            g_decaismt_monnaie := r_sel_decaismt.monnaie;
            g_decaismt_montant_d := r_sel_decaismt.montant_d;
            g_decaismt_monnaie_d := r_sel_decaismt.monnaie_d;
            g_decaismt_numbene := r_sel_decaismt.numbene;
            g_decaismt_numdest := r_sel_decaismt.numdest;
            g_decaismt_codope := r_sel_decaismt.codope;
            g_decaismt_modpmt := r_sel_decaismt.modpmt;
            g_decaismt_nombene := r_sel_decaismt.nombene;

            IF g_monnaie_old_d != g_decaismt_monnaie_d
            THEN
               g_numremise := g_numremise + 1;
            END IF;
         END IF;

--
         p_sel_piece_contrat;
         --
         --
         IF g_pie_contrat_trouve = 'N'
         THEN
            --
            --*msg debut
            g_niv_msg := 2;
            g_msg_adm :=
                  'Le decaismt n° '
               || TO_CHAR (g_decaismt_numdecaismt)
               || ' n"a pas de référence pièce - contrat ';
            p_ins_journal;
            g_niv_msg := 2;
            g_msg_adm :=
               'Les références bancaires générales de ce bénéficiaire ne sont pas définies';
            p_ins_journal;
         --*msg fin
         --
         ELSE
           -- Recherche du rib en cours
           g_idrib := f_bene_rib ( g_decaismt_numdest
                                 , g_decaismt_codope
                                 , g_min_numgar
                                 , 1
                                 , G_decaismt_monnaie_d
                                 , sysdate
                                 );
           --
           IF g_idrib > 0 THEN
             -- Vérification de la validité du rib(normalisé ou non normalisé)
             g_rib_existe:=F_RIB_VALIDE(g_idrib); -- g_rib_existe=1
             -- MODIF TLE SEPA
             --IF g_rib_existe =1 THEN
              IF g_rib_existe  in (1,2) THEN
               BEGIN
                  SELECT rib.codbque, rib.guichet, rib.compte,
                         rib.clerib, rib.intitule, rib.clef_iban,
                         rib.bban, rib.bic, rib.codpays, rib.nature,
                         rib.devise_compte,rib.numindiv            -- TLE : SEPA :AJOUT DU NUMINDIV POUR LE MESSAGE
                    INTO g_rib_codbque, g_rib_guichet, g_rib_compte,
                         g_rib_clerib, g_rib_intitule, g_rib_clef_iban,
                         g_rib_bban, g_rib_bic, g_rib_codpays, g_rib_nature,
                         g_rib_devise,g_rib_numindiv
                    FROM rib
                   WHERE idrib = g_idrib;
                  --
				  -- Si  g_rib_existe = 2 (BIC non renseigné) : message vers l'utilisateur
                  -- TLE : SEPA : si f_rib_valide = 2 alors message "BIC NON RENSEIGNE"
                    IF f_rib_valide (g_idrib) = 2 THEN
                           g_niv_msg := 1;
                           g_msg_adm := 'Le bic pour le bénéficiaire N° '
                                             || g_rib_numindiv
                                             || ' n''est pas renseigné.';
                      p_ins_journal;
                    END IF;
               --
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     g_rib_existe := 0;
               END;
             END IF;
              --
           ELSE
             g_rib_existe:=0;
           END IF;
           --
           IF g_rib_existe= 0
           THEN
              --
              --*msg debut
              g_niv_msg := 2;
              g_msg_adm :=
                    'Le RIB du decaismt n° '
                 || TO_CHAR (g_decaismt_numdecaismt)
                 || ' destiné à '
                 || g_decaismt_nombene
                 || ' n" est pas défini ';
              p_ins_journal;
           --*msg fin
           --
           ELSIF (g_nb_numgar > 1 AND g_min_numgar != 0)
           THEN
              --
              --*msg debut
              g_niv_msg := 2;
              g_msg_adm :=
                    'Le decaismt n° '
                 || TO_CHAR (g_decaismt_numdecaismt)
                 || ' concerne plusieurs contrats ';
              p_ins_journal;
              g_niv_msg := 2;
              g_msg_adm :=
                 'Les références bancaires générales de ce bénéficiaire ne sont pas définies';
              p_ins_journal;
           --*msg fin
           --
           ELSIF   -- g_rib_codpays <> pk_devise.pays_ref OR    -- TLE SEPA 01/07/2014
			     g_rib_nature <> 2
                 OR g_monnaiecompte <> g_decaismt_monnaie
                 OR g_rib_devise <> g_decaismt_monnaie
           THEN
              --
              g_niv_msg := 2;
              g_msg_adm :=
                    'Le decaismt n° '
                 || TO_CHAR (g_decaismt_numdecaismt)
                 || ' n''a pas un Rib valide pour un virement.';
              p_ins_journal;
              g_niv_msg := 2;
              g_msg_adm :=
                         'Le pays du RIB<> pays de ref. ou RIB non normalisé';
              p_ins_journal;
           ELSE
              g_vire_detail_ins := 'O';
              --
              --*debogage debut
              g_niv_msg := 3;
              g_msg_adm :=
                    'ins remise_vire_detail decaismt n° '
                 || TO_CHAR (g_decaismt_numdecaismt)
                 || ' - '
                 || 'G_idrib n° '
                 || TO_CHAR (g_idrib);
              p_ins_journal;

              --*debogage fin

              --David 30/12/2004
              IF (   g_idrib_old != g_idrib
                  OR g_monnaie_old_d != g_decaismt_monnaie_d
                  OR NVL(g_numvirement,0)=0  -- JBO : 23/11/2010 : M0003309
                 )
              THEN                                          -- JPF 22/02/2005
                 SELECT numvirement.NEXTVAL
                   INTO g_numvirement
                   FROM DUAL;
              END IF;

              --G_idrib_old  :=G_idrib;              -- JPF 22/02/2005
              INSERT INTO remise_vire_detail
                          (numremise, numcpte, numvirement,
                           numdecaismt, montant,
                           monnaie, montant_d,
                           monnaie_d, codbque,
                           guichet, compte, clerib,
                           intitule, clef_iban, bban,
                           bic, codpays
                          )
                   --
              VALUES      (g_numremise, g_numcpte, g_numvirement,
                           g_decaismt_numdecaismt, g_decaismt_montant,
                           g_decaismt_monnaie, g_decaismt_montant_d,
                           g_decaismt_monnaie_d, g_rib_codbque,
                           g_rib_guichet, g_rib_compte, g_rib_clerib,
                           g_rib_intitule, g_rib_clef_iban, g_rib_bban,
                           g_rib_bic, g_rib_codpays
                          );
           END IF;
         END IF;
      END LOOP;

      CLOSE c_sel_decaismt;
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
