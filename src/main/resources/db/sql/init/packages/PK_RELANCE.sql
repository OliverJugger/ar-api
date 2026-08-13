CREATE OR REPLACE PACKAGE ARTHUS."PK_RELANCE" AS
-- $Rev:: 795                                    $:  Revision du dernier commit
-- $Author:: s.calvez                            $:  Auteur du dernier commit
-- $Date: 2023-09-07 17:31:39 +0200 (jeu., 07 sept. 2023) $:  Date du dernier commit
-- $HeadURL: svn://svn2019/arthus/GEREP/trunk/dbschema/ARTHUS/PACKAGES/PK_RELANCE.pkh $:  Chemin

/*===========================================================================*/
/* Package      : PK_RELANCE.sql                                             */
/* Domaine      : Tresorerie                                                 */
/* Version      : V1.0                                                       */
/* Auteur       : V7 ?                                                       */
/* CrÃ©ation     : DD/MM/AAAA ?                                               */
/* Description  : gestion des relances de cotisations                        */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : PHA / 16/12/2010 / NVL(loc_mt_seuil,0) f_sel_param_relance */
/*===========================================================================*/
-- Chaine de reconnaissance SCCS
-- @(#)pk_relance.sql   1.1  00/11/10

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
   PROCEDURE p_sel_etendue_cle (
      i_numgar    IN       contrat.numgar%TYPE,
      o_etendue   OUT      param_relance.etendue%TYPE,
      o_cle       OUT      param_relance.cle%TYPE
   );

--
--
   FUNCTION f_sel_param_relance (
      i_etendue   IN   NUMBER,
      i_cle       IN   NUMBER,
      i_codope    IN   NUMBER,
      i_niveau    IN   NUMBER,
      i_type      IN   NUMBER,
      i_numgar    IN   NUMBER,
      i_modpmt    IN   NUMBER
   )
      RETURN VARCHAR2;


   PROCEDURE P_NIV_RELANCE (
      i_numfact   IN   facture.numfact%TYPE,
      -- i_niveau => recherche date pour un niveau donnÃ©e
      --             Si NULL, recherche pour le dernier niveau
      i_niveau    IN   param_relance.niveau%TYPE,
      o_niveau    OUT  param_relance.niveau%TYPE,
      o_date_niv  OUT  DATE
   );

   FUNCTION F_DATE_RELANCE (
      i_niveau    IN  param_relance.niveau%TYPE,
      i_numfact   IN  facture.numfact%TYPE,
      i_numgar    IN  qttc_global.numgar%TYPE,
      i_dateMED   IN  DATE DEFAULT NULL
   ) RETURN DATE;


   FUNCTION F_NIV_RELANCE (
      i_numfact   IN  facture.numfact%TYPE
   ) RETURN param_relance.niveau%TYPE;

   FUNCTION F_DATE_RELANCE_ATTEINT (
      i_numfact   IN  facture.numfact%TYPE
   ) RETURN DATE;

   PROCEDURE P_ANNUL_EMISSION_QTTC (
      i_numfact   IN  facture.numfact%TYPE
   );
   PROCEDURE P_QG72T(i_traitement IN VARCHAR2,
                     i_session    IN    NUMBER DEFAULT 1,
                     i_date       IN  DATE ,
                     io_nb_lignes IN OUT NUMBER) ;
   PROCEDURE P_QG73T(i_traitement IN VARCHAR2,
                     i_session    IN    NUMBER DEFAULT 1,
                     i_date       IN  DATE ,
                     io_nb_lignes IN OUT NUMBER) ;
   FUNCTION F_CTRL_ETAT(i_numgar contrat.numgar%TYPE  ,i_idadhesion adhe_cntrt.idadhesion%TYPE, i_debut DATE, i_etat NUMBER) RETURN NUMBER;
   PROCEDURE P_suspension_adhe(i_date   IN  DATE ,i_motif NUMBER,  io_journal IN OUT journal_adm%ROWTYPE);
   PROCEDURE P_suspension_cntrt(i_date   IN  DATE ,i_motif NUMBER,  io_journal IN OUT journal_adm%ROWTYPE) ;
   PROCEDURE P_resiliation_adhe(i_date   IN  DATE ,i_motif NUMBER,  io_journal IN OUT journal_adm%ROWTYPE);
   PROCEDURE P_resiliation_cntrt(i_date   IN  DATE ,i_motif NUMBER,  io_journal IN OUT journal_adm%ROWTYPE);
   FUNCTION F_CTRL_COTIS_RESIL (i_numgar contrat.numgar%TYPE ,i_idadhesion adhe_cntrt.idadhesion%TYPE, i_debut DATE, io_journal IN OUT journal_adm%ROWTYPE) RETURN NUMBER;
   PROCEDURE P_ANNUL_COT_RESIL (i_numgar contrat.numgar%TYPE ,i_idadhesion adhe_cntrt.idadhesion%TYPE, i_debut DATE);


   PRAGMA RESTRICT_REFERENCES (f_sel_param_relance, WNDS, WNPS);

   PROCEDURE P_ANNUL_COT_ADHE(i_numgar      IN     CONTRAT.NUMGAR%TYPE 
                             ,i_idadhesion  IN     ADHE_CNTRT.IDADHESION%TYPE
                             ,i_debut       IN     DATE
                             ,io_journal    IN OUT JOURNAL_ADM%ROWTYPE);
----------------------------------------------------------------------------
-- -------------------------------------------- Fin des procedures publiques --
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_RELANCE" AS
-- $Rev:: 795                                    $:  Revision du dernier commit
-- $Author:: s.calvez                            $:  Auteur du dernier commit
-- $Date: 2023-09-07 17:31:39 +0200 (jeu., 07 sept. 2023) $:  Date du dernier commit
-- $HeadURL: svn://svn2019/arthus/GEREP/trunk/dbschema/ARTHUS/PACKAGE_BODIES/PK_RELANCE.pkb $:  Chemin

-- Chaine de reconnaissance SCCS
-- @(#)pk_relance.sql   1.1  00/11/10

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
   PROCEDURE P_INS_journal(
             P_niv  IN NUMBER,
             p_journal IN OUT JOURNAL_ADM%ROWTYPE,
             P_msg  IN VARCHAR2,
             p_tracemail VARCHAR2 DEFAULT NULL);

-- ----------------------------- Fin des declarations des procedures privees --

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
   PROCEDURE p_sel_etendue_cle (
      i_numgar    IN       contrat.numgar%TYPE,
      o_etendue   OUT      param_relance.etendue%TYPE,
      o_cle       OUT      param_relance.cle%TYPE
   )
   IS
   BEGIN
      BEGIN
         SELECT 8, contrat.delegataire
           INTO o_etendue, o_cle
           FROM contrat
          WHERE EXISTS (SELECT 1
                          FROM param_relance
                         WHERE etendue = 8 AND cle = contrat.delegataire)
            AND contrat.numgar = i_numgar;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT 9, societe.numindiv
                 INTO o_etendue, o_cle
                 FROM societe, contrat
                WHERE societe.numsoc = contrat.numinterm
                  AND EXISTS (SELECT 1
                                FROM param_relance
                               WHERE etendue = 9 AND cle = societe.numindiv)
                  AND contrat.numgar = i_numgar;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  o_etendue := 0;
                  o_cle := 0;
            END;
      END;
   END;

--
--
   FUNCTION f_sel_param_relance (
      i_etendue   IN   NUMBER,
      i_cle       IN   NUMBER,
      i_codope    IN   NUMBER,
      i_niveau    IN   NUMBER,
      -- i_type :   1 - param_relance.mt_seuil
      --            2 - param_relance.courrier
      --            3 - param_relance.type_dest
      --            4 - param_relance.delai
      --            5 - param_relance.blocage
      i_type      IN   NUMBER,
      i_numgar    IN   NUMBER,
      i_modpmt    IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      loc_type        VARCHAR2 (15);
      loc_mt_seuil    NUMBER;
      loc_courrier    VARCHAR2 (1);
      loc_type_dest   NUMBER;
      loc_delai       NUMBER;
      loc_blocage     VARCHAR2 (1);
      loc_etendue     NUMBER        := i_etendue;
      loc_cle         NUMBER        := i_cle;
      loc_codope      NUMBER        := i_codope;
      loc_niveau      NUMBER        := i_niveau;
      loc_modpmt      NUMBER        := i_modpmt;
  -- -- 25-01-2008 NSO Correction des fiches Humanis (Prélévement ou Autres))
   BEGIN
-- -- 25-01-2008 NSO Correction des fiches Humanis (Prélévement ou Autres))
      IF loc_modpmt = 2
      THEN
         NULL;
      ELSE
         loc_modpmt := 1;                                   --Signifie autres
      END IF;

-- -- 25-01-2008 NSO Correction des fiches Humanis (Prélévement ou Autres))
      <<debut>>
      BEGIN
         SELECT param_relance.mt_seuil, param_relance.courrier,
                param_relance.type_dest, param_relance.delai,
                param_relance.blocage
           INTO loc_mt_seuil, loc_courrier,
                loc_type_dest, loc_delai,
                loc_blocage
           FROM param_relance
          WHERE etendue = loc_etendue
            AND cle = loc_cle
            AND codope = loc_codope
            AND niveau = loc_niveau
            AND modpmt =
                   loc_modpmt
       -- 25-01-2008 NSO Correction des fiches Humanis (2037-2065-2064 etc...)
                             ;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               IF (loc_etendue = 2)
               THEN
                  BEGIN
                     SELECT delegataire, 8
                       INTO loc_cle, loc_etendue
                       FROM contrat
                      WHERE numgar = i_numgar;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        BEGIN
                           SELECT numindiv, 9
                             INTO loc_cle, loc_etendue
                             FROM societe, contrat
                            WHERE societe.numsoc = contrat.numinterm
                              AND contrat.numgar = i_numgar;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              loc_type := -1;
                              RETURN (loc_type);
                        END;

                        GOTO debut;
                  END;

                  GOTO debut;
               ELSIF (loc_etendue = 8)
               THEN
                  BEGIN
                     SELECT numindiv, 9
                       INTO loc_cle, loc_etendue
                       FROM societe, contrat
                      WHERE societe.numsoc = contrat.numinterm
                        AND contrat.numgar = i_numgar;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        loc_type := -1;
                        RETURN (loc_type);
                  END;

                  GOTO debut;
               ELSIF (loc_etendue = 9)
               THEN
                  loc_type := -1;
                  RETURN (loc_type);
               END IF;
            END;
      END;

      IF (i_type = 1)
      THEN
         loc_type := TO_CHAR (NVL(loc_mt_seuil,'0'));
      ELSIF (i_type = 2)
      THEN
         loc_type := loc_courrier;
      ELSIF (i_type = 3)
      THEN
         loc_type := TO_CHAR (loc_type_dest);
      ELSIF (i_type = 4)
      THEN
         loc_type := TO_CHAR (loc_delai);
      ELSIF (i_type = 5)
      THEN
         loc_type := loc_blocage;
      END IF;

      RETURN (loc_type);
   END;

   ----------------------------------------------------------------------
   FUNCTION F_DATE_RELANCE (
      i_niveau    IN  param_relance.niveau%TYPE,
      i_numfact   IN  facture.numfact%TYPE,
      i_numgar    IN  qttc_global.numgar%TYPE,
      i_dateMED   IN  DATE DEFAULT NULL
   ) RETURN DATE
   IS 
      o_date            DATE;
      -- date/niveau atteints
      loc_date          DATE;
      loc_niveau        param_relance.niveau%TYPE;

      loc_numgar        qttc_global.numgar%TYPE;
      loc_modpmt        facture.mregl%TYPE;
      loc_echeance_fact facture.echeance%TYPE;

      loc_delai         NUMBER(3);
      --loc_blocage       VARCHAR2 (15);
   BEGIN
      -- dbms_output.put_line('F_DATE_RELANCE:Entrée:i_numfact='||i_numfact
      --                                         ||'|i_niveau=' ||i_niveau
      --                                         ||'|i_numgar=' ||i_numgar);

      -- Controles- données obligatoires
      IF  i_niveau IS NULL
       OR i_numfact IS NULL THEN
         -- dbms_output.put_line('F_DATE_RELANCE:Sortie:Données incomplètes');
         RETURN NULL;
      END IF;

     -- Recheche niveau atteint
      P_NIV_RELANCE (i_numfact  => i_numfact,
                     i_niveau   => NULL,
                     o_niveau   => loc_niveau,
                     o_date_niv => loc_date );
      -- dbms_output.put_line('F_DATE_RELANCE:niveau en cours='|| loc_niveau
      --                                     ||' à date='||TO_CHAR(loc_date,'DD/MM/YYYY'));
      CASE
         WHEN loc_niveau = 99 THEN
            -- dbms_output.put_line('F_DATE_RELANCE:Sortie:niveau 99');
            RETURN NULL;
         -- si niveau atteint = niveau demandé
         WHEN loc_niveau = i_niveau THEN
            -- dbms_output.put_line('F_DATE_RELANCE:Sortie:niveau atteint = niveau demandé');
            RETURN loc_date;
         -- si niveau atteint > niveau demandé, recherche date
         WHEN loc_niveau > i_niveau THEN
            -- dbms_output.put_line('F_DATE_RELANCE:niveau atteint > niveau demandé');
            P_NIV_RELANCE(i_numfact  => i_numfact,
                          i_niveau   => i_niveau,
                          o_niveau   => loc_niveau,
                          o_date_niv => o_date );
            RETURN o_date;
         ELSE
            NULL;
      END CASE;

      -------------------------------------------------------------------------------------
      -- Le niveau i_niveau n'a pas été atteint (absent de EMISSION) => CALCUL de la date
      -------------------------------------------------------------------------------------
      -- Recherche si emission du niveau demandé déjà positionnée dans le futur
      BEGIN
         SELECT e.datemis
         INTO   o_date
         FROM facture f
         INNER JOIN emission e ON e.numfact = f.numfact
                              AND e.codope  = f.codope
         WHERE 
               f.numfact    = i_numfact
           AND e.numrelance = i_niveau
           -- on écarte les editions annulées
           AND e.annul_date IS NULL
         ORDER BY e.datemis DESC
         FETCH FIRST 1 ROWS ONLY;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            o_date := NULL;
            -- dbms_output.put_line('P_NIV_RELANCE:niveau futur non trouvé');
         WHEN OTHERS THEN
            o_date := NULL;
            -- dbms_output.put_line('P_NIV_RELANCE:recherche niveau furur:' || SQLERRM);
      END;
      IF o_date IS NOT NULL THEN
         RETURN o_date;
      END IF;


      -- Détermination contrat
      IF i_numgar IS NOT NULL THEN
         loc_numgar := PK_QTTC.F_SEL_NUMGAR(i_numgar);
      ELSE
         BEGIN
            SELECT F_NUMGAR_REF(qg.numgar)
            INTO loc_numgar
            FROM qttc_global qg
            WHERE qg.numquit = i_numfact;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- dbms_output.put_line('F_DATE_RELANCE:Sortie:numgar non trouvé');
               RETURN NULL;
            WHEN OTHERS THEN
               -- dbms_output.put_line('F_DATE_RELANCE:Sortie:erreur recherche numgar:'||SQLERRM);
               RETURN NULL;
         END;
      END IF;

      -- Détermination mdpmt et echeance
      BEGIN
         SELECT f.echeance
               ,f.mregl
         INTO  loc_echeance_fact
              ,loc_modpmt
         FROM facture f
         WHERE f.codope  = 4
           AND f.numfact = i_numfact;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- dbms_output.put_line('F_DATE_RELANCE:Sortie:echeance non trouvé');
            RETURN NULL;
         WHEN OTHERS THEN
            -- dbms_output.put_line('F_DATE_RELANCE:Sortie:erreur recherche echanche:'||SQLERRM);
            RETURN NULL;
      END;
      
      -- loc_blocage := f_sel_param_relance (
      --                            i_etendue  => 2,
      --                            i_cle      => loc_numgar,
      --                            i_codope   => 3,    -- historique: seule la valeur 3 est prise en compte
      --                            i_niveau   => i_niveau,
      --                            i_type     => 5,    -- blocage
      --                            i_numgar   => loc_numgar,
      --                            i_modpmt   => loc_modpmt );

      --dbms_output.put_line('F_DATE_RELANCE:loc_blocage=' || loc_blocage);

      -- CASE loc_blocage
      --    WHEN 'N' THEN
      --       NULL;
      --    WHEN 'O' THEN
      --       -- dbms_output.put_line('F_DATE_RELANCE:Sortie:niveau bloqué');
      --       RETURN NULL;
      --    ELSE
      --       -- dbms_output.put_line('F_DATE_RELANCE:Sortie:parametre relance non trouvé');
      --       RETURN NULL;
      -- END CASE;

      loc_delai := TO_NUMBER ( f_sel_param_relance (
                                       i_etendue  => 2,
                                       i_cle      => loc_numgar,
                                       i_codope   => 3,    -- historique: seule la valeur 3 est prise en compte
                                       i_niveau   => i_niveau,
                                       i_type     => 4,  -- delai
                                       i_numgar   => loc_numgar,
                                       i_modpmt   => loc_modpmt ));
      -- dbms_output.put_line('F_DATE_RELANCE:loc_delai=' || loc_delai);
      CASE
         WHEN loc_delai = -1 THEN      -- pas de delai de relance trouvé
            RETURN NULL;
         WHEN i_niveau < 10 THEN       -- Si inférieur (10 - Mise en demeure), alors date calculée à partir de facture.echeance
            o_date := TRUNC(loc_echeance_fact) + loc_delai;
         WHEN i_niveau = 10            -- (10 - Mise en demeure), alors date calculée à partir de facture.echeance
          AND i_dateMED IS NULL THEN   
            o_date := TRUNC(loc_echeance_fact) + loc_delai;
         WHEN i_niveau = 10            -- (10 - Mise en demeure) mais date MED passée en paramètre
          AND i_dateMED IS NOT NULL THEN   
            o_date := TRUNC(i_dateMED) ;
         WHEN i_niveau > 10            -- Si supérieur à (10 - Mise en demeure), date calculée à partir de la date de mise en demeure passée
          AND i_dateMED IS NOT NULL THEN 
            o_date := TRUNC(i_dateMED) + loc_delai;
         WHEN i_niveau > 10 THEN   -- Si supérieur à (10 - Mise en demeure), date calculé à partir de la date de mise en demeure
            o_date := F_DATE_RELANCE(i_niveau  => 10,
                                     i_numfact => i_numfact,
                                     i_numgar  => loc_numgar,
                                     i_dateMED => i_dateMED) + loc_delai;
         ELSE
            RETURN NULL;
      END CASE;

     RETURN o_date;

   END F_DATE_RELANCE;

   ----------------------------------------------------------------------
   -- Renvoit le niveau de relance atteint sur une facture et la date correspondante
   --   Ne filtre pas le niveau 99 (qui correspond à l'annulation)
   PROCEDURE P_NIV_RELANCE (
      i_numfact   IN   facture.numfact%TYPE,
      -- i_niveau => recherche date pour un niveau donné
      --             Si NULL, recherche pour le dernier niveau
      i_niveau    IN   param_relance.niveau%TYPE,
      o_niveau    OUT  param_relance.niveau%TYPE,
      o_date_niv  OUT  DATE
   ) 
   IS 
      loc_niveau     param_relance.niveau%TYPE;
      loc_date_niv   DATE;
   BEGIN
      -- dbms_output.put_line('P_NIV_RELANCE:Entrée:i_numfact='||i_numfact
      --                                         ||'i_niveau=' ||i_niveau);

      BEGIN  
         SELECT e.numrelance
               ,e.datemis
         INTO   loc_niveau
               ,loc_date_niv
         FROM facture f
         INNER JOIN emission e ON e.numfact = f.numfact
                              AND e.codope  = f.codope
         WHERE 
               f.numfact = i_numfact
           -- on écarte les editions annulées
           AND e.annul_date IS NULL
           -- on ecarte des emission dans le futur
           AND e.datemis < TRUNC(sysdate +1)
           AND e.type_doc = 1
           AND (i_niveau IS NULL
                OR e.numrelance = i_niveau)
         ORDER BY e.datemis DESC,
                  e.numrelance DESC
         FETCH FIRST 1 ROWS ONLY;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            loc_niveau   := NULL;
            loc_date_niv := NULL;
            -- dbms_output.put_line('P_NIV_RELANCE:niveau non trouvé');
         WHEN OTHERS THEN
            loc_niveau   := NULL;
            loc_date_niv := NULL;
            -- dbms_output.put_line('P_NIV_RELANCE:recherche niveau:' || SQLERRM);
      END;

      o_niveau   := loc_niveau;
      o_date_niv := loc_date_niv;
      -- dbms_output.put_line('P_NIV_RELANCE:Sortie:o_niveau='   ||TO_CHAR(o_niveau)
      --                                         ||'o_date_niv=' ||TO_CHAR(o_date_niv,'DD/MM/YYYY'));
      RETURN;
   END P_NIV_RELANCE;

   ----------------------------------------------------------------------
   -- Renvoit le niveau de relance atteint sur une facture
   FUNCTION F_NIV_RELANCE (
      i_numfact   IN  facture.numfact%TYPE
   ) RETURN param_relance.niveau%TYPE
   IS 
      o_niveau     param_relance.niveau%TYPE;
      loc_date     DATE;
   BEGIN
      P_NIV_RELANCE (i_numfact  => i_numfact,
                     i_niveau   => NULL,
                     o_niveau   => o_niveau,
                     o_date_niv => loc_date );
      IF o_niveau = 99 THEN
         RETURN NULL;
      ELSE
         RETURN o_niveau;
      END IF;
   END F_NIV_RELANCE;

   ----------------------------------------------------------------------
   -- Renvoit la date de relance atteint sur une facture
   FUNCTION F_DATE_RELANCE_ATTEINT (
      i_numfact   IN  facture.numfact%TYPE
   ) RETURN DATE
   IS 
      loc_niveau     param_relance.niveau%TYPE;
      o_date         DATE;
   BEGIN
      P_NIV_RELANCE (i_numfact  => i_numfact,
                     i_niveau   => NULL,
                     o_niveau   => loc_niveau,
                     o_date_niv => o_date );
      IF loc_niveau = 99 THEN
         RETURN NULL;
      ELSE 
         RETURN o_date;
      END IF;
   END F_DATE_RELANCE_ATTEINT;

   ----------------------------------------------------------------------
   --Annulation d'une emission de cotisations 
   PROCEDURE P_ANNUL_EMISSION_QTTC (
      i_numfact   IN  facture.numfact%TYPE
   )
   IS
   BEGIN
      UPDATE emission e
      SET e.motif_annul     = 1
         ,e.annul_date      = sysdate
         ,e.annul_numutil   = f_numutil
      WHERE
          e.codope          = 4
      AND e.numfact         = i_numfact
      AND e.annul_date      IS NULL
      AND e.numrelance      NOT IN (0, 99);
   EXCEPTION
      WHEN OTHERS THEN
         PK_TRACE.P_INS_JOURNAL_ADM(I_nom_traitement => 'P_ANNUL_EMISSION_QTTC',
                                    I_session        => sid,
                                    I_niv_msg        => 1,
                                    I_msg_adm        => 'Erreur:'||SQLERRM,
                                    I_date           => sysdate,
                                    I_idligne        => 1);
   END P_ANNUL_EMISSION_QTTC;

---------------------------------------------------------------------
-- Traitement des cotisations après résiliation adhésion
PROCEDURE P_ANNUL_COT_ADHE(i_numgar      IN     CONTRAT.NUMGAR%TYPE 
                          ,i_idadhesion  IN     ADHE_CNTRT.IDADHESION%TYPE
                          ,i_debut       IN     DATE
                          --,i_actif_Perte IN     NUMBER
                          --,i_factMED     IN     FACTURE.NUMFACT%TYPE
                          ,io_journal    IN OUT JOURNAL_ADM%ROWTYPE)  IS

CURSOR C_COTIS_RESIL(p_idadhesion ADHESION.IDADHESION%TYPE
                    ,p_numgar     CONTRAT.NUMGAR%TYPE
                    ,p_debut      DATE) IS
   SELECT qg.numquit
         -- ,f_montant_du(qg.numquit,4,30)             mt
         ,f_totaffec (qg.numquit, 4)                mt
         ,NVL(qg.mt_ttc_d,0) - NVL(qg.mt_affec_d,0) mt_d
         ,NVL(qg.mt_affec_d,0)                      mt_affec_d
         ,qg.comptant
         ,e.datemis
         ,qg.debut
         ,qg.fin
         ,qg.type_qttc
         ,qg.numquerable
         ,p.numprelev
         ,qg.monnaie
         ,qg.monnaie_d  
   FROM QTTC_GLOBAL qg
   LEFT OUTER JOIN emission e           ON  e.numfact    = qg.numquit 
                                        AND e.codope     = 4 
                                        AND e.numrelance = 0
   LEFT OUTER JOIN prelevement_detail p ON  p.numfact = qg.numquit 
                                        AND p.codope  = 4
   WHERE qg.idadhesion = p_idadhesion
     AND qg.numgar     = p_numgar
     AND qg.debut     >= p_debut
     AND NOT EXISTS (SELECT 1 FROM facture_regul WHERE numfact_regul = qg.numquit)
     AND NOT EXISTS (SELECT 1 FROM facture_annul where facture_annul.numfact =  qg.numquit AND codope =4) --non déjà annulée
     --AND ( f_montant_du(qg.numquit,4,30) <>0 OR qg.type_qttc = 3 )--non soldée
     --AND p.numprelev IS  NULL --sans prélèvement en cours
   ORDER BY qg.debut desc;

BEGIN
   --recherche des cotisations à annuler postérieure à la date de résilation
   FOR r_cotis_resil IN C_COTIS_RESIL(i_idadhesion, i_numgar, i_debut) LOOP
      --on ne traite pas les factures post résiliation en cours de prélèvement ou avec un montant affecté (normalement gérer par la fct de contrôle)
      IF i_debut < r_cotis_resil.debut 
      AND (r_cotis_resil.numprelev IS NOT NULL OR r_cotis_resil.mt_affec_d > 0) THEN
         CONTINUE;
      --on bloque unitairement le traitement des cotisations pour les factures anté résiliation post facture MED 
      ELSIF r_cotis_resil.numprelev IS NOT NULL THEN
         P_INS_journal(1,io_journal,'Traitement cotisation impossible, facture '||r_cotis_resil.numquit || ' en cours de prélèvement','KO');
         CONTINUE;
      ELSIF r_cotis_resil.mt <> 0 AND r_cotis_resil.type_qttc <> 3 THEN
         P_INS_journal(1,io_journal,'Traitement cotisation impossible, facture '||r_cotis_resil.numquit || ' partiellement affectée','KO');
         CONTINUE;
      END IF;

      BEGIN
         --facture antérieure /chevauchante avec la date de résiliation
         IF r_cotis_resil.type_qttc = 3 OR r_cotis_resil.datemis IS NULL THEN        
            DELETE qttc_global
            WHERE qttc_global.numquit = r_cotis_resil.numquit;
         --annulation des cotisations émises
         ELSIF r_cotis_resil.datemis IS NOT NULL THEN  
            --existance d'un TRG d'insertion dans facture_annul sur emission
            INSERT INTO emission (codope, numfact, numrelance, datemis, type_doc)
               SELECT 4,r_cotis_resil.numquit, 99, sysdate, 1 FROM dual
               WHERE NOT EXISTS (SELECT 1 FROM emission
                                 WHERE codope = 4
                                 AND numfact = r_cotis_resil.numquit
                                 AND numrelance = 99
                                 AND type_doc = 1);
         END IF;  
      EXCEPTION
         WHEN OTHERS THEN
            P_INS_journal(1,io_journal,'Annulation / Suppression impossible, facture '||r_cotis_resil.numquit || ' Err :'||SQLERRM,'KO');
      END;
   END LOOP;

   --mise à jour de l'échéance suivante sur l'échéancier de cotisation
   --Nécéssaire en cas de règlement de la dette et donc suppression de la résiliation
   IF i_idadhesion <> 0 THEN
     PK_QTTC.P_MAJ_echesuiv(I_etendue=>13,I_cle => i_idadhesion);
   ELSIF f_numgar_ref(i_numgar) = i_numgar THEN
     PK_QTTC.P_MAJ_echesuiv(I_etendue=>2, I_cle => i_numgar);
   ELSE
     PK_QTTC.P_MAJ_echesuiv(I_etendue=>24, I_cle => i_numgar);
   END IF;

END P_ANNUL_COT_ADHE;

   ----------------------------------------------------------------------
   --Création massive des émissions de suspension et résiliation après mise en demeure
   PROCEDURE P_QG72T(i_traitement IN VARCHAR2,
                     i_session    IN    NUMBER DEFAULT 1,
                     i_date       IN  DATE ,
                     io_nb_lignes IN OUT NUMBER) IS

  /*-	Codope = 4 (cotisations)
  -	Numrelance = 10 (MED) atteinte
  -	Date pivot traitement = date_emis  
  -	Annul_date is NULL (non annulée)
  -	Jointure qttc_global pour différencier indiv / coll (idadhesion = 0 ou non)
  -	Sans emission (non annulée) pour la même facture de niveau supérieur à 10 
  -	La facture ne doit pas être annulée
  -	La facture ne doit pas être régularisée
  - les émissions ne doivent pas préexister
  -	La facture doit présenter un montant restant du en accord avec le paramétrage (exemple de code dans en11 => attention aux devises en v6)
  */

    CURSOR C_facture (p_date DATE) IS
    SELECT f.numfact , e.DATEMIS, q.numgar,q.idadhesion
    FROM facture f
    INNER JOIN emission e ON (e.numfact = f.numfact and e.codope =f.codope)
    INNER JOIN qttc_global q  ON (e.numfact = q.numquit)
    WHERE e.numrelance =10
    AND e.DATEMIS >=  p_date 
    AND e.DATEMIS < p_date+1 --pour éviter le trunc
    AND e.annul_date IS NULL
    AND f.codope = 4
    AND q.type_qttc <>3 --non prévisionnelle
    AND NOT EXISTS(SELECT numfact FROM facture_annul WHERE numfact = f.numfact)
    AND NOT EXISTS(SELECT numfact FROM facture_regul WHERE numfact_regul = f.numfact)  
    AND NOT EXISTS (SELECT numfact FROM emission WHERE numfact = f.numfact AND codope = 4 AND NUMRELANCE in (20,30) AND annul_date IS NULL) ;

    loc_journal JOURNAL_ADM%ROWTYPE; 
    loc_sujet VARCHAR2(300);
    loc_corps CLOB;
    loc_erreur VARCHAR2(200);
    loc_sender VARCHAR2(200);
    loc_date_susp  DATE;
    loc_date_resil DATE;
    cpt_adh_20   NUMBER;
    cpt_adh_30   NUMBER;
    cpt_cntrt_20 NUMBER;
    cpt_cntrt_30 NUMBER;

  BEGIN
    IF i_traitement IS NULL OR i_date IS NULL THEN RETURN;
    END IF;
    loc_journal.nom_traitement := i_traitement;
    loc_journal.id_session := NVL(i_session,SID);
    loc_journal.idligne := NVL(io_nb_lignes,1);

    BEGIN
      SELECT DECODE(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
      INTO loc_journal.niv_msg
      FROM PARAM_BATCH
      WHERE NUMBATCH = loc_journal.nom_traitement;
    EXCEPTION
      WHEN OTHERS THEN loc_journal.niv_msg:=3;
    END;

    P_INS_journal(1,loc_journal,'Début du traitement '||loc_journal.nom_traitement ||' des MED en date du :'|| i_date );
    loc_sujet :='[Rapport_ARTHUS] Création massive des émissions suite à MED '||I_traitement|| ' - ' ||sysdate ||' sur l''instance #INSTANCE';
    loc_corps := ' ' ;
    loc_sender :=NULL;

    --initialisation des compteurs
    cpt_adh_20 :=0;
    cpt_adh_30 :=0;
    cpt_cntrt_20 :=0;
    cpt_cntrt_30 :=0;
    --parcourt des factures mises en demeure à date pivot
    FOR R_facture IN C_facture (i_date) LOOP

      IF f_montant_du(R_facture.numfact,4,10)=0 THEN
        P_INS_journal(1,loc_journal,'Montant dû nul pour la facture '|| R_facture.numfact || ' MED non prise en compte');
        CONTINUE;
      END IF;
      --détermination de la date de suspension
      loc_date_susp:=NULL;
      loc_date_susp:=PK_RELANCE.F_DATE_RELANCE( i_niveau=> 20,  i_numfact=> R_facture.numfact,  i_numgar=> NULL,  i_dateMED=> R_facture.DATEMIS);
      IF loc_date_susp IS NULL THEN
        P_INS_journal(1,loc_journal,'Détermination de la suspension pour la facture '|| R_facture.numfact || 'impossible, MED ='||R_facture.DATEMIS);
        CONTINUE;
      END IF;

      --détermination de la date de résiliation
      loc_date_resil:=NULL;
      loc_date_resil:=PK_RELANCE.F_DATE_RELANCE( i_niveau=> 30,  i_numfact=> R_facture.numfact,  i_numgar=> NULL,  i_dateMED=> R_facture.DATEMIS);
      IF loc_date_resil IS NULL THEN
        P_INS_journal(1,loc_journal,'Détermination de la résiliation pour la facture '|| R_facture.numfact || 'impossible, MED ='||R_facture.DATEMIS);
        CONTINUE;
      END IF;


      --insertion emission 20 de suspension
      INSERT INTO EMISSION (CODOPE,NUMFACT,NUMRELANCE,DATEMIS,TYPE_DOC) VALUES (4,R_facture.numfact,20,loc_date_susp,1);
      IF R_facture.idadhesion <> 0  THEN
        cpt_adh_20 := cpt_adh_20+1;
      ELSE
        cpt_cntrt_20 := cpt_cntrt_20 +1;
      END IF; 
      --insertion emission 30 de résiliation
      INSERT INTO EMISSION (CODOPE,NUMFACT,NUMRELANCE,DATEMIS,TYPE_DOC) VALUES (4,R_facture.numfact,30,loc_date_resil,1);
      IF R_facture.idadhesion <> 0  THEN
        cpt_adh_30 := cpt_adh_30+1;
      ELSE
        cpt_cntrt_30 := cpt_cntrt_30 +1;
      END IF; 

    END LOOP;

    COMMIT;
    IF cpt_adh_20 +cpt_cntrt_20 = 0 THEN
      P_INS_journal(1,loc_journal,'Aucune émission de suspension ou résiliation effectuée','OK');
    ELSE
      --Denombrement
      P_INS_journal(1,loc_journal,'Individuel : Nombre de suspensions = '|| cpt_adh_20 || ', résiliations ='||cpt_adh_30,'OK');
      P_INS_journal(1,loc_journal,'Collectif : Nombre de suspensions = '|| cpt_cntrt_20 || ', résiliations ='||cpt_cntrt_30,'OK');
    END IF;
    
    
    P_ENVOI_MAIL_BATCH (loc_sujet,loc_corps,loc_sender,loc_journal, loc_erreur );
    IF loc_erreur IS NOT NULL THEN      
      P_INS_journal(1,loc_journal,'Mail impossible - '||loc_erreur,'KO');
    END IF;
    io_nb_lignes :=loc_journal.idligne;
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
    --Si une anomalie technique est rencontrée, aucune mise à jour ne doit être effectuée.  
    P_INS_journal(1,loc_journal,'Erreur bloquante : traitement impossible des MED du '|| i_date || ' -'||SQLERRM,'KO');
    P_ENVOI_MAIL_BATCH (loc_sujet,loc_corps,loc_sender,loc_journal, loc_erreur );
    IF loc_erreur IS NOT NULL THEN      
      P_INS_journal(1,loc_journal,'Mail impossible - '||loc_erreur,'KO');
      io_nb_lignes :=loc_journal.idligne;
    END IF;
    ROLLBACK;

  END P_QG72T;


  ----------------------------------------------------------------------
  --Création massive des émissions de suspension et résiliation après mise en demeure
  PROCEDURE P_QG73T(i_traitement IN VARCHAR2,
                     i_session    IN    NUMBER DEFAULT 1,
                     i_date       IN  DATE ,
                     io_nb_lignes IN OUT NUMBER) IS
    
    loc_journal JOURNAL_ADM%ROWTYPE;
    loc_sujet VARCHAR2(300);
    loc_corps CLOB;
    loc_erreur VARCHAR2(200);    
    loc_sender VARCHAR2(200);
    loc_delai_susp NUMBER;
    loc_delai_resil NUMBER;
    loc_actif_coll NUMBER;
    motif_susp_adh NUMBER;
    motif_susp_cntrt  NUMBER;
    motif_resil_adh  NUMBER;
    motif_resil_cntrt  NUMBER;
    exc_fin_traitement EXCEPTION;

    CURSOR C_motif IS 
    SELECT lb.code,lb.libelle FROM LIBELLE_BIS lb, LIBELLE l
    WHERE lb.MNEMO = 'MT_DETTE'
    AND l.MNEMO = 'ET_ADHE'
    AND l.code = to_number(lb.libelle)
    AND lb.CODE <>'-2';
  BEGIN
    IF i_traitement IS NULL OR i_date IS NULL THEN RETURN;
    END IF;
    loc_journal.nom_traitement := i_traitement;
    loc_journal.id_session := NVL(i_session,SID);
    loc_journal.idligne := NVL(io_nb_lignes,1);

    BEGIN
      SELECT DECODE(PARAM5 ,'notest', 1, 'test', 2, 'totale', 3)
      INTO loc_journal.niv_msg
      FROM PARAM_BATCH
      WHERE NUMBATCH = loc_journal.nom_traitement;
    EXCEPTION
      WHEN OTHERS THEN loc_journal.niv_msg:=3;
    END;

    P_INS_journal(1,loc_journal,'Début du traitement '||loc_journal.nom_traitement ||' - Suspension / Résiliation avec date pivot :'|| i_date );
    loc_sujet :='[Rapport_ARTHUS] Suspension / Résiliation suite à MED '||I_traitement|| ' - ' ||sysdate ||' sur l''instance #INSTANCE';
    loc_corps := ' ' ;
    loc_sender :=NULL;

    --contrôle et récupération du paramétrage 
    --motif de suspension et résiliation paramétrage
    BEGIN
     FOR r_motif IN C_motif LOOP
      CASE r_motif.code 
      WHEN 'SUSPCNTRT' THEN motif_susp_cntrt := to_number(r_motif.libelle);
      WHEN 'SUSPADH' THEN motif_susp_adh := to_number(r_motif.libelle);
      WHEN 'RESCNTRT' THEN motif_resil_cntrt := to_number(r_motif.libelle);
      WHEN 'RESADH' THEN motif_resil_adh := to_number(r_motif.libelle); 
      ELSE NULL;
      END CASE;

     END LOOP;
     IF motif_susp_cntrt IS NULL OR motif_susp_adh IS NULL OR motif_resil_cntrt IS NULL OR motif_resil_adh IS NULL THEN 
       P_INS_journal(1,loc_journal,'Erreur bloquante : paramétrage des motifs manquant','KO' );       
       RAISE exc_fin_traitement;
     END IF;
    EXCEPTION
      WHEN exc_fin_traitement THEN
        RAISE exc_fin_traitement;      
      WHEN OTHERS THEN
        P_INS_journal(1,loc_journal,'Erreur bloquante : paramétrage des motifs non numérique','KO' );       
        RAISE exc_fin_traitement;
    END;

    BEGIN
      SELECT to_number(NVL(param2,0)),to_number(NVL(param3,0)) , to_number(NVL(param1,0)) 
      INTO loc_delai_susp  , loc_delai_resil  , loc_actif_coll
      FROM param_batch
      WHERE NUMBATCH = loc_journal.nom_traitement;
    EXCEPTION
      WHEN OTHERS THEN
        P_INS_journal(1,loc_journal,'Erreur bloquante : paramétrage incohérent du traitement' ,'KO');
        RAISE exc_fin_traitement;
    END;
    P_INS_journal(1,loc_journal,'Délai de suspension '||loc_delai_susp ||', délai de résiliation '||loc_delai_resil );

    P_suspension_adhe(i_date+loc_delai_susp, motif_susp_adh, loc_journal);
   
    P_resiliation_adhe(i_date+loc_delai_resil, motif_resil_adh, loc_journal);    
    IF loc_actif_coll = 1 THEN
      P_suspension_cntrt (i_date+loc_delai_susp, motif_susp_cntrt, loc_journal);
      P_resiliation_cntrt(i_date+loc_delai_resil, motif_resil_cntrt, loc_journal);
    ELSE
       P_INS_journal(1,loc_journal,'Suspension et radiation non activées sur le collectif','OK' );
    END IF;
    P_ENVOI_MAIL_BATCH (loc_sujet,loc_corps,loc_sender,loc_journal, loc_erreur );
    IF loc_erreur IS NOT NULL THEN      
      P_INS_journal(1,loc_journal,'Mail impossible - '||loc_erreur,'KO');
    END IF;
    io_nb_lignes :=loc_journal.idligne;
    COMMIT;
    EXCEPTION
      WHEN exc_fin_traitement THEN 
        P_ENVOI_MAIL_BATCH (loc_sujet,loc_corps,loc_sender,loc_journal, loc_erreur );
        IF loc_erreur IS NOT NULL THEN      
          P_INS_journal(1,loc_journal,'Mail impossible - '||loc_erreur,'KO');
          io_nb_lignes :=loc_journal.idligne;
        END IF;
      WHEN OTHERS THEN
        --Si une anomalie technique est rencontrée, aucune mise à jour ne doit être effectuée.  
        P_INS_journal(1,loc_journal,'Erreur bloquante : traitement '||loc_journal.nom_traitement ||' non finalisé -'||SQLERRM,'KO');
        P_ENVOI_MAIL_BATCH (loc_sujet,loc_corps,loc_sender,loc_journal, loc_erreur );
        IF loc_erreur IS NOT NULL THEN      
          P_INS_journal(1,loc_journal,'Mail impossible - '||loc_erreur,'KO');
          io_nb_lignes :=loc_journal.idligne;
        END IF;
        ROLLBACK;
    
  END P_QG73T;

  ----------------------------------------------------------------------
  --fonction de contrôles de cohérence des états contrat ou adhésion
  --i_debut est la date cible du changement d'état
  FUNCTION F_CTRL_ETAT(i_numgar contrat.numgar%TYPE  ,i_idadhesion adhe_cntrt.idadhesion%TYPE, i_debut DATE, i_etat NUMBER) RETURN NUMBER IS
    loc_etat NUMBER;
    loc_debut DATE;
  BEGIN
    loc_etat:=NULL;
    IF i_idadhesion = 0 THEN
      loc_etat:= Pk_histo_contrat.f_sel_etat(i_numgar,i_debut);
    ELSE
      loc_etat:= f_etat_adhe(i_idadhesion ,i_debut,1);
    END IF;

    --	Si l’état est en vigueur => pas de blocage
    IF loc_etat =1 THEN
      RETURN 0;
    --si l'état cible est inférieur ou identique à l'état à date
    ELSIF i_etat<=loc_etat THEN
      RETURN 1;
    ELSIF loc_etat IN (2,3) THEN
      IF i_idadhesion = 0 THEN
        loc_debut:= Pk_histo_contrat.F_SEL_debut_etat(i_numgar,loc_etat,i_debut);
      ELSE
        loc_debut:= j2d(f_etat_adhe(i_idadhesion ,i_debut,3));
      END IF;
      
      --si le changement d'état est antérieur à l'état existant
      IF loc_debut>=i_debut THEN RETURN 1;
      ELSE RETURN 0; 
      END IF;
    END IF;

  END F_CTRL_ETAT;

  ----------------------------------------------------------------------
  --Suspension des adhesions individuelles ayant atteint le délai
  PROCEDURE P_suspension_adhe(i_date   IN  DATE ,i_motif NUMBER,  io_journal IN OUT journal_adm%ROWTYPE) IS

   /* -	Codope = 4 (cotisations)
  -	Numrelance = 20 suspension
  -	Date pivot traitement = date_emis – délai NVL(P2,0)  
  -	Annul_date is NULL (non annulée)
  -	Jointure avec qttc_global avec idadhesion <>0
  -	La facture ne doit pas être annulée
  -	La facture ne doit pas être régularisée
  -	La facture doit présenter un montant restant dû en accord avec le paramétrage (exemple de code dans en11 => attention aux devises en v6)
  */
    CURSOR C_emisAdSusp (p_date DATE) IS
    SELECT f.numfact , e.DATEMIS, q.numgar,q.idadhesion
    FROM facture f
    INNER JOIN emission e ON (e.numfact = f.numfact and e.codope =f.codope)
    INNER JOIN qttc_global q  ON (e.numfact = q.numquit)
    WHERE e.numrelance =20
    AND e.DATEMIS >=  p_date 
    AND e.DATEMIS < p_date+1 --pour éviter le trunc
    AND e.annul_date IS NULL
    AND f.codope = 4
    AND q.type_qttc <>3 --non prévisionnelle
    AND q.idadhesion <>0
    AND NOT EXISTS(SELECT numfact FROM facture_annul WHERE numfact = f.numfact)
    AND NOT EXISTS(SELECT numfact FROM facture_regul WHERE numfact_regul = f.numfact)  ;

    cpt_susp NUMBER :=0;

    --TODO trouver des contrats coll chez welcare dont l'idadhesion peut être valorisé... ???

  BEGIN


    FOR R_emisAdSusp IN C_emisAdSusp (i_date) LOOP
      IF f_montant_du(R_emisAdSusp.numfact,4,20)=0 THEN
        P_INS_journal(1,io_journal,'Montant dû nul pour la facture '|| R_emisAdSusp.numfact || ' suspension de l''adhésion '||R_emisAdSusp.idadhesion ||' non effectuée','KO');
        CONTINUE;
      END IF;

      --contrôle de l'état avant mise à  jour 
      IF F_CTRL_ETAT (R_emisAdSusp.numgar , R_emisAdSusp.idadhesion, R_emisAdSusp.datemis,2) = 1 THEN
        P_INS_journal(1,io_journal,'Action manuelle : un état susp/résil. existe au '||i_date|| ' suspension de l''adhésion '||R_emisAdSusp.idadhesion ||' impossible','KO');
        CONTINUE;
      END IF;
      --suspension de l'adhésion à date d'émission de la relance de niveau 20
      INSERT INTO HISTO_ADHESION (idadhesion,debut,datsai,etat,motif,numutil) 
      SELECT R_emisAdSusp.idadhesion,R_emisAdSusp.datemis,SYSDATE,2,i_motif, f_numutil
      FROM DUAL
      WHERE NOT EXISTS
        (SELECT 1
        FROM HISTO_ADHESION
        WHERE idadhesion = R_emisAdSusp.idadhesion
        AND debut = R_emisAdSusp.datemis
        AND etat IN(2,3)
        );

      IF SQL%ROWCOUNT =0 THEN     
        P_INS_journal(1,io_journal,'Action manuelle : contrôler la suspension  à '||i_date|| ' de l''adhesion '||R_emisAdSusp.idadhesion,'KO');
      ELSE
        cpt_susp:=cpt_susp+1;
      END IF;
    END LOOP;

    P_INS_journal(1,io_journal,'Nombre d''adhésions suspendues =  '||cpt_susp,'OK');

  END P_suspension_adhe;  


  ----------------------------------------------------------------------
  --Suspension des adhesions individuelles ayant atteint le délai
  PROCEDURE P_suspension_cntrt(i_date   IN  DATE ,i_motif NUMBER , io_journal IN OUT journal_adm%ROWTYPE) IS

   /* -	Codope = 4 (cotisations)
-	Numrelance = 20 suspension
-	Date pivot traitement = date_emis – délai NVL(P2,0)
-	Annul_date is NULL (non annulée)
-	Jointure avec qttc_global avec idadhesion =0
-	La facture ne doit pas être annulée
-	La facture ne doit pas être régularisée
-	La facture doit présenter un montant restant dû en accord avec le paramétrage (exemple de code dans en11 => attention aux devises en v6)

  */
    CURSOR C_emisCntrtSusp (p_date DATE) IS
    SELECT f.numfact , e.DATEMIS, q.numgar,q.idadhesion
    FROM facture f
    INNER JOIN emission e ON (e.numfact = f.numfact and e.codope =f.codope)
    INNER JOIN qttc_global q  ON (e.numfact = q.numquit)
    WHERE e.numrelance =20
    AND e.DATEMIS >=  p_date 
    AND e.DATEMIS < p_date+1 --pour éviter le trunc
    AND e.annul_date IS NULL
    AND f.codope = 4
    AND q.type_qttc <>3 --non prévisionnelle
    AND q.idadhesion =0
    AND NOT EXISTS(SELECT numfact FROM facture_annul WHERE numfact = f.numfact)
    AND NOT EXISTS(SELECT numfact FROM facture_regul WHERE numfact_regul = f.numfact)  ;


    cpt_susp NUMBER :=0;

    --TODO trouver des contrats coll chez welcare dont l'idadhesion peut être valorisé... ???
  BEGIN  

    FOR R_emisCntrtSusp IN C_emisCntrtSusp (i_date) LOOP
      IF f_montant_du(R_emisCntrtSusp.numfact,4,20)=0 THEN
        P_INS_journal(1,io_journal,'Montant dû nul pour la facture '|| R_emisCntrtSusp.numfact || ' suspension du contrat '||R_emisCntrtSusp.numgar ||' non effectuée','OK');
        CONTINUE;
      END IF;

      --contrôle de l'état avant mise à  jour 
      IF F_CTRL_ETAT (R_emisCntrtSusp.numgar , 0, R_emisCntrtSusp.datemis,2) = 1 THEN
        P_INS_journal(1,io_journal,'Action manuelle : un état susp/résil. existe au '||i_date|| ' suspension du contrat '||R_emisCntrtSusp.numgar ||' impossible','KO');
        CONTINUE;
      END IF;
      --suspension du contrat à date d'émission de la relance de niveau 20
      INSERT INTO HISTO_CONTRAT (numgar,debut,datsai,etat,motif,numutil) 
      SELECT R_emisCntrtSusp.numgar,R_emisCntrtSusp.datemis,SYSDATE,2,i_motif, f_numutil
      FROM DUAL
      WHERE NOT EXISTS
        (SELECT 1
        FROM HISTO_CONTRAT
        WHERE numgar = R_emisCntrtSusp.numgar
        AND debut = R_emisCntrtSusp.datemis
        AND etat IN(2,3)
        );

      IF SQL%ROWCOUNT =0 THEN
        P_INS_journal(1,io_journal,'Action manuelle : contrôler la suspension  à '||i_date|| ' de contrat '||R_emisCntrtSusp.numgar,'KO');
      ELSE
        cpt_susp := cpt_susp+1;
      END IF;

    END LOOP;
    P_INS_journal(1,io_journal,'Nombre de contrats suspendus =  '||cpt_susp,'OK');

  END P_suspension_cntrt;

  ----------------------------------------------------------------------
  --Résiliation des adhesions individuelles ayant atteint le délai
  PROCEDURE P_resiliation_adhe(i_date   IN  DATE ,i_motif NUMBER, io_journal IN OUT journal_adm%ROWTYPE) IS

   /* -	Codope = 4 (cotisations)
-	Numrelance = 30 résiliation
-	Date pivot traitement = date_emis – délai NVL(P3,0)
-	Annul_date is NULL (non annulée)
-	Jointure avec qttc_global avec idadhesion <>0
-	La facture ne doit pas être annulée
-	La facture ne doit pas être régularisée
-	La facture doit présenter un montant restant dû en accord avec le paramétrage (exemple de code dans en11 => attention aux devises en v6)
*/
    CURSOR C_emisAdResil (p_date DATE) IS
    SELECT f.numfact , e.DATEMIS, q.numgar,q.idadhesion,ad.numadhe
    FROM facture f
    INNER JOIN emission e ON (e.numfact = f.numfact and e.codope =f.codope)
    INNER JOIN qttc_global q  ON (e.numfact = q.numquit)
    INNER JOIN adhe_cntrt ad ON (ad.idadhesion = q.idadhesion)
    WHERE e.numrelance =30
    AND e.DATEMIS >=  p_date 
    AND e.DATEMIS < p_date+1 --pour éviter le trunc
    AND e.annul_date IS NULL
    AND f.codope = 4
    AND q.type_qttc <>3 --non prévisionnelle
    AND q.idadhesion <>0
    AND NOT EXISTS(SELECT numfact FROM facture_annul WHERE numfact = f.numfact)
    AND NOT EXISTS(SELECT numfact FROM facture_regul WHERE numfact_regul = f.numfact)  ;

    loc_ctrl NUMBER := 0;
    cpt_resil NUMBER :=0;

  BEGIN


    FOR R_emisAdResil IN C_emisAdResil (i_date) LOOP
      IF f_montant_du(R_emisAdResil.numfact,4,30)=0 THEN
        P_INS_journal(1,io_journal,'Montant dû nul pour la facture '|| R_emisAdResil.numfact || ' résiliation de l''adhésion '||R_emisAdResil.idadhesion ||' non effectuée','OK');
        CONTINUE;
      END IF;

      --contrôle de l'état avant mise à  jour 
      IF F_CTRL_ETAT (R_emisAdResil.numgar , R_emisAdResil.idadhesion, R_emisAdResil.datemis,3) = 1 THEN
        P_INS_journal(1,io_journal,'Action manuelle : un état susp/résil. existe au '||i_date|| ' résiliation de l''adhésion '||R_emisAdResil.idadhesion ||' impossible','KO');
        CONTINUE;
      END IF;
      --contrôle des cotisations de l'adhésion
      loc_ctrl := F_CTRL_COTIS_RESIL (R_emisAdResil.numgar , R_emisAdResil.idadhesion, R_emisAdResil.datemis, io_journal);
      --erreur sur les cotisations non bloquantes
      IF loc_ctrl <>0 THEN
        P_INS_journal(1,io_journal,'Action manuelle : contrôle des cotisations à réaliser suite à la résiliation de l''adhésion '||R_emisAdResil.idadhesion,'KO' );
        --CONTINUE;
        /*CASE loc_ctrl 
          WHEN 1 THEN NULL;
          WHEN 2 THEN NULL;
          WHEN 3 THEN NULL;
          WHEN 5 THEN NULL; 
          ELSE NULL;
        END CASE;  */
      END IF;

      --résiliation de l'adhésion avec forcage des dates de fin de couverture
      PK_TRANSFERT.p_resilie_adhe( R_emisAdResil.numgar
                                 , R_emisAdResil.idadhesion
                                 , R_emisAdResil.numadhe
                                 , i_motif
                                 , R_emisAdResil.datemis
                                 , f_numutil
                                 ,1) ;
--ToDO
      /*IF SQL%ROWCOUNT =0 THEN
      null;
      --message informatif => ya un pb
      ELSE
      null;
      END IF;*/
      cpt_resil := cpt_resil +1;
      -- annulation des cotisations du contrat
      P_ANNUL_COT_RESIL(R_emisAdResil.numgar , R_emisAdResil.idadhesion, R_emisAdResil.datemis);  
    END LOOP;
    P_INS_journal(1,io_journal,'Nombre d''adhésions résiliées =  '||cpt_resil,'OK');
  END P_resiliation_adhe;  


    ----------------------------------------------------------------------
  --Résiliation des contrats et adhésions collectives ayant atteint le délai
  PROCEDURE P_resiliation_cntrt(i_date   IN  DATE ,i_motif NUMBER , io_journal IN OUT journal_adm%ROWTYPE) IS

   /* -	Codope = 4 (cotisations)
-	Numrelance = 30 résiliation
-	Date pivot traitement = date_emis– délai NVL(P3,0)
-	Annul_date is NULL (non annulée)
-	Jointure avec qttc_global avec idadhesion =0
-	La facture ne doit pas être annulée
-	La facture ne doit pas être régularisée
-	La facture doit présenter un montant restant dû en accord avec le paramétrage (exemple de code dans en11 => attention aux devises en v6)
*/
    CURSOR C_emisCntrtResil (p_date DATE) IS
    SELECT f.numfact , e.DATEMIS, q.numgar,q.idadhesion
    FROM facture f
    INNER JOIN emission e ON (e.numfact = f.numfact and e.codope =f.codope)
    INNER JOIN qttc_global q  ON (e.numfact = q.numquit)
    WHERE e.numrelance =30
    AND e.DATEMIS >=  p_date 
    AND e.DATEMIS < p_date+1 --pour éviter le trunc
    AND e.annul_date IS NULL
    AND f.codope = 4
    AND q.type_qttc <>3 --non prévisionnelle
    AND q.idadhesion =0
    AND NOT EXISTS(SELECT numfact FROM facture_annul WHERE numfact = f.numfact)
    AND NOT EXISTS(SELECT numfact FROM facture_regul WHERE numfact_regul = f.numfact)  ;

    loc_ctrl NUMBER := 0;
    cpt_resil NUMBER :=0;

  BEGIN


    FOR R_emisCntrtResil IN C_emisCntrtResil (i_date) LOOP
      IF f_montant_du(R_emisCntrtResil.numfact,4,30)=0 THEN
        P_INS_journal(1,io_journal,'Montant dû nul pour la facture '|| R_emisCntrtResil.numfact || ' résiliation du contrat '||R_emisCntrtResil.numgar ||' non effectuée','OK');
        CONTINUE;
      END IF;

      --contrôle de l'état avant mise à  jour 
      IF F_CTRL_ETAT (R_emisCntrtResil.numgar , 0, R_emisCntrtResil.datemis,3) = 1 THEN
        P_INS_journal(1,io_journal,'Action manuelle : un état susp/résil. existe au '||i_date|| ' résiliation du contrat '||R_emisCntrtResil.numgar ||' impossible','KO');
        CONTINUE;
      END IF;
       --contrôle des cotisations du contrat
      loc_ctrl := F_CTRL_COTIS_RESIL (R_emisCntrtResil.numgar , 0, R_emisCntrtResil.datemis,io_journal);
      --erreur sur les cotisations non bloquantes
      IF loc_ctrl <>0 THEN
        P_INS_journal(1,io_journal,'Action manuelle : contrôle des cotisations à réaliser suite à la résiliation du contrat '||R_emisCntrtResil.numgar ,'KO');
        --CONTINUE;
        /*CASE loc_ctrl 
          WHEN 1 THEN NULL;
          WHEN 2 THEN NULL;
          WHEN 3 THEN NULL;
          WHEN 5 THEN NULL; 
          ELSE NULL;
        END CASE;  */
      END IF;

      --résiliation du contrat à date d'émission de la relance de niveau 30
      INSERT INTO HISTO_CONTRAT (numgar,debut,datsai,etat,motif,numutil) 
      SELECT R_emisCntrtResil.numgar,R_emisCntrtResil.datemis,SYSDATE,3,i_motif, f_numutil
      FROM DUAL
      WHERE NOT EXISTS
        (SELECT 1
        FROM HISTO_CONTRAT
        WHERE numgar = R_emisCntrtResil.numgar
        AND debut = R_emisCntrtResil.datemis
        AND etat IN(2,3)
        );

      IF SQL%ROWCOUNT =0 THEN
        P_INS_journal(1,io_journal,'Action manuelle : contrôler la résiliation  à '||i_date|| ' du contrat '||R_emisCntrtResil.numgar,'KO');
      ELSE
        cpt_resil := cpt_resil +1;
        -- annulation des cotisations du contrat
        P_ANNUL_COT_RESIL(R_emisCntrtResil.numgar , 0, R_emisCntrtResil.datemis);        
      END IF;
    END LOOP;
    P_INS_journal(1,io_journal,'Nombre de contrats résiliés =  '||cpt_resil,'OK');

  END P_resiliation_cntrt; 

  ----------------------------------------------------------------------
  --Contrôle de l'état des cotisation avant résiliation
  FUNCTION F_CTRL_COTIS_RESIL (i_numgar contrat.numgar%TYPE ,i_idadhesion adhe_cntrt.idadhesion%TYPE, i_debut DATE , io_journal IN OUT journal_adm%ROWTYPE) RETURN NUMBER IS

    --on vérifie toutes les cotisations de l'adhésion ou du contrat postérieures à la résiliation
    CURSOR C_COTIS_COMPTANT (p_debut DATE, p_idadhesion adhesion.idadhesion %TYPE,p_numgar contrat.numgar%TYPE ) IS
    SELECT  qg.numquit ,qg.mt_affec_d, qg.comptant, e.datemis,p.numprelev
    FROM QTTC_GLOBAL qg
      LEFT OUTER JOIN emission e ON (e.numfact=qg.numquit AND e.codope = 4 AND e.numrelance=0)
      LEFT OUTER JOIN prelevement_detail p ON (p.numfact = qg.numquit AND p.codope = 4 )
     WHERE qg.idadhesion=p_idadhesion
       AND qg.numgar = p_numgar
       AND p_debut < qg.fin
       AND NOT EXISTS (SELECT 1 FROM facture_regul WHERE numfact_regul = qg.numquit)
       AND NOT EXISTS (SELECT 1 FROM facture_annul where facture_annul.numfact =  qg.numquit AND codope =4) --non déjà annulée
       AND qg.type_qttc <> 3; --non prévsionnelle

    exc_affec              EXCEPTION;
    exc_emis               EXCEPTION;
    exc_prelev             EXCEPTION;
  BEGIN

  -- Parcours de l'ensemble des adhesions concernées par une radiation ==> la question se pose pour GEREP avec les montages avec des cotisants....

    FOR R_COTIS_COMPTANT IN C_COTIS_COMPTANT (i_debut ,i_idadhesion, i_numgar) LOOP
      --si la cotisation est prélevée, on vérifie qu'elle n'est pas prise dans un bordereau
      IF R_COTIS_COMPTANT.numprelev IS NOT NULL THEN
        P_INS_journal(1,io_journal,'Annulation cotisation impossible, facture '||R_COTIS_COMPTANT.numquit || ' en cours de prélèvement','KO');
        RAISE exc_prelev;

      --si au moins une cotisation est affectée, on n'annule aucune adhésion
      ELSIF NVL(R_COTIS_COMPTANT.mt_affec_d,0) >0 THEN
        P_INS_journal(1,io_journal,'Annulation cotisation impossible, facture '||R_COTIS_COMPTANT.numquit || ' partiellement affectée','KO');
        RAISE exc_affec;

      --si au moins une cotisatoin est émise  , on n'annule aucune adhésion
      /*ELSIF R_COTIS_COMPTANT.datemis IS NOT NULL THEN
        P_INS_journal(1,io_journal,'Annulation cotisation impossible, facture '||R_COTIS_COMPTANT.numquit || ' émise');
       RAISE exc_emis;*/
      END IF;

    END LOOP;
    RETURN 0;

  EXCEPTION
    WHEN exc_prelev THEN RETURN 1;
    WHEN exc_emis THEN RETURN 2;
    WHEN exc_affec THEN RETURN 3;
    WHEN OTHERS THEN 
      P_INS_journal(1,io_journal,'Annulation cotisation impossible, contrat '||i_numgar ||'/adh  '||i_idadhesion || ' Err :'||SQLERRM,'KO');
      RETURN 5 ;

  END F_CTRL_COTIS_RESIL;

  ----------------------------------------------------------------------
  --traitement des cotisations après résiliation (POST date de résiliation)
  PROCEDURE P_ANNUL_COT_RESIL (i_numgar contrat.numgar%TYPE ,i_idadhesion adhe_cntrt.idadhesion%TYPE, i_debut DATE)  IS

  CURSOR C_COTIS_ANN (P_DateResil DATE, P_idadhesion adhesion.idadhesion %TYPE,p_numgar contrat.numgar%TYPE ) IS
  SELECT  qg.numquit ,qg.mt_affec_d, qg.comptant, e.datemis,qg.debut,qg.type_qttc  
  FROM QTTC_GLOBAL qg
    LEFT OUTER JOIN emission e ON (e.numfact=qg.numquit AND e.codope = 4 AND e.numrelance=0)
   WHERE qg.idadhesion=P_idadhesion
     AND qg.numgar = p_numgar
     AND P_DateResil < qg.fin
     AND NOT EXISTS (SELECT 1 FROM facture_regul WHERE numfact_regul = qg.numquit)
     AND NOT EXISTS (SELECT 1 FROM facture_annul where facture_annul.numfact =  qg.numquit AND codope =4) --non déjà annulée
   ORDER BY qg.debut desc;

  BEGIN

    --recherche des cotisations à annuler
    FOR R_COTIS_ANN IN C_COTIS_ANN(i_debut ,i_idadhesion, i_numgar) LOOP
      BEGIN

      IF  R_COTIS_ANN.debut <= i_debut THEN --on annule pas la cotisation => TODO que fait-on des cotisations chevauchantes... => régul ?
        CONTINUE;
      END IF;

      --si la cotisation est prévisionnelleou non émise on la supprime => table audit qttc_delete
      IF R_COTIS_ANN.type_qttc = 3 OR  R_COTIS_ANN.datemis  IS NULL THEN        
        DELETE	qttc_global
        WHERE	qttc_global.numquit = R_COTIS_ANN.numquit;
      --annulation des cotisations émises
      ELSIF R_COTIS_ANN.datemis  IS NOT NULL THEN  
        --existance d'un TRG d'insertion dans facture_annul sur emission
        INSERT INTO emission (codope, numfact, numrelance, datemis, type_doc)
        SELECT 4,R_COTIS_ANN.numquit, 99, sysdate, 1 FROM dual
        WHERE NOT EXISTS (
        SELECT 1 FROM emission
        WHERE codope = 4
        AND numfact = R_COTIS_ANN.numquit
        AND numrelance = 99
        AND type_doc = 1);
      END IF;  


      EXCEPTION
        WHEN OTHERS THEN
          NULL; --à gérer
      END;
    END LOOP;

    --mise à jour de l'échéance suivante sur l'échéancier de cotisation
    --Nécéssaire en cas de règlement de la dette et donc suppression de la résiliation
    IF i_idadhesion <> 0 THEN
      PK_QTTC.P_MAJ_echesuiv(I_etendue=>13,I_cle => i_idadhesion);
    ELSIF f_numgar_ref(i_numgar) = i_numgar THEN
      PK_QTTC.P_MAJ_echesuiv(I_etendue=>2, I_cle => i_numgar);
    ELSE
      PK_QTTC.P_MAJ_echesuiv(I_etendue=>24, I_cle => i_numgar);
    END IF;

  END P_ANNUL_COT_RESIL;

 

-- ---------------------------------- Fin des corps des procedures publiques --

-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
  /*---------------------------------------------------------------------------*/
  /* PROCEDURE                                                                 */
  /* Nom          :  P_INS_journal                                             */
  /* Type         :  Public                                                    */
  /* Description  :  procedure d'insertion dans journal ADM                    */
  /* Retour       :                                                            */
  /*---------------------------------------------------------------------------*/
  PROCEDURE P_INS_journal(
        P_niv  IN NUMBER,
        p_journal IN OUT JOURNAL_ADM%ROWTYPE,
        P_msg  IN VARCHAR2,
        p_tracemail VARCHAR2 default NULL)
  IS
  BEGIN
     --dbms_output.put_line(P_msg);
     IF p_journal.niv_msg >= P_niv THEN
        p_journal.idligne := p_journal.idligne +1;
        PK_trace.P_INS_journal_adm ( I_nom_traitement => p_journal.nom_traitement, I_session => p_journal.id_session, I_niv_msg => P_niv, I_msg_adm => P_msg, I_idligne => p_journal.idligne);
     END IF;
     IF p_tracemail IS NOT NULL THEN
       PK_AUTO_FLUX.P_INS_AUTO_FLUX ( sysdate,
                                        p_journal.nom_traitement,
                                        p_journal.id_session ,
                                        NULL,
                                        p_tracemail,
                                        P_msg,
                                        0);
    END IF;
  END P_INS_journal;

-- ------------------------------------ Fin des corps des procedures privees --
END;
/
