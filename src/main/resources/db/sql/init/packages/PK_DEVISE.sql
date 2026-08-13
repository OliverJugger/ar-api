CREATE OR REPLACE PACKAGE ARTHUS."PK_DEVISE"
AS
/*===========================================================================*/
/* Package      : PK_DEVISE.sql                                              */
/* Domaine      : Tresorerie/et conversions monnaies                         */
/* Version      : V1.0                                                       */
/* Auteur       : ARTHUS                                                     */
/* Création     : DD/MM/AAAA                                                 */
/* Description  : Regroupe les différentes fonctions développées autour des  */
/*              : devises et de leur manipulations                           */
/*              :                                                            */
/*===========================================================================*/
/* Evolution    :                                                            */
/* Auteur       :                                                            */
/* Date         :                                                            */
/* Commentaire  :                                                            */
/*===========================================================================*/
/* Correction   : PHA / 01/06/2015 / correction anomalie calcul santé :      */
/*            Pb de calcul sur le remb. de la consultation (exemple) > 19.99 */
/*            au lieu de 20€ (contrat en devise) ajout F_conv_montant        */
/*            repris par f_conv_mt, ancienne fonction pour compatibilité     */
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
   FUNCTION pays_ref
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(Pays_ref, WNDS, WNPS);
   FUNCTION devise_ref
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(Devise_ref, WNDS, WNPS);
   FUNCTION devise_unref
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(Devise_unref, WNDS, WNPS);
   FUNCTION euro
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(Euro, WNDS, WNPS);
   FUNCTION franc
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(Franc, WNDS, WNPS);
   FUNCTION symbole (a_codmon IN NUMBER)
      RETURN VARCHAR2;

--David 26/05/2004
--Pragma Restrict_References(Symbole, WNDS, WNPS);
   FUNCTION codmon (a_symbole IN VARCHAR2)
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(Codmon, WNDS, WNPS);
   FUNCTION converti (
      a_devise       IN   NUMBER,
      a_devise_ref   IN   NUMBER,
      a_montant      IN   NUMBER,
      a_date         IN   DATE DEFAULT SYSDATE
   )
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(Converti, WNDS, WNPS);
   FUNCTION eurofranc_franceuro (
      a_devise    IN   NUMBER DEFAULT NULL,
      a_montant   IN   NUMBER
   )
      RETURN NUMBER;

   FUNCTION lib_symbole (a_codmon IN NUMBER)
      RETURN VARCHAR2;

--David 26/05/2004
--Pragma Restrict_References(lib_symbole, WNDS, WNPS);
   FUNCTION lib_compte (a_numcpte IN NUMBER)
      RETURN VARCHAR2;

--David 26/05/2004
--Pragma Restrict_References(lib_compte, WNDS, WNPS);
--
-- Retourne le montant converti dans la devise inverse de celle de reference
--
   FUNCTION f_convert_euro (
      i_montant   IN   NUMBER,
      i_devise    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER;

--David 26/05/2004
--Pragma Restrict_References(F_convert_euro, WNDS, WNPS);
--
   FUNCTION devise_ct (in_numgar IN NUMBER)
      RETURN NUMBER;

--
--Retourne le montant converti dans la devise2
-- PHA 01/06/2015
   FUNCTION F_conv_montant (
      a_devise1   IN   NUMBER,
      a_devise2   IN   NUMBER,
      a_montant   IN   NUMBER,
      a_date      IN   DATE DEFAULT SYSDATE,
      arrondi_large     IN   VARCHAR2
   )
      RETURN NUMBER;

--
--Retourne le montant converti dans la devise2
-- David 27/08/2004
   FUNCTION f_conv_mt (
      a_devise1   IN   NUMBER,
      a_devise2   IN   NUMBER,
      a_montant   IN   NUMBER,
      a_date      IN   DATE DEFAULT SYSDATE
   )
      RETURN NUMBER;

--
-- Par NS en date du 01/10/2004
-- Retourne la NCL(Numéro, Code, Nom/Libelle) de la devise active
--     d'un contrat à une date déterminée
--
--
   FUNCTION f_dev_cntrt (
      i_numgar   IN   NUMBER,
      i_date     IN   DATE DEFAULT SYSDATE,
      i_ncl      IN   NUMBER DEFAULT 0
   )
      RETURN VARCHAR2;

--
--Pragma Restrict_References(F_Dev_Cntrt , WNDS, WNPS);
--
-- Retourne la NCL(Numéro, Code, Nom/Libelle) du pays
--     d'une prestation donnée
--
   FUNCTION f_pays_presta (i_numsin IN NUMBER, i_ncl IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

--
--Pragma Restrict_References(F_Pays_Presta, WNDS, WNPS);
--
   FUNCTION f_dev_pays (i_codpays IN NUMBER, i_ncl IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

--
--Pragma Restrict_References(F_Dev_Pays, WNDS, WNPS);
--
   FUNCTION langue_ref
      RETURN NUMBER;
--
-- -------------------------------------------- Fin des procedures publiques --
END pk_devise;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_DEVISE"
AS
-- Chaine de reconnaissance SCCS
-- %W%  %E%
-- -- CONSTANTES PRIVEES ------------------------------------------------------
   cst_tx_euro   CONSTANT NUMBER := 6.55957;

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
--
-- Retourne le pays par defaut
--
   FUNCTION pays_ref
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      SELECT dfpays
        INTO loc_retour
        FROM parametres;

      RETURN (loc_retour);
   END pays_ref;

--
-- Retourne la devise de reference
--
   FUNCTION devise_ref
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      SELECT dfdev
        INTO loc_retour
        FROM parametres;

      RETURN (loc_retour);
   END devise_ref;

--
-- Retourne la devise inverse de celle de reference
--
   FUNCTION devise_unref
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      IF (devise_ref = euro)
      THEN
         loc_retour := franc;
      ELSE
         loc_retour := euro;
      END IF;

      RETURN (loc_retour);
   END devise_unref;

--
-- Retourne le code monnaie Euro
--
   FUNCTION euro
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      SELECT dfsoc
        INTO loc_retour
        FROM parametres;

      RETURN (loc_retour);
   END euro;

--
-- Retourne le code monnaie Franc
--
   FUNCTION franc
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      SELECT dfranc
        INTO loc_retour
        FROM parametres;

      RETURN (loc_retour);
   END franc;

--
   FUNCTION symbole (a_codmon IN NUMBER)
      RETURN VARCHAR2
   IS
      loc_retour   VARCHAR2 (5);
   BEGIN
      SELECT symbole
        INTO loc_retour
        FROM monnaie
       WHERE codmon = a_codmon;

      RETURN (loc_retour);
   END symbole;

--
   FUNCTION codmon (a_symbole IN VARCHAR2)
      RETURN NUMBER
   IS
      loc_retour   NUMBER;
   BEGIN
      SELECT codmon
        INTO loc_retour
        FROM monnaie
       WHERE symbole = a_symbole;

      RETURN (loc_retour);
   END codmon;

--
   FUNCTION converti (
      a_devise       IN   NUMBER,
      a_devise_ref   IN   NUMBER,
      a_montant      IN   NUMBER,
      a_date         IN   DATE DEFAULT SYSDATE
   )
      RETURN NUMBER
   IS
      loc_retour   NUMBER                 DEFAULT 0;
      loc_date     DATE                   := a_date;

      CURSOR fetch_change
      IS
         SELECT   valeur, base
             FROM CHANGE
            WHERE codmon = a_devise
              AND codmon_ref = a_devise_ref
              AND datcours <= NVL (loc_date, datcours)
         ORDER BY datcours DESC;

      c_change     fetch_change%ROWTYPE;
   BEGIN
      FOR c_change IN fetch_change
      LOOP
         IF fetch_change%NOTFOUND
         THEN
            RAISE NO_DATA_FOUND;
         ELSE
            loc_retour :=
               ROUND (a_montant * c_change.valeur / NVL (c_change.base, 1),
                      2);
            EXIT;
         END IF;
      END LOOP;

      RETURN (loc_retour);
   END converti;

--
   FUNCTION eurofranc_franceuro (
      a_devise    IN   NUMBER DEFAULT NULL,
      a_montant   IN   NUMBER
   )
      RETURN NUMBER
   IS
      loc_retour          NUMBER                            DEFAULT 0;
      c_valeur   CONSTANT NUMBER                            DEFAULT 6.55957;
      loc_devise_ref      NUMBER;
      g_nom_traitement    journal_adm.nom_traitement%TYPE
                                    DEFAULT 'pk_devise.EuroFranc_
FrancEuro';
      l_code_msg          mess_erreur.code_msg%TYPE;
      l_lib_msg           mess_erreur.lib_msg%TYPE;
   BEGIN
      -- devise non renseignee
      IF a_devise IS NULL
      THEN
         loc_devise_ref := pk_devise.devise_ref;
      ELSE
         loc_devise_ref := a_devise;
      END IF;

      IF loc_devise_ref = pk_devise.franc
      THEN
         loc_retour := ROUND ((a_montant / c_valeur), 2);
      ELSIF loc_devise_ref = pk_devise.euro
      THEN
         loc_retour := ROUND ((a_montant * c_valeur), 2);
      ELSE
         l_code_msg := 20001;
         -- Recherche du message dans la table
         l_lib_msg :=
            pk_trace.f_aff_mess_err (i_code_msg         => l_code_msg,
                                     i_code_pays        => 1193,
                                     i_liste_param      => g_nom_traitement
                                    );
             --
         -- Retour du message vers les postes clients(sqlforms)
         raise_application_error ((l_code_msg * -1), l_lib_msg);
      END IF;

      RETURN (loc_retour);
   END eurofranc_franceuro;

--
   FUNCTION lib_symbole (a_codmon IN NUMBER)
      RETURN VARCHAR2
   IS
      loc_retour   VARCHAR2 (45);
   BEGIN
      SELECT libelle
        INTO loc_retour
        FROM monnaie
       WHERE codmon = a_codmon;

      RETURN (loc_retour);
   END lib_symbole;

--
   FUNCTION lib_compte (a_numcpte IN NUMBER)
      RETURN VARCHAR2
   IS
      loc_retour   VARCHAR2 (30);
   BEGIN
      SELECT libcompte
        INTO loc_retour
        FROM compte
       WHERE numcpte = a_numcpte;

      RETURN (loc_retour);
   END lib_compte;

--
-- Retourne le montant converti dans la devise inverse de celle de reference
--
   FUNCTION f_convert_euro (
      i_montant   IN   NUMBER,
      i_devise    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      l_retour   NUMBER := i_montant;
   BEGIN
      IF (devise_ref = euro)
      THEN
         l_retour := ROUND (i_montant * cst_tx_euro, 2);
      ELSE
         l_retour := ROUND (i_montant / cst_tx_euro, 2);
      END IF;

      RETURN (l_retour);
   END f_convert_euro;

--
-- Retourne retourner la devise active d'un contrat
--
   FUNCTION devise_ct (in_numgar IN NUMBER)
      RETURN NUMBER
   IS
      numgarref   NUMBER (6);

      CURSOR c_dct
      IS
         SELECT codmon
           FROM param_devise
          WHERE numgar = numgarref AND debut = (SELECT MAX (debut)
                                                  FROM param_devise
                                                 WHERE numgar = numgarref);

      rec_dct     c_dct%ROWTYPE;
      dev_syst    NUMBER (2);
   BEGIN
      SELECT numgar_ref
        INTO numgarref
        FROM contrat
       WHERE numgar = in_numgar;

      OPEN c_dct;

      FETCH c_dct
       INTO rec_dct;

      IF c_dct%FOUND
      THEN
         CLOSE c_dct;

         RETURN rec_dct.codmon;
      ELSE
         CLOSE c_dct;

         SELECT codmon
           INTO dev_syst
           FROM param_devise
          WHERE numgar = 0 AND debut = (SELECT MAX (debut)
                                          FROM param_devise
                                         WHERE numgar = 0);

         RETURN dev_syst;
      END IF;
   END devise_ct;

--Retourne le montant converti dans la devise2 avec ou sans arrondi large
-- PHA 01/06/2015
  FUNCTION F_conv_montant (
      a_devise1   IN   NUMBER,
      a_devise2   IN   NUMBER,
      a_montant   IN   NUMBER,
      a_date      IN   DATE DEFAULT SYSDATE,
      arrondi_large     IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      loc_retour      NUMBER               DEFAULT 0;
      loc_retour1     NUMBER               DEFAULT 0;
      loc_date        DATE                 := a_date;
      loc_date_max1   DATE;
      loc_date_max2   DATE;
      loc_arrondi1    NUMBER               DEFAULT 2;
      loc_arrondi2    NUMBER               DEFAULT 3;

      CURSOR c_change_devise1
      IS
         SELECT CHANGE.valeur, CHANGE.base
           FROM CHANGE, monnaie
          WHERE CHANGE.codmon = a_devise1
            AND CHANGE.codmon = monnaie.codmon
            AND CHANGE.codmon_ref = pk_devise.euro
            AND CHANGE.datcours =
                          DECODE (monnaie.freq_tx,
                                  1, loc_date,
                                  loc_date_max1
                                 );

      v_devise1       CHANGE.valeur%TYPE;

      CURSOR c_change_devise2
      IS
         SELECT CHANGE.valeur, CHANGE.base
           FROM CHANGE, monnaie
          WHERE CHANGE.codmon = a_devise2
            AND CHANGE.codmon = monnaie.codmon
            AND CHANGE.codmon_ref = pk_devise.euro
            AND CHANGE.datcours =
                          DECODE (monnaie.freq_tx,
                                  1, loc_date,
                                  loc_date_max2
                                 );

      CURSOR c_date_devise1
      IS
         SELECT MAX (datcours)
           FROM CHANGE
          WHERE datcours <= loc_date
            AND codmon = a_devise1
            AND codmon_ref = pk_devise.euro;

      CURSOR c_date_devise2
      IS
         SELECT MAX (datcours)
           FROM CHANGE
          WHERE datcours <= loc_date
            AND codmon = a_devise2
            AND codmon_ref = pk_devise.euro;

      v_devise2       CHANGE.valeur%TYPE;
      v_base          CHANGE.base%TYPE;
      v_valeur        CHANGE.valeur%TYPE;
   BEGIN
      IF arrondi_large = 'O' THEN
        loc_arrondi1 := 5;
        loc_arrondi2 := 5;
      ELSE
        loc_arrondi1 := 2;
        loc_arrondi2 := 3;
      END IF;

      IF a_devise1 = a_devise2
      THEN
         RETURN (a_montant);
      END IF;

      OPEN c_date_devise1;

      FETCH c_date_devise1
       INTO loc_date_max1;

      IF c_date_devise1%NOTFOUND
      THEN
         loc_date_max1 := loc_date;
      END IF;

      CLOSE c_date_devise1;

      OPEN c_date_devise2;

      FETCH c_date_devise2
       INTO loc_date_max2;

      IF c_date_devise2%NOTFOUND
      THEN
         loc_date_max2 := loc_date;
      END IF;

      CLOSE c_date_devise2;

      IF (a_devise1 = pk_devise.euro)
      THEN
         OPEN c_change_devise2;

         FETCH c_change_devise2
          INTO v_devise2, v_base;

         LOOP
            IF v_devise2 IS NULL
            THEN
               -- Raise No_data_found;
               EXIT;
            ELSE
               loc_retour :=
                         ROUND (a_montant * (v_devise2 / NVL (v_base, 1)), loc_arrondi1);
               EXIT;
            END IF;
         END LOOP;

         CLOSE c_change_devise2;
      ELSE
         IF (a_devise2 = pk_devise.euro)
         THEN
            OPEN c_change_devise1;

            FETCH c_change_devise1
             INTO v_devise1, v_base;

            LOOP
               IF v_devise1 IS NULL
               THEN
                  -- Raise No_data_found;
                  EXIT;
               ELSE
                  loc_retour :=
                         ROUND (a_montant / (v_devise1 / NVL (v_base, 1)), loc_arrondi1);
                  EXIT;
               END IF;
            END LOOP;

            CLOSE c_change_devise1;
         ELSE
            OPEN c_change_devise1;

            FETCH c_change_devise1
             INTO v_devise1, v_base;

            LOOP
               IF v_devise1 IS NULL
               THEN
                  --Raise No_data_found;
                  EXIT;
               ELSE
                  loc_retour1 :=
                         ROUND (a_montant * (v_devise1 / NVL (v_base, 1)), loc_arrondi2);

                  SELECT valeur, base
                    INTO v_valeur, v_base
                    FROM CHANGE
                   WHERE codmon = a_devise2
                     AND codmon_ref = pk_devise.euro
                     AND datcours = loc_date;

                  IF SQL%NOTFOUND
                  THEN
                     --Raise No_data_found;
                     EXIT;
                  ELSE
                     loc_retour :=
                        ROUND (loc_retour1 / (v_valeur / NVL (v_base, 1)), loc_arrondi1);
                     EXIT;
                  END IF;
               END IF;
            END LOOP;

            CLOSE c_change_devise1;
         END IF;
      END IF;

      RETURN (loc_retour);
   END F_conv_montant;


--Retourne le montant converti dans la devise2
-- David 27/08/2004
   FUNCTION f_conv_mt (
      a_devise1   IN   NUMBER,
      a_devise2   IN   NUMBER,
      a_montant   IN   NUMBER,
      a_date      IN   DATE DEFAULT SYSDATE
   )
      RETURN NUMBER
   IS
      loc_retour      NUMBER               DEFAULT 0;

    BEGIN
      loc_retour := F_conv_montant ( a_devise1, a_devise2, a_montant, a_date, 'N');
      RETURN (loc_retour);
   END f_conv_mt;

--
--
-- Retourne la NCL(Numéro, Code, Nom/Libelle) de la devise active
--     d'un contrat à une date déterminée
--
-- I   => Données en Entrée    (I-Input)
-- LOC => Données locales      (LOC-Local/Working data)
-- O   => Données en Sortie    (O-Output)
-- B   => Données en E/S       (B-Both)
--
   FUNCTION f_dev_cntrt (
      i_numgar   IN   NUMBER,
      i_date     IN   DATE DEFAULT SYSDATE,
      i_ncl      IN   NUMBER DEFAULT 0
   )
      RETURN VARCHAR2
   IS
      numgarref    NUMBER (6);

      CURSOR c_dc
      IS
         SELECT codmon
           FROM param_devise
          WHERE numgar = numgarref
            AND debut = (SELECT MAX (debut)
                           FROM param_devise
                          WHERE numgar = numgarref AND debut <= i_date);

      rec_dc       c_dc%ROWTYPE;
      loc_retour   VARCHAR2 (45);
      b_codmon     NUMBER (4);
   BEGIN
      SELECT numgar_ref
        INTO numgarref
        FROM contrat
       WHERE numgar = i_numgar;

      OPEN c_dc;

      FETCH c_dc
       INTO rec_dc;

      IF c_dc%NOTFOUND
      THEN
         b_codmon := pk_devise.devise_ref;
      ELSE
         b_codmon := rec_dc.codmon;
      END IF;

      CLOSE c_dc;

--
--  Les codes RETOURs
--  NCL (Numéro, Code, Nom)
--  NCL = 0-RETURN(NUMBER)=> Recherche S/Numéro (effectué par le cuseur)
--  NCL = 1-RETURN(VARCHAR2(3)) => Recherche S/Code
--  NCL = 2-RETURN(VARCHAR2(45)) => Recherche S/Libelle
--
      IF i_ncl = 0
      THEN
         loc_retour := TO_CHAR (b_codmon);
         RETURN (loc_retour);
      END IF;

      IF i_ncl = 1
      THEN
         loc_retour := pk_devise.symbole (b_codmon);
         RETURN (SUBSTR (loc_retour, 1, 3));
      END IF;

      IF i_ncl = 2
      THEN
         loc_retour := pk_devise.lib_symbole (b_codmon);
         RETURN (loc_retour);
      END IF;
--
--  RETURN(Loc_retour);
--
   END f_dev_cntrt;

--
--
--
-- Retourne la NCL(Numéro, Code, Nom/Libelle) du pays
--     d'une prestation donnée
--
-- I   => Données en Entrée    (I-Input)
-- LOC => Données locales      (LOC-Local/Working data)
-- O   => Données en Sortie    (O-Output)
-- B   => Données en E/S       (B-Both)
--
   FUNCTION f_pays_presta (i_numsin IN NUMBER, i_ncl IN NUMBER DEFAULT 0)
      RETURN VARCHAR2
   IS
--
      CURSOR c_ss
      IS
         SELECT codpays
           FROM sinistre_sante
          WHERE i_numsin = num_dossier;

      rec_ss       c_ss%ROWTYPE;
--
      loc_retour   VARCHAR2 (45);
      b_codpays    NUMBER (4);
   BEGIN
      OPEN c_ss;

      FETCH c_ss
       INTO rec_ss;

      IF c_ss%NOTFOUND
      THEN
         b_codpays := pk_devise.pays_ref;
      ELSE
         b_codpays := rec_ss.codpays;
      END IF;

      CLOSE c_ss;

--
--  NCL (Numéro, Code, Nom)
--  NCL = 0 => Recherche S/Numéro (effectué par le cuseur)
--  NCL = 1 => Recherche S/Code
--  NCL = 2 => Recherche S/Libelle
--
      IF i_ncl = 0
      THEN
         loc_retour := TO_CHAR (b_codpays);
         RETURN (loc_retour);
      END IF;

      IF i_ncl = 1
      THEN
         BEGIN
            SELECT codeiso
              INTO loc_retour
              FROM pays
             WHERE codpays = b_codpays;
         EXCEPTION
            WHEN OTHERS
            THEN
               loc_retour := '** - CODEISO Introuvable';
         END;

         RETURN (SUBSTR (loc_retour, 1, 2));
      END IF;

--
      IF i_ncl = 2
      THEN
         BEGIN
            SELECT nom
              INTO loc_retour
              FROM pays
             WHERE codpays = b_codpays;
         EXCEPTION
            WHEN OTHERS
            THEN
               loc_retour := '!? - NOM Introuvable';
         END;

         RETURN (loc_retour);
      END IF;
--
--  RETURN(Loc_retour);
--
   END f_pays_presta;

--
-- Retourne la NCL(Numéro, Code, Nom/Libelle) de la devise
--     d'un pays déterminée
--
-- I   => Données en Entrée    (I-Input)
-- LOC => Données locales      (LOC-Local/Working data)
-- O   => Données en Sortie    (O-Output)
-- B   => Données en E/S       (B-Both)
--
   FUNCTION f_dev_pays (i_codpays IN NUMBER, i_ncl IN NUMBER DEFAULT 0)
      RETURN VARCHAR2
   IS
      CURSOR c_dev
      IS
         SELECT codmon
           FROM pays
          WHERE codpays = i_codpays;

      rec_dev      c_dev%ROWTYPE;
      loc_retour   VARCHAR2 (45);
      b_codmon     NUMBER (4);
   BEGIN
      OPEN c_dev;

      FETCH c_dev
       INTO rec_dev;

      IF c_dev%NOTFOUND
      THEN
         b_codmon := pk_devise.devise_ref;
      ELSE
         b_codmon := NVL (rec_dev.codmon, pk_devise.devise_ref);
      END IF;

      CLOSE c_dev;

--
--  Les codes RETOURs
--  NCL (Numéro, Code, Nom)
--  NCL = 0-RETURN(NUMBER)=> Recherche S/Numéro (effectué par le cuseur)
--  NCL = 1-RETURN(VARCHAR2(3)) => Recherche S/Code
--  NCL = 2-RETURN(VARCHAR2(45)) => Recherche S/Libelle
--
      IF i_ncl = 0
      THEN
         loc_retour := TO_CHAR (b_codmon);
         RETURN (TO_NUMBER (loc_retour));
      END IF;

      IF i_ncl = 1
      THEN
         loc_retour := pk_devise.symbole (b_codmon);
         RETURN (SUBSTR (loc_retour, 1, 3));
      END IF;

      IF i_ncl = 2
      THEN
         loc_retour := pk_devise.lib_symbole (b_codmon);
         RETURN (loc_retour);
      END IF;
--
--  RETURN(Loc_retour);
--
   END f_dev_pays;

--
-- Retourne la langue référence d'un pays
--
   FUNCTION langue_ref
      RETURN NUMBER
   IS
--
      CURSOR c_pays_langue
      IS
         SELECT   codlangue
             FROM pays_langue
            WHERE codpays = pk_devise.pays_ref
         ORDER BY defaut DESC, codlangue ASC;

--
      v_codlangue   pays_langue.codlangue%TYPE;
--
   BEGIN
--
      OPEN c_pays_langue;

      FETCH c_pays_langue
       INTO v_codlangue;

      CLOSE c_pays_langue;

--
      IF (v_codlangue IS NOT NULL)
      THEN
         RETURN v_codlangue;
      ELSE
         RETURN 1;
      END IF;
--
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 1;
      WHEN OTHERS
      THEN
         RETURN 1;
   END langue_ref;
--
-- ---------------------------------- Fin des corps des procedures publiques --
-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------
-- Aucune
-- ------------------------------------ Fin des corps des procedures privees --
END pk_devise;
/
