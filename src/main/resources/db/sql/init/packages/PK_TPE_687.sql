CREATE OR REPLACE PACKAGE ARTHUS.PK_TPE_687 AS
/*===========================================================================*/
/* Package/Fonction/Procedure/Trigger/Vue      : PK_TPE_687.sql              */
/* Domaine      : Prestation santé                                           */
/* Version      : V1.0                                                       */
/* Auteur       : Trigramme de la personne                                   */
/* Création     : DD/MM/AAAA                                                 */
/* Description  : Expliquer le but du programme sur plusieurs lignes si      */
/*              : nécessaire                                                 */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : PHA / date 16/05/2012 / Optimisation du temps de traitement*/
/*===========================================================================*/
/* Correction   : JBO / date 07/10/2014 / Optimisation du temps de traitement*/
/*                de la procédure p_const_bord     +   complt_titre          */
/*===========================================================================*/
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
   PROCEDURE p_annul_import_tpe (
      i_numremise   IN   stock_entite.numremise%TYPE,	  
	  i_numporte    IN   porte_remise.numporte%TYPE,
      i_session     IN   NUMBER DEFAULT 1,
      i_niv_msg     IN   NUMBER DEFAULT 1
   );

/*
   Projet : Tiers payant etendu TPE
   Permet d'annuler une importation TPE
   16/09/2005  W.ROUVRAY
*/
   PROCEDURE p_const_bord (
      i_numporte  IN   PORTE_REMISE.NUMPORTE%TYPE,
      i_session   IN   NUMBER DEFAULT 1,
      i_niv_msg   IN   NUMBER DEFAULT 1
   );

/*
   Projet : Tiers payant etendu TPE
   Permet de constituer les bordereaux d'acceptation et de rejet
   20/09/2005  W.ROUVRAY
*/
   PROCEDURE p_annul_const_bord (
      i_numremise    IN   remise_externe.numremise%TYPE,
      i_nature_exp   IN   remise_externe.nature%TYPE,
      i_session      IN   NUMBER DEFAULT 1,
      i_niv_msg      IN   NUMBER DEFAULT 1
   );

/*
   Projet : Tiers payant etendu TPE
   Permet d'annuler les bordereaux d'acceptation et de rejet
   20/09/2005  W.ROUVRAY
*/
   PROCEDURE p_export_acc_rej (
      i_traitement   IN   VARCHAR2,
      i_remise_exp   IN   stock_entite.numremise%TYPE,
      i_nature_exp   IN   VARCHAR2,
      i_repertoire   IN   VARCHAR2 DEFAULT NULL,
      i_fichier      IN   VARCHAR2 DEFAULT NULL,
      i_session      IN   NUMBER DEFAULT 1,
      i_niv_msg      IN   NUMBER DEFAULT 1
   );

/*
   Projet : Tiers payant etendu TPE
   Permet de generer un fichier acceptation ou un fichier rejet apres identification factures rejetees
   18/08/2005  W.ROUVRAY
*/
   PROCEDURE p_forcage_facture (
      i_idfactpe   IN   suivi_fact_tpe.idfactpe%TYPE,
      i_remise     IN   suivi_fact_tpe.numremise_import%TYPE,
      i_forcage    IN   suivi_fact_tpe.user_forcage%TYPE
   );

/*
Appelé dans l'écran PE05, permet de forcer une facture après avoir modifié l'"état" du ou des sinistres de cette facture.
CTT : 17/01/2008 : Cette procédure a été intégrée dans la form PE05, seule utilisatrice de cette procédure .....
*/
   PROCEDURE p_sinistre_accepte (
      i_nom_traitement   IN   journal_adm.nom_traitement%TYPE,
      i_session          IN   journal_adm.id_session%TYPE,
      i_numremise        IN   sinistre_porte.numremise%TYPE DEFAULT 0
   );
/*
Appelé dans le programme no10 en fin de traitement de fichier.
*/
END pk_tpe_687;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_TPE_687 AS
/*===========================================================================*/
/* Package/Fonction/Procedure/Trigger/Vue      : PK_TPE_687.sql              */
/* Domaine      : Prestation santé                                           */
/* Version      : V1.0                                                       */
/* Auteur       : Trigramme de la personne                                   */
/* Création     : DD/MM/AAAA                                                 */
/* Description  : Expliquer le but du programme sur plusieurs lignes si      */
/*              : nécessaire                                                 */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : PHA / date 16/05/2012 / Optimisation du temps de traitement*/
/*===========================================================================*/
/* Correction   : JBO / date 07/10/2014 / Optimisation du temps de traitement*/
/*                de la procédure p_const_bord                               */
/*===========================================================================*/

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
   PROCEDURE p_nom_fichier;

--
-- ----------------------------- Fin des declarations des procedures privees --
--
-- -- VARIABLES GLOBALES PRIVEES ----------------------------------------------
-- Variables de sortie
   g_date             VARCHAR2 (8);
   g_heure            VARCHAR2 (8);
   g_fichier          VARCHAR2 (200);
--
-- Variables de P_INS_journal
--
   g_prefixe          VARCHAR2 (11)                     := 'pk_tpe_687.';
   g_nom_traitement   journal_adm.nom_traitement%TYPE;
   g_msg_adm          journal_adm.msg_adm%TYPE;
   g_session          journal_adm.id_session%TYPE       DEFAULT 1;
   g_flag_test        NUMBER;
   g_niv_msg          journal_adm.niv_msg%TYPE          := 1;
   g_max_msg          journal_adm.niv_msg%TYPE          := 1;
   g_idligne          journal_adm.idligne%TYPE          := 0;
   g_proc             VARCHAR2 (80);
   g_rowcount         INTEGER                           DEFAULT 0;

--
-- G_niv_msg prend les Valeurs :
-- 0 --> Message d'erreurs (Erreur ORACLE)
-- 1 --> Message informatif(tout se passe bien)
-- 2 et + Niveau de detail
-- -------------------------------------- Fin des variables globales privees --
-- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
--
-- Insertion dans journal_adm
--
   PROCEDURE p_ins_journal;

--
-- Retourne le prochain idligne
--
   FUNCTION f_max_idligne (i_session IN journal_adm.id_session%TYPE)
      RETURN NUMBER;

-- ----------------------------- Fin des declarations des procedures privees --
-- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
   PROCEDURE p_annul_import_tpe (
      i_numremise   IN   stock_entite.numremise%TYPE,
	  i_numporte    IN   porte_remise.numporte%TYPE,
      i_session     IN   NUMBER DEFAULT 1,
      i_niv_msg     IN   NUMBER DEFAULT 1
   )
/*
   Projet : Tiers payant etendu TPE
   Permet d'annuler une importation TPE
   16/09/2005  W.ROUVRAY
*/
   IS
      l_flg_decompte     PLS_INTEGER;
      l_autorise_del     PLS_INTEGER;
      l_nature           porte_remise.nature%TYPE;
      l_nb_dossier       NUMBER(3);


    /*  CURSOR C_dossier(p_remise IN porte_remise.numremise%TYPE) IS
      SELECT num_dossier,numremise_sntrprt
      FROM dossier_sante
      WHERE numremise_sntrprt = p_remise;

      Rec_C_dossier C_dossier%ROWTYPE;*/

   BEGIN
      g_nom_traitement := g_prefixe || 'P_Annul_Import_TPE';
      g_max_msg := i_niv_msg;
      g_session := i_session;
      g_idligne := f_max_idligne (i_session => g_session);
      g_niv_msg := 1;
      g_msg_adm :=
         'Début du traitement le ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
      p_ins_journal;

      --
      /* CTT 07/12/2005 : Nature de la remise => Table Libelle, code mnemo "FIC_IMP" */
      SELECT nature
        INTO l_nature
        FROM porte_remise
       WHERE numremise = i_numremise
       and numporte = i_numporte ; -- MUR M0005718

      --
      BEGIN
         SELECT 1
           INTO l_flg_decompte
           FROM DUAL
          WHERE EXISTS (
                   SELECT 1
                     FROM sinistre
                    WHERE numsin IN (SELECT numsin
                                       FROM sntr_ref
                                      WHERE numremise = i_numremise)
                      AND numdec + 0 != 0);

         g_msg_adm :=
               'La remise '
            || TO_CHAR (i_numremise)
            || ' ne peut plus être supprimée (sinistres décomptés)';
         p_ins_journal;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT 1
                 INTO l_autorise_del
                 FROM suivi_fact_tpe s
                WHERE EXISTS (SELECT NULL
                                FROM remise_externe
                               WHERE numremise = s.numremise_export)
                                 -- On ne peut pas annuler une importation qui
                  AND s.numremise_import =
                                       i_numremise
                                                  -- appartient à un bordereau
                  AND ROWNUM = 1;

               g_msg_adm :=
                     'La remise '
                  || TO_CHAR (i_numremise)
                  || ' ne peut plus être supprimée (Bordereau remise export crée)';
               p_ins_journal;
            --COMMIT;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  --ABO 16/01/2012 correction pour annulation TPE dossier de PEC
                  DELETE      sinistre
                        WHERE flagam = 'p'
                        AND numsin IN (SELECT numsin
                                         FROM sntr_ref
                                        WHERE numremise = i_numremise)
                        AND numsin NOT IN (SELECT numsin_sntr
                                         FROM sntr_dossier);
                  g_msg_adm :=
                        'Nombre de lignes supprimées dans sinistre '
                     || TO_CHAR (SQL%ROWCOUNT);
                  p_ins_journal;

                  --
                  DELETE      porte_remise
                        WHERE numremise = i_numremise AND numporte = i_numporte;

                  g_msg_adm :=
                        'Nombre de lignes supprimées dans porte_remise '
                     || TO_CHAR (SQL%ROWCOUNT);
                  p_ins_journal;

                  --
                  DELETE      sntrprt
                        WHERE numremise = i_numremise;

                  g_msg_adm :=
                        'Nombre de lignes supprimées dans sntrprt '
                     || TO_CHAR (SQL%ROWCOUNT);
                  p_ins_journal;

                  l_nb_dossier:=0;
                  --
                  IF l_nature = 2 --facture
                  THEN
                     DELETE      stock_entite
                           WHERE numremise = i_numremise;

                     g_msg_adm :=
                           'Nombre de lignes supprimées dans stock_entite '
                        || TO_CHAR (SQL%ROWCOUNT);
                     p_ins_journal;
                     l_nb_dossier := PK_CALCUL_DOSSIER.F_ANNUL_DOSSIER_FACT(i_numremise );
                    --ABO 07/12/2011 mise à jour de l'état du dossier de PEC
                    /* FOR Rec_C_Dossier IN C_Dossier(i_numremise) LOOP
                      l_nb_dossier :=l_nb_dossier+1;
                      DELETE histo_dossier
                      WHERE num_dossier = Rec_C_Dossier.num_dossier
                      AND etat=0
                      AND motif = 6;--etat en cours de facturation

                      UPDATE SINISTRE_SANTE SET numsin_sntrprt =null
                      WHERE num_dossier =Rec_C_Dossier.num_dossier;

                      UPDATE DOSSIER_SANTE SET numremise_sntrprt =null
                      WHERE num_dossier =Rec_C_Dossier.num_dossier;
                     -- Rec_C_Dossier.numremise_sntrprt:=NULL;

                     END LOOP;*/

                     g_msg_adm :=
                           'Nombre de dossier de PEC réinitialisé '
                        || TO_CHAR (l_nb_dossier);
                     p_ins_journal;

                  ELSIF l_nature = 3 --avis de paiement
                  THEN
                     DELETE      stock_entite_p
                           WHERE numremise = i_numremise;

                     g_msg_adm :=
                           'Nombre de lignes supprimées dans stock_entite_p '
                        || TO_CHAR (SQL%ROWCOUNT);
                     p_ins_journal;
                    --ABO 07/12/2011 Liquidation automatique de dossier optique
                    l_nb_dossier:=PK_CALCUL_DOSSIER.F_ANNUL_DOSSIER_LIQ(i_numremise,null);
                    IF l_nb_dossier=-1 THEN
                      g_msg_adm :=
                           'ECHEC : Erreur dans la suppression des dossiers de liquidation';
                       p_ins_journal;
                      ROLLBACK;
                    ELSE
                     g_msg_adm :=
                           'Nombre de dossiers de liquidation supprimés '
                        || TO_CHAR (l_nb_dossier);
                     p_ins_journal;
                     END IF;
                  ELSIF l_nature = 4 --rejet à l'import no10
                  THEN
                     DELETE      stock_entite_r
                           WHERE numremise = i_numremise;

                     g_msg_adm :=
                           'Nombre de lignes supprimées dans stock_entite_r '
                        || TO_CHAR (SQL%ROWCOUNT);
                     p_ins_journal;
                  END IF;

                  --
                  DELETE      suivi_fact_tpe
                        WHERE numremise_import = i_numremise;

                  g_msg_adm :=
                        'Nombre de lignes supprimées dans suivi_fact_tpe '
                     || TO_CHAR (SQL%ROWCOUNT);
                  p_ins_journal;

                  --
                  DELETE      sinistre_porte_forcage
                        WHERE numremise = i_numremise;

                  g_msg_adm :=
                        'Nombre de lignes supprimées dans sinistre_porte_forcage '
                     || TO_CHAR (SQL%ROWCOUNT);
                  p_ins_journal;
                  g_msg_adm :=
                        'Fin Normale du traitement le '
                     || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
                  p_ins_journal;
                  COMMIT;
            END;
      END;
   END p_annul_import_tpe;

-- ******************************************************************************************************
   PROCEDURE p_const_bord (
      i_numporte  IN   PORTE_REMISE.NUMPORTE%TYPE,
      i_session   IN   NUMBER DEFAULT 1,
      i_niv_msg   IN   NUMBER DEFAULT 1
   )
/*
   Projet : Tiers payant etendu TPE
   Permet de constituer les bordereaux d'acceptation et de rejet
   20/09/2005  W.ROUVRAY
   22/06/2006 CTT : Le code événement "20"  (facture acceptée) est tellement éphémère qu'on se demande bien à
              quoi il peut servir !. En fait, le refus ou l'acceptation n'a de valeur que lorsque le bordereau de retour
              est constitué.   => Lors de la constitution du bordereau d'acceptation, une facture non refusée passe directement
                     "acceptée sur bordereau"... (10 à 40)
   16/08/2006 CTT : Refonte du traitement : On ne peut constituer des bordereaux d'export que sur des remises factures entièrement "calculées"
             (pas de  prestation en etat "2")
*/
   IS
      l_remexp_accepte   remise_externe.numremise%TYPE;
      l_remexp_refuse    remise_externe.numremise%TYPE;
      l_porte            remise_externe.numporte%TYPE;
      l_count            PLS_INTEGER;
	  
   BEGIN
      g_nom_traitement := g_prefixe || 'P_Const_Bord';
      g_max_msg := i_niv_msg;
      g_session := i_session;
      g_idligne := f_max_idligne (i_session => g_session);
      g_niv_msg := 1;
      g_msg_adm :=
         'Début du traitement le ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
      p_ins_journal;

      -- Récupération du prochain numéro de remise externe (pour les factures acceptées) :
      -- (Cas possible  de conflit d'attribution de numéro si plusieurs utilisateurs lancent un traitement insérant des infos dans la table remise_externe et
      -- risque de trou dans la numérotation s'il n'y a aucune facture acceptée pour les remises traitées.)

      --SDA Mantis 3988
      /*SELECT NVL (MAX (numremise), 0) + 1
        INTO l_remexp_accepte
        FROM remise_externe;*/

      select seq_numremise.nextval into l_remexp_accepte from dual;
      select seq_numremise.nextval into l_remexp_refuse from dual;

      --l_remexp_refuse := l_remexp_accepte + 1;

      -- On prend toutes les remises de factures en cours
      -- qui n'ont pas été déjà constituées en bordereaux
      FOR encours IN
/*         (SELECT   numremise_import
              FROM suivi_fact_tpe s
             WHERE codevefac = 10
               AND numremise_import NOT IN (
                      SELECT   numremise_import
                          FROM suivi_fact_tpe
                         WHERE numremise_import = s.numremise_import
                           AND (codevefac = 35 OR codevefac = 40)
                      GROUP BY numremise_import)
          GROUP BY numremise_import)
*/
/*ABO 16/12/2014 optimisation du traitement,curseur prenant toutes les remises TPE, on prend donc uniquement celles importées depuis 30 jours. le délai de traitement étant de 3j*/
           ( SELECT distinct numremise numremise_import FROM porte_remise 
		     WHERE numporte =i_numporte 
			 AND dateremise >sysdate -30)
      LOOP   

         FOR valide IN
            (SELECT DISTINCT numremise
                        FROM sinistre_porte
                       WHERE numremise = encours.numremise_import
                         AND NOT EXISTS (
                                SELECT NULL
                                  FROM sinistre_porte
                                 WHERE numremise = encours.numremise_import
                                   AND etat = 2))
         LOOP
            -- Récupération du numéro de porte (puisqu'il n'est pas passé à la procédure...)
          /*  SELECT DISTINCT (b.numporte)
                       INTO l_porte
                       FROM suivi_fact_tpe a, porte_remise b
                      WHERE b.numremise = valide.numremise
                        AND a.numremise_import = b.numremise;*/
          l_porte:=i_numporte;
--------------------------------------------------------------
-- Constitution du bordereau d'ACCEPTATION
--------------------------------------------------------------
            INSERT INTO suivi_fact_tpe
                        (codadeli, numfact, numremise_import,
                         numremise_export, datfact, codbenefinsee,
                         codbenefcle, datnaibenef, rangbenef, codtypfact,
                         datreceptor, datlimiamc, numcompos, codamcdet,
                         idcptebq, reffin, typavireg, codevefac, idfactpe,
                         montant,complt_titre)
               (SELECT codadeli, numfact, numremise_import, l_remexp_accepte,
                       datfact, codbenefinsee, codbenefcle, datnaibenef,
                       rangbenef, codtypfact, datreceptor, datlimiamc,
                       numcompos, codamcdet, idcptebq, reffin, typavireg, 40,
                       idfactpe, montant,complt_titre
                  FROM suivi_fact_tpe s
                 WHERE NOT EXISTS (
                          SELECT NULL
                            FROM suivi_fact_tpe
                           WHERE idfactpe = s.idfactpe
                             AND numremise_import = s.numremise_import
                             AND (codevefac = 30 OR codevefac = 40))
                   AND s.numremise_import = valide.numremise
                   AND s.codevefac = 10);
            --
            IF SQL%FOUND
            THEN
               UPDATE sinistre_porte
                  SET codevefac = 40
                WHERE codevefac = 10 AND numremise = valide.numremise;
            END IF;

----------------------------------------------------
-- Constitution du bordereau de REJET --
----------------------------------------------------
            INSERT INTO suivi_fact_tpe
                        (codadeli, numfact, numremise_import,
                         numremise_export, datfact, codbenefinsee,
                         codbenefcle, datnaibenef, rangbenef, codtypfact,
                         datreceptor, datlimiamc, numcompos, codamcdet,
                         idcptebq, reffin, typavireg, codevefac, idfactpe,
                         montant,complt_titre)
               (SELECT codadeli, numfact, numremise_import, l_remexp_refuse,
                       datfact, codbenefinsee, codbenefcle, datnaibenef,
                       rangbenef, codtypfact, datreceptor, datlimiamc,
                       numcompos, codamcdet, idcptebq, reffin, typavireg, 35,
                       idfactpe, montant,complt_titre
                  FROM suivi_fact_tpe s
                 WHERE NOT EXISTS (
                          SELECT NULL
                            FROM suivi_fact_tpe
                           WHERE idfactpe = s.idfactpe
                             AND numremise_import = s.numremise_import
                             AND codevefac = 35)
                   AND s.numremise_import = valide.numremise
                   AND s.codevefac = 30);
             --
            --14/08/2007 CTT  : La procédure p_sinistre_accepte est appelée en fin d'importation des paiements dans le but de récupérer les informations
            --           des prestations contrôlées et éventuellement modifiées  (numsin,numindiv,numassu).
            --           Les factures refusées pouvant contenir des prestations validées lors du processus de contrôle (codevefac à 40)  et afin,
            --           d' éviter tout risque de doublons lors du contrôle, le codevefac de chaque sinistre des factures rejetées est remis à 35.
            IF SQL%FOUND
            THEN
               UPDATE sinistre_porte
                  SET codevefac = 35
                WHERE numremise = valide.numremise
                  AND (idfactpe, numfact) IN (
                         SELECT idfactpe, numfact
                           FROM suivi_fact_tpe
                          WHERE numremise_import = valide.numremise
                            AND codevefac = 35);
            END IF;
         --
         END LOOP;                            -- remises entièrement calculées

         --
         -- Information sur les remises pas encore calculées (mÛme partiellement)
         --
         FOR nonvalide IN (SELECT DISTINCT numremise
                                      FROM sinistre_porte
                                     WHERE numremise =
                                                      encours.numremise_import
                                       AND EXISTS (
                                              SELECT NULL
                                                FROM sinistre_porte
                                               WHERE numremise =
                                                        encours.numremise_import
                                                 AND etat = 2))
         LOOP
            g_niv_msg := 1;
            g_msg_adm :=
                  'Remise import '
               || TO_CHAR (nonvalide.numremise)
               || ' non validée';
            p_ins_journal;
         END LOOP;
      END LOOP;                        -- Toutes les remises factures en cours

------------------------------------------------------------
-- traitement de FIN des factures ACCEPTEES
------------------------------------------------------------
   -- nb remises import
      SELECT COUNT (DISTINCT (numremise_import))
        INTO l_count
        FROM suivi_fact_tpe
       WHERE numremise_export = l_remexp_accepte;

      --
      IF (l_count > 0)
      THEN
         INSERT INTO remise_externe
                     (numremise, date_remise, numporte, nombre, batch,
                      valide, numutil, datedit, datvalide, date_trans, nature
                     )
              VALUES (l_remexp_accepte, SYSDATE, l_porte, l_count, NULL,
                      'N', NULL, SYSDATE, NULL, NULL, '4'
                     );
      END IF;

      --
      g_msg_adm :=
            'Remise export '
         || TO_CHAR (l_remexp_accepte)
         || ' : '
         || TO_CHAR (l_count)
         || ' remise(s) d''import';
      p_ins_journal;

      -- nb rfactures acceptées
      SELECT COUNT (numremise_import)
        INTO l_count
        FROM suivi_fact_tpe
       WHERE numremise_export = l_remexp_accepte;

      --
      g_msg_adm :=
         '               ==> ' || TO_CHAR (l_count)
         || ' facture(s) acceptée(s)';
      p_ins_journal;

----------------------------------------------------------
-- traitement de FIN des factures REFUSEES
----------------------------------------------------------
      SELECT COUNT (DISTINCT (numremise_import))
        INTO l_count
        FROM suivi_fact_tpe
       WHERE numremise_export = l_remexp_refuse;

      --
      IF (l_count > 0)
      THEN
         INSERT INTO remise_externe
                     (numremise, date_remise, numporte, nombre, batch,
                      valide, numutil, datedit, datvalide, date_trans, nature
                     )
              VALUES (l_remexp_refuse, SYSDATE, l_porte, l_count, NULL,
                      'N', NULL, SYSDATE, NULL, NULL, '5'
                     );
      END IF;

      --
      g_msg_adm :=
            'Remise export '
         || TO_CHAR (l_remexp_refuse)
         || ' : '
         || TO_CHAR (l_count)
         || ' remise(s) d''import';
      p_ins_journal;

      --
         -- nb rfactures refusées
      SELECT COUNT (numremise_import)
        INTO l_count
        FROM suivi_fact_tpe
       WHERE numremise_export = l_remexp_refuse;

      --
      g_msg_adm :=
         '               ==> ' || TO_CHAR (l_count)
         || ' facture(s) refusée(s)';
      p_ins_journal;
      --
      g_msg_adm :=
            'Fin Normale du traitement le '
         || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
      p_ins_journal;
      COMMIT;
   --
   END p_const_bord;

-- ******************************************************************************************************
   PROCEDURE p_annul_const_bord (
      i_numremise    IN   remise_externe.numremise%TYPE,
      i_nature_exp   IN   remise_externe.nature%TYPE,
      i_session      IN   NUMBER DEFAULT 1,
      i_niv_msg      IN   NUMBER DEFAULT 1
   )
/*
   Projet : Tiers payant etendu TPE
   Permet d'annuler les bordereaux d'acceptation et de rejet
   20/09/2005  W.ROUVRAY
   07/12/2005  CTT : Annulation ciblée sur la nature de la remise : acceptation (4) ou rejet (5)
   21/06/2006 CTT :  L'état 20 est un état éphémère, l'état normal d'une facture potentiellement
              acceptée est 10 (fiche : 425).
*/
   IS
   BEGIN
      g_nom_traitement := g_prefixe || 'P_Annul_Const_Bord';
      g_max_msg := i_niv_msg;
      g_session := i_session;
      g_idligne := f_max_idligne (i_session => g_session);
      g_niv_msg := 1;
      g_msg_adm :=
         'Début du traitement le ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
      p_ins_journal;

      --
      IF i_nature_exp = '4'
      THEN
         UPDATE sinistre_porte s
            SET s.codevefac = 10
          WHERE EXISTS (
                   SELECT NULL
                     FROM suivi_fact_tpe
                    WHERE numremise_import = s.numremise
                      AND idfactpe = s.idfactpe
                      AND numremise_export = i_numremise)
            AND s.codevefac = 40;

         --
         g_msg_adm :=
               'Bordereau exportation '
            || TO_CHAR (i_numremise)
            || ' annulé pour  '
            || TO_CHAR (SQL%ROWCOUNT)
            || ' factures acceptées ';
         p_ins_journal;
      --
      ELSIF i_nature_exp = '5'
      THEN
         UPDATE sinistre_porte s
            SET s.codevefac = 30
          WHERE EXISTS (
                   SELECT NULL
                     FROM suivi_fact_tpe
                    WHERE numremise_import = s.numremise
                      AND idfactpe = s.idfactpe
                      AND numremise_export = i_numremise)
            AND s.codevefac = 35;

         --
         g_msg_adm :=
               'Bordereau exportation '
            || TO_CHAR (i_numremise)
            || ' annulé pour  '
            || TO_CHAR (SQL%ROWCOUNT)
            || ' factures rejetées ';
         p_ins_journal;
      --
      ELSE
         --
         g_msg_adm :=
               'Nature de bordereau export '
            || i_nature_exp
            || ' incompatible avec le traitement';
         p_ins_journal;
      --
      END IF;

      --
      IF i_nature_exp = '4' OR i_nature_exp = '5'
      THEN
         DELETE      suivi_fact_tpe
               WHERE numremise_export = i_numremise;

         --
         DELETE      remise_externe
               WHERE numremise = i_numremise;
      END IF;

      --
      g_msg_adm :=
            'Fin du traitement le ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
      p_ins_journal;
   --COMMIT;
   END p_annul_const_bord;

-- ******************************************************************************************************
   PROCEDURE p_export_acc_rej (
      i_traitement   IN   VARCHAR2,
      i_remise_exp   IN   stock_entite.numremise%TYPE,
      i_nature_exp   IN   VARCHAR2,
      i_repertoire   IN   VARCHAR2 DEFAULT NULL,
      i_fichier      IN   VARCHAR2 DEFAULT NULL,
      i_session      IN   NUMBER DEFAULT 1,
      i_niv_msg      IN   NUMBER DEFAULT 1
   )
/*
   Projet : Tiers payant etendu TPE
   Permet de generer un fichier acceptation ou un fichier rejet apres identification factures rejetees
   18/08/2005  W.ROUVRAY
*/
   IS
      f_sortie              UTL_FILE.file_type;
      e_i_repertoire_vide   EXCEPTION;
--  e_I_fichier_vide EXCEPTION;
--  G_msg_adm  journal_adm.msg_adm%TYPE;
/*  VCR ORA-29285 : erreur d'écriture sur le fichier
  l_buffer VARCHAR2(1500);
  l_buffer_1019 VARCHAR2(1019); */
      l_buffer              VARCHAR2 (32767);
      l_buffer_1019         VARCHAR2 (32767);
      l_longueur_chaine     PLS_INTEGER;
      l_count_line          PLS_INTEGER;
      l_total_line          PLS_INTEGER;
      l_count_010           PLS_INTEGER;
      l_count_070           PLS_INTEGER;
      l_count_110           PLS_INTEGER;
      l_count_127           PLS_INTEGER;
      l_count_025           PLS_INTEGER;
      l_count_045           PLS_INTEGER;
      l_count_100           PLS_INTEGER;
      l_count_150           PLS_INTEGER;
      l_count_080           PLS_INTEGER;
      l_count_99            PLS_INTEGER;
      l_ordre               stock_entite.ordre%TYPE;
      l_ordre_fin           stock_entite.ordre%TYPE;
      l_true                PLS_INTEGER;
      l_070                 VARCHAR2 (12);
      l_110                 VARCHAR2 (88);
      l_120                 VARCHAR2 (57);
      l_040                 VARCHAR2 (21);
      l_150                 VARCHAR2 (8);
      l_080                 VARCHAR2 (15);
      l_100                 VARCHAR2 (15);
      l_160                 VARCHAR2 (23);
      l_290                 VARCHAR2 (98);
      l_repertoire          VARCHAR2 (50);

      PROCEDURE cherche_ordre (
         p_ordre_in       IN   stock_entite.ordre%TYPE,
         p_niv_in         IN   VARCHAR2,
         p_numremise_in   IN   stock_entite.numremise%TYPE
      )
      /*
         Projet : Tiers payant etendu TPE
         Permet de recuperer l'ordre de la prochaine entite 990
         18/08/2005  W.ROUVRAY
      */
      IS
      BEGIN
         SELECT MIN (ordre)
           INTO l_ordre
           FROM stock_entite
          --WHERE ROWNUM = 1
         WHERE  ordre > p_ordre_in
            AND SUBSTR (entite, 4, 2) = p_niv_in
            AND cod_entite = '990'
            AND numremise = p_numremise_in;
      --ORDER BY ordre;
      END cherche_ordre;

      PROCEDURE formatage_900 (p_buffer_in IN VARCHAR2)
      /*
         Projet : Tiers payant etendu TPE
         Permet d'ecrire dans le fichier de rejet
         18/08/2005  W.ROUVRAY
      */
      IS
      BEGIN
         l_buffer_1019 := l_buffer;
         l_buffer := l_buffer || p_buffer_in;
         l_longueur_chaine := LENGTH (l_buffer);

          -- Version Oracle7.3.4 fournit un package UTL_FILE qui met 1023 caracteres maximum sur 1 ligne
         -- Ctt 07/11/2007 Mail  06/11/07 Véronique Massé sur erreur retour fichier factures acceptées
         IF l_longueur_chaine = 1019
         THEN
            --UTL_FILE.PUT_LINE ( f_sortie, '1023'||l_buffer );
            UTL_FILE.put_line (f_sortie,
                                  LPAD (TO_CHAR (LENGTH (l_buffer)), 4, '0')
                               || l_buffer
                              );
            l_count_line := l_count_line + 1;
            l_buffer := NULL;
         ELSIF l_longueur_chaine > 1019
         THEN
            UTL_FILE.put_line (f_sortie,
                                  LPAD (TO_CHAR (LENGTH (l_buffer_1019)),
                                        4,
                                        '0'
                                       )
                               || l_buffer_1019
                              );
            l_count_line := l_count_line + 1;
            l_buffer := p_buffer_in;
         END IF;
      END formatage_900;

      PROCEDURE recalcul_cumuls (
         p_numremise_in   IN   stock_entite.numremise%TYPE
      )
      --Permet de recalculer les cumuls des entites 990 et 999 apres rejet de factures
      IS

          
          CURSOR C_existStock (i_idfactpe IN stock_entite.group_rejet%TYPE,
                               i_borne_ordre IN stock_entite.ordre%TYPE,
                               i_borne_prec IN stock_entite.ordre%TYPE) IS
          SELECT ordre
          FROM stock_entite
          WHERE group_rejet = i_idfactpe AND ordre < i_borne_ordre AND ordre > i_borne_prec;

          Rec_C_existStock C_existStock%ROWTYPE;
          i_present        NUMBER (1);
          

         l_cumul        NUMBER (11);
         l_ordre1       stock_entite.ordre%TYPE;
         l_niv          VARCHAR2 (2);
         l_borne_prec   stock_entite.ordre%TYPE;
      BEGIN
         l_borne_prec := 0;

         FOR borne IN (SELECT   ordre
                           FROM stock_entite
                          WHERE cod_entite = '999'
                            AND numremise = p_numremise_in
                       ORDER BY ordre)
         -- CTT 14/11/2005 : Utilisation de l'identifiant unique IDFACTPE
         -- CTT 01/12/2005 : fiche 380.6 : le cumul du montant des actes des factures rejetées n'est plus divisée par 100
         --                  (l_cumul number (11,0))
         LOOP
            BEGIN
            /* PHA 16/05/2012
               FOR rec IN (SELECT s.idfactpe
                             FROM suivi_fact_tpe s
                            WHERE EXISTS (
                                     SELECT NULL
                                       FROM stock_entite
                                      WHERE group_rejet = s.idfactpe
                                        AND ordre < borne.ordre
                                        AND ordre > l_borne_prec)
                              AND s.codevefac = 35
                              AND s.numremise_import = p_numremise_in)
                              */
               FOR rec IN (SELECT s.idfactpe
                       FROM suivi_fact_tpe s
                      WHERE s.codevefac = 35
                        AND s.numremise_import = p_numremise_in)
               LOOP
                 
                  i_present := 0;
                  OPEN C_existStock(rec.idfactpe, borne.ordre, l_borne_prec);

                  FETCH C_existStock
                         INTO Rec_C_existStock;
                  --
                  IF (C_existStock%NOTFOUND) THEN
                      i_present := 0;
                      CLOSE C_existStock;
                  ELSE
                      i_present := 1;
                      CLOSE C_existStock;
                  END IF;
                  IF i_present = 1 THEN
                   
                    SELECT SUM (TO_NUMBER (SUBSTR (entite, 107, 8)))
                      INTO l_cumul
                      FROM stock_entite
                     WHERE cod_entite = '255'
                       AND group_rejet = rec.idfactpe
                       AND numremise = p_numremise_in;

                    SELECT MIN (ordre)
                      INTO l_ordre1
                      FROM stock_entite
                     --WHERE ROWNUM = 1
                    WHERE  cod_entite = '255'
                       AND group_rejet = rec.idfactpe
                       AND numremise = p_numremise_in;

                    FOR i IN 1 .. 6
                    LOOP
                       DECLARE
                          l_ordre2   stock_entite.ordre%TYPE;
                       BEGIN
                          SELECT MIN (ordre)
                            INTO l_ordre2
                            FROM stock_entite
                           --WHERE ROWNUM = 1
                          WHERE  ordre > l_ordre1
                             AND ordre < borne.ordre
                             AND SUBSTR (entite, 4, 2) =
                                                      LPAD (TO_CHAR (i), 2, '0')
                             AND cod_entite = '990'
                             AND numremise = p_numremise_in;

                          --ORDER BY ordre;
                          UPDATE stock_entite
                             SET entite =
                                       SUBSTR (entite, 1, 30)
                                    || LPAD
                                          (TO_CHAR (  TO_NUMBER (SUBSTR (entite,
                                                                         31,
                                                                         11
                                                                        )
                                                                )
                                                    - l_cumul
                                                   ),
                                           11,
                                           '0'
                                          )
                                    || SUBSTR (entite, 42, 2)
                           WHERE ordre = l_ordre2 AND numremise = p_numremise_in;
                       EXCEPTION
                          WHEN INVALID_NUMBER
                          THEN
                             g_msg_adm :=
                                   'PROCEDURE recalcul_cumuls INVALID_NUMBER : Paramètre p_numremise_in = '
                                || TO_CHAR (p_numremise_in);
                             pk_trace.p_ins_journal_adm
                                                 ('pk_tpe_687.p_export_acc_rej',
                                                  1,
                                                  0,
                                                  g_msg_adm,
                                                  SYSDATE,
                                                  0
                                                 );
                       END;
                    END LOOP;

                    BEGIN
                       UPDATE stock_entite
                          SET entite =
                                    SUBSTR (entite, 1, 85)
                                 || LPAD (TO_CHAR (  TO_NUMBER (SUBSTR (entite,
                                                                        86,
                                                                        11
                                                                       )
                                                               )
                                                   - l_cumul
                                                  ),
                                          11,
                                          '0'
                                         )
                                 || SUBSTR (entite, 97, 32)
                        WHERE ordre = borne.ordre AND numremise = p_numremise_in;
                    EXCEPTION
                       WHEN INVALID_NUMBER
                       THEN
                          g_msg_adm :=
                                'PROCEDURE recalcul_cumuls INVALID_NUMBER : Paramètre p_numremise_in = '
                             || TO_CHAR (p_numremise_in);
                          pk_trace.p_ins_journal_adm
                                                 ('pk_tpe_687.p_export_acc_rej',
                                                  1,
                                                  0,
                                                  g_msg_adm,
                                                  SYSDATE,
                                                  0
                                                 );
                    END;
                 
                  END IF;
                 
               END LOOP;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  g_msg_adm :=
                        'PROCEDURE recalcul_cumuls NO_DATA_FOUND : Paramètre p_numremise_in = '
                     || TO_CHAR (p_numremise_in);
                  pk_trace.p_ins_journal_adm ('pk_tpe_687.p_export_acc_rej',
                                              1,
                                              0,
                                              g_msg_adm,
                                              SYSDATE,
                                              0
                                             );
            END;

            l_borne_prec := borne.ordre;
         END LOOP;
      END recalcul_cumuls;
--
-- Procedure principale p_export_acc_rej
--
   BEGIN
      g_nom_traitement := g_prefixe || 'P_export_acc_rej';
      g_max_msg := i_niv_msg;
      g_session := i_session;
      g_idligne := f_max_idligne (i_session => g_session);
      g_niv_msg := 1;
      g_msg_adm :=
         'Début du traitement le ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
      p_ins_journal;
      g_msg_adm :=
            'Paramètres Traitement :<'
         || i_traitement
         || '> Fic :< '
         || i_session
         || '> N¦ Rem:< '
         || TO_CHAR (i_remise_exp)
         || '> Nature:< '
         || i_nature_exp
         || '>';
      p_ins_journal;

      --
      -- Si repertoire ou fichier de sortie non precise alors le traitement s'arrete
      --
      IF i_repertoire IS NULL
      THEN
         RAISE e_i_repertoire_vide;
      END IF;

      --
      g_fichier := i_fichier;
      --
       -- Formatage du nom de fichier
      p_nom_fichier;
      --
      -- Creation fichier
      f_sortie := UTL_FILE.fopen (i_repertoire, g_fichier, 'w', 32767);

      -- traitement de l'acceptation
      --
      IF i_nature_exp = '4'
      THEN
          -- VCR : 09/01/2007
         -- Initialisation de la variable 'l_total_line' avant le LOOP :
         l_total_line := 0;

         --
         FOR rec_40 IN
            (SELECT DISTINCT numremise_import
                    -- On prend toutes les importations du bordereau concerne
                        FROM suivi_fact_tpe
                       WHERE codevefac = 40
                         AND numremise_export = i_remise_exp)
         LOOP
            recalcul_cumuls (rec_40.numremise_import);
                -- Procedure locale, appelee uniquement lors de l'acceptation
            l_ordre_fin := 0;
            l_count_line := 0;
            l_count_010 := 0;
            l_count_070 := 0;
            l_count_110 := 0;
            l_count_127 := 0;
            l_count_025 := 0;
            l_count_045 := 0;
            l_count_99 := 0;

            --
            -- On recupere les infos, dans la table stock_entite, qui correspondent aux factures acceptees
            --
            -- CTT 14/11/2005 : Utilisation de l'identifiant unique IDFACTPE
            FOR rec IN (SELECT   a.entite, a.cod_entite, a.ordre
                            FROM stock_entite a
                           WHERE (   EXISTS (
                                        SELECT NULL
                                          FROM suivi_fact_tpe
                                         WHERE idfactpe = a.group_rejet
                                           AND codevefac = 40
                                           AND numremise_import =
                                                       rec_40.numremise_import)
                                  OR a.group_rejet IS NULL
                                 )
                             AND a.numremise = rec_40.numremise_import
                        ORDER BY a.ordre)
            LOOP
               --
               -- On recupere le prochain ordre correspondant a une entite 990 selon le niveau, ce qui va servir,
               -- par la suite, a determiner les niveaux superieurs qui n'ont pas de factures acceptees associees
               --
               IF rec.cod_entite = '000'
               THEN
                  SELECT MIN (ordre)
                    INTO l_ordre
                    FROM stock_entite
                   --WHERE ROWNUM = 1
                  WHERE  ordre > rec.ordre
                     AND cod_entite = '999'
                     AND numremise = rec_40.numremise_import;
               --ORDER BY ordre;
               ELSIF rec.cod_entite = '010'
               THEN
                  cherche_ordre (rec.ordre, '01', rec_40.numremise_import);
               ELSIF rec.cod_entite = '070'
               THEN
                  cherche_ordre (rec.ordre, '02', rec_40.numremise_import);
               ELSIF rec.cod_entite = '110'
               THEN
                  cherche_ordre (rec.ordre, '03', rec_40.numremise_import);
               ELSIF rec.cod_entite = '127'
               THEN
                  cherche_ordre (rec.ordre, '04', rec_40.numremise_import);
               ELSIF rec.cod_entite = '025'
               THEN
                  cherche_ordre (rec.ordre, '05', rec_40.numremise_import);
               ELSIF rec.cod_entite = '045'
               THEN
                  cherche_ordre (rec.ordre, '06', rec_40.numremise_import);
               ELSE
                  l_true := 0;
                  l_ordre := 0;
               END IF;

                 --
                 -- Permet de ne pas prendre en compte les niveaux superieurs qui n'ont plus de factures associees
                 --
               -- CTT 14/11/2005 : Utilisation de l'identifiant unique IDFACTPE
               IF l_ordre > l_ordre_fin
               THEN
                  BEGIN
                     SELECT 1
                       INTO l_true
                       FROM stock_entite a
                      WHERE (   EXISTS (
                                   SELECT NULL
                                     FROM suivi_fact_tpe
                                    WHERE idfactpe = a.group_rejet
                                      AND codevefac = 40
                                      AND numremise_import =
                                                       rec_40.numremise_import)
                             OR a.group_rejet IS NULL
                            )
                        AND cod_entite = '100'
                        AND ordre > rec.ordre
                        AND ordre < l_ordre
                        AND a.numremise = rec_40.numremise_import;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        l_ordre_fin := l_ordre;
                        l_true := 0;
                     WHEN TOO_MANY_ROWS
                     THEN
                        l_true := 1;
                  END;
               END IF;

               --
               -- A partir de maintenant, on ecrit dans le fichier uniquement les factures acceptees et
               -- leurs niveaux superieurs associes
               --
               IF l_true = 1 OR (l_true = 0 AND rec.ordre > l_ordre_fin)
               THEN
                  IF rec.cod_entite = '000'
                  THEN
--CTT 04/11/2005 ano cgrcr 380
            --UTL_FILE.PUT_LINE ( f_sortie, '0128'||rec.entite );
            --En attendant le traitement relatif à l'identifiant des comptes bancaires on force le n¦ ordre à 1 (pos 120)
                     UTL_FILE.put_line (f_sortie,
                                           '0128000OC'
                                        || LPAD (LTRIM (SUBSTR (rec.entite,
                                                                28,
                                                                20
                                                               )
                                                       ),
                                                 20,
                                                 '0'
                                                )
                                        || 'CS'
                                        || LPAD (LTRIM (SUBSTR (rec.entite,
                                                                6,
                                                                20
                                                               )
                                                       ),
                                                 20,
                                                 '0'
                                                )
                                        || SUBSTR (rec.entite, 48, 8)
                                        || TO_CHAR (SYSDATE, 'DDMMYY')
                                        || '687 '
                                        || SUBSTR (rec.entite, 66, 55)
                                        || '1'
                                        || SUBSTR (rec.entite, 122, 7)
                                       );
--CTT 22/11/2005 fiche Cgrcr 380 ano sur correctif : décalage de 1 caract. à partir de 122
                     l_count_line := l_count_line + 1;
                           -- On compte le nbre de lignes physiques du fichier
                  ELSIF rec.cod_entite = '999'
                  THEN
                     IF l_buffer IS NOT NULL
                     THEN
                        UTL_FILE.put_line (f_sortie,
                                              LPAD (TO_CHAR (LENGTH (l_buffer)),
                                                    4,
                                                    '0'
                                                   )
                                           || l_buffer
                                          );
                        l_count_line := l_count_line + 1;
                        l_buffer := NULL;
                     END IF;

                     l_count_line := l_count_line + 1;
--CTT 04/11/2005 ano cgrcr 380
--            UTL_FILE.PUT_LINE ( f_sortie, '0128'||SUBSTR ( rec.entite, 1, 55 )||
--                                          LPAD ( TO_CHAR ( l_count_line ), 8, '0' )||
--                                          SUBSTR ( rec.entite, 64, 19 )||
--                                          LPAD ( TO_CHAR ( l_count_010 ), 3, '0' )||
--                                          SUBSTR ( rec.entite, 86, 43 ) );
                     UTL_FILE.put_line (f_sortie,
                                           '0128999OC'
                                        || LPAD (LTRIM (SUBSTR (rec.entite,
                                                                28,
                                                                20
                                                               )
                                                       ),
                                                 20,
                                                 '0'
                                                )
                                        || 'CS'
                                        || LPAD (LTRIM (SUBSTR (rec.entite,
                                                                6,
                                                                20
                                                               )
                                                       ),
                                                 20,
                                                 '0'
                                                )
                                        || SUBSTR (rec.entite, 48, 8)
                                        || LPAD (TO_CHAR (l_count_line),
                                                 8,
                                                 '0'
                                                )
                                        || SUBSTR (rec.entite, 64, 19)
                                        || LPAD (TO_CHAR (l_count_010), 3,
                                                 '0')
                                        || SUBSTR (rec.entite, 86, 43)
                                       );
                     l_total_line := l_total_line + l_count_line;
                     l_count_line := 0;
                     l_count_010 := 0;
                  ELSE
                     IF rec.cod_entite = '010'
                     THEN
                        l_count_010 := l_count_010 + 1;
-- On compte le nbre d'entites de niveau 01           ELSIF rec.cod_entite = '070' THEN
                        l_count_070 := l_count_070 + 1;
                           -- On compte le nbre d'entites de niveau inferieur
                     ELSIF rec.cod_entite = '110'
                     THEN
                        l_count_110 := l_count_110 + 1;
                     ELSIF rec.cod_entite = '127'
                     THEN
                        l_count_127 := l_count_127 + 1;
                     ELSIF rec.cod_entite = '025'
                     THEN
                        l_count_025 := l_count_025 + 1;
                     ELSIF rec.cod_entite = '045'
                     THEN
                        l_count_045 := l_count_045 + 1;
                     ELSIF rec.cod_entite = '990'
                     THEN
                    -- On reecrit les entites 990 differemment selon le niveau
                        IF SUBSTR (rec.entite, 4, 2) = '06'
                        THEN
                           rec.entite :=
                                 SUBSTR (rec.entite, 1, 22)
                              || LPAD (TO_CHAR (l_count_99), 8, '0')
                              || SUBSTR (rec.entite, 31, 13);
                           l_count_99 := 0;
                        ELSIF SUBSTR (rec.entite, 4, 2) = '05'
                        THEN
                           rec.entite :=
                                 SUBSTR (rec.entite, 1, 22)
                              || LPAD (TO_CHAR (l_count_045), 8, '0')
                              || SUBSTR (rec.entite, 31, 13);
                           l_count_045 := 0;
                        ELSIF SUBSTR (rec.entite, 4, 2) = '04'
                        THEN
                           rec.entite :=
                                 SUBSTR (rec.entite, 1, 22)
                              || LPAD (TO_CHAR (l_count_025), 8, '0')
                              || SUBSTR (rec.entite, 31, 13);
                           l_count_025 := 0;
                        ELSIF SUBSTR (rec.entite, 4, 2) = '03'
                        THEN
                           rec.entite :=
                                 SUBSTR (rec.entite, 1, 22)
                              || LPAD (TO_CHAR (l_count_127), 8, '0')
                              || SUBSTR (rec.entite, 31, 13);
                           l_count_127 := 0;
                        ELSIF SUBSTR (rec.entite, 4, 2) = '02'
                        THEN
                           rec.entite :=
                                 SUBSTR (rec.entite, 1, 22)
                              || LPAD (TO_CHAR (l_count_110), 8, '0')
                              || SUBSTR (rec.entite, 31, 13);
                           l_count_110 := 0;
                        ELSIF SUBSTR (rec.entite, 4, 2) = '01'
                        THEN
                           rec.entite :=
                                 SUBSTR (rec.entite, 1, 22)
                              || LPAD (TO_CHAR (l_count_070), 8, '0')
                              || SUBSTR (rec.entite, 31, 13);
                           l_count_070 := 0;
                        END IF;
                     ELSE
                        l_count_99 := l_count_99 + 1;
                     END IF;

                     --
                     -- Permet d'ecrire dans le fichier d'acceptation
                     --
                     l_buffer_1019 := l_buffer;
                     l_buffer := l_buffer || rec.entite;
                     l_longueur_chaine := LENGTH (l_buffer);

                        -- Version Oracle7.3.4 fournit un package UTL_FILE qui met 1023 caracteres maximum sur 1 ligne
                     -- Ctt 07/11/2007 Mail  06/11/07 Véronique Massé sur erreur retour fichier factures acceptées
                     IF l_longueur_chaine = 1019
                     THEN
                        --UTL_FILE.PUT_LINE ( f_sortie, '1023'||l_buffer );
                        UTL_FILE.put_line (f_sortie,
                                              LPAD (TO_CHAR (LENGTH (l_buffer)),
                                                    4,
                                                    '0'
                                                   )
                                           || l_buffer
                                          );
                        l_count_line := l_count_line + 1;
                        l_buffer := NULL;
                     ELSIF l_longueur_chaine > 1019
                     THEN
                        UTL_FILE.put_line
                                     (f_sortie,
                                         LPAD (TO_CHAR (LENGTH (l_buffer_1019)),
                                               4,
                                               '0'
                                              )
                                      || l_buffer_1019
                                     );
                        l_count_line := l_count_line + 1;
                        l_buffer := rec.entite;
                     END IF;
                  END IF;
               END IF;
            END LOOP;

            --
            l_total_line := l_total_line + l_count_line;
         --
         END LOOP;

         --
         -- CTT 01/12/2005 : Fiche 391 : Mise à jour de la date de transmission
         UPDATE remise_externe
            SET date_trans = TRUNC (SYSDATE)
          WHERE numremise = i_remise_exp;

         --
         g_msg_adm :=
               'Fichier acceptations '
            || g_fichier
            || ' crée ('
            || TO_CHAR (l_total_line)
            || ' lignes)';
         p_ins_journal;
       --
      --
      -- traitement rejet
      --
      ELSIF i_nature_exp = '5'
      THEN
          -- VCR : 09/01/2007
         -- Initialisation de la variable 'l_total_line' avant le LOOP :
         l_total_line := 0;

         --
         FOR rec_45 IN
            (SELECT DISTINCT numremise_import
                    -- On prend toutes les importations du bordereau concerne
                        FROM suivi_fact_tpe
                       WHERE codevefac = 35
                         AND numremise_export = i_remise_exp)
         LOOP
            l_ordre_fin := 0;
            l_count_line := 0;
            l_count_010 := 0;
            l_count_070 := 0;
            l_count_99 := 0;
            l_count_100 := 0;
            l_count_150 := 0;
            l_count_080 := 0;
            l_buffer := NULL;

             --
             -- On recupere les infos, dans la table stock_entite, qui correspondent aux factures rejetees
             --
            -- CTT 14/11/2005 : Utilisation de l'identifiant unique IDFACTPE
            FOR rec IN (SELECT   a.entite, a.cod_entite, a.ordre, a.numsin
                            FROM stock_entite a
                           WHERE (   EXISTS (
                                        SELECT NULL
                                          FROM suivi_fact_tpe
                                         WHERE idfactpe = a.group_rejet
                                           AND codevefac = 35
                                           AND numremise_import =
                                                       rec_45.numremise_import)
                                  OR a.group_rejet IS NULL
                                 )
                             AND a.numremise = rec_45.numremise_import
                        ORDER BY a.ordre)
            LOOP
               --
               -- On recupere le prochain ordre correspondant a une entite 990 selon le niveau, ce qui va servir,
               -- par la suite, a determiner les niveaux superieurs qui n'ont pas de factures rejetees associees
               --
               IF rec.cod_entite = '000'
               THEN
                  SELECT MIN (ordre)
                    INTO l_ordre
                    FROM stock_entite
                   --WHERE ROWNUM = 1
                  WHERE  ordre > rec.ordre
                     AND cod_entite = '999'
                     AND numremise = rec_45.numremise_import;
               --ORDER BY ordre;
               ELSIF rec.cod_entite = '010'
               THEN
                  cherche_ordre (rec.ordre, '01', rec_45.numremise_import);
               ELSIF rec.cod_entite = '070'
               THEN
                  cherche_ordre (rec.ordre, '02', rec_45.numremise_import);
               ELSIF rec.cod_entite = '110'
               THEN
                  cherche_ordre (rec.ordre, '03', rec_45.numremise_import);
               ELSIF rec.cod_entite = '127'
               THEN
                  cherche_ordre (rec.ordre, '04', rec_45.numremise_import);
               ELSIF rec.cod_entite = '025'
               THEN
                  cherche_ordre (rec.ordre, '05', rec_45.numremise_import);
               ELSIF rec.cod_entite = '045'
               THEN
                  cherche_ordre (rec.ordre, '06', rec_45.numremise_import);
               ELSE
                  l_true := 0;
                  l_ordre := 0;
               END IF;

                 --
                 -- Permet de ne pas prendre en compte les niveaux superieurs qui n'ont plus de factures associees
                 --
               -- CTT 14/11/2005 : Utilisation de l'identifiant unique IDFACTPE
               IF l_ordre > l_ordre_fin
               THEN
                  BEGIN
                     SELECT 1
                       INTO l_true
                       FROM stock_entite a
                      WHERE (   EXISTS (
                                   SELECT NULL
                                     FROM suivi_fact_tpe
                                    WHERE idfactpe = a.group_rejet
                                      AND codevefac = 35
                                      AND numremise_import =
                                                       rec_45.numremise_import)
                             OR a.group_rejet IS NULL
                            )
                        AND a.cod_entite = '100'
                        AND a.ordre > rec.ordre
                        AND a.ordre < l_ordre
                        AND a.numremise = rec_45.numremise_import;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        l_ordre_fin := l_ordre;
                        l_true := 0;
                     WHEN TOO_MANY_ROWS
                     THEN
                        l_true := 1;
                  END;
               END IF;

               --
               -- A partir de maintenant, on ecrit dans le fichier uniquement les factures rejetees et
               -- leurs niveaux superieurs associes
               --
               IF l_true = 1 OR (l_true = 0 AND rec.ordre > l_ordre_fin)
               THEN
                  IF rec.cod_entite = '000'
                  THEN
--CTT 04/11/2005 ano cgrcr 380
--            UTL_FILE.PUT_LINE ( f_sortie, '0128'||
--                                          SUBSTR ( rec.entite, 1, 27 )||
--                                          LPAD ( LTRIM ( SUBSTR ( rec.entite, 28, 34 ) ), 34, '0' )||
--                                          '900 '||
--                                          SUBSTR ( rec.entite, 66, 37 )||
--                                          SUBSTR ( rec.entite, 103, 6 )||
--                                          SUBSTR ( rec.entite, 111, 6 )||
--                                          SUBSTR ( rec.entite, 119, 10 )||
--                                          '    ' );
--CTT 09/11/2005 Mise en phase avec document SINTIA Alimentation 900 Version 3.0
                     UTL_FILE.put_line (f_sortie,
                                           '0128000OC'
                                        || LPAD (LTRIM (SUBSTR (rec.entite,
                                                                28,
                                                                20
                                                               )
                                                       ),
                                                 20,
                                                 '0'
                                                )
                                        || 'CS'
                                        || LPAD (LTRIM (SUBSTR (rec.entite,
                                                                6,
                                                                20
                                                               )
                                                       ),
                                                 20,
                                                 '0'
                                                )
                                        || SUBSTR (rec.entite, 48, 8)
                                        || TO_CHAR (SYSDATE, 'DDMMYY')
                                        || '900 '
                                        || SUBSTR (rec.entite, 66, 37)
                                        || RPAD ('0', 8, '0')
                                        || RPAD ('0', 8, '0')
                                        || SUBSTR (rec.entite, 119, 10)
                                       );
                     l_count_line := l_count_line + 1;
                  ELSIF rec.cod_entite = '999'
                  THEN
                     l_040 := '0';
                     l_070 := NULL;
                     l_080 := NULL;
                     l_150 := NULL;
                     l_100 := NULL;
                     l_290 := NULL;

                     --
                     -- Lorsqu'on atteint l'entite 999, on ecrit dans le fichier de rejet les infos qu'on a precedemment
                     -- stockees dans la table stock_entite_norm_900 lorsqu'on a atteint l'entite 255
                     -- ( Voir le commentaire ins_stock_entite_norm_900 )
                     --
                     FOR rec_900 IN
                        (SELECT   ent_040, ent_070, ent_080, ent_150,
                                  ent_100, ent_110, ent_120, ent_160,
                                  ent_290
                             FROM stock_entite_norm_900
                            WHERE numremise = rec_45.numremise_import
                         ORDER BY ent_040,
                                  ent_070,
                                  ent_080,
                                  ent_150,
                                  ent_100,
                                  ent_290)             -- ordonne en norme 900
                     LOOP
                        IF rec_900.ent_040 != l_040
                        THEN
           -- Si l'entite 040 est differente de l'entite 040 precedente alors
                           IF l_040 != '0'
                           THEN
                   -- on l'ecrit, sinon on continue sur le prochain ELSIF ...
                              --
                              -- ... mais avant, on ecrit les entites 990 afin de boucler sur les niveaux
                              --
                              formatage_900 (   '99005'
                                             || SUBSTR (l_100, 6, 9)
                                             || '        '
                                             || LPAD (TO_CHAR (l_count_99),
                                                      8,
                                                      '0'
                                                     )
                                             || '00000000000P@'
                                            );
                              l_count_99 := 0;
                              formatage_900 (   '99004'
                                             || SUBSTR (l_150, 6, 2)
                                             || '               '
                                             || LPAD (TO_CHAR (l_count_100),
                                                      8,
                                                      '0'
                                                     )
                                             || '00000000000P@'
                                            );
                              l_count_100 := 0;
                              formatage_900 (   '99003'
                                             || SUBSTR (l_080, 6, 9)
                                             || '        '
                                             || LPAD (TO_CHAR (l_count_150),
                                                      8,
                                                      '0'
                                                     )
                                             || '00000000000P@'
                                            );
                              l_count_150 := 0;
                              formatage_900 (   '99002'
                                             || SUBSTR (l_070, 6, 6)
                                             || '           '
                                             || LPAD (TO_CHAR (l_count_080),
                                                      8,
                                                      '0'
                                                     )
                                             || '00000000000P@'
                                            );
                              l_count_080 := 0;
                              formatage_900 (   '99001'
                                             || SUBSTR (l_040, 6, 15)
                                             || '  '
                                             || LPAD (TO_CHAR (l_count_070),
                                                      8,
                                                      '0'
                                                     )
                                             || '00000000000P@'
                                            );
                              l_count_070 := 0;
                           END IF;

                           formatage_900 (rec_900.ent_040);
                                                      -- On ecrit l'entite 040
                           formatage_900 (rec_900.ent_070);
                           formatage_900 (rec_900.ent_080);
                           formatage_900 (rec_900.ent_150);
                           formatage_900 (rec_900.ent_100);
                           formatage_900 (rec_900.ent_110);
                           formatage_900 (rec_900.ent_120);
                           formatage_900 (rec_900.ent_160);
                           formatage_900 (rec_900.ent_290);
                           l_count_99 := l_count_99 + 2;
                           l_count_100 := l_count_100 + 1;
                           l_count_150 := l_count_150 + 1;
                           l_count_080 := l_count_080 + 1;
                           l_count_070 := l_count_070 + 1;
                           l_count_010 := l_count_010 + 1;
                        ELSIF rec_900.ent_070 != l_070
                        THEN                 -- Meme principe que precedemment
                           formatage_900 (   '99005'
                                          || SUBSTR (l_100, 6, 9)
                                          || '        '
                                          || LPAD (TO_CHAR (l_count_99),
                                                   8,
                                                   '0'
                                                  )
                                          || '00000000000P@'
                                         );
                           l_count_99 := 0;
                           formatage_900 (   '99004'
                                          || SUBSTR (l_150, 6, 2)
                                          || '               '
                                          || LPAD (TO_CHAR (l_count_100),
                                                   8,
                                                   '0'
                                                  )
                                          || '00000000000P@'
                                         );
                           l_count_100 := 0;
                           formatage_900 (   '99003'
                                          || SUBSTR (l_080, 6, 9)
                                          || '        '
                                          || LPAD (TO_CHAR (l_count_150),
                                                   8,
                                                   '0'
                                                  )
                                          || '00000000000P@'
                                         );
                           l_count_150 := 0;
                           formatage_900 (   '99002'
                                          || SUBSTR (l_070, 6, 6)
                                          || '           '
                                          || LPAD (TO_CHAR (l_count_080),
                                                   8,
                                                   '0'
                                                  )
                                          || '00000000000P@'
                                         );
                           l_count_080 := 0;
                           formatage_900 (rec_900.ent_070);
                           formatage_900 (rec_900.ent_080);
                           formatage_900 (rec_900.ent_150);
                           formatage_900 (rec_900.ent_100);
                           formatage_900 (rec_900.ent_110);
                           formatage_900 (rec_900.ent_120);
                           formatage_900 (rec_900.ent_160);
                           formatage_900 (rec_900.ent_290);
                           l_count_99 := l_count_99 + 2;
                           l_count_100 := l_count_100 + 1;
                           l_count_150 := l_count_150 + 1;
                           l_count_080 := l_count_080 + 1;
                           l_count_070 := l_count_070 + 1;
                        ELSIF rec_900.ent_080 != l_080
                        THEN
                           formatage_900 (   '99005'
                                          || SUBSTR (l_100, 6, 9)
                                          || '        '
                                          || LPAD (TO_CHAR (l_count_99),
                                                   8,
                                                   '0'
                                                  )
                                          || '00000000000P@'
                                         );
                           l_count_99 := 0;
                           formatage_900 (   '99004'
                                          || SUBSTR (l_150, 6, 2)
                                          || '               '
                                          || LPAD (TO_CHAR (l_count_100),
                                                   8,
                                                   '0'
                                                  )
                                          || '00000000000P@'
                                         );
                           l_count_100 := 0;
                           formatage_900 (   '99003'
                                          || SUBSTR (l_080, 6, 9)
                                          || '        '
                                          || LPAD (TO_CHAR (l_count_150),
                                                   8,
                                                   '0'
                                                  )
                                          || '00000000000P@'
                                         );
                           l_count_150 := 0;
                           formatage_900 (rec_900.ent_080);
                           formatage_900 (rec_900.ent_150);
                           formatage_900 (rec_900.ent_100);
                           formatage_900 (rec_900.ent_110);
                           formatage_900 (rec_900.ent_120);
                           formatage_900 (rec_900.ent_160);
                           formatage_900 (rec_900.ent_290);
                           l_count_99 := l_count_99 + 2;
                           l_count_100 := l_count_100 + 1;
                           l_count_150 := l_count_150 + 1;
                           l_count_080 := l_count_080 + 1;
                        ELSIF rec_900.ent_150 != l_150
                        THEN
                           formatage_900 (   '99005'
                                          || SUBSTR (l_100, 6, 9)
                                          || '        '
                                          || LPAD (TO_CHAR (l_count_99),
                                                   8,
                                                   '0'
                                                  )
                                          || '00000000000P@'
                                         );
                           l_count_99 := 0;
                           formatage_900 (   '99004'
                                          || SUBSTR (l_150, 6, 2)
                                          || '               '
                                          || LPAD (TO_CHAR (l_count_100),
                                                   8,
                                                   '0'
                                                  )
                                          || '00000000000P@'
                                         );
                           l_count_100 := 0;
                           formatage_900 (rec_900.ent_150);
                           formatage_900 (rec_900.ent_100);
                           formatage_900 (rec_900.ent_110);
                           formatage_900 (rec_900.ent_120);
                           formatage_900 (rec_900.ent_160);
                           formatage_900 (rec_900.ent_290);
                           l_count_99 := l_count_99 + 2;
                           l_count_100 := l_count_100 + 1;
                           l_count_150 := l_count_150 + 1;
                        ELSIF rec_900.ent_100 != l_100
                        THEN
                           formatage_900 (   '99005'
                                          || SUBSTR (l_100, 6, 9)
                                          || '        '
                                          || LPAD (TO_CHAR (l_count_99),
                                                   8,
                                                   '0'
                                                  )
                                          || '00000000000P@'
                                         );
                           l_count_99 := 0;
                           formatage_900 (rec_900.ent_100);
                           formatage_900 (rec_900.ent_110);
                           formatage_900 (rec_900.ent_120);
                           formatage_900 (rec_900.ent_160);
                           formatage_900 (rec_900.ent_290);
                           l_count_99 := l_count_99 + 2;
                           l_count_100 := l_count_100 + 1;
                        ELSIF rec_900.ent_290 != l_290
                        THEN
                           formatage_900 (rec_900.ent_290);
                           l_count_99 := l_count_99 + 1;
                        END IF;

                        l_040 := rec_900.ent_040;
                        l_070 := rec_900.ent_070;
                        l_080 := rec_900.ent_080;
                        l_150 := rec_900.ent_150;
                        l_100 := rec_900.ent_100;
                        l_290 := rec_900.ent_290;
                     END LOOP;

                     --
                     -- On purge cette table car les infos ont ete ecrites dans le fichier
                     --
                     DELETE      stock_entite_norm_900;

                     --
                     -- On ecrit les derniers 990 pour clore le fichier logique
                     --
                     formatage_900 (   '99005'
                                    || SUBSTR (l_100, 6, 9)
                                    || '        '
                                    || LPAD (TO_CHAR (l_count_99), 8, '0')
                                    || '00000000000P@'
                                   );
                     l_count_99 := 0;
                     formatage_900 (   '99004'
                                    || SUBSTR (l_150, 6, 2)
                                    || '               '
                                    || LPAD (TO_CHAR (l_count_100), 8, '0')
                                    || '00000000000P@'
                                   );
                     l_count_100 := 0;
                     formatage_900 (   '99003'
                                    || SUBSTR (l_080, 6, 9)
                                    || '        '
                                    || LPAD (TO_CHAR (l_count_150), 8, '0')
                                    || '00000000000P@'
                                   );
                     l_count_150 := 0;
                     formatage_900 (   '99002'
                                    || SUBSTR (l_070, 6, 6)
                                    || '           '
                                    || LPAD (TO_CHAR (l_count_080), 8, '0')
                                    || '00000000000P@'
                                   );
                     l_count_080 := 0;
                     formatage_900 (   '99001'
                                    || SUBSTR (l_040, 6, 15)
                                    || '  '
                                    || LPAD (TO_CHAR (l_count_070), 8, '0')
                                    || '00000000000P@'
                                   );
                     l_count_070 := 0;

                     --
                     IF l_buffer IS NOT NULL
                     THEN
                        UTL_FILE.put_line (f_sortie,
                                              LPAD (TO_CHAR (LENGTH (l_buffer)),
                                                    4,
                                                    '0'
                                                   )
                                           || l_buffer
                                          );
                        l_count_line := l_count_line + 1;
                        l_buffer := NULL;
                     END IF;

                     l_count_line := l_count_line + 1;
            --
            -- On ecrit le 999 rejet final
            --
--CTT 04/11/2005 ano cgrcr 380
--            UTL_FILE.PUT_LINE ( f_sortie, '0128'||
--                                          SUBSTR ( rec.entite, 1, 27 )||
--                                          LPAD ( LTRIM ( SUBSTR ( rec.entite, 28, 28 ) ), 28, '0' )||
--                                          LPAD ( TO_CHAR ( l_count_line ), 8, '0' )||
--                                          SUBSTR ( rec.entite, 64, 19 )||
--                                          LPAD ( TO_CHAR ( l_count_010 ), 3, '0' )||
--                                          '00000000000P'||
--                                          SUBSTR ( rec.entite, 98, 31 ) );
                     UTL_FILE.put_line (f_sortie,
                                           '0128999OC'
                                        || LPAD (LTRIM (SUBSTR (rec.entite,
                                                                28,
                                                                20
                                                               )
                                                       ),
                                                 20,
                                                 '0'
                                                )
                                        || 'CS'
                                        || LPAD (LTRIM (SUBSTR (rec.entite,
                                                                6,
                                                                20
                                                               )
                                                       ),
                                                 20,
                                                 '0'
                                                )
                                        || SUBSTR (rec.entite, 48, 8)
                                        || LPAD (TO_CHAR (l_count_line),
                                                 8,
                                                 '0'
                                                )
                                        || SUBSTR (rec.entite, 64, 19)
                                        || LPAD (TO_CHAR (l_count_010), 3,
                                                 '0')
                                        || '00000000000'
                                        || SUBSTR (rec.entite, 97, 32)
                                       );
                     l_total_line := l_total_line + l_count_line;
                     l_count_line := 0;
                     l_count_010 := 0;
                  --
                  -- On reformate chaque entite norme 687 en norme 900
                  --
                  ELSIF rec.cod_entite = '070'
                  THEN
                     l_070 := rec.entite;
                  ELSIF rec.cod_entite = '110'
                  THEN
                     l_110 := '11005' || SUBSTR (rec.entite, 6, 83);
                  ELSIF rec.cod_entite = '127'
                  THEN
                     l_120 := '12005' || SUBSTR (rec.entite, 6, 7) || SUBSTR (rec.entite, 15, 44) || '@';
                  ELSIF rec.cod_entite = '025'
                  THEN
                     l_160 := '16099' || SUBSTR (rec.entite, 24, 17) || '@';
                  ELSIF rec.cod_entite = '045'
                  THEN
                     l_040 := '04001' || SUBSTR (rec.entite, 6, 15) || '@';
                  ELSIF rec.cod_entite = '155'
                  THEN
                     l_150 := '15004' || SUBSTR (rec.entite, 6, 2) || '@';
                  ELSIF rec.cod_entite = '080'
                  THEN
                     l_080 := '08003' || SUBSTR (rec.entite, 6, 10);
                  ELSIF rec.cod_entite = '100'
                  THEN
                     l_100 := '10005' || SUBSTR (rec.entite, 6, 10);
                  ELSIF rec.cod_entite = '255'
                  THEN
                     DECLARE
                        l_numano    sinistre_ano.numano%TYPE;
                        l_codapli   libelle.codapli%TYPE;
                        l_libelle   libelle.libelle%TYPE;
                     BEGIN
                        --
                        -- On recupere la donnee de l'anomalie qui a cause le rejet de la facture
                        --
                        SELECT MIN (numano)
                          INTO l_numano
                          FROM sinistre_ano
                         WHERE numsin = rec.numsin
                           AND numremise = rec_45.numremise_import;

                        IF l_numano IS NOT NULL
                        THEN
                           BEGIN
                              SELECT codapli
                                INTO l_codapli
                                FROM libelle
                               WHERE code = l_numano AND mnemo = 'SNTRANO';

                              IF l_codapli IS NULL
                              THEN
                                 l_codapli := 0;
                              END IF;

                              SELECT libelle
                                INTO l_libelle
                                FROM libelle
                               WHERE code = TO_NUMBER (l_codapli)
                                 AND mnemo = 'TPE_REJETS';
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 l_libelle := 'CODE TPE INCONNU';
                           END;

                           --
                           -- ins_stock_entite_norm_900
                           --
                           INSERT INTO stock_entite_norm_900
                                       (numremise, ent_040,
                                        ent_070, ent_080, ent_150, ent_100,
                                        ent_110, ent_120, ent_160,
                                        ent_290
                                       )
                                VALUES (rec_45.numremise_import, l_040,
                                        l_070, l_080, l_150, l_100,
                                        l_110, l_120, l_160,
                                           '29099'
                                        || SUBSTR (rec.entite, 6, 2)
                                        || 'AAA'
                                        || LPAD (l_codapli, 6, '0')
                                        || 'R'
                                        || RPAD (l_libelle, 80)
                                        || '@'
                                       );
                        END IF;
                     END;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;

         --
         -- CTT 01/12/2005 : Fiche 391 : Mise à jour de la date de transmission
         UPDATE remise_externe
            SET date_trans = TRUNC (SYSDATE)
          WHERE numremise = i_remise_exp;

         --
         g_msg_adm :=
               'Fichier rejets '
            || i_session
            || ' crée ('
            || TO_CHAR (l_total_line)
            || ' lignes)';
         p_ins_journal;
      --
      ELSE
         --
         g_msg_adm :=
               'Nature de fichier export '
            || i_nature_exp
            || ' incompatible avec le traitement';
         p_ins_journal;
      --
      END IF;

      --
      UTL_FILE.fclose (f_sortie);
      g_msg_adm :=
            'Fin du traitement le ' || TO_CHAR (SYSDATE, 'dd/mm/yyyy hh24:mi');
      p_ins_journal;
   --
   EXCEPTION
      WHEN e_i_repertoire_vide
      THEN
         g_msg_adm := 'Nom de(s) répertoire(s) de sortie manquant';
         pk_trace.p_ins_journal_adm (g_nom_traitement,
                                     g_session,
                                     g_niv_msg,
                                     g_msg_adm,
                                     SYSDATE,
                                     f_max_idligne (i_session => g_session)
                                    );
         DBMS_OUTPUT.put_line (g_msg_adm);
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.internal_error
      THEN
         g_msg_adm := 'UTL_FILE.INTERNAL_ERROR';
         pk_trace.p_ins_journal_adm (g_nom_traitement,
                                     g_session,
                                     g_niv_msg,
                                     g_msg_adm,
                                     SYSDATE,
                                     f_max_idligne (i_session => g_session)
                                    );
         DBMS_OUTPUT.put_line (g_msg_adm);
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.invalid_filehandle
      THEN
         g_msg_adm := 'UTL_FILE.INVALID_FILEHANDLE';
         pk_trace.p_ins_journal_adm (g_nom_traitement,
                                     g_session,
                                     g_niv_msg,
                                     g_msg_adm,
                                     SYSDATE,
                                     f_max_idligne (i_session => g_session)
                                    );
         DBMS_OUTPUT.put_line (g_msg_adm);
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.invalid_mode
      THEN
         g_msg_adm := 'UTL_FILE.INVALID_MODE';
         pk_trace.p_ins_journal_adm (g_nom_traitement,
                                     g_session,
                                     g_niv_msg,
                                     g_msg_adm,
                                     SYSDATE,
                                     f_max_idligne (i_session => g_session)
                                    );
         DBMS_OUTPUT.put_line (g_msg_adm);
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.invalid_operation
      THEN
         g_msg_adm := 'UTL_FILE.INVALID_OPERATION';
         pk_trace.p_ins_journal_adm (g_nom_traitement,
                                     g_session,
                                     g_niv_msg,
                                     g_msg_adm,
                                     SYSDATE,
                                     f_max_idligne (i_session => g_session)
                                    );
         DBMS_OUTPUT.put_line (g_msg_adm);
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.invalid_path
      THEN
         g_msg_adm := 'UTL_FILE.INVALID_PATH';
         pk_trace.p_ins_journal_adm (g_nom_traitement,
                                     g_session,
                                     g_niv_msg,
                                     g_msg_adm,
                                     SYSDATE,
                                     f_max_idligne (i_session => g_session)
                                    );
         DBMS_OUTPUT.put_line (g_msg_adm);
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.read_error
      THEN
         g_msg_adm := 'UTL_FILE.READ_ERROR';
         pk_trace.p_ins_journal_adm (g_nom_traitement,
                                     g_session,
                                     g_niv_msg,
                                     g_msg_adm,
                                     SYSDATE,
                                     f_max_idligne (i_session => g_session)
                                    );
         DBMS_OUTPUT.put_line (g_msg_adm);
         UTL_FILE.fclose (f_sortie);
      WHEN UTL_FILE.write_error
      THEN
         g_msg_adm := 'UTL_FILE.WRITE_ERROR';
         pk_trace.p_ins_journal_adm (g_nom_traitement,
                                     g_session,
                                     g_niv_msg,
                                     g_msg_adm,
                                     SYSDATE,
                                     f_max_idligne (i_session => g_session)
                                    );
         DBMS_OUTPUT.put_line (g_msg_adm);
         UTL_FILE.fclose (f_sortie);
      WHEN VALUE_ERROR
      THEN
         g_msg_adm := 'UTL_FILE.VALUE_ERROR';
         pk_trace.p_ins_journal_adm (g_nom_traitement,
                                     g_session,
                                     g_niv_msg,
                                     g_msg_adm,
                                     SYSDATE,
                                     f_max_idligne (i_session => g_session)
                                    );
         DBMS_OUTPUT.put_line (g_msg_adm);
         UTL_FILE.fclose (f_sortie);
      WHEN OTHERS
      THEN
         g_msg_adm := SUBSTR (SQLERRM (SQLCODE), 1, 128);
         pk_trace.p_ins_journal_adm (g_nom_traitement,
                                     g_session,
                                     g_niv_msg,
                                     g_msg_adm,
                                     SYSDATE,
                                     f_max_idligne (i_session => g_session)
                                    );
         DBMS_OUTPUT.put_line ('erreur !!!');
         DBMS_OUTPUT.put_line (g_msg_adm);

         IF UTL_FILE.is_open (f_sortie)
         THEN
            UTL_FILE.fclose (f_sortie);
         END IF;
   END p_export_acc_rej;

-- *******************************************************************************************************************************************************************************
   PROCEDURE p_forcage_facture (
      i_idfactpe   IN   suivi_fact_tpe.idfactpe%TYPE,
      i_remise     IN   suivi_fact_tpe.numremise_import%TYPE,
      i_forcage    IN   suivi_fact_tpe.user_forcage%TYPE
   )
   IS
      l_count_rejet   NUMBER;
   BEGIN
      l_count_rejet := 0;

      SELECT COUNT (codevefac)
        INTO l_count_rejet
        FROM sinistre_porte
       WHERE idfactpe = i_idfactpe AND numremise = i_remise AND codevefac = 30;

      IF l_count_rejet > 0
      THEN
         INSERT INTO suivi_fact_tpe
                     (codadeli, numfact, numremise_import, datfact,
                      codbenefinsee, codbenefcle, datnaibenef, rangbenef,
                      codtypfact, datreceptor, datlimiamc, numcompos,
                      codamcdet, idcptebq, reffin, typavireg, codevefac,
                      idfactpe, montant,complt_titre, user_forcage)
            (SELECT codadeli, numfact, numremise_import, datfact,
                    codbenefinsee, codbenefcle, datnaibenef, rangbenef,
                    codtypfact, datreceptor, datlimiamc, numcompos,
                    codamcdet, idcptebq, reffin, typavireg, 30, idfactpe,
                    montant,complt_titre, i_forcage
               FROM suivi_fact_tpe
              WHERE idfactpe = i_idfactpe
                AND codevefac = 10
                AND numremise_import = i_remise
                AND NOT EXISTS (
                       SELECT NULL
                         FROM suivi_fact_tpe
                        WHERE idfactpe = i_idfactpe
                          AND codevefac = 30
                          AND numremise_import = i_remise));
      ELSE                                         -- Pas de sinistre en rejet
         DELETE FROM suivi_fact_tpe
               WHERE idfactpe = i_idfactpe
                 AND codevefac = 30
                 AND numremise_import = i_remise;

         --
         UPDATE suivi_fact_tpe
            SET user_forcage = i_forcage
          WHERE idfactpe = i_idfactpe
            AND numremise_import = i_remise
            AND codevefac = 10;
      END IF;
   END p_forcage_facture;

-- *******************************************************************************************************************************************************************************
   PROCEDURE p_sinistre_accepte (
      i_nom_traitement   IN   journal_adm.nom_traitement%TYPE,
      i_session          IN   journal_adm.id_session%TYPE,
      i_numremise        IN   sinistre_porte.numremise%TYPE DEFAULT 0
   )
   IS
   BEGIN
      g_nom_traitement := i_nom_traitement;
      g_max_msg := 1;
      g_session := i_session;
      g_idligne := f_max_idligne (i_session => g_session);
      g_niv_msg := 1;

      UPDATE sinistre_porte a
         SET (datsin, numindiv, numassu) =
                (SELECT datsin, numindiv, numassu
                   FROM sinistre_porte b
                  WHERE b.idfactpe = a.idfactpe
                    AND b.numligne = a.numligne
                    AND b.codevefac = 40)
       WHERE a.numremise = i_numremise
         AND a.etat != 3
         AND EXISTS (
                SELECT 1
                  FROM sinistre_porte b
                 WHERE b.idfactpe = a.idfactpe
                   AND b.numligne = a.numligne
                   AND b.codevefac = 40);

      g_msg_adm :=
            'PK_TPE_687.P_SINISTRE_ACCEPTE - Mise à jour : '
         || TO_CHAR (SQL%ROWCOUNT);
      p_ins_journal;
   END p_sinistre_accepte;


-- *******************************************************************************************************************************************************************************
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
--
-- ----------------------------------------------------------------------------------------
--
-- Formatage du nom de fichier (variable G_fichier)
--
-- ----------------------------------------------------------------------------------------
   PROCEDURE p_nom_fichier
   IS
   BEGIN
--
      g_proc := 'p_nom_fichier';
--
   --
      g_date := TO_CHAR (SYSDATE, 'YYYYMMDD');

      --
      SELECT REPLACE (TO_CHAR (SYSDATE, 'fmHH24:MI:SS'), ':', '-')
        INTO g_heure
        FROM DUAL;

      --
      SELECT REPLACE (REPLACE (g_fichier, '#DT', g_date), '#HR', g_heure)
        INTO g_fichier
        FROM DUAL;
--
   EXCEPTION
      WHEN OTHERS
      THEN
         g_niv_msg := 0;
         g_msg_adm := f_centre ('erreur procedure ' || g_proc || ' : ', 78);
         p_ins_journal;
         g_msg_adm :=
                TO_CHAR (SQLCODE) || '-'
                || SUBSTR (SQLERRM (SQLCODE), 1, 128);
         p_ins_journal;
--
   END;

--
-- ----------------------------------------------------------------------------------------
--
-- ------------------------------------ Fin des corps des procedures privees --
--
-- Retourne le prochain idligne
--
   FUNCTION f_max_idligne (i_session IN journal_adm.id_session%TYPE)
      RETURN NUMBER
   IS
      l_idligne   NUMBER;
   BEGIN
      SELECT NVL (MAX (idligne), 0)
        INTO l_idligne
        FROM journal_adm
       WHERE id_session = i_session;

--
      RETURN (l_idligne);
--
   END f_max_idligne;

-- ----------------------------------------------------------------
-- Insertion dans journal_adm
-- ----------------------------------------------------------------
   PROCEDURE p_ins_journal
   IS
      l_idligne   NUMBER;
   BEGIN
--
      IF (g_niv_msg <= g_max_msg)
      THEN
         --
         g_idligne := g_idligne + 1;

         IF (g_niv_msg = 0)
         THEN
            l_idligne := -1 * g_idligne;
         ELSE
            l_idligne := g_idligne;
         END IF;

         --
         pk_trace.p_ins_journal_adm (i_nom_traitement      => g_nom_traitement,
                                     i_session             => g_session,
                                     i_niv_msg             => g_niv_msg,
                                     i_msg_adm             => g_msg_adm,
                                     i_idligne             => l_idligne
                                    );
      --
      END IF;
   END p_ins_journal;
END pk_tpe_687;
/
