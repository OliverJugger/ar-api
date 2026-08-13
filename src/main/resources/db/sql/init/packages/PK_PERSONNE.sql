CREATE OR REPLACE PACKAGE ARTHUS.PK_PERSONNE
IS
/*============================================================================*/
/* PACKAGE      : PK_PERSONNE.sql                                             */
/* Domaine      : PERSONNE                                                    */
/* Version      :                                                             */
/* Auteur       :                                                             */
/* Création     : 25/10/2011                                                  */
/* Description  : gestion de la personne                                      */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/*============================================================================*/
/*  SDA 25/10/2011                                                           */
/*     mise en place cartouche + mise au norme nomenclature pk                */
/*     ajout des functions lot 2 - commisionnement unique                     */
/*       F_INSERT_PERS_ADRESSE                                                */
/*       F_INSERT_INDIVIDU                                                    */
/*       F_INSERT_PERS_MORALE                                                 */
/*  TLE 06/06/2013 - MANTIS 3768 : modification de f_nom_abrege               */
/*  JBO 03/06/2013 - Projet CAPRA Affiliation : F_INSERT_PERS_HISTO_PHYS      */
/*============================================================================*/

-- Chaine de reconnaissance SCCS
-- %W% Gestion des personnes adresses et situation  %E%
   FUNCTION f_decompose (a_chaine IN VARCHAR2, a_indice IN NUMBER)
      RETURN VARCHAR2;

-- Pragma Restrict_References(f_decompose, WNDS);
   FUNCTION f_recompose (
      a_novoie      IN   NUMBER,
      a_bis         IN   VARCHAR2,
      a_type_voie   IN   VARCHAR2,
      a_nom_voie    IN   VARCHAR2,
      a_longueur    IN   NUMBER,
      a_flag        IN   NUMBER DEFAULT 0
   )
      RETURN VARCHAR2;

-- Pragma Restrict_References(f_recompose, WNDS);
   PROCEDURE lit_un_mot (
      loc_chaine   IN       VARCHAR2,
      mot          OUT      VARCHAR2,
      reste        OUT      VARCHAR2
   );

--David 26/05/2004
--Pragma Restrict_References(Lit_un_mot, WNDS);
   FUNCTION is_a_separateur (a_chaine IN VARCHAR2, a_separateur IN VARCHAR2)
      RETURN BOOLEAN;

--David 26/05/2004
--Pragma Restrict_References(is_a_separateur, WNDS);
   FUNCTION f_init_chaine (a_chaine IN VARCHAR2)
      RETURN BOOLEAN;

--David 26/05/2004
--Pragma Restrict_References(f_init_chaine, WNDS);
   FUNCTION f_abrege (
      a_chaine   IN   VARCHAR2,
      a_mnemo    IN   VARCHAR2,
      a_sens     IN   NUMBER DEFAULT 1
   )
      RETURN VARCHAR2;

-- Pragma Restrict_References(f_abrege, WNDS);
   FUNCTION f_concatene (
      a_gauche       IN   VARCHAR2,
      a_droite       IN   VARCHAR2,
      a_separateur   IN   VARCHAR2 DEFAULT ' '
   )
      RETURN VARCHAR2;

--David 26/05/2004
--Pragma Restrict_References(f_concatene, WNDS);
   FUNCTION f_idadresse (
      a_numindiv   IN   NUMBER,
      a_codope     IN   NUMBER DEFAULT 0,
      a_debut      IN   DATE DEFAULT SYSDATE,
      a_defaut     IN   VARCHAR2 DEFAULT 'O',
      a_numgar     IN   NUMBER DEFAULT 0,
      a_type_adr   IN   NUMBER DEFAULT -1
   )
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(f_idadresse, WNDS);
   FUNCTION f_idrib (
      a_numindiv   IN   NUMBER,
      a_dec_enc    IN   NUMBER DEFAULT 1,
      a_debut      IN   DATE DEFAULT SYSDATE,
      a_codope     IN   NUMBER DEFAULT 0,
      a_numgar     IN   NUMBER DEFAULT 0
   )
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(f_idrib, WNDS);
   FUNCTION f_adresse (
      a_idadresse   IN   NUMBER,
      a_indice      IN   NUMBER,
      a_numindiv    IN   NUMBER DEFAULT 0,
      a_force       IN   NUMBER DEFAULT 0,
      a_codope      IN   NUMBER DEFAULT 0
   )
      RETURN VARCHAR2;

-- VCR 15/04/2009
-- Modification de l'appel à f_adresse dans les éditions courriers
   FUNCTION f_adresse (
      a_idadresse   IN   NUMBER,
      a_indice      IN   NUMBER,
      a_numindiv    IN   NUMBER DEFAULT 0,
      a_force       IN   NUMBER DEFAULT 0,
      a_codope      IN   NUMBER DEFAULT 0,
	  a_interloc    IN NUMBER
   )
      RETURN VARCHAR2;

-- Pragma Restrict_References(f_adresse, WNDS);
   FUNCTION f_nom (
      a_numindiv   IN   NUMBER,
      a_longueur   IN   NUMBER DEFAULT 32,
      a_type       IN   NUMBER DEFAULT 0
   --a_trop_long     in Number       Default 0
   )
      RETURN VARCHAR2;

-- Pragma Restrict_References(f_nom, WNDS);
   FUNCTION f_nom_inv (
      a_numindiv   IN   NUMBER,
      a_longueur   IN   NUMBER DEFAULT 32,
      a_type       IN   NUMBER DEFAULT 0
   --a_trop_long     in Number       Default 0
   )
      RETURN VARCHAR2;

-- Pragma Restrict_References(f_nom_inv, WNDS);
   PROCEDURE p_info_morale (
      i_numindiv      IN       NUMBER,
      io_siret_naf    IN OUT   VARCHAR2,
      io_convention   IN OUT   VARCHAR2,
      io_situation    IN OUT   VARCHAR2,
      io_chiffre      IN OUT   VARCHAR2,
      io_masse_sal    IN OUT   VARCHAR2,
      io_capital      IN OUT   VARCHAR2,
      io_effectif     IN OUT   VARCHAR2
   );

--
   PROCEDURE p_nomjf (
      i_numindiv   IN       NUMBER,
      io_nomjf     IN OUT   VARCHAR2,
      io_datnais   IN OUT   VARCHAR2
   );

   FUNCTION f_numassu (a_numindiv IN NUMBER)
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(f_numassu, WNDS);
   FUNCTION f_situ_phys (
      a_numindiv   IN   NUMBER,
      a_indice     IN   NUMBER,
      a_date       IN   DATE DEFAULT SYSDATE
   )
      RETURN VARCHAR2;

--David 26/05/2004
--Pragma Restrict_References(f_situ_phys, WNDS);
   FUNCTION f_situ_pers (
      a_numindiv   IN   NUMBER,
      a_indice     IN   NUMBER,
      a_date       IN   DATE DEFAULT SYSDATE
   )
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(f_situ_pers, WNDS);
   FUNCTION f_nom_compta (a_numindiv IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_dependance (
      a_numindiv   IN   NUMBER,
      a_role       IN   NUMBER,
      a_date       IN   DATE
   )
      RETURN NUMBER;

   PROCEDURE init_abrege;


FUNCTION F_INSERT_INDIVIDU (
                 i_indivdu  IN  INDIVIDU%ROWTYPE,O_erreur OUT VARCHAR2
)
RETURN BOOLEAN;

FUNCTION F_INSERT_PERS_HISTO_PHYS( P_PERS_HISTO_PHYS IN PERS_HISTO_PHYS%ROWTYPE)
RETURN BOOLEAN;

FUNCTION F_INSERT_PERS_MORALE  (
                 i_pers_morale  IN  PERS_MORALE%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION F_INSERT_PERS_ADRESSE  (
                i_pers_adresse   IN PERS_ADRESSE%ROWTYPE
)
RETURN BOOLEAN;

FUNCTION F_INSERT_PERS_HISTO_MORALE  (
                i_pers_histo_morale in PERS_HISTO_MORALE%ROWTYPE
)
RETURN BOOLEAN;

--ABO 23/11/2010
--Réinitialisation de la globale avant appel de f_decompose pour projet WS TPO
FUNCTION f_appel_decompose (a_chaine IN VARCHAR2, a_indice IN NUMBER)
  RETURN VARCHAR2;

-- Pragma Restrict_References(Init_abrege, WNDS);
CURSOR fetch_abrege (a_mnemo VARCHAR2)
IS
  SELECT libelle_bis.code, libelle_bis.libelle
    FROM libelle_bis
   WHERE mnemo = a_mnemo AND code NOT IN ('-2', '-3');

TYPE tab_info_morale IS TABLE OF VARCHAR2 (42)
  INDEX BY BINARY_INTEGER;

TYPE adresse IS TABLE OF VARCHAR2 (33)
  INDEX BY BINARY_INTEGER;

TYPE court IS TABLE OF VARCHAR2 (6)
  INDEX BY BINARY_INTEGER;

TYPE code IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

t_adresse                     adresse;
t_situ                        adresse;
t_long                        adresse;
t_court                       court;
t_situ_pers                   code;
nb_abrege                     BINARY_INTEGER         := 0;
t_voie1                       VARCHAR2 (32);
t_voie2                       VARCHAR2 (32);
t_voie3                       VARCHAR2 (32);
t_voie4                       VARCHAR2 (32);
comm_date                     DATE                   := SYSDATE - 1000000;
comm_numindiv                 NUMBER                 := -1;
comm_idadresse                NUMBER                 := -1;
loc_chaine                    VARCHAR2 (40);
abrege                        fetch_abrege%ROWTYPE;
--
-- Constantes Globales
cst_glob_situation   CONSTANT VARCHAR2 (24)  DEFAULT 'Situation inconnue ';
cst_glob_tiret       CONSTANT VARCHAR2 (2)           DEFAULT '- ';
--
-- Fin des Constantes Globales
END pk_personne;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.PK_PERSONNE
IS

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  is_too_long                                                 */
/* Type         :  Privee                                                      */
/* Description  :  Test si la chaine est trop longue                           */
/* Entree       :  i_chaine IN VARCHAR2,i_longueur IN NUMBER                   */
/* Sortie       :  BOOLEAN                                                     */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION is_too_long (i_chaine IN VARCHAR2, i_longueur IN NUMBER)
RETURN BOOLEAN;


FUNCTION is_too_long (i_chaine IN VARCHAR2, i_longueur IN NUMBER)
  RETURN BOOLEAN
IS
BEGIN
  RETURN (LENGTH (i_chaine) > i_longueur);
END is_too_long;

/*-----------------------------------------------------------------------------*/
/* PROCEDURE                                                                   */
/* Nom          :  init_abrege                                                 */
/* Type         :                                                              */
/* Description  :  initialisation de long et court de type de voie             */
/* Entree       :                                                              */
/* Sortie       :                                                              */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/


PROCEDURE init_abrege
IS
BEGIN
  FOR abrege IN fetch_abrege ('ABREGE')
  LOOP
     nb_abrege := nb_abrege + 1;
     t_court (nb_abrege) := abrege.code;
     t_long (nb_abrege) := abrege.libelle;
  END LOOP;

  FOR abrege IN fetch_abrege ('TYPE_VOIE')
  LOOP
     nb_abrege := nb_abrege + 1;
     t_court (nb_abrege) := abrege.code;
     t_long (nb_abrege) := abrege.libelle;
  END LOOP;
END init_abrege;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_init_chaine                                               */
/* Type         :                                                              */
/* Description  :  initialise chaine type voie                                 */
/* Entree       :  a_chaine                                                    */
/* Sortie       :  BOOLEAN                                                     */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_init_chaine (a_chaine IN VARCHAR2)
  RETURN BOOLEAN
IS
  i   NUMBER;
BEGIN
  IF ((a_chaine != loc_chaine) OR (loc_chaine IS NULL))
  THEN
     loc_chaine := a_chaine;
     t_voie1 := NULL;
     t_voie2 := NULL;
     t_voie3 := NULL;
     t_voie4 := NULL;
-- For i in 1 .. 4 Loop
--    t_voie( i ) := Null;
--    End loop;
     RETURN (TRUE);
  END IF;

  RETURN (FALSE);
END f_init_chaine;


/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_situ_pers                                                 */
/* Type         :                                                              */
/* Description  :  retourne la situation de la personne                        */
/* Entree       :  a_numindiv   IN   NUMBER,                                   */
/*                 a_indice     IN   NUMBER,                                   */
/*                 a_date       IN   DATE DEFAULT SYSDATE                      */
/* Sortie       :  NUMBER                                                      */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/



FUNCTION f_situ_pers (
  a_numindiv   IN   NUMBER,
  a_indice     IN   NUMBER,
  a_date       IN   DATE DEFAULT SYSDATE
)
  RETURN NUMBER
IS
  i          BINARY_INTEGER            := 0;
  c_situ     pers_histo_phys%ROWTYPE;
  loc_date   DATE                      := a_date;
BEGIN
  IF (a_numindiv != comm_numindiv OR a_date != comm_date)
  THEN
     FOR i IN 1 .. 7
     LOOP
        t_situ_pers (i) := NULL;
     END LOOP;

     comm_numindiv := a_numindiv;
     comm_date := a_date;
  ELSE
     GOTO retourne;
  END IF;

  <<recommence>>
  FOR c_situ IN (SELECT   debut, situ_fam, situ_prof, csp_1, csp_2,
                          profession, salaire
                     FROM pers_histo_phys
                    WHERE numindiv = a_numindiv
                      AND debut <= NVL (loc_date, debut)
                 ORDER BY debut DESC)
  LOOP
     t_situ_pers (1) := d2j (c_situ.debut);
     t_situ_pers (2) := c_situ.situ_fam;
     t_situ_pers (3) := c_situ.situ_prof;
     t_situ_pers (4) := c_situ.profession;
     t_situ_pers (5) := c_situ.csp_2;
     t_situ_pers (6) := c_situ.csp_1;
     t_situ_pers (7) := c_situ.salaire;
     EXIT;
  END LOOP;

  IF (t_situ_pers (1) IS NULL)
  THEN
     IF (a_date = loc_date)
     THEN
        loc_date := NULL;
        GOTO recommence;
     END IF;
  END IF;

  <<retourne>>
  RETURN (t_situ_pers (a_indice));
END f_situ_pers;

FUNCTION f_situ_phys (
  a_numindiv   IN   NUMBER,
  a_indice     IN   NUMBER,
  a_date       IN   DATE DEFAULT SYSDATE
)
  RETURN VARCHAR2
IS
  CURSOR c_situ_phys
  IS
     SELECT   debut, situ_fam, situ_prof, csp_1, csp_2, profession,
              salaire
         FROM pers_histo_phys
        WHERE numindiv = a_numindiv AND debut <= a_date
     ORDER BY debut DESC;

--
  c_situ   c_situ_phys%ROWTYPE;
--
  i        BINARY_INTEGER        := 0;
--
BEGIN
  IF (a_numindiv != comm_numindiv OR a_date != comm_date)
  THEN
     --
     -- Initialisation du tableau
     FOR i IN 1 .. 7
     LOOP
        IF i = 1
        THEN
           t_situ (i) := cst_glob_situation;
        ELSE
           t_situ (i) := NULL;
        END IF;
     END LOOP;

     --
     comm_numindiv := a_numindiv;
     comm_date := a_date;

     --
     OPEN c_situ_phys;

     FETCH c_situ_phys
      INTO c_situ;

     IF c_situ_phys%FOUND
     THEN
        i := 1;

        IF c_situ.debut IS NOT NULL
        THEN
           t_situ (i) :=
                  'Situation au ' || TO_CHAR (c_situ.debut, 'dd/mm/yyyy');
        END IF;

        i := i + 1;

        IF (c_situ.situ_fam IS NOT NULL)
        THEN
           t_situ (i) :=
                 cst_glob_tiret
              || pk_libelle.f_lib ('SITU_FAM', c_situ.situ_fam);
           i := i + 1;
        END IF;

        IF (c_situ.situ_prof IS NOT NULL)
        THEN
           t_situ (i) :=
                 cst_glob_tiret
              || pk_libelle.f_lib ('SITU_PROF', c_situ.situ_prof);
           i := i + 1;
        END IF;

        IF (c_situ.profession IS NOT NULL)
        THEN
           t_situ (i) :=
                 cst_glob_tiret
              || pk_libelle.f_lib ('CSP_4', c_situ.profession);
           i := i + 1;
        END IF;

        IF (c_situ.csp_2 IS NOT NULL)
        THEN
           t_situ (i) :=
               cst_glob_tiret || pk_libelle.f_lib ('CSP_2', c_situ.csp_2);
           i := i + 1;
        END IF;

        IF (c_situ.csp_1 IS NOT NULL)
        THEN
           t_situ (i) :=
               cst_glob_tiret || pk_libelle.f_lib ('CSP_1', c_situ.csp_1);
           i := i + 1;
        END IF;
     END IF;

     CLOSE c_situ_phys;
  END IF;

  --
  RETURN (t_situ (a_indice));
END f_situ_phys;


/*-----------------------------------------------------------------------------*/
/* PROCEDURE                                                                   */
/* Nom          :  p_info_morale                                               */
/* Type         :                                                              */
/* Description  :  retourne tableau info morale                                */
/* Entree       :  i_numindiv      IN       NUMBER,                            */
/*                 io_siret_naf    IN OUT   VARCHAR2,                          */
/*                 io_convention   IN OUT   VARCHAR2,                          */
/*                 io_situation    IN OUT   VARCHAR2,                          */
/*                 io_chiffre      IN OUT   VARCHAR2,                          */
/*                 io_masse_sal    IN OUT   VARCHAR2,                          */
/*                 io_capital      IN OUT   VARCHAR2,                          */
/*                 io_effectif     IN OUT   VARCHAR2                           */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :  io_siret_naf    IN OUT   VARCHAR2,                          */
/*                 io_convention   IN OUT   VARCHAR2,                          */
/*                 io_situation    IN OUT   VARCHAR2,                          */
/*                 io_chiffre      IN OUT   VARCHAR2,                          */
/*                 io_masse_sal    IN OUT   VARCHAR2,                          */
/*                 io_capital      IN OUT   VARCHAR2,                          */
/*                 io_effectif     IN OUT   VARCHAR2                           */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

PROCEDURE p_info_morale (
  i_numindiv      IN       NUMBER,
  io_siret_naf    IN OUT   VARCHAR2,
  io_convention   IN OUT   VARCHAR2,
  io_situation    IN OUT   VARCHAR2,
  io_chiffre      IN OUT   VARCHAR2,
  io_masse_sal    IN OUT   VARCHAR2,
  io_capital      IN OUT   VARCHAR2,
  io_effectif     IN OUT   VARCHAR2
)
IS
--
  CURSOR c_pers_morale
  IS
     SELECT pers_morale.siret, pers_morale.code_naf naf,
            pers_morale.convention
       FROM pers_morale
      WHERE numindiv = i_numindiv;

--
  rec_c_pers_morale               c_pers_morale%ROWTYPE;

--
  CURSOR c_convention (p_code_convention NUMBER)
  IS
     SELECT SUBSTR (libelle, 1, 27) libelle
       FROM libelle
      WHERE mnemo = 'CONVENTION' AND code = p_code_convention;

--
  rec_c_convention                c_convention%ROWTYPE;

--
  CURSOR c_situ_morale
  IS
     SELECT   debut, LTRIM (TO_CHAR (capital, '99999999999.99')) capital,
              LTRIM (TO_CHAR (chiffre, '99999999999.99')) chiffre,
              TO_CHAR (effectif) effectif,
              LTRIM (TO_CHAR (masse, '99999999999.99')) masse
         FROM pers_histo_morale
        WHERE numindiv = i_numindiv AND debut <= SYSDATE
     ORDER BY debut DESC;

--
  rec_c_situ_morale               c_situ_morale%ROWTYPE;
--
-- Declaration de type tableau de Varchar2(33)
  rec_tab_info_morale             tab_info_morale;
--
  i                               BINARY_INTEGER;
--
  cst_loc_siret          CONSTANT VARCHAR2 (6)           DEFAULT 'Siret ';
  cst_loc_naf            CONSTANT VARCHAR2 (4)            DEFAULT 'Naf ';
  cst_loc_conv           CONSTANT VARCHAR2 (6)           DEFAULT 'Conv. ';
  cst_loc_capital        CONSTANT VARCHAR2 (13)   DEFAULT '- Capital  : ';
  cst_loc_chif_affaire   CONSTANT VARCHAR2 (13)   DEFAULT '- C. Aff.  : ';
  cst_loc_effectif       CONSTANT VARCHAR2 (13)   DEFAULT '- Effectif : ';
  cst_loc_masse_sal      CONSTANT VARCHAR2 (13)   DEFAULT '- Salaires : ';
  cst_loc_blanc          CONSTANT VARCHAR2 (2)            DEFAULT '  ';
  cst_loc_long_champ     CONSTANT NUMBER (2)              DEFAULT 34;
--
BEGIN
  -- Initialisation du tableau
  FOR i IN 1 .. 7
  LOOP
     rec_tab_info_morale (i) := NULL;
  END LOOP;

  --
  OPEN c_pers_morale;

  FETCH c_pers_morale
   INTO rec_c_pers_morale;

  CLOSE c_pers_morale;

  --
  i := 1;

  -- Recheche du libelle convention
  IF rec_c_pers_morale.convention IS NOT NULL
  THEN
     OPEN c_convention (rec_c_pers_morale.convention);

     FETCH c_convention
      INTO rec_c_convention;

     CLOSE c_convention;
  END IF;

  --
  -- Teste si existence du code Siret
  IF rec_c_pers_morale.siret IS NOT NULL
  THEN
     rec_tab_info_morale (i) :=
                cst_loc_siret || rec_c_pers_morale.siret || cst_loc_blanc;
  END IF;

  --
  -- Teste Si existence du code Ape
  IF rec_c_pers_morale.naf IS NOT NULL
  THEN
     rec_tab_info_morale (i) :=
           rec_tab_info_morale (i) || cst_loc_naf
           || rec_c_pers_morale.naf;
  END IF;

  --
  IF rec_tab_info_morale (i) IS NOT NULL
  THEN
     i := i + 1;
  END IF;

  --
  -- Teste si existence du code convention
  IF rec_c_pers_morale.convention IS NOT NULL
  THEN
     rec_tab_info_morale (i) := cst_loc_conv || rec_c_convention.libelle;
     i := i + 1;
  END IF;

  --
  OPEN c_situ_morale;

  FETCH c_situ_morale
   INTO rec_c_situ_morale;

  IF c_situ_morale%FOUND
  THEN
     --
     rec_tab_info_morale (i) :=
                         'Situation au ' || d2e (rec_c_situ_morale.debut);
     i := i + 1;

     --
     -- Teste si existence du Chiffre d'affaires
     IF rec_c_situ_morale.chiffre IS NOT NULL
     THEN
        rec_tab_info_morale (i) :=
                        cst_loc_chif_affaire || rec_c_situ_morale.chiffre;
        i := i + 1;
     END IF;

     --
     -- Teste si existence de masse salariale
     IF rec_c_situ_morale.masse IS NOT NULL
     THEN
        rec_tab_info_morale (i) :=
                             cst_loc_masse_sal || rec_c_situ_morale.masse;
        i := i + 1;
     END IF;

     --
     --
     IF rec_c_situ_morale.capital IS NOT NULL
     THEN
        rec_tab_info_morale (i) :=
                             cst_loc_capital || rec_c_situ_morale.capital;
        i := i + 1;
     END IF;

     --
     --
     IF rec_c_situ_morale.effectif IS NOT NULL
     THEN
        rec_tab_info_morale (i) :=
                           cst_loc_effectif || rec_c_situ_morale.effectif;
     END IF;
  --
  ELSE                                     -- Il n'existe pas de situation
     rec_tab_info_morale (i) := cst_glob_situation;
  END IF;

  --
  CLOSE c_situ_morale;

  --
  -- On vide le tableau dans les Parametres pour restitution des valeurs==>FORMS
  --
  FOR i IN 1 .. 7
  LOOP
     IF i = 1
     THEN
        io_siret_naf := rec_tab_info_morale (i);
     ELSIF i = 2
     THEN
        io_convention := rec_tab_info_morale (i);
     ELSIF i = 3
     THEN
        io_situation := rec_tab_info_morale (i);
     ELSIF i = 4
     THEN
        io_chiffre := rec_tab_info_morale (i);
     ELSIF i = 5
     THEN
        io_masse_sal := rec_tab_info_morale (i);
     ELSIF i = 6
     THEN
        io_capital := rec_tab_info_morale (i);
     ELSIF i = 7
     THEN
        io_effectif := rec_tab_info_morale (i);
     END IF;
  END LOOP;
--
END;

/*-----------------------------------------------------------------------------*/
/* PROCEDURE                                                                   */
/* Nom          :  p_nomjf                                                     */
/* Type         :                                                              */
/* Description  :  retourne tableau info morale                                */
/* Entree       :  i_numindiv      IN       NUMBER,                            */
/*                 io_siret_naf    IN OUT   VARCHAR2,                          */
/*                 io_convention   IN OUT   VARCHAR2,                          */
/*                 io_situation    IN OUT   VARCHAR2,                          */
/*                 io_chiffre      IN OUT   VARCHAR2,                          */
/*                 io_masse_sal    IN OUT   VARCHAR2,                          */
/*                 io_capital      IN OUT   VARCHAR2,                          */
/*                 io_effectif     IN OUT   VARCHAR2                           */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :  io_siret_naf    IN OUT   VARCHAR2,                          */
/*                 io_convention   IN OUT   VARCHAR2,                          */
/*                 io_situation    IN OUT   VARCHAR2,                          */
/*                 io_chiffre      IN OUT   VARCHAR2,                          */
/*                 io_masse_sal    IN OUT   VARCHAR2,                          */
/*                 io_capital      IN OUT   VARCHAR2,                          */
/*                 io_effectif     IN OUT   VARCHAR2                           */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/


PROCEDURE p_nomjf (
  i_numindiv   IN       NUMBER,
  io_nomjf     IN OUT   VARCHAR2,
  io_datnais   IN OUT   VARCHAR2
)
IS
--
  CURSOR c_individu
  IS
     SELECT INITCAP (LOWER (SUBSTR (individu.nomjf, 1, 28))) nomjf,
            individu.datnais, individu.sexe
       FROM individu
      WHERE numindiv = i_numindiv;

--
  rec_c_individu             c_individu%ROWTYPE;
--
  loc_age                    VARCHAR2 (10);
--
  cst_loc_nee       CONSTANT VARCHAR2 (4)         DEFAULT 'Née ';
  cst_loc_ne        CONSTANT VARCHAR2 (3)         DEFAULT 'Né ';
  cst_loc_article   CONSTANT VARCHAR2 (3)         DEFAULT 'le ';
  cst_loc_an        CONSTANT VARCHAR2 (3)         DEFAULT ' an';
  cst_loc_ans       CONSTANT VARCHAR2 (4)         DEFAULT ' ans';
--
BEGIN
  io_nomjf := NULL;
  io_datnais := NULL;

  --
  OPEN c_individu;

  FETCH c_individu
   INTO rec_c_individu;

  CLOSE c_individu;

  IF rec_c_individu.nomjf IS NOT NULL
  THEN
     io_nomjf := cst_loc_nee || rec_c_individu.nomjf;

     --
     IF rec_c_individu.datnais IS NOT NULL
     THEN
        loc_age :=
           TO_CHAR (FLOOR (  MONTHS_BETWEEN (SYSDATE,
                                             rec_c_individu.datnais
                                            )
                           / 12
                          )
                   );

        IF loc_age IN ('0', '1')
        THEN
           loc_age := ' (' || loc_age || cst_loc_an || ')';
        ELSE
           loc_age := ' (' || loc_age || cst_loc_ans || ')';
        END IF;

        io_datnais :=
                 cst_loc_article || d2e (rec_c_individu.datnais)
                 || loc_age;
     END IF;
  ELSE                            -- IL n'existe pas de nom de jeune fille
     IF rec_c_individu.datnais IS NOT NULL
     THEN
        loc_age :=
           TO_CHAR (FLOOR (  MONTHS_BETWEEN (SYSDATE,
                                             rec_c_individu.datnais
                                            )
                           / 12
                          )
                   );

        IF loc_age IN ('0', '1')
        THEN
           loc_age := ' (' || loc_age || cst_loc_an || ')';
        ELSE
           loc_age := ' (' || loc_age || cst_loc_ans || ')';
        END IF;

        --
        IF rec_c_individu.sexe = 2
        THEN
           io_nomjf :=
                 cst_loc_nee
              || cst_loc_article
              || d2e (rec_c_individu.datnais)
              || loc_age;
        ELSE
           io_nomjf :=
                 cst_loc_ne
              || cst_loc_article
              || d2e (rec_c_individu.datnais)
              || loc_age;
        END IF;
     END IF;
  END IF;
END;


/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_nom                                                       */
/* Type         :                                                              */
/* Description  :  retourne le nom                                             */
/* Entree       :  a_numindiv   IN   NUMBER,                                   */
/*                 a_longueur   IN   NUMBER DEFAULT 32,                        */
/*                 a_type       IN   NUMBER DEFAULT 0                          */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :    return VARCHAR2                                           */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_nom (
  a_numindiv   IN   NUMBER,
  a_longueur   IN   NUMBER DEFAULT 32,
  a_type       IN   NUMBER DEFAULT 0
--a_trop_long     in Number       Default 0
)
  RETURN VARCHAR2
IS
--
  CURSOR c_individu
  IS
     SELECT individu.nom, individu.prenom, individu.qualite,
            individu.TYPE, individu.codcourrier1 codc1
       FROM individu
      WHERE numindiv = a_numindiv;

--
  rec_c_individu   c_individu%ROWTYPE;
--
  l_nom            VARCHAR2 (255);
  l_prenom         VARCHAR2 (32);
  l_qualite        VARCHAR2 (45);
  l_nom_abrege     VARCHAR2 (25);

--
-- Fonction locale a la procedure F_nom
--
  FUNCTION f_nom_abrege (i_numindiv IN NUMBER)
     RETURN VARCHAR2
  IS
     CURSOR c_pers_morale
     IS
        SELECT abrege
          FROM pers_morale
         WHERE numindiv = i_numindiv;

     --
     l_abrege   VARCHAR2 (25);
  --
  BEGIN
     OPEN c_pers_morale;

     FETCH c_pers_morale
      INTO l_abrege;

     CLOSE c_pers_morale;

     RETURN l_abrege;
  END;
--
BEGIN
  OPEN c_individu;

  FETCH c_individu
   INTO rec_c_individu;

  CLOSE c_individu;

  IF (a_type = 2)
  THEN
     RETURN (SUBSTR (UPPER (rec_c_individu.nom), 1, a_longueur));
  END IF;

--
  l_prenom := rec_c_individu.prenom;
  l_qualite := pk_libelle.f_lib ('QLTE', rec_c_individu.qualite);

--
  IF (a_type = 1)
  THEN                                                                   --
         --l_qualite := f_abrege (UPPER (l_qualite), 'ABREGE', 1);
         l_qualite := f_abrege (UPPER (l_qualite), 'CODC1', 1);  -- TLE - MANTIS 3768
  END IF;

--
  IF rec_c_individu.TYPE = 1
  THEN                                                -- Personne Physique
     l_nom := f_concatene (l_qualite, INITCAP (l_prenom));
     l_nom := f_concatene (l_nom, rec_c_individu.nom);
  ELSE                                                  -- Personne Morale
     l_nom := f_concatene (l_qualite, rec_c_individu.nom);
     l_nom := f_concatene (l_nom, rec_c_individu.prenom);
  END IF;

--
  IF (is_too_long (l_nom, a_longueur))
  THEN
     LOOP
        IF (LENGTH (l_qualite) > 4)
        THEN
           IF (rec_c_individu.codc1 IS NOT NULL)
           THEN
              l_qualite :=
                         pk_libelle.f_lib ('CODC1', rec_c_individu.codc1);
           ELSE
              l_qualite := NULL;
           END IF;
        END IF;

        --
        IF rec_c_individu.TYPE = 1
        THEN                                          -- Personne Physique
           l_nom := f_concatene (l_qualite, INITCAP (l_prenom));
           l_nom := f_concatene (l_nom, rec_c_individu.nom);
        ELSE                                            -- Personne Morale
           l_nom := f_concatene (l_qualite, rec_c_individu.nom);
           l_nom := f_concatene (l_nom, rec_c_individu.prenom);
        END IF;

        --
        IF (is_too_long (l_nom, a_longueur))
        THEN
           IF rec_c_individu.TYPE = 1
           THEN                                      -- Personne Physique
              IF (LENGTH (l_prenom) > 1)
              THEN
                 l_prenom := SUBSTR (rec_c_individu.prenom, 1, 1);
                 l_nom := f_concatene (l_qualite, UPPER (l_prenom));
                 l_nom := f_concatene (l_nom, rec_c_individu.nom);
              END IF;
           ELSE                                         -- Personne morale
              l_nom_abrege := f_nom_abrege (i_numindiv => a_numindiv);

              IF l_nom_abrege IS NOT NULL
              THEN
                 l_qualite :=
                          pk_libelle.f_lib ('QLTE', rec_c_individu.codc1);
                 l_nom := f_concatene (l_qualite, l_nom_abrege);

                 IF (is_too_long (l_nom, a_longueur))
                 THEN
                    l_qualite :=
                       pk_libelle.f_lib ('CODC1', rec_c_individu.qualite);
                    l_nom := f_concatene (l_qualite, l_nom_abrege);
                 END IF;
              END IF;
           END IF;
        END IF;

        -- Dans tous les cas on sort
        l_nom := SUBSTR (l_nom, 1, a_longueur);
        EXIT;
     END LOOP;
  END IF;

--
  IF (a_type = 1)
  THEN
     RETURN (UPPER (l_nom));
  ELSE
     RETURN (l_nom);
  END IF;
END f_nom;


/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_nom_inv                                                   */
/* Type         :                                                              */
/* Description  :  retourne le nom                                             */
/* Entree       :  a_numindiv   IN   NUMBER,                                   */
/*                 a_longueur   IN   NUMBER DEFAULT 32,                        */
/*                 a_type       IN   NUMBER DEFAULT 0                          */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :    return VARCHAR2                                           */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_nom_inv (
  a_numindiv   IN   NUMBER,
  a_longueur   IN   NUMBER DEFAULT 32,
  a_type       IN   NUMBER DEFAULT 0
--a_trop_long     in Number       Default 0
)
  RETURN VARCHAR2
IS
--
  CURSOR c_individu
  IS
     SELECT individu.nom, individu.prenom, individu.qualite,
            individu.TYPE, individu.codcourrier1 codc1
       FROM individu
      WHERE numindiv = a_numindiv;

--
  rec_c_individu   c_individu%ROWTYPE;
--
  l_nom            VARCHAR2 (255);
  l_prenom         VARCHAR2 (32);
  l_qualite        VARCHAR2 (45);
  l_nom_abrege     VARCHAR2 (25);

--
-- Fonction locale a la procedure F_nom
--
  FUNCTION f_nom_abrege (i_numindiv IN NUMBER)
     RETURN VARCHAR2
  IS
     CURSOR c_pers_morale
     IS
        SELECT abrege
          FROM pers_morale
         WHERE numindiv = i_numindiv;

     --
     l_abrege   VARCHAR2 (25);
  --
  BEGIN
     OPEN c_pers_morale;

     FETCH c_pers_morale
      INTO l_abrege;

     CLOSE c_pers_morale;

     RETURN l_abrege;
  END;
--
BEGIN
  OPEN c_individu;

  FETCH c_individu
   INTO rec_c_individu;

  CLOSE c_individu;

--
  l_prenom := rec_c_individu.prenom;
  l_qualite := pk_libelle.f_lib ('QLTE', rec_c_individu.qualite);

--
  IF (a_type = 1)
  THEN                                                                  --
     l_qualite := f_abrege (UPPER (l_qualite), 'ABREGE', 1);
  END IF;

--
  IF rec_c_individu.TYPE = 1
  THEN                                                -- Personne Physique
     l_nom := f_concatene (rec_c_individu.nom, rec_c_individu.prenom);
     l_nom := f_concatene (l_nom, l_qualite);
  ELSE                                                  -- Personne Morale
     l_nom := f_concatene (rec_c_individu.nom, rec_c_individu.nom);
     l_nom := f_concatene (l_nom, l_qualite);
  END IF;

--
  IF (is_too_long (l_nom, a_longueur))
  THEN
     LOOP
        IF (LENGTH (l_qualite) > 4)
        THEN
           IF (rec_c_individu.codc1 IS NOT NULL)
           THEN
              l_qualite :=
                         pk_libelle.f_lib ('CODC1', rec_c_individu.codc1);
           ELSE
              l_qualite := NULL;
           END IF;
        END IF;

        --
        IF rec_c_individu.TYPE = 1
        THEN                                          -- Personne Physique
           l_nom := f_concatene (rec_c_individu.nom, l_prenom);
           l_nom := f_concatene (l_nom, l_qualite);
        ELSE                                            -- Personne Morale
           l_nom := f_concatene (rec_c_individu.nom, l_prenom);
           l_nom := f_concatene (l_nom, l_qualite);
        END IF;

        --
        IF (is_too_long (l_nom, a_longueur))
        THEN
           IF rec_c_individu.TYPE = 1
           THEN                                      -- Personne Physique
              IF (LENGTH (l_prenom) > 1)
              THEN
                 l_prenom := SUBSTR (rec_c_individu.prenom, 1, 1);
                 l_nom :=
                       f_concatene (rec_c_individu.nom, UPPER (l_prenom));
                 l_nom := f_concatene (l_nom, l_qualite);
              END IF;
           ELSE                                         -- Personne morale
              l_nom_abrege := f_nom_abrege (i_numindiv => a_numindiv);

              IF l_nom_abrege IS NOT NULL
              THEN
                 l_qualite :=
                          pk_libelle.f_lib ('QLTE', rec_c_individu.codc1);
                 l_nom := f_concatene (l_nom_abrege, l_qualite);

                 IF (is_too_long (l_nom, a_longueur))
                 THEN
                    l_qualite :=
                       pk_libelle.f_lib ('CODC1', rec_c_individu.qualite);
                    l_nom := f_concatene (l_nom_abrege, l_qualite);
                 END IF;
              END IF;
           END IF;
        END IF;

        -- Dans tous les cas on sort
        l_nom := SUBSTR (l_nom, 1, a_longueur);
        EXIT;
     END LOOP;
  END IF;

--
  IF (a_type = 1)
  THEN
     RETURN (UPPER (l_nom));
  ELSE
     RETURN (l_nom);
  END IF;
END f_nom_inv;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_adresse                                                   */
/* Type         :                                                              */
/* Description  :  retourne l' adresse                                         */
/* Entree       :  a_idadresse   IN   NUMBER,                                  */
/*                   a_indice      IN   NUMBER,                                */
/*                   a_numindiv    IN   NUMBER DEFAULT 0,                      */
/*                   a_force       IN   NUMBER DEFAULT 0,                      */
/*                   a_codope      IN   NUMBER DEFAULT 0                       */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :    return VARCHAR2                                           */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_adresse (
  a_idadresse   IN   NUMBER,
  a_indice      IN   NUMBER,
  a_numindiv    IN   NUMBER DEFAULT 0,
  a_force       IN   NUMBER DEFAULT 0,
  a_codope      IN   NUMBER DEFAULT 0
)
  RETURN VARCHAR2
IS
  i                          BINARY_INTEGER;

  CURSOR fetch_adresse
  IS
     SELECT individu.codtitre, pers_adresse.no_voie, pers_adresse.bis,
            pers_adresse.type_voie, pers_adresse.nom_voie,
            pers_adresse.comp_adresse, pers_adresse.adresse_2,
            DECODE (pers_adresse.codpos,
                    '99999', '',
                    pers_adresse.codpos
                   ) codpos,
            pers_adresse.ville, pers_adresse.flag_cedex,
            pers_adresse.no_cedex, pers_adresse.codpays,
            pers_adresse.TYPE type_adresse, individu.TYPE
       FROM pers_adresse, individu
      WHERE pers_adresse.idadresse = a_idadresse
        AND individu.numindiv = pers_adresse.numindiv + 0;

--
  c_indiv                    individu%ROWTYPE;

--
  CURSOR c_ope_gest
  IS
     SELECT ope_gest
       FROM ope_gest
      WHERE type_crrr = a_codope;

--
  rec_c_ope_gest             c_ope_gest%ROWTYPE;

--
  CURSOR c_interlocuteur (p_ope_gest NUMBER)
  IS
     SELECT interlocuteur
       FROM interlocuteur
      WHERE numindiv = a_numindiv AND valide = 'O'
            AND ope_crrr = p_ope_gest;

--
  rec_c_interlocuteur        c_interlocuteur%ROWTYPE;

--
  CURSOR c_individu
  IS
     SELECT TYPE
       FROM individu
      WHERE numindiv = a_numindiv;

  rec_c_individu             c_individu%ROWTYPE;

--
  CURSOR c_international
  IS
     SELECT adr1, adr2, adr3, adr4, adr5
       FROM adr_internationale
      WHERE idadresse = a_idadresse;

  rec_c_international        c_international%ROWTYPE;
--
  c_adresse                  fetch_adresse%ROWTYPE;
--
--  Si il n'existe pas de courrier specifique , on prend
--  par defaut le type courrier =0 pour rechercher l'interlocuteur
--
  cst_loc_ope_crr   CONSTANT NUMBER (1)                DEFAULT 0;
--
  loc_nom_interlocuteur      VARCHAR2 (32);
  loc_charge_tableau         BOOLEAN;
--
BEGIN
  loc_charge_tableau := FALSE;

  IF (a_idadresse != comm_idadresse OR a_force <> 0)
  THEN
     -- 28/01/2005 David For i In 1 .. 6 Loop
     FOR i IN 1 .. 7
     LOOP
        t_adresse (i) := NULL;
     END LOOP;

     IF a_idadresse != comm_idadresse
     THEN
        comm_idadresse := a_idadresse;
     END IF;

     --
     loc_charge_tableau := TRUE;
  END IF;

--
  IF loc_charge_tableau
  THEN
     i := 1;

     IF (a_idadresse != 0)
     THEN
        --
        loc_nom_interlocuteur := NULL;

        --
        -- Recherche type personne : Morale ou Physique
        OPEN c_individu;

        FETCH c_individu
         INTO rec_c_individu;

        CLOSE c_individu;

        --
        IF rec_c_individu.TYPE = 2
        THEN                                           -- Personne Morale
           IF a_codope <> 0
           THEN               -- Si codope different de valeur par defaut
              OPEN c_ope_gest;      -- Alors on recherche l'interlocuteur

              FETCH c_ope_gest
               INTO rec_c_ope_gest;

              IF c_ope_gest%FOUND
              THEN
                 OPEN c_interlocuteur (rec_c_ope_gest.ope_gest);

                 FETCH c_interlocuteur
                  INTO rec_c_interlocuteur;

                 IF c_interlocuteur%FOUND
                 THEN                    -- Si il existe un interlocuteur
                    -- Recherche du nom de l'interlocuteur
                    loc_nom_interlocuteur :=
                       f_nom
                          (a_numindiv      => rec_c_interlocuteur.interlocuteur
                          );
                 ELSE            -- Interlocuteur non trouve avec ope_gest
                    CLOSE c_interlocuteur;

                    -- Recherche du nom de l'interlocuteur avec ope_crr=0
                    OPEN c_interlocuteur (cst_loc_ope_crr);

                    FETCH c_interlocuteur
                     INTO rec_c_interlocuteur;

                    IF c_interlocuteur%FOUND
                    THEN
                       loc_nom_interlocuteur :=
                          f_nom
                             (a_numindiv      => rec_c_interlocuteur.interlocuteur
                             );
                    END IF;
                 END IF;

                 CLOSE c_interlocuteur;
              ELSE
                 -- Recherche du nom de l'interlocuteur avec ope_crr=0
                 OPEN c_interlocuteur (cst_loc_ope_crr);

                 FETCH c_interlocuteur
                  INTO rec_c_interlocuteur;

                 IF c_interlocuteur%FOUND
                 THEN
                    loc_nom_interlocuteur :=
                       f_nom
                          (a_numindiv      => rec_c_interlocuteur.interlocuteur
                          );
                 END IF;

                 CLOSE c_interlocuteur;
              END IF;

              CLOSE c_ope_gest;
           ELSE                                              -- Codope = 0
              -- Recherche du nom de l'interlocuteur avec ope_crr=0
              OPEN c_interlocuteur (cst_loc_ope_crr);

              FETCH c_interlocuteur
               INTO rec_c_interlocuteur;

              IF c_interlocuteur%FOUND
              THEN
                 loc_nom_interlocuteur :=
                    f_nom
                         (a_numindiv      => rec_c_interlocuteur.interlocuteur);
              END IF;

              CLOSE c_interlocuteur;
           END IF;
        END IF;

        --
        -- Fin gestion interlocuteur
        -- Gestion des adresses normalisees ou internationales
        --
        FOR c_adresse IN fetch_adresse
        LOOP
           --
           IF loc_nom_interlocuteur IS NOT NULL
           THEN
              t_adresse (i) := loc_nom_interlocuteur;
              i := i + 1;
           END IF;

           --
           IF (c_adresse.type_adresse != 3)
           THEN                                              -- Normalisee
              IF (c_adresse.comp_adresse IS NOT NULL)
              THEN
                 t_adresse (i) := c_adresse.comp_adresse;
                 i := i + 1;
              ELSIF (c_adresse.codtitre IS NOT NULL)
              THEN
                 t_adresse (i) :=
                           pk_libelle.f_lib ('TITRE', c_adresse.codtitre);
                 i := i + 1;
              END IF;

              --
              t_adresse (i) :=
                 SUBSTR (f_recompose (c_adresse.no_voie,
                                      c_adresse.bis,
                                      c_adresse.type_voie,
                                      c_adresse.nom_voie,
                                      32
                                     ),
                         1,
                         32
                        );
              i := i + 1;

              --
              -- Modification 06/11/00 pour gérer 5 lignes adresses
              --
              IF c_adresse.adresse_2 IS NOT NULL
              THEN
                 t_adresse (i) := c_adresse.adresse_2;
                 i := i + 1;
              END IF;

              --
              t_adresse (i) :=
                           f_concatene (c_adresse.codpos, c_adresse.ville);

              --
              IF (c_adresse.flag_cedex = 'O')
              THEN
                 IF (INSTR (c_adresse.ville, 'CEDEX') = 0)
                 THEN
                    t_adresse (i) :=
                       SUBSTR (f_concatene (t_adresse (i), 'CEDEX'),
                               1,
                               32
                              );
                 END IF;

                 t_adresse (i) :=
                    SUBSTR (f_concatene (t_adresse (i),
                                         c_adresse.no_cedex),
                            1,
                            32
                           );
              END IF;

              i := i + 1;
           --
           ELSE                                  -- Adresse internationale
              OPEN c_international;

              FETCH c_international
               INTO rec_c_international;

              --David 04/02/2005 Contitionner affichage des adresses
              IF (rec_c_international.adr1 IS NOT NULL)
              THEN
                 t_adresse (i) :=
                                 SUBSTR (rec_c_international.adr1, 1, 32);
                 i := i + 1;
              END IF;

              IF (rec_c_international.adr2 IS NOT NULL)
              THEN
                 t_adresse (i) :=
                                 SUBSTR (rec_c_international.adr2, 1, 32);
                 i := i + 1;
              END IF;

              IF (rec_c_international.adr3 IS NOT NULL)
              THEN
                 t_adresse (i) :=
                                 SUBSTR (rec_c_international.adr3, 1, 32);
                 i := i + 1;
              END IF;

              IF (rec_c_international.adr4 IS NOT NULL)
              THEN
                 --t_adresse(i) := Substr(Rec_C_international.adr4,1,32);
                 t_adresse (i) :=
                    SUBSTR (f_concatene (rec_c_international.adr4,
                                         rec_c_international.adr5
                                        ),
                            1,
                            32
                           );
                 i := i + 1;
              ELSE
                 IF (rec_c_international.adr5 IS NOT NULL)
                 THEN
                    t_adresse (i) :=
                                 SUBSTR (rec_c_international.adr5, 1, 32);
                    i := i + 1;
                 END IF;
              END IF;
                     /*
           If ( Rec_C_international.adr5 Is Not null ) then
              t_adresse(i) := Substr(Rec_C_international.adr5,1,32);
              i := i + 1;
           End If;
                    */
           END IF;

           --
           IF (c_adresse.codpays != pk_devise.pays_ref)
           THEN
              t_adresse (i) :=
                     UPPER (pk_libelle.f_lib ('PAYS', c_adresse.codpays));
           END IF;
        --
        END LOOP;
     ELSE
        FOR c_indiv IN (SELECT individu.codtitre, individu.adr1,
                               individu.adr2, individu.codpos,
                               individu.ville, individu.codpays
                          FROM individu
                         WHERE numindiv = a_numindiv)
        LOOP
           IF (c_indiv.codtitre IS NOT NULL)
           THEN
              t_adresse (i) :=
                             pk_libelle.f_lib ('TITRE', c_indiv.codtitre);
              i := i + 1;
           END IF;

           -- Modification 06/11/00 pour gérer 5 lignes adresses
           IF c_indiv.adr1 IS NOT NULL
           THEN
              t_adresse (i) := c_indiv.adr1;
              i := i + 1;
           END IF;

           IF c_indiv.adr2 IS NOT NULL
           THEN
              t_adresse (i) := c_indiv.adr2;
              i := i + 1;
           END IF;

           t_adresse (i) := c_indiv.codpos || ' ' || c_indiv.ville;
           i := i + 1;

           IF (c_indiv.codpays != 1)
           THEN
              t_adresse (i) := pk_libelle.f_lib ('PAYS', c_indiv.codpays);
           END IF;
        END LOOP;
     END IF;
  END IF;

  RETURN (SUBSTR (t_adresse (a_indice), 1, 32));
-- M0004516 : MUR le 16/05/2014 : ajout de l'exception
EXCEPTION
  when others then return null ;
END f_adresse;


/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_adresse                                                   */
/* Type         :                                                              */
/* Description  :  retourne l' adresse                                         */
/* Entree       :  a_idadresse   IN   NUMBER,                                  */
/*                 a_indice      IN   NUMBER,                                  */
/*                 a_numindiv    IN   NUMBER DEFAULT 0,                        */
/*                 a_force       IN   NUMBER DEFAULT 0,                        */
/*                 a_codope      IN   NUMBER DEFAULT 0                         */
/*                 a_interloc    IN NUMBER                                     */
/*                                                                             */
/*                                                                             */
/* Sortie       :    return VARCHAR2                                           */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_adresse (
  a_idadresse   IN   NUMBER,
  a_indice      IN   NUMBER,
  a_numindiv    IN   NUMBER DEFAULT 0,
  a_force       IN   NUMBER DEFAULT 0,
  a_codope      IN   NUMBER DEFAULT 0,
a_interloc    IN NUMBER
)
  RETURN VARCHAR2
IS
  i                          BINARY_INTEGER;

  CURSOR fetch_adresse
  IS
     SELECT individu.codtitre, pers_adresse.no_voie, pers_adresse.bis,
            pers_adresse.type_voie, pers_adresse.nom_voie,
            pers_adresse.comp_adresse, pers_adresse.adresse_2,
            DECODE (pers_adresse.codpos,
                    '99999', '',
                    pers_adresse.codpos
                   ) codpos,
            pers_adresse.ville, pers_adresse.flag_cedex,
            pers_adresse.no_cedex, pers_adresse.codpays,
            pers_adresse.TYPE type_adresse, individu.TYPE
       FROM pers_adresse, individu
      WHERE pers_adresse.idadresse = a_idadresse
        AND individu.numindiv = pers_adresse.numindiv + 0;

--
  c_indiv                    individu%ROWTYPE;

--
  CURSOR c_ope_gest
  IS
     SELECT ope_gest
       FROM ope_gest
      WHERE type_crrr = a_codope;

--
  rec_c_ope_gest             c_ope_gest%ROWTYPE;

--
  CURSOR c_interlocuteur (p_ope_gest NUMBER)
  IS
     SELECT interlocuteur
       FROM interlocuteur
      WHERE numindiv = a_numindiv AND valide = 'O'
            AND ope_crrr = p_ope_gest;

--
  rec_c_interlocuteur        c_interlocuteur%ROWTYPE;

--
  CURSOR c_individu
  IS
     SELECT TYPE
       FROM individu
      WHERE numindiv = a_numindiv;

  rec_c_individu             c_individu%ROWTYPE;

--
  CURSOR c_international
  IS
     SELECT adr1, adr2, adr3, adr4, adr5
       FROM adr_internationale
      WHERE idadresse = a_idadresse;

  rec_c_international        c_international%ROWTYPE;
--
  c_adresse                  fetch_adresse%ROWTYPE;
--
--  Si il n'existe pas de courrier specifique , on prend
--  par defaut le type courrier =0 pour rechercher l'interlocuteur
--
  cst_loc_ope_crr   CONSTANT NUMBER (1)                DEFAULT 0;
--
  loc_nom_interlocuteur      VARCHAR2 (32);
  loc_charge_tableau         BOOLEAN;
--
BEGIN
  loc_charge_tableau := FALSE;

  IF (a_idadresse != comm_idadresse OR a_force <> 0)
  THEN
     -- 28/01/2005 David For i In 1 .. 6 Loop
     FOR i IN 1 .. 7
     LOOP
        t_adresse (i) := NULL;
     END LOOP;

     IF a_idadresse != comm_idadresse
     THEN
        comm_idadresse := a_idadresse;
     END IF;

     --
     loc_charge_tableau := TRUE;
  END IF;

--
  IF loc_charge_tableau
  THEN
     i := 1;

     IF (a_idadresse != 0)
     THEN
        --
        loc_nom_interlocuteur := NULL;

        --
        -- Recherche type personne : Morale ou Physique
        OPEN c_individu;

        FETCH c_individu
         INTO rec_c_individu;

        CLOSE c_individu;

        --
        IF rec_c_individu.TYPE = 2
        THEN                                           -- Personne Morale
           IF a_codope <> 0
           THEN               -- Si codope different de valeur par defaut
              OPEN c_ope_gest;      -- Alors on recherche l'interlocuteur

              FETCH c_ope_gest
               INTO rec_c_ope_gest;

              IF c_ope_gest%FOUND
              THEN
                 OPEN c_interlocuteur (rec_c_ope_gest.ope_gest);

                 FETCH c_interlocuteur
                  INTO rec_c_interlocuteur;

                 IF c_interlocuteur%FOUND
                 THEN                    -- Si il existe un interlocuteur
                    -- Recherche du nom de l'interlocuteur
                    loc_nom_interlocuteur :=
                       f_nom
                          (a_numindiv      => rec_c_interlocuteur.interlocuteur
                          );
                 ELSE            -- Interlocuteur non trouve avec ope_gest
                    CLOSE c_interlocuteur;

                    -- Recherche du nom de l'interlocuteur avec ope_crr=0
                    OPEN c_interlocuteur (cst_loc_ope_crr);

                    FETCH c_interlocuteur
                     INTO rec_c_interlocuteur;

                    IF c_interlocuteur%FOUND
                    THEN
                       loc_nom_interlocuteur :=
                          f_nom
                             (a_numindiv      => rec_c_interlocuteur.interlocuteur
                             );
                    END IF;
                 END IF;

                 CLOSE c_interlocuteur;
              ELSE
                 -- Recherche du nom de l'interlocuteur avec ope_crr=0
                 OPEN c_interlocuteur (cst_loc_ope_crr);

                 FETCH c_interlocuteur
                  INTO rec_c_interlocuteur;

                 IF c_interlocuteur%FOUND
                 THEN
                    loc_nom_interlocuteur :=
                       f_nom
                          (a_numindiv      => rec_c_interlocuteur.interlocuteur
                          );
                 END IF;

                 CLOSE c_interlocuteur;
              END IF;

              CLOSE c_ope_gest;
           ELSE                                              -- Codope = 0
              -- Recherche du nom de l'interlocuteur avec ope_crr=0
              OPEN c_interlocuteur (cst_loc_ope_crr);

              FETCH c_interlocuteur
               INTO rec_c_interlocuteur;

              IF c_interlocuteur%FOUND
              THEN
                 loc_nom_interlocuteur :=
                    f_nom
                         (a_numindiv      => rec_c_interlocuteur.interlocuteur);
              END IF;

              CLOSE c_interlocuteur;
           END IF;
        END IF;

        --
        -- Fin gestion interlocuteur
        -- Gestion des adresses normalisees ou internationales
        --
        FOR c_adresse IN fetch_adresse
        LOOP
           --
	   IF a_interloc is not null
	   THEN
		    loc_nom_interlocuteur := f_nom(a_numindiv => a_interloc);
			If loc_nom_interlocuteur is not null then
				t_adresse (i) := loc_nom_interlocuteur;
				i := i + 1;
			end if;
           ELSIF loc_nom_interlocuteur IS NOT NULL
           THEN
              t_adresse (i) := loc_nom_interlocuteur;
              i := i + 1;
           END IF;

           --
           IF (c_adresse.type_adresse != 3)
           THEN                                              -- Normalisee
              IF (c_adresse.comp_adresse IS NOT NULL)
              THEN
                 t_adresse (i) := c_adresse.comp_adresse;
                 i := i + 1;
              ELSIF (c_adresse.codtitre IS NOT NULL)
              THEN
                 t_adresse (i) :=
                           pk_libelle.f_lib ('TITRE', c_adresse.codtitre);
                 i := i + 1;
              END IF;

              --
              t_adresse (i) :=
                 SUBSTR (f_recompose (c_adresse.no_voie,
                                      c_adresse.bis,
                                      c_adresse.type_voie,
                                      c_adresse.nom_voie,
                                      32
                                     ),
                         1,
                         32
                        );
              i := i + 1;

              --
              -- Modification 06/11/00 pour gérer 5 lignes adresses
              --
              IF c_adresse.adresse_2 IS NOT NULL
              THEN
                 t_adresse (i) := c_adresse.adresse_2;
                 i := i + 1;
              END IF;

              --
              t_adresse (i) :=
                           f_concatene (c_adresse.codpos, c_adresse.ville);

              --
              IF (c_adresse.flag_cedex = 'O')
              THEN
                 IF (INSTR (c_adresse.ville, 'CEDEX') = 0)
                 THEN
                    t_adresse (i) :=
                       SUBSTR (f_concatene (t_adresse (i), 'CEDEX'),
                               1,
                               32
                              );
                 END IF;

                 t_adresse (i) :=
                    SUBSTR (f_concatene (t_adresse (i),
                                         c_adresse.no_cedex),
                            1,
                            32
                           );
              END IF;

              i := i + 1;
           --
           ELSE                                  -- Adresse internationale
              OPEN c_international;

              FETCH c_international
               INTO rec_c_international;

              --David 04/02/2005 Contitionner affichage des adresses
              IF (rec_c_international.adr1 IS NOT NULL)
              THEN
                 t_adresse (i) :=
                                 SUBSTR (rec_c_international.adr1, 1, 32);
                 i := i + 1;
              END IF;

              IF (rec_c_international.adr2 IS NOT NULL)
              THEN
                 t_adresse (i) :=
                                 SUBSTR (rec_c_international.adr2, 1, 32);
                 i := i + 1;
              END IF;

              IF (rec_c_international.adr3 IS NOT NULL)
              THEN
                 t_adresse (i) :=
                                 SUBSTR (rec_c_international.adr3, 1, 32);
                 i := i + 1;
              END IF;

              IF (rec_c_international.adr4 IS NOT NULL)
              THEN
                 --t_adresse(i) := Substr(Rec_C_international.adr4,1,32);
                 t_adresse (i) :=
                    SUBSTR (f_concatene (rec_c_international.adr4,
                                         rec_c_international.adr5
                                        ),
                            1,
                            32
                           );
                 i := i + 1;
              ELSE
                 IF (rec_c_international.adr5 IS NOT NULL)
                 THEN
                    t_adresse (i) :=
                                 SUBSTR (rec_c_international.adr5, 1, 32);
                    i := i + 1;
                 END IF;
              END IF;
                     /*
           If ( Rec_C_international.adr5 Is Not null ) then
              t_adresse(i) := Substr(Rec_C_international.adr5,1,32);
              i := i + 1;
           End If;
                    */
           END IF;

           --
           IF (c_adresse.codpays != pk_devise.pays_ref)
           THEN
              t_adresse (i) :=
                     UPPER (pk_libelle.f_lib ('PAYS', c_adresse.codpays));
           END IF;
        --
        END LOOP;
     ELSE
        FOR c_indiv IN (SELECT individu.codtitre, individu.adr1,
                               individu.adr2, individu.codpos,
                               individu.ville, individu.codpays
                          FROM individu
                         WHERE numindiv = a_numindiv)
        LOOP
           IF (c_indiv.codtitre IS NOT NULL)
           THEN
              t_adresse (i) :=
                             pk_libelle.f_lib ('TITRE', c_indiv.codtitre);
              i := i + 1;
           END IF;

           -- Modification 06/11/00 pour gérer 5 lignes adresses
           IF c_indiv.adr1 IS NOT NULL
           THEN
              t_adresse (i) := c_indiv.adr1;
              i := i + 1;
           END IF;

           IF c_indiv.adr2 IS NOT NULL
           THEN
              t_adresse (i) := c_indiv.adr2;
              i := i + 1;
           END IF;

           t_adresse (i) := c_indiv.codpos || ' ' || c_indiv.ville;
           i := i + 1;

           IF (c_indiv.codpays != 1)
           THEN
              t_adresse (i) := pk_libelle.f_lib ('PAYS', c_indiv.codpays);
           END IF;
        END LOOP;
     END IF;
  END IF;

  RETURN (SUBSTR (t_adresse (a_indice), 1, 32));
END f_adresse;


/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_idrib                                                     */
/* Type         :                                                              */
/* Description  :  retourne l'idrib                                            */
/* Entree       :  a_numindiv   IN   NUMBER,                                   */
/*                   a_dec_enc    IN   NUMBER DEFAULT 1,                       */
/*                   a_debut      IN   DATE DEFAULT SYSDATE,                   */
/*                   a_codope     IN   NUMBER DEFAULT 0,                       */
/*                   a_numgar     IN   NUMBER DEFAULT 0                        */
/*                                                                             */
/*                                                                             */
/* Sortie       :    return NUMBER                                             */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_idrib (
  a_numindiv   IN   NUMBER,
  a_dec_enc    IN   NUMBER DEFAULT 1,
  a_debut      IN   DATE DEFAULT SYSDATE,
  a_codope     IN   NUMBER DEFAULT 0,
  a_numgar     IN   NUMBER DEFAULT 0
)
  RETURN NUMBER
IS
  loc_idrib      NUMBER              := 0;
  /*loc_numindiv   BINARY_INTEGER      := a_numindiv;  --jbn debut 24/03/11
  loc_codope     BINARY_INTEGER      := a_codope;
  loc_numgar     BINARY_INTEGER      := a_numgar;
  loc_dec_enc    BINARY_INTEGER      := a_dec_enc;
  loc_debut      DATE                := a_debut;

  CURSOR fetch_rib
  IS
     SELECT   idrib
         FROM rib
        WHERE numindiv = loc_numindiv
          AND TYPE = loc_dec_enc
          AND codope = loc_codope
          AND numgar = loc_numgar
          AND debut <= NVL (loc_debut, debut)
     ORDER BY debut DESC;

  c_rib          fetch_rib%ROWTYPE;
BEGIN

  <<recommence>>
  FOR c_rib IN fetch_rib
  LOOP
     loc_idrib := c_rib.idrib;
     EXIT WHEN fetch_rib%FOUND;
  END LOOP;

  IF (loc_idrib = 0)
  THEN
     IF (loc_numindiv != f_numassu (a_numindiv))
     THEN
        loc_numindiv := f_numassu (a_numindiv);
        GOTO recommence;
     END IF;

     IF (loc_numgar != 0)
     THEN
        loc_numgar := 0;
        GOTO recommence;
     ELSIF (loc_codope != 0)
     THEN
        loc_codope := 0;
        GOTO recommence;
     ELSIF (loc_debut IS NOT NULL)
     THEN
        loc_debut := NULL;
        GOTO recommence;
     ELSIF (loc_dec_enc != 0)
     THEN
        loc_dec_enc := 0;
        GOTO recommence;
     END IF;
  END IF;*/

  loc_numindiv number := a_numindiv;
  loc_codope	 number := a_codope;
  loc_numgar	 number := a_numgar;
  loc_dec_enc	 number := a_dec_enc;
  loc_debut	   Date   := a_debut;

  BEGIN
    SELECT f_bene_rib(
  		loc_numindiv,
  		loc_codope,
  		loc_numgar,
  		loc_dec_enc,
      null,    -- devise
      loc_debut)
    INTO loc_idrib
    FROM dual;
  /*jbn fin 24/03/11*/

  RETURN (loc_idrib);
END f_idrib;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_idadresse                                                 */
/* Type         :                                                              */
/* Description  :  retourne l' idadresse                                       */
/* Entree       :  a_numindiv   IN   NUMBER,                                   */
/*                   a_codope     IN   NUMBER DEFAULT 0,                       */
/*                   a_debut      IN   DATE DEFAULT SYSDATE,                   */
/*                   a_defaut     IN   VARCHAR2 DEFAULT 'O',                   */
/*                   a_numgar     IN   NUMBER DEFAULT 0,                       */
/*                   a_type_adr   IN   NUMBER DEFAULT -1                       */
/*                                                                             */
/*                                                                             */
/* Sortie       :    return NUMBER                                             */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_idadresse (
  a_numindiv   IN   NUMBER,
  a_codope     IN   NUMBER DEFAULT 0,
  a_debut      IN   DATE DEFAULT SYSDATE,
  a_defaut     IN   VARCHAR2 DEFAULT 'O',
  a_numgar     IN   NUMBER DEFAULT 0,
  a_type_adr   IN   NUMBER DEFAULT -1
)
  RETURN NUMBER
IS
  loc_idadresse   NUMBER                  := 0;
  loc_numindiv    BINARY_INTEGER          := a_numindiv;
  loc_codope      BINARY_INTEGER          := a_codope;
  loc_numgar      BINARY_INTEGER          := a_numgar;
  loc_defaut      VARCHAR2 (1)            := a_defaut;
  loc_debut       DATE                    := a_debut;

  CURSOR fetch_adresse
  IS
     SELECT   idadresse
         FROM pers_adresse
        WHERE numindiv = loc_numindiv
          AND codope = loc_codope
          AND numgar = loc_numgar
          AND TYPE = DECODE (a_type_adr, -1, TYPE, a_type_adr)
          AND defaut = NVL (loc_defaut, defaut)
          AND debut <= NVL (loc_debut, debut)
     ORDER BY debut DESC;

  c_adresse       fetch_adresse%ROWTYPE;
BEGIN

  <<recommence>>
  FOR c_adresse IN fetch_adresse
  LOOP
     loc_idadresse := c_adresse.idadresse;
     EXIT WHEN fetch_adresse%FOUND;
  END LOOP;

  IF (loc_idadresse = 0)
  THEN
     IF (loc_numgar != 0)
     THEN
        loc_numgar := 0;
        GOTO recommence;
     ELSIF (loc_codope != 0)
     THEN
        loc_codope := 0;
        GOTO recommence;
     ELSIF (loc_debut IS NOT NULL)
     THEN
        loc_debut := NULL;
        GOTO recommence;
     ELSIF (loc_defaut = 'O')
     THEN
        loc_defaut := 'N';
        GOTO recommence;
     ELSIF (loc_defaut = 'N')
     THEN
        loc_defaut := NULL;
        GOTO recommence;
     END IF;

     IF (loc_numindiv != f_numassu (a_numindiv))
     THEN
        loc_numindiv := f_numassu (a_numindiv);
        loc_codope := a_codope;
        loc_numgar := a_numgar;
        loc_defaut := a_defaut;
        loc_debut := a_debut;
        GOTO recommence;
     END IF;
  END IF;

  RETURN (loc_idadresse);
END f_idadresse;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_decompose                                                 */
/* Type         :                                                              */
/* Description  :  decompose l'adresse                                         */
/* Entree       :  a_chaine IN VARCHAR2,                                       */
/*                 a_indice IN NUMBER                                          */
/*                                                                             */
/*                                                                             */
/* Sortie       :    return VARCHAR2                                           */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_decompose (a_chaine IN VARCHAR2, a_indice IN NUMBER)
  RETURN VARCHAR2
IS
  loc_mot     VARCHAR2 (40);
  loc_reste   VARCHAR2 (40);
  i           NUMBER                := 0;
  no_voie     NUMBER;
  type_voie   libelle_bis%ROWTYPE;
BEGIN
  IF (NOT f_init_chaine (a_chaine))
  THEN
     GOTO fin_boucle;
  END IF;

  WHILE (loc_chaine IS NOT NULL)
  LOOP
     i := i + 1;
     lit_un_mot (loc_chaine, loc_mot, loc_reste);

     IF (i = 1)
     THEN                                                /* No de voie */
        BEGIN
           no_voie := TO_NUMBER (loc_mot);
           t_voie1 := loc_mot;
           loc_chaine := loc_reste;
        EXCEPTION
           WHEN VALUE_ERROR
           THEN
              NULL;
        END;
     ELSIF ((i = 2) AND (t_voie1 IS NOT NULL))
     THEN
        IF (loc_mot IN
               ('BIS', 'TER', 'QUATER', 'QUINQUIES', 'A', 'B', 'C', 'D',
                'E', 'F')
           )
        THEN
           t_voie2 := f_abrege (loc_mot, 'ABREGE', 1);
           loc_chaine := loc_reste;
        END IF;
     ELSE                                               /* Type de voie */
        BEGIN
           FOR type_voie IN (SELECT libelle_bis.code,
                                    libelle_bis.libelle
                               FROM libelle_bis
                              WHERE mnemo = 'TYPE_VOIE'
                                AND code NOT IN ('-2', '-3'))
           LOOP
              IF (   loc_mot = UPPER (type_voie.libelle)
                  OR loc_mot = UPPER (type_voie.code)
                 )
              THEN
                 t_voie3 := type_voie.code;
                 loc_chaine := loc_reste;
              END IF;
           END LOOP;
        END;
     END IF;

     EXIT WHEN ((i >= 3) OR (t_voie3 IS NOT NULL));
  END LOOP;

  t_voie4 := loc_chaine;                                 /* Nom de voie */

  <<fin_boucle>>
  IF (a_indice = 1)
  THEN
     RETURN (t_voie1);
  ELSIF (a_indice = 2)
  THEN
     RETURN (t_voie2);
  ELSIF (a_indice = 3)
  THEN
     RETURN (t_voie3);
  ELSE
     RETURN (t_voie4);
  END IF;
END f_decompose;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_recompose                                                 */
/* Type         :                                                              */
/* Description  :  recompose l'adresse                                         */
/* Entree       :  a_novoie      IN   NUMBER,                                  */
/*                   a_bis         IN   VARCHAR2,                              */
/*                   a_type_voie   IN   VARCHAR2,                              */
/*                   a_nom_voie    IN   VARCHAR2,                              */
/*                   a_longueur    IN   NUMBER,                                */
/*                   a_flag        IN   NUMBER DEFAULT 0                       */
/*                                                                             */
/*                                                                             */
/* Sortie       :    return VARCHAR2                                           */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_recompose (
  a_novoie      IN   NUMBER,
  a_bis         IN   VARCHAR2,
  a_type_voie   IN   VARCHAR2,
  a_nom_voie    IN   VARCHAR2,
  a_longueur    IN   NUMBER,
  a_flag        IN   NUMBER DEFAULT 0
)
  RETURN VARCHAR2
IS
  loc_bis         VARCHAR2 (32)  := f_abrege (a_bis, 'ABREGE', -1);
  loc_type_voie   VARCHAR2 (32) := f_abrege (a_type_voie, 'TYPE_VOIE',
                                             -1);
  loc_nom_voie    VARCHAR2 (78)  := a_nom_voie;
  loc_mot         VARCHAR2 (40);
  loc_reste       VARCHAR2 (78)  := a_nom_voie;
  loc_chaine      VARCHAR2 (255) := NULL;
BEGIN

  <<recommence>>
  loc_chaine := NULL;
  loc_chaine := f_concatene (loc_chaine, TO_CHAR (a_novoie));
  loc_chaine := f_concatene (loc_chaine, loc_bis);
  loc_chaine := f_concatene (loc_chaine, loc_type_voie);
  loc_chaine := f_concatene (loc_chaine, loc_nom_voie);

  WHILE (LENGTH (loc_chaine) > a_longueur)
  LOOP
     IF LENGTH (loc_bis) > 1
     THEN
        loc_bis := f_abrege (loc_bis, 'ABREGE', 1);
        GOTO recommence;
     ELSIF LENGTH (loc_type_voie) > 4
     THEN
        loc_type_voie := f_abrege (loc_type_voie, 'TYPE_VOIE', 1);
        GOTO recommence;
     ELSE
        EXIT WHEN (loc_reste IS NULL);
        lit_un_mot (loc_reste, loc_mot, loc_reste);
        loc_nom_voie :=
           f_concatene (SUBSTR (loc_nom_voie,
                                1,
                                (INSTR (loc_nom_voie, loc_mot) - 2)
                               ),
                        f_abrege (loc_mot, 'ABREGE', 1)
                       );
        loc_nom_voie := f_concatene (loc_nom_voie, loc_reste);
        GOTO recommence;
     END IF;
  END LOOP;

  IF (a_flag = 0)
  THEN
     RETURN (loc_chaine);
  ELSE
     RETURN (loc_nom_voie);
  END IF;
END f_recompose;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_abrege                                                    */
/* Type         :                                                              */
/* Description  :  ???                                                         */
/* Entree       :  a_chaine   IN   VARCHAR2,                                   */
/*                 a_mnemo    IN   VARCHAR2,                                   */
/*                 a_sens     IN   NUMBER DEFAULT 1                            */
/*                                                                             */
/*                                                                             */
/* Sortie       :    return VARCHAR2                                           */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_abrege (
  a_chaine   IN   VARCHAR2,
  a_mnemo    IN   VARCHAR2,
  a_sens     IN   NUMBER DEFAULT 1
)
  RETURN VARCHAR2
IS
  i   BINARY_INTEGER;
BEGIN
  IF (nb_abrege = 0)
  THEN
     init_abrege;
  END IF;

  FOR i IN 1 .. nb_abrege
  LOOP
     IF (a_sens = 1)
     THEN
        IF (t_long (i) = a_chaine)
        THEN
           RETURN (t_court (i));
        END IF;
     ELSE
        IF (t_court (i) = a_chaine)
        THEN
           RETURN (t_long (i));
        END IF;
     END IF;
  END LOOP;

  RETURN (a_chaine);
END f_abrege;

/*-----------------------------------------------------------------------------*/
/* PROCEDURE                                                                   */
/* Nom          :  lit_un_mot                                                  */
/* Type         :                                                              */
/* Description  :  ???                                                         */
/* Entree       :  loc_chaine   IN       VARCHAR2                              */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :  mot          OUT      VARCHAR2,                             */
/*                 reste        OUT      VARCHAR2                              */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

PROCEDURE lit_un_mot (
  loc_chaine   IN       VARCHAR2,
  mot          OUT      VARCHAR2,
  reste        OUT      VARCHAR2
)
IS
  loc_separateur   VARCHAR2 (5)  := ' ,.;';
  loc_mot          VARCHAR2 (78) := NULL;
  i                NUMBER;
  j                NUMBER;
  longueur         NUMBER        := LENGTH (loc_chaine);
BEGIN
  FOR i IN 1 .. longueur
  LOOP
     IF (is_a_separateur (SUBSTR (loc_chaine, i, 1), loc_separateur))
     THEN
        FOR j IN i + 1 .. longueur
        LOOP
           IF (NOT is_a_separateur (SUBSTR (loc_chaine, j, 1),
                                    loc_separateur
                                   )
              )
           THEN
              reste := SUBSTR (loc_chaine, j);
              EXIT;
           END IF;
        END LOOP;

        EXIT;
     END IF;

     loc_mot := loc_mot || SUBSTR (loc_chaine, i, 1);
  END LOOP;

  mot := loc_mot;
END lit_un_mot;


/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  is_a_separateur                                             */
/* Type         :                                                              */
/* Description  :  retourne la position du  separateur                         */
/* Entree       :  a_chaine IN VARCHAR2,                                       */
/*                 a_separateur IN VARCHAR2                                    */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :  BOOLEAN                                                     */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION is_a_separateur (a_chaine IN VARCHAR2, a_separateur IN VARCHAR2)
  RETURN BOOLEAN
IS
BEGIN
  RETURN (INSTR (a_separateur, a_chaine) > 0);
END is_a_separateur;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_concatene                                                 */
/* Type         :                                                              */
/* Description  :  concatene 2 chaines avec un séparateur                      */
/* Entree       :  a_gauche       IN   VARCHAR2,                               */
/*                 a_droite       IN   VARCHAR2,                               */
/*                 a_separateur   IN   VARCHAR2 DEFAULT ' '                    */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :  VARCHAR2                                                    */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_concatene (
  a_gauche       IN   VARCHAR2,
  a_droite       IN   VARCHAR2,
  a_separateur   IN   VARCHAR2 DEFAULT ' '
)
  RETURN VARCHAR2
IS
  loc_separateur   VARCHAR2 (10) := a_separateur;
BEGIN
  IF ((a_gauche IS NOT NULL) AND (a_droite IS NOT NULL))
  THEN
     loc_separateur := a_separateur;
  ELSE
     loc_separateur := NULL;
  END IF;

  RETURN (a_gauche || loc_separateur || a_droite);
END f_concatene;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_numassu                                                   */
/* Type         :                                                              */
/* Description  :  retourne le numassu                                         */
/* Entree       :  a_numindiv IN NUMBER                                        */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :  number                                                      */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_numassu (a_numindiv IN NUMBER)
  RETURN NUMBER
IS
  loc_numassu   NUMBER := NULL;
BEGIN
  BEGIN
     SELECT numassu
       INTO loc_numassu
       FROM indvs
      WHERE numindiv = a_numindiv;
  EXCEPTION
     WHEN NO_DATA_FOUND
     THEN
        NULL;
  END;

  RETURN (loc_numassu);
END f_numassu;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_nom_compta                                                */
/* Type         :                                                              */
/* Description  :  retourne le nom du compta                                   */
/* Entree       :  a_numindiv IN NUMBER                                        */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :  VARCHAR2                                                    */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_nom_compta (a_numindiv IN NUMBER)
  RETURN VARCHAR2
IS
--
  CURSOR c_individu
  IS
     SELECT nom_compta
       FROM pers_morale
      WHERE numindiv = a_numindiv;

--
  rec_c_individu   c_individu%ROWTYPE;
  l_nom_cpta       pers_morale.nom_compta%TYPE;
BEGIN
  OPEN c_individu;

  FETCH c_individu
   INTO rec_c_individu;

  IF c_individu%FOUND
  THEN
     l_nom_cpta := rec_c_individu.nom_compta;
  ELSE
     l_nom_cpta := '0';
  END IF;

  CLOSE c_individu;

--
  RETURN l_nom_cpta;
END f_nom_compta;

/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_dependance                                                */
/* Type         :                                                              */
/* Description  :  retourne le nombre de dependance                            */
/* Entree       :                                                              */
/*                   a_numindiv   IN   NUMBER,                                 */
/*                   a_role       IN   NUMBER,                                 */
/*                   a_date       IN   DATE                                    */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :  NUMBER                                                      */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_dependance (
  a_numindiv   IN   NUMBER,
  a_role       IN   NUMBER,
  a_date       IN   DATE
)
  RETURN NUMBER
IS
--
  CURSOR c_dep
  IS
     SELECT 1
       FROM dependance
      WHERE ROLE = a_role
        AND numde = a_numindiv
        AND a_date BETWEEN dependance.datapli
                       AND NVL (dependance.datper, a_date);

--
  l_dependant   NUMBER;
BEGIN
  OPEN c_dep;

  FETCH c_dep
   INTO l_dependant;

  IF c_dep%NOTFOUND
  THEN
     l_dependant := 0;
  END IF;

  CLOSE c_dep;

--
  RETURN l_dependant;
END f_dependance;
--
/*-----------------------------------------------------------------------------*/
/* FUNCTION                                                                    */
/* Nom          :  f_appel_decompose                                           */
/* Type         :                                                              */
/* Description  :  retourne le nombre de dependance                            */
/* Entree       :                                                              */
/*                  a_chaine IN VARCHAR2,                                      */
/*                  a_indice IN NUMBER                                         */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/* Sortie       :  VARCHAR2                                                    */
/*                                                                             */
/*                                                                             */
/*                                                                             */
/*-----------------------------------------------------------------------------*/

FUNCTION f_appel_decompose (a_chaine IN VARCHAR2, a_indice IN NUMBER)
  RETURN VARCHAR2 IS
BEGIN
loc_chaine :='';
RETURN f_decompose (a_chaine , a_indice);
END f_appel_decompose;


/*----------------------------------------------------------------------------*/
/* FONCTION                                                                    */
/* Nom          :  F_INSER_INDIVIDU                                            */
/* Type         :  Privé                                                       */
/* Description  :  insertion dans la table individu                            */
/*                                                                            */
/* Entree       :   i_indivdu   IN  INDIVIDU%ROWTYPE                           */
/*                                                                            */
/*                                                                            */
/* Retour       :  BOOLEAN                                                     */
/*             :                                                              */
------------------------------------------------------------------------------*/
FUNCTION F_INSERT_INDIVIDU (
         i_indivdu      IN  INDIVIDU%ROWTYPE, O_erreur OUT VARCHAR2
)
RETURN BOOLEAN IS
BEGIN

  Insert into INDIVIDU VALUES i_indivdu;
  RETURN true;

EXCEPTION
  WHEN OTHERS THEN
       O_erreur:='Insertion impossible :'||SQLERRM;
       RETURN false;
END F_INSERT_INDIVIDU;

/*---------------------------------------------------------------------------*/
/* FUNCTION                                                                  */
/* Nom          :  F_INSERT_PERS_HISTO_PHYS                                  */
/* Type         :  Public                                                    */
/* Description  :  fonction de insertion dans PERS_HISTO_PHYS                */
/* Retour       :  TRUE=>OK, FALSE=>KO                                       */
/*---------------------------------------------------------------------------*/
FUNCTION F_INSERT_PERS_HISTO_PHYS( P_PERS_HISTO_PHYS IN PERS_HISTO_PHYS%ROWTYPE)
RETURN BOOLEAN
IS
BEGIN

  INSERT INTO PERS_HISTO_PHYS VALUES P_PERS_HISTO_PHYS;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END F_INSERT_PERS_HISTO_PHYS;

/*----------------------------------------------------------------------------*/
/* FONCTION                                                                    */
/* Nom          :  F_INSER_PERS_MORALE                                         */
/* Type         :  Privé                                                       */
/* Description  :  Recoit un flux xml et renvoi un flux xml                    */
/*                                                                            */
/* Entree       :   i_pers_morale      IN  PERS_MORALE%ROWTYPE                 */
/* Retour       :  BOOLEAN                                                     */
/*             :                                                              */
------------------------------------------------------------------------------*/
FUNCTION F_INSERT_PERS_MORALE  (
          i_pers_morale      IN  PERS_MORALE%ROWTYPE

)
RETURN BOOLEAN IS
BEGIN

      Insert into PERS_MORALE VALUES i_pers_morale;
      RETURN true;

EXCEPTION
  WHEN OTHERS THEN
       RETURN false;
END F_INSERT_PERS_MORALE;


/*--------------------------------------------------------------------------- -*/
/* FONCTION                                                                     */
/* Nom          :  F_INSERT_PERS_HISTO_MORALE                                   */
/* Type         :  Privé                                                        */
/* Description  :  Recoit un flux xml et renvoi un flux xml                     */
/*                                                                             */
/* Entree       :   i_pers_histo_morale in PERS_HISTO_MORALE%ROWTYPE            */
/*                                                                             */
/* Retour       :  BOOLEAN                                                      */
/*             :                                                               */
/*                                                                             */
/*-----------------------------------------------------------------------------*/
FUNCTION F_INSERT_PERS_HISTO_MORALE  (

         i_pers_histo_morale in PERS_HISTO_MORALE%ROWTYPE
)
RETURN BOOLEAN IS
BEGIN


     Insert into PERS_HISTO_MORALE VALUES i_pers_histo_morale;
     RETURN true;

EXCEPTION
  WHEN OTHERS THEN
       RETURN false;
END F_INSERT_PERS_HISTO_MORALE;

/*----------------------------------------------------------------------------*/
/* FONCTION                                                                    */
/* Nom          :  F_INSER_PERS_ADRESSE                                        */
/* Type         :  Privé                                                       */
/* Description  :  insertion dans la table PERS_ADRESSE                        */
/*                                                                            */
/* Entree       :   i_pers_adresse   IN PERS_ADRESSE%ROWTYPE                   */
/* Retour       :  BOOLEAN                                                     */
/*             :                                                              */
/*                                                                            */
/*----------------------------------------------------------------------------*/

FUNCTION F_INSERT_PERS_ADRESSE  (
         i_pers_adresse    IN pers_adresse%ROWTYPE
)
RETURN BOOLEAN IS

       v_pers_adresse pers_adresse%ROWTYPE;
BEGIN

  v_pers_adresse := i_pers_adresse;
  SELECT  idadresse.nextval INTO  v_pers_adresse.idadresse FROM  Dual;

  Insert into PERS_ADRESSE VALUES v_pers_adresse;
  RETURN true;


EXCEPTION
  WHEN OTHERS THEN
       RETURN false;
END F_INSERT_PERS_ADRESSE;



END pk_personne;
/
