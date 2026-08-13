CREATE OR REPLACE PACKAGE ARTHUS.PK_COTIS AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_cotis.sql  1.2  02/08/06

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
   comm_numquit   NUMBER DEFAULT 0;
   comm_numfor    NUMBER DEFAULT 0;
   comm_idaffec   NUMBER DEFAULT 0;

-- --------------------------------------------- Fin des variables publiques --

   -- -- PROCEDURES PUBLIQUES ----------------------------------------------------
--@pub
   FUNCTION totappel (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

-- Pragma Restrict_References(totappel, WNDS, WNPS);
   FUNCTION totappel_d (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION totbrut (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

-- Pragma Restrict_References(totbrut, WNDS, WNPS);
   FUNCTION totbrut_d (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION totgar (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

-- Pragma Restrict_References(totgar, WNDS, WNPS);
   FUNCTION totgar_d (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION totretro (
      a_numquit         IN   NUMBER,
      a_type_comm       IN   NUMBER DEFAULT NULL,
      a_numbene         IN   NUMBER DEFAULT NULL,
      a_numfor          IN   NUMBER DEFAULT NULL,
      a_prelev_revers   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

-- Pragma Restrict_References(totretro, WNDS, WNPS);
   FUNCTION totretro_d (
      a_numquit         IN   NUMBER,
      a_type_comm       IN   NUMBER DEFAULT NULL,
      a_numbene         IN   NUMBER DEFAULT NULL,
      a_numfor          IN   NUMBER DEFAULT NULL,
      a_prelev_revers   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION retro_regle (
      a_numquit      IN   NUMBER,
      a_mode_retro   IN   NUMBER,
      a_type_comm    IN   NUMBER DEFAULT NULL,
      a_numbene      IN   NUMBER DEFAULT NULL,
      a_numfor       IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

-- Pragma Restrict_References(retro_regle, WNDS, WNPS);
   FUNCTION retro_regle_d (
      a_numquit      IN   NUMBER,
      a_mode_retro   IN   NUMBER,
      a_type_comm    IN   NUMBER DEFAULT NULL,
      a_numbene      IN   NUMBER DEFAULT NULL,
      a_numfor       IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION retro_due (
      a_numquit     IN   NUMBER,
      a_type_comm   IN   NUMBER DEFAULT NULL,
      a_numbene     IN   NUMBER DEFAULT NULL,
      a_numfor      IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

-- Pragma Restrict_References(retro_due, WNDS, WNPS);
   FUNCTION retro_due_d (
      a_numquit     IN   NUMBER,
      a_type_comm   IN   NUMBER DEFAULT NULL,
      a_numbene     IN   NUMBER DEFAULT NULL,
      a_numfor      IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION totcomm (
      a_numquit     IN   NUMBER,
      a_numfor      IN   NUMBER DEFAULT NULL,
      a_numindiv    IN   NUMBER DEFAULT NULL,
      a_type_comm   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

-- Pragma Restrict_References(totcomm, WNDS, WNPS);
   FUNCTION totcomm_d (
      a_numquit     IN   NUMBER,
      a_numfor      IN   NUMBER DEFAULT NULL,
      a_numindiv    IN   NUMBER DEFAULT NULL,
      a_type_comm   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION totfrais (
      a_numquit      IN   NUMBER,
      a_numfor       IN   NUMBER DEFAULT NULL,
      a_numindiv     IN   NUMBER DEFAULT NULL,
      a_niveau       IN   NUMBER DEFAULT NULL,
      a_type_frais   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

-- Pragma Restrict_References(totfrais, WNDS, WNPS);
   FUNCTION totfrais_d (
      a_numquit      IN   NUMBER,
      a_numfor       IN   NUMBER DEFAULT NULL,
      a_numindiv     IN   NUMBER DEFAULT NULL,
      a_niveau       IN   NUMBER DEFAULT NULL,
      a_type_frais   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION tottaxe (
      a_numquit     IN   NUMBER,
      a_numfor      IN   NUMBER DEFAULT NULL,
      a_numindiv    IN   NUMBER DEFAULT NULL,
      a_type_taxe   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

-- Pragma Restrict_References(tottaxe, WNDS, WNPS);
   FUNCTION tottaxe_d (
      a_numquit     IN   NUMBER,
      a_numfor      IN   NUMBER DEFAULT NULL,
      a_numindiv    IN   NUMBER DEFAULT NULL,
      a_type_taxe   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION mt_affec (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

-- Pragma Restrict_References(mt_affec, WNDS, WNPS);
   FUNCTION mt_affec_d (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

   FUNCTION mt_affec_tfc (
      a_numquit    IN   NUMBER,
      a_idrevers   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_prelev     IN   NUMBER DEFAULT NULL,
      a_tfc        IN   NUMBER DEFAULT NULL,
      a_type       IN   NUMBER DEFAULT NULL,
      a_force      IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER;

-- Pragma Restrict_References(mt_affec_tfc, WNDS, WNPS);
   FUNCTION mt_affec_tfc_d (
      a_numquit    IN   NUMBER,
      a_idrevers   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_prelev     IN   NUMBER DEFAULT NULL,
      a_tfc        IN   NUMBER DEFAULT NULL,
      a_type       IN   NUMBER DEFAULT NULL,
      a_force      IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER;

   FUNCTION datemis (
      a_numquit      IN   NUMBER,
      a_numrelance   IN   NUMBER DEFAULT 0,
      a_type_doc     IN   NUMBER DEFAULT 1
   )
      RETURN DATE;

-- Pragma Restrict_References(datemis, WNDS, WNPS);
   FUNCTION comm_prelev (
      a_numquit    IN   NUMBER,
      a_idrevers   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_prelev     IN   NUMBER DEFAULT NULL,
      a_tfc        IN   NUMBER DEFAULT NULL,
      a_type       IN   NUMBER DEFAULT NULL,
      a_force      IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER;

-- Pragma Restrict_References(comm_prelev, WNDS, WNPS);
   FUNCTION comm_prelev_d (
      a_numquit    IN   NUMBER,
      a_idrevers   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_prelev     IN   NUMBER DEFAULT NULL,
      a_tfc        IN   NUMBER DEFAULT NULL,
      a_type       IN   NUMBER DEFAULT NULL,
      a_force      IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER;

-- NS 28-03-2005
   FUNCTION f_idcotis (a_type IN NUMBER, a_clef IN NUMBER)
      RETURN NUMBER;

--VDD : Calcul du montant dû en fonction du n° de quitance
  FUNCTION F_MONTANT_DU (
     a_numquit    IN   NUMBER,
     a_codope     IN   NUMBER,
     a_delai      IN   NUMBER,
     a_rappel     IN   NUMBER
  )
     RETURN NUMBER;

  FUNCTION F_MONTANT_DU_D (
     a_numquit    IN   NUMBER,
     a_codope     IN   NUMBER,
     a_delai      IN   NUMBER,
     a_rappel     IN   NUMBER
  )
     RETURN NUMBER;

-- -------------------------------------------- Fin des procedures publiques --
END PK_COTIS;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_COTIS AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_cotis.sql  1.2  02/08/06

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
-- Aucune
-- ----------------------------- Fin des declarations des procedures privees --

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
   FUNCTION totappel (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
   BEGIN
      RETURN (  totgar (a_numquit, a_numfor, a_numindiv)
              + totfrais (a_numquit, a_numfor)
             );
   END totappel;

--
-- Début d'une Fonction
--
   FUNCTION totappel_d (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
   BEGIN
      RETURN (  totgar_d (a_numquit, a_numfor, a_numindiv)
              + totfrais_d (a_numquit, a_numfor)
             );
   END totappel_d;

--
-- Début d'une Fonction
--
   FUNCTION totbrut (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
   BEGIN
      RETURN (  totgar (a_numquit, a_numfor, a_numindiv)
              - totcomm (a_numquit, a_numfor, a_numindiv)
              - tottaxe (a_numquit, a_numfor, a_numindiv)
             );
   END totbrut;

--
-- Début d'une Fonction
--
   FUNCTION totbrut_d (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
   BEGIN
      RETURN (  totgar_d (a_numquit, a_numfor, a_numindiv)
              - totcomm_d (a_numquit, a_numfor, a_numindiv)
              - tottaxe_d (a_numquit, a_numfor, a_numindiv)
             );
   END totbrut_d;

--
-- Début d'une Fonction
--
   FUNCTION totgar (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT   NVL (SUM (mt_ttc), 0)
             INTO loc_retour
             FROM qttc_gar
            WHERE numquit = a_numquit
              AND numfor = NVL (a_numfor, numfor)
              AND numindiv = NVL (a_numindiv, numindiv)
         GROUP BY DECODE (a_numindiv, '', numfor, '');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN (loc_retour);
   END totgar;

--
-- Début d'une Fonction
--
   FUNCTION totgar_d (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT   NVL (SUM (mt_ttc_d), 0)
             INTO loc_retour
             FROM qttc_gar
            WHERE numquit = a_numquit
              AND numfor = NVL (a_numfor, numfor)
              AND numindiv = NVL (a_numindiv, numindiv)
         GROUP BY DECODE (a_numindiv, '', numfor, '');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN (loc_retour);
   END totgar_d;

--
-- Début d'une Fonction
--
   FUNCTION totretro (
      a_numquit         IN   NUMBER,
      a_type_comm       IN   NUMBER DEFAULT NULL,
      a_numbene         IN   NUMBER DEFAULT NULL,
      a_numfor          IN   NUMBER DEFAULT NULL,
      a_prelev_revers   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT NVL (SUM (montant), 0)
           INTO loc_retour
           FROM qttc_retro
          WHERE numquit = a_numquit
            AND numfor = NVL (a_numfor, numfor)
            AND type_comm = NVL (a_type_comm, type_comm)
            AND numbene = NVL (a_numbene, numbene)
            AND prelev_revers = NVL (a_prelev_revers, prelev_revers);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN loc_retour;
   END totretro;

--
-- Début d'une Fonction
--
   FUNCTION totretro_d (
      a_numquit         IN   NUMBER,
      a_type_comm       IN   NUMBER DEFAULT NULL,
      a_numbene         IN   NUMBER DEFAULT NULL,
      a_numfor          IN   NUMBER DEFAULT NULL,
      a_prelev_revers   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT NVL (SUM (montant_d), 0)
           INTO loc_retour
           FROM qttc_retro
          WHERE numquit = a_numquit
            AND numfor = NVL (a_numfor, numfor)
            AND type_comm = NVL (a_type_comm, type_comm)
            AND numbene = NVL (a_numbene, numbene)
            AND prelev_revers = NVL (a_prelev_revers, prelev_revers);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN loc_retour;
   END totretro_d;

--
-- Début d'une Fonction
--
   FUNCTION retro_due (
      a_numquit     IN   NUMBER,
      a_type_comm   IN   NUMBER DEFAULT NULL,
      a_numbene     IN   NUMBER DEFAULT NULL,
      a_numfor      IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT NVL (SUM (montant), 0)
           INTO loc_retour
           FROM qttc_affec_tfc
          WHERE numquit = a_numquit
            AND tfc = 5
            AND type_tfc = NVL (a_type_comm, type_tfc)
            AND numbene = NVL (a_numbene, numbene)
            AND numfor = NVL (a_numfor, numfor)
            AND prelev_revers = 2
            AND idrevers = 0;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN loc_retour;
   END retro_due;

--
-- Début d'une Fonction
--
   FUNCTION retro_due_d (
      a_numquit     IN   NUMBER,
      a_type_comm   IN   NUMBER DEFAULT NULL,
      a_numbene     IN   NUMBER DEFAULT NULL,
      a_numfor      IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT NVL (SUM (montant_d), 0)
           INTO loc_retour
           FROM qttc_affec_tfc
          WHERE numquit = a_numquit
            AND tfc = 5
            AND type_tfc = NVL (a_type_comm, type_tfc)
            AND numbene = NVL (a_numbene, numbene)
            AND numfor = NVL (a_numfor, numfor)
            AND prelev_revers = 2
            AND idrevers = 0;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN loc_retour;
   END retro_due_d;

--
-- Début d'une Fonction
--
   FUNCTION retro_regle (
      a_numquit      IN   NUMBER,
      a_mode_retro   IN   NUMBER,
      a_type_comm    IN   NUMBER DEFAULT NULL,
      a_numbene      IN   NUMBER DEFAULT NULL,
      a_numfor       IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      IF (a_mode_retro = 1)
      THEN
         BEGIN
            SELECT NVL (SUM (montant), 0)
              INTO loc_retour
              FROM qttc_affec_tfc
             WHERE numquit = a_numquit
               AND tfc = 5
               AND prelev_revers = 1
               AND type_tfc = NVL (a_type_comm, type_tfc)
               AND numbene = NVL (a_numbene, numbene)
               AND numfor = NVL (a_numfor, numfor);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_retour := 0;
         END;
      ELSE
         BEGIN
            SELECT NVL (SUM (montant), 0)
              INTO loc_retour
              FROM qttc_affec_tfc
             WHERE numquit = a_numquit
               AND tfc = 5
               AND type_tfc = NVL (a_type_comm, type_tfc)
               AND numbene = NVL (a_numbene, numbene)
               AND numfor = NVL (a_numfor, numfor)
               AND idrevers > 0;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_retour := 0;
         END;
      END IF;

      RETURN loc_retour;
   END retro_regle;

--
-- Début d'une Fonction
--
   FUNCTION retro_regle_d (
      a_numquit      IN   NUMBER,
      a_mode_retro   IN   NUMBER,
      a_type_comm    IN   NUMBER DEFAULT NULL,
      a_numbene      IN   NUMBER DEFAULT NULL,
      a_numfor       IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      IF (a_mode_retro = 1)
      THEN
         BEGIN
            SELECT NVL (SUM (montant_d), 0)
              INTO loc_retour
              FROM qttc_affec_tfc
             WHERE numquit = a_numquit
               AND tfc = 5
               AND prelev_revers = 1
               AND type_tfc = NVL (a_type_comm, type_tfc)
               AND numbene = NVL (a_numbene, numbene)
               AND numfor = NVL (a_numfor, numfor);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_retour := 0;
         END;
      ELSE
         BEGIN
            SELECT NVL (SUM (montant_d), 0)
              INTO loc_retour
              FROM qttc_affec_tfc
             WHERE numquit = a_numquit
               AND tfc = 5
               AND type_tfc = NVL (a_type_comm, type_tfc)
               AND numbene = NVL (a_numbene, numbene)
               AND numfor = NVL (a_numfor, numfor)
               AND idrevers > 0;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               loc_retour := 0;
         END;
      END IF;

      RETURN loc_retour;
   END retro_regle_d;

--
-- Début d'une Fonction
--
   FUNCTION totcomm (
      a_numquit     IN   NUMBER,
      a_numfor      IN   NUMBER DEFAULT NULL,
      a_numindiv    IN   NUMBER DEFAULT NULL,
      a_type_comm   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT   NVL (SUM (montant), 0)
             INTO loc_retour
             FROM qttc_comm
            WHERE numquit = a_numquit
              AND numfor = NVL (a_numfor, numfor)
              AND numindiv = NVL (a_numindiv, numindiv)
              AND type_comm = NVL (a_type_comm, type_comm)
         GROUP BY DECODE (a_numindiv, '', numfor, '');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN loc_retour;
   END totcomm;

--
-- Début d'une Fonction
--
   FUNCTION totcomm_d (
      a_numquit     IN   NUMBER,
      a_numfor      IN   NUMBER DEFAULT NULL,
      a_numindiv    IN   NUMBER DEFAULT NULL,
      a_type_comm   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT   NVL (SUM (montant_d), 0)
             INTO loc_retour
             FROM qttc_comm
            WHERE numquit = a_numquit
              AND numfor = NVL (a_numfor, numfor)
              AND numindiv = NVL (a_numindiv, numindiv)
              AND type_comm = NVL (a_type_comm, type_comm)
         GROUP BY DECODE (a_numindiv, '', numfor, '');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN loc_retour;
   END totcomm_d;

--
-- Début d'une Fonction
--
   FUNCTION totfrais (
      a_numquit      IN   NUMBER,
      a_numfor       IN   NUMBER DEFAULT NULL,
      a_numindiv     IN   NUMBER DEFAULT NULL,
      a_niveau       IN   NUMBER DEFAULT NULL,
      a_type_frais   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT   NVL (SUM (montant), 0)
             INTO loc_retour
             FROM qttc_frais
            WHERE numquit = a_numquit
              AND numfor = NVL (a_numfor, numfor)
              AND numfor != NVL (a_niveau, -1)
              AND numindiv = NVL (a_numindiv, numindiv)
              AND type_frais = NVL (a_type_frais, type_frais)
         GROUP BY DECODE (a_numindiv, '', numfor, '');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN (loc_retour);
   END totfrais;

--
-- Début d'une Fonction
--
   FUNCTION totfrais_d (
      a_numquit      IN   NUMBER,
      a_numfor       IN   NUMBER DEFAULT NULL,
      a_numindiv     IN   NUMBER DEFAULT NULL,
      a_niveau       IN   NUMBER DEFAULT NULL,
      a_type_frais   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT   NVL (SUM (montant_d), 0)
             INTO loc_retour
             FROM qttc_frais
            WHERE numquit = a_numquit
              AND numfor = NVL (a_numfor, numfor)
              AND numfor != NVL (a_niveau, -1)
              AND numindiv = NVL (a_numindiv, numindiv)
              AND type_frais = NVL (a_type_frais, type_frais)
         GROUP BY DECODE (a_numindiv, '', numfor, '');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN (loc_retour);
   END totfrais_d;

--
-- Début d'une Fonction
--
   FUNCTION tottaxe (
      a_numquit     IN   NUMBER,
      a_numfor      IN   NUMBER DEFAULT NULL,
      a_numindiv    IN   NUMBER DEFAULT NULL,
      a_type_taxe   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT   NVL (SUM (montant), 0)
             INTO loc_retour
             FROM qttc_taxe
            WHERE numquit = a_numquit
              AND numfor = NVL (a_numfor, numfor)
              AND numindiv = NVL (a_numindiv, numindiv)
              AND type_taxe = NVL (a_type_taxe, type_taxe)
         GROUP BY DECODE (a_numindiv, '', numfor, '');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN loc_retour;
   END tottaxe;

--
-- Début d'une Fonction
--
   FUNCTION tottaxe_d (
      a_numquit     IN   NUMBER,
      a_numfor      IN   NUMBER DEFAULT NULL,
      a_numindiv    IN   NUMBER DEFAULT NULL,
      a_type_taxe   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT   NVL (SUM (montant_d), 0)
             INTO loc_retour
             FROM qttc_taxe
            WHERE numquit = a_numquit
              AND numfor = NVL (a_numfor, numfor)
              AND numindiv = NVL (a_numindiv, numindiv)
              AND type_taxe = NVL (a_type_taxe, type_taxe)
         GROUP BY DECODE (a_numindiv, '', numfor, '');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN loc_retour;
   END tottaxe_d;

--
-- Début d'une Fonction
--
   FUNCTION mt_affec (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT   NVL (SUM (montant), 0)
             INTO loc_retour
             FROM qttc_affec
            WHERE numquit = a_numquit
              AND numfor = NVL (a_numfor, numfor)
              AND numindiv = NVL (a_numindiv, numindiv)
              AND idaffec = NVL (a_idaffec, idaffec)
              AND idgar != 0
         GROUP BY DECODE (a_numindiv, '', numfor, '');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN (loc_retour);
   END mt_affec;

--
-- Début d'une Fonction
--
   FUNCTION mt_affec_d (
      a_numquit    IN   NUMBER,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_numindiv   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT   NVL (SUM (montant_d), 0)
             INTO loc_retour
             FROM qttc_affec
            WHERE numquit = a_numquit
              AND numfor = NVL (a_numfor, numfor)
              AND numindiv = NVL (a_numindiv, numindiv)
              AND idaffec = NVL (a_idaffec, idaffec)
              AND idgar != 0
         GROUP BY DECODE (a_numindiv, '', numfor, '');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN (loc_retour);
   END mt_affec_d;

--
-- Début d'une Fonction
--
   FUNCTION mt_affec_tfc (
      a_numquit    IN   NUMBER,
      a_idrevers   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_prelev     IN   NUMBER DEFAULT NULL,
      a_tfc        IN   NUMBER DEFAULT NULL,
      a_type       IN   NUMBER DEFAULT NULL,
      a_force      IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT NVL (SUM (montant), 0)
           INTO loc_retour
           FROM qttc_affec_tfc
          WHERE numquit = a_numquit
            AND NVL (prelev_revers, 1) = NVL (a_prelev, 1)
            AND idrevers = NVL (a_idrevers, idrevers)
            AND idaffec = NVL (a_idaffec, idaffec)
            AND numfor = NVL (a_numfor, numfor)
            AND tfc = NVL (a_tfc, tfc)
            AND type_tfc = NVL (a_type, type_tfc);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN (loc_retour);
   END mt_affec_tfc;

--
-- Début d'une Fonction
--
   FUNCTION mt_affec_tfc_d (
      a_numquit    IN   NUMBER,
      a_idrevers   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_prelev     IN   NUMBER DEFAULT NULL,
      a_tfc        IN   NUMBER DEFAULT NULL,
      a_type       IN   NUMBER DEFAULT NULL,
      a_force      IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      BEGIN
         SELECT NVL (SUM (montant_d), 0)
           INTO loc_retour
           FROM qttc_affec_tfc
          WHERE numquit = a_numquit
            AND NVL (prelev_revers, 1) = NVL (a_prelev, 1)
            AND idrevers = NVL (a_idrevers, idrevers)
            AND idaffec = NVL (a_idaffec, idaffec)
            AND numfor = NVL (a_numfor, numfor)
            AND tfc = NVL (a_tfc, tfc)
            AND type_tfc = NVL (a_type, type_tfc);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := 0;
      END;

      RETURN (loc_retour);
   END mt_affec_tfc_d;

--
-- Début d'une Fonction
--
   FUNCTION comm_prelev (
      a_numquit    IN   NUMBER,
      a_idrevers   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_prelev     IN   NUMBER DEFAULT NULL,
      a_tfc        IN   NUMBER DEFAULT NULL,
      a_type       IN   NUMBER DEFAULT NULL,
      a_force      IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
   BEGIN
      RETURN (mt_affec_tfc (a_numquit,
                            a_idrevers,
                            a_idaffec,
                            a_numfor,
                            a_prelev,
                            a_tfc,
                            a_type,
                            a_force
                           )
             );
   END comm_prelev;

--
-- Début d'une Fonction
--
   FUNCTION comm_prelev_d (
      a_numquit    IN   NUMBER,
      a_idrevers   IN   NUMBER DEFAULT NULL,
      a_idaffec    IN   NUMBER DEFAULT NULL,
      a_numfor     IN   NUMBER DEFAULT NULL,
      a_prelev     IN   NUMBER DEFAULT NULL,
      a_tfc        IN   NUMBER DEFAULT NULL,
      a_type       IN   NUMBER DEFAULT NULL,
      a_force      IN   NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
   BEGIN
      RETURN (mt_affec_tfc_d (a_numquit,
                              a_idrevers,
                              a_idaffec,
                              a_numfor,
                              a_prelev,
                              a_tfc,
                              a_type,
                              a_force
                             )
             );
   END comm_prelev_d;

--
-- Début d'une Fonction
--
   FUNCTION datemis (
      a_numquit      IN   NUMBER,
      a_numrelance   IN   NUMBER DEFAULT 0,
      a_type_doc     IN   NUMBER DEFAULT 1
   )
      RETURN DATE
   IS
      loc_retour   DATE;
   BEGIN
      BEGIN
         SELECT datemis
           INTO loc_retour
           FROM emission
          WHERE codope = 4
            AND numfact = a_numquit
            AND numrelance = a_numrelance
            AND type_doc = a_type_doc
            AND NOT EXISTS (
                   SELECT 1
                     FROM emission
                    WHERE codope = 4
                      AND numfact = a_numquit
                      AND numrelance IN (4, 99));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            loc_retour := NULL;
      END;

      RETURN (loc_retour);
   END datemis;

--
-- Début d'une Fonction
--
   FUNCTION f_idcotis (a_type IN NUMBER, a_clef IN NUMBER)
      RETURN NUMBER
   AS
      loc_retour   NUMBER       DEFAULT 0;

      CURSOR c1
      IS
         SELECT ALL qttc_global.idadhesion, qttc_global.numgar,
                    qttc_global.numquerable
               FROM qttc_global
              WHERE qttc_global.numquit = a_clef;

      r1           c1%ROWTYPE;
   BEGIN
      OPEN c1;

      FETCH c1
       INTO r1;

      IF a_type = 1 AND r1.idadhesion = 0
      THEN
         loc_retour := r1.numgar;
      ELSIF a_type = 1 AND r1.idadhesion <> 0
      THEN
         loc_retour := r1.idadhesion;
      ELSIF a_type = 2
      THEN
         loc_retour := r1.numquerable;
      ELSIF a_type = 3
      THEN
         loc_retour := r1.numgar;
      ELSE
         IF r1.idadhesion = 0
         THEN
            loc_retour := f_type_numgar (r1.numgar);
         ELSE
            loc_retour := 4;
         END IF;
      END IF;

      CLOSE c1;

      RETURN (loc_retour);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (0);

         CLOSE c1;
   END f_idcotis;


  --VDD : Calcul du montant dû en fonction du n° de quitance
  FUNCTION F_MONTANT_DU (
     a_numquit IN NUMBER,
     a_codope  IN NUMBER,
     a_delai   IN NUMBER,
     a_rappel  IN NUMBER
  )
     RETURN NUMBER
  AS
     loc_montant   NUMBER;
  BEGIN
     SELECT   SUM(facture.montant)
            - SUM(NVL(f_totaffec(facture.numfact, facture.codope),0))
       INTO loc_montant
       FROM facture
      WHERE facture.numfact = a_numquit
        AND facture.codope = a_codope
        AND facture.montant > (NVL(f_totaffec(facture.numfact, facture.codope),0))
        AND NOT EXISTS (
               SELECT 1
                 FROM qttc_global
                WHERE codope = a_codope
                  AND qttc_global.numquit = facture.numfact
                  AND qttc_global.type_qttc = 3)
        AND numfact IN (
               SELECT numquit
                 FROM qttc_global
                WHERE type_qttc != 3
                  AND numquit = facture.numfact
                  AND codope  = facture.codope)
        AND (   (a_rappel = 0)
             OR (    a_rappel != 0
                 AND numfact IN (
                        SELECT numfact
                          FROM emission, qttc_global
                         WHERE qttc_global.numquit = facture.numfact
                           AND emission.codope = facture.codope
                           AND qttc_global.numquit = emission.numfact
                           AND qttc_global.type_qttc != 3
                           AND emission.type_doc = 1
                           AND emission.numrelance = (a_rappel - 1)
                           AND SYSDATE >
                                  GREATEST (emission.datemis + a_delai,
                                            qttc_global.debut + a_delai
                                           ))
                )
            )
        AND NOT EXISTS (
               SELECT 1
                 FROM facture_regul
                WHERE facture_regul.codope = facture.codope
                  AND facture_regul.numfact_regul = facture.numfact);

     RETURN NVL(loc_montant,0);
  EXCEPTION
    WHEN OTHERS THEN RETURN (0);
  END;

  FUNCTION F_MONTANT_DU_D (
     a_numquit    IN   NUMBER,
     a_codope     IN   NUMBER,
     a_delai      IN   NUMBER,
     a_rappel     IN   NUMBER
  )
     RETURN NUMBER
  AS
     loc_montant   NUMBER;
  BEGIN
     SELECT   SUM(facture.montant_d)
            - SUM(NVL(f_totaffec_d (facture.numfact, facture.codope), 0))
       INTO loc_montant
       FROM facture
      WHERE facture.numfact = a_numquit
        AND facture.codope = a_codope
        AND facture.montant_d > NVL(f_totaffec_d(facture.numfact, facture.codope), 0)
        AND NOT EXISTS (
               SELECT 1
                 FROM qttc_global
                WHERE codope = a_codope
                  AND qttc_global.numquit = facture.numfact
                  AND qttc_global.type_qttc = 3)
        AND numfact IN (
               SELECT numquit
                 FROM qttc_global
                WHERE type_qttc != 3
                  AND numquit = facture.numfact
                  AND codope  = facture.codope)
        AND (   (a_rappel = 0)
             OR (    a_rappel != 0
                 AND numfact IN (
                        SELECT numfact
                          FROM emission, qttc_global
                         WHERE qttc_global.numquit = facture.numfact
                           AND emission.codope = facture.codope
                           AND qttc_global.numquit = emission.numfact
                           AND qttc_global.type_qttc != 3
                           AND emission.type_doc = 1
                           AND emission.numrelance = (a_rappel - 1)
                           AND SYSDATE >
                                  GREATEST (emission.datemis + a_delai,
                                            qttc_global.debut + a_delai
                                           ))
                )
            )
        AND NOT EXISTS (
               SELECT 1
                 FROM facture_regul
                WHERE facture_regul.codope = facture.codope
                  AND facture_regul.numfact_regul = facture.numfact);

     RETURN NVL(loc_montant,0);
  EXCEPTION
    WHEN OTHERS THEN RETURN (0);
  END;

-- ---------------------------------- Fin des corps des procedures publiques --

-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --
END PK_COTIS;
/
