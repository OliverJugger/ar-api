CREATE OR REPLACE PACKAGE ARTHUS."PK_VIREM"
AS
-- Chaine de reconnaissance SCCS
-- %W% Bordereau de virement %E%
-- -- CONSTANTES PUBLIQUE -----------------------------------------------------
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
--@pub
   PROCEDURE p_vire_cpte (
      i_numcpte_deb   IN   NUMBER,
      i_numcpte_fin   IN   NUMBER,
      i_codope_deb    IN   NUMBER,
      i_codope_fin    IN   NUMBER
   );
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_VIREM"
AS
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
-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
--@global
   g_erreur                    journal_adm.msg_adm%TYPE;
-- Flag de commit ou rollback a retourner a Forms
   g_commit                    BOOLEAN                           := FALSE;
   g_rollback                  BOOLEAN                           := FALSE;
   g_auto_valide               BOOLEAN                           := FALSE;
--
-- Variables de P_INS_journal
--
   g_nom_traitement   CONSTANT journal_adm.nom_traitement%TYPE
                                                    DEFAULT 'pk_retrocession';
   g_msg_adm                   journal_adm.msg_adm%TYPE;
   g_session                   journal_adm.id_session%TYPE       DEFAULT 1;
   g_flag_test                 NUMBER;
   g_niv_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_max_msg                   journal_adm.niv_msg%TYPE          := 1;
   g_idligne                   journal_adm.idligne%TYPE          := 0;
   g_proc                      VARCHAR2 (80);

--
-- G_niv_msg prend les Valeurs :
-- 0 --> Message d'erreurs (Erreur ORACLE)
-- 1 --> Message informatif(tout se passe bien)
-- 2 et + Niveau de detail
-- -------------------------------------- Fin des variables globales privees --
-- -- DEFINITION DES CURSEURS PRIVES ------------------------------------------
--@curs
   CURSOR c_numcpte (i_numcpte_deb NUMBER, i_numcpte_fin NUMBER)
   IS
      SELECT numcpte
        FROM vs_compte
       WHERE vs_compte.numcpte BETWEEN NVL (i_numcpte_deb, vs_compte.numcpte)
                                   AND NVL (i_numcpte_fin,
                                            NVL (i_numcpte_deb,
                                                 vs_compte.numcpte
                                                )
                                           );

-- -------------------------------------- Fin des curseurs prives -------------
-- -- DEFINITION DES PROCEDURES ET FONCTIONS PRIVEES --------------------------
--@priv
-- Insertion dans journal_adm
--
--Procedure P_INS_journal;
-- ----------------------------- Fin des definitions des procedures privees ---
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
   PROCEDURE p_vire_cpte (
      i_numcpte_deb   IN   NUMBER,
      i_numcpte_fin   IN   NUMBER,
      i_codope_deb    IN   NUMBER,
      i_codope_fin    IN   NUMBER
   )
   IS
      e_rib                 rib%ROWTYPE;
      e_idrib               rib.idrib%TYPE;
      rib_existe            VARCHAR2 (1)                          := 'N';
      vire_detail_ins       VARCHAR2 (1)                          := 'N';
      dernier_vire_detail   VARCHAR2 (1)                          := 'N';
      e_numremise           remise_vire.numremise%TYPE;
      e_numvirement         remise_vire_detail.numvirement%TYPE;
      min_numgar_pie        adhe_cntrt.numgar%TYPE                := 0;
      v_numgar_pie          adhe_cntrt.numgar%TYPE                := 0;
      nb_numgar_pie         NUMBER                                := 0;

-------------
      CURSOR c_numcpte (i_numcpte_deb NUMBER, i_numcpte_fin NUMBER)
      IS
         SELECT numcpte
           FROM vs_compte
          WHERE vs_compte.numcpte BETWEEN NVL (i_numcpte_deb,
                                               vs_compte.numcpte
                                              )
                                      AND NVL (i_numcpte_fin,
                                               NVL (i_numcpte_deb,
                                                    vs_compte.numcpte
                                                   )
                                              );


      rec_c_numcpte         c_numcpte%ROWTYPE;

--
      CURSOR c_decais (
         i_numcpte      NUMBER,
         i_codope_deb   NUMBER,
         i_codope_fin   NUMBER
      )
      IS
         SELECT   decaismt.numdecaismt, decaismt.montant, decaismt.numbene,
                  decaismt.numdest, decaismt.codope, decaismt.modpmt
             FROM decaismt
            WHERE decaismt.flagpay = -1
              AND decaismt.numutil + 0 >= 0
              AND decaismt.montant + 0 > 0
              AND decaismt.modpmt = 2
              AND decaismt.numcpte + 0 = i_numcpte
              AND decaismt.codope BETWEEN NVL (i_codope_deb, decaismt.codope)
                                      AND NVL (i_codope_fin,
                                               NVL (i_codope_deb,
                                                    decaismt.codope
                                                   )
                                              )
              AND NOT EXISTS (
                     SELECT 1
                       FROM remise_vire_detail
                      WHERE remise_vire_detail.numdecaismt =
                                                          decaismt.numdecaismt)
         GROUP BY decaismt.numcpte
         ORDER BY decaismt.numcpte;

--
      rec_c_decais          c_decais%ROWTYPE;
      e_decais_nomdest      VARCHAR2 (30);

--
/*
   Recherche le nombre de numgar et le min(numgar) concernes
   par les pieces attachees a ce decaissement
   SELECT   nvl(min(v_piece_contrat.numgar),0),
      count(v_piece_contrat.numgar)
   SELECT   f_piece_contrat(a.codope, a.numaffec),
   FROM  affectation a
   Where    a.numdecaismt=e_numdecaismt;
*/
--
      CURSOR c_pie_decais (i_numdecaismt NUMBER)
      IS
         SELECT codope, numaffec
           FROM affectation
          WHERE affectation.numdecaismt = i_numdecaismt;

--
      rec_c_pie_decais      c_pie_decais%ROWTYPE;

--
-- Sélection des virements qui viennent d'etre inseres (numremise=zéro),
--
      CURSOR c_vire_detail (i_numremise NUMBER)
      IS
         SELECT   *
             FROM remise_vire_detail b
            WHERE b.numremise = i_numremise
         GROUP BY b.codbque, b.guichet, b.compte, b.clerib, b.intitule
         ORDER BY b.codbque, b.guichet, b.compte, b.clerib, b.intitule;

--
      rec_c_vire_detail     c_vire_detail%ROWTYPE;
      v_vire_old            c_vire_detail%ROWTYPE;
--
/*Type t_compte_vire is record (codbque Rec_c_vire_detail.codbque%type,
               guichet Rec_c_vire_detail.guichet%type,
               compte Rec_c_vire_detail.compte%type,
               clerib Rec_c_vire_detail.clerib%type,
               intitule Rec_c_vire_detail.intitule%type
              );
*/
      v_compte_vire         VARCHAR2 (60);
      v_compte_vire_old     VARCHAR2 (60);
      v_numbque             pers_banque.numindiv%TYPE;
      v_numbque_old         pers_banque.numindiv%TYPE;
   BEGIN
      OPEN c_numcpte (i_numcpte_deb, i_numcpte_fin);

      LOOP
--
-- sélection du compte de trésorerie à traiter
--
         FETCH c_numcpte
          INTO rec_c_numcpte;

         EXIT WHEN c_numcpte%NOTFOUND;
--
         vire_detail_ins := 'N';
         dernier_vire_detail := 'N';

--
         OPEN c_decais (rec_c_numcpte.numcpte, i_codope_deb, i_codope_fin);

         LOOP
--
-- selection du decaismt à traiter (pour le n° de compte à traiter)
--
            FETCH c_decais
             INTO rec_c_decais;

            EXIT WHEN c_decais%NOTFOUND;
--
            e_decais_nomdest := pk_personne.f_nom (rec_c_decais.numdest, 32);
--
/*
   Recherche le nombre de numgar et le min(numgar) concernes
   par les pieces attachees a ce decaissement
   SELECT   nvl(min(v_piece_contrat.numgar),0),
      count(v_piece_contrat.numgar)
   SELECT   f_piece_contrat(a.codope, a.numaffec),
   FROM  affectation a
   Where    a.numdecaismt=e_numdecaismt;
*/
--
            min_numgar_pie := 0;
            nb_numgar_pie := 0;

            OPEN c_pie_decais (rec_c_decais.numdecaismt);

            LOOP
               FETCH c_pie_decais
                INTO rec_c_pie_decais;

               IF c_pie_decais%NOTFOUND
               THEN
                  EXIT;
               END IF;

--
               v_numgar_pie :=
                  f_piece_contrat (rec_c_pie_decais.codope,
                                   rec_c_pie_decais.numaffec
                                  );

--
               IF ((v_numgar_pie < min_numgar_pie) AND v_numgar_pie <> 0)
               THEN
                  min_numgar_pie := v_numgar_pie;
                  nb_numgar_pie := nb_numgar_pie + 1;
               ELSIF v_numgar_pie > min_numgar_pie
               THEN
                  nb_numgar_pie := nb_numgar_pie + 1;
               END IF;
            END LOOP;

            CLOSE c_pie_decais;

--
-- Si plus d'un contrat concerne et pas de references pour
-- bancaire pour tous contrats alors anomalie
--
            rib_existe := 'N';

--
            SELECT f_bene_rib (rec_c_decais.numbene,
                               rec_c_decais.codope,
                               min_numgar_pie,
                               1
                              )
              INTO e_idrib
              FROM DUAL;

--
-- Caractéristiques du Rib selon l'identifiant récupéré par f_bene_rib !
--
            SELECT rib.codbque, rib.guichet, rib.compte, rib.clerib,
                   rib.intitule, 'O'
              INTO e_rib.codbque, e_rib.guichet, e_rib.compte, e_rib.clerib,
                   e_rib.intitule, rib_existe
              FROM rib
             WHERE idrib = e_idrib AND rib.clerib IS NOT NULL;

--
-- Contrôles avant insertion dans la table des virements (remise_vire_detail)
--
            IF (NVL (rib_existe, 'N') = 'N')
            THEN
/*
--> message d'anomalie dans le Journal_ADM ?
--
   'Le décaissement No : '||c_decais.numdecaismt ||' concerne le destinataire n° : '
   || c_decais.numdest||' - '||c_decais.nomdest||'dont les références bancaires générales ne sont pas définies'
*/
               EXIT;
            ELSIF (nb_numgar_pie > 1 AND min_numgar_pie != 0)
            THEN
/*
--> message d'anomalie dans le Journal_ADM ?
--
   'Le décaissement No : '||c_decais.numdecaismt ||' concerne plusieurs contrats.'
   ||' Les références bancaires générales de ce bénéficiaire ne sont pas définies'
*/
               EXIT;
            ELSE
--
               vire_detail_ins := 'O';

               INSERT INTO remise_vire_detail
                           (numremise, numcpte, numvirement,
                            numdecaismt, montant,
                            codbque, guichet, compte,
                            clerib, intitule
                           )
                    VALUES (0, rec_c_numcpte.numcpte, 0,
                            rec_c_decais.numdecaismt, rec_c_decais.montant,
                            e_rib.codbque, e_rib.guichet, e_rib.compte,
                            e_rib.clerib, e_rib.intitule
                           );
            END IF;
--
         END LOOP;

-- fin de la sélection des décaissements pour ce n° de compte et les autres paramètres
         CLOSE c_decais;

--
-- test de virements insérés pour ce n° de compte
--
         IF vire_detail_ins = 'N'
         THEN
-- aller au n° de compte trésorerie suivant !
            EXIT;
         ELSE
            SELECT NVL (MAX (numremise), 0) + 1
              INTO e_numremise
              FROM remise_vire;
         END IF;

-- traitement des virements insérés avec le n° de virement à zero et le n° de remise à zero
         OPEN c_vire_detail (0);

         dernier_vire_detail := 'N';

         LOOP
            FETCH c_vire_detail
             INTO rec_c_vire_detail;

            IF c_vire_detail%NOTFOUND
            THEN
               dernier_vire_detail := 'O';
               v_compte_vire := '';
            ELSE
               v_compte_vire :=
                     rec_c_vire_detail.codbque
                  || rec_c_vire_detail.guichet
                  || rec_c_vire_detail.compte
                  || rec_c_vire_detail.clerib
                  || rec_c_vire_detail.intitule;
            END IF;

-- 1er n° de virement pour la remise
            IF (v_compte_vire <> '' AND v_compte_vire_old = '')
            THEN
               v_compte_vire_old := v_compte_vire;

               SELECT numvirement.NEXTVAL
                 INTO e_numvirement
                 FROM DUAL;
            END IF;

--
-- Rupture sur n° de compte de virement
--
            IF    (v_compte_vire <> v_compte_vire_old)
               OR (dernier_vire_detail = 'O')
            THEN
--
               UPDATE remise_vire_detail a
                  SET a.numvirement = e_numvirement
                WHERE a.numremise = e_numremise
                  AND a.numvirement = 0
                  AND a.codbque = v_vire_old.codbque
                  AND a.guichet = v_vire_old.guichet
                  AND a.compte = v_vire_old.compte
                  AND a.clerib = v_vire_old.clerib
                  AND a.intitule = v_vire_old.intitule;

--
               v_vire_old := rec_c_vire_detail;
               v_compte_vire_old := v_compte_vire;

-- n° de virement suivant (sequence)
               IF dernier_vire_detail <> 'O'
               THEN
                  SELECT numvirement.NEXTVAL
                    INTO e_numvirement
                    FROM DUAL;
               END IF;
            END IF;

--
            IF (dernier_vire_detail = 'O')
            THEN
--
               INSERT INTO remise_vire
                           (numremise, numcpte, datrem, nombre, montant,
                            valide, numdest, natrem)
                  SELECT   numremise, rec_c_numcpte.numcpte, TRUNC (SYSDATE),
                           COUNT (DISTINCT numvirement), SUM (montant), 'N',
                           v_numbque_old, 2
                      FROM remise_vire_detail
                     WHERE remise_vire_detail.numremise = e_numremise
                  GROUP BY numremise, numcpte;

--
-- Si traitement du dernier virement, sortie du curseur !
               IF dernier_vire_detail = 'O'
               THEN
                  EXIT;
               END IF;
--
            END IF;
         END LOOP;

--
-- fin de l'insertion de la sélection des décaissements pour ce n° de compte et les autres paramètres
         CLOSE c_vire_detail;
--
--
      END LOOP;

--
      CLOSE c_numcpte;

--
      COMMIT;
--
   END;
END;
/
