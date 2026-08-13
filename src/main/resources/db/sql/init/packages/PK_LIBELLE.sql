CREATE OR REPLACE PACKAGE ARTHUS."PK_LIBELLE"
IS

   FUNCTION f_lib (
      a_mnemo    IN   VARCHAR2,
      a_code     IN   NUMBER,
      a_retour   IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2;


   FUNCTION f_lib (
      a_mnemo    IN   VARCHAR2,
      a_code     IN   VARCHAR2,
      a_retour   IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2;


   FUNCTION f_nat_risque (i_risque IN NUMBER, i_type_risque IN NUMBER)
      RETURN VARCHAR2;


   FUNCTION f_lib_groupe (
      i_mnemo         IN   def_grp_libelle.mnemo%TYPE,
      i_code_groupe   IN   def_grp_libelle.code_groupe%TYPE
   )
      RETURN VARCHAR2;


   FUNCTION f_lib_entite (a_etendue IN NUMBER, a_clef IN NUMBER)
      RETURN VARCHAR2;


   FUNCTION F_LIB_SENS_BY_MNEMO (
       a_mnemo IN VARCHAR2,
       a_code IN NUMBER
   ) RETURN NUMBER;

END pk_libelle;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_LIBELLE"
IS

   FUNCTION f_lib_groupe (
      i_mnemo         IN   def_grp_libelle.mnemo%TYPE,
      i_code_groupe   IN   def_grp_libelle.code_groupe%TYPE
   )
      RETURN VARCHAR2
   IS
      CURSOR c_groupe
      IS
         SELECT libelle
           FROM def_grp_libelle
          WHERE code_groupe = i_code_groupe AND mnemo = i_mnemo;

      l_libelle   def_grp_libelle.libelle%TYPE;
   BEGIN
      OPEN c_groupe;

      FETCH c_groupe
       INTO l_libelle;

      IF c_groupe%NOTFOUND
      THEN
         IF (i_mnemo = 'CMCR' AND i_code_groupe = 99)
         THEN
            l_libelle := 'Compensation / remboursements';
         ELSE
            l_libelle := 'Indéterminé';
         END IF;
      END IF;

      CLOSE c_groupe;

      RETURN (l_libelle);
   END f_lib_groupe;


   FUNCTION f_nat_risque (i_risque IN NUMBER, i_type_risque IN NUMBER)
      RETURN VARCHAR2
   IS
      l_nat_risque   VARCHAR2 (45);
   BEGIN
      IF (i_risque > 0)
      THEN
         l_nat_risque := f_lib ('RISQ', i_risque);
      ELSIF (i_risque = 0)
      THEN
         l_nat_risque := 'Santé';
      ELSIF (i_risque > -99)
      THEN
         IF (i_type_risque = 4)
         THEN
            l_nat_risque := f_lib ('TYPFRAIS', -i_risque);
         ELSIF (i_type_risque = 3)
         THEN
            l_nat_risque := f_lib ('FRAIS_GAR', -i_risque);
         ELSIF (i_type_risque = 1)
         THEN
            l_nat_risque := f_lib ('TYPTAX', -i_risque);
         ELSIF (i_type_risque = 2)
         THEN
            l_nat_risque := f_lib ('TYPCOMM', -i_risque);
         ELSIF (i_type_risque = 5)
         THEN
            l_nat_risque := f_lib ('TYPRETRO', -i_risque);
         END IF;
      ELSE
         l_nat_risque := 'Indéterminé';
      END IF;

      RETURN (l_nat_risque);
   END f_nat_risque;


   FUNCTION f_lib (
      a_mnemo    IN   VARCHAR2,
      a_code     IN   NUMBER,
      a_retour   IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      loc_lib   VARCHAR2 (210) := 'Indeterminee';
   BEGIN
      BEGIN
         SELECT libelle
           INTO loc_lib
           FROM libelle
          WHERE mnemo = a_mnemo AND code = a_code;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT libelle
                 INTO loc_lib
                 FROM v_lble_ext
                WHERE mnemo = a_mnemo AND code = a_code;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  IF (a_retour IS NOT NULL)
                  THEN
                     RAISE NO_DATA_FOUND;
                  ELSE
                     NULL;
                  END IF;
            END;
      END;

      RETURN (loc_lib);
   END f_lib;


   FUNCTION f_lib (
      a_mnemo    IN   VARCHAR2,
      a_code     IN   VARCHAR2,
      a_retour   IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      loc_lib   VARCHAR2 (78) := 'Indéterminée';
   BEGIN
      BEGIN
         SELECT libelle
           INTO loc_lib
           FROM libelle_bis
          WHERE mnemo = a_mnemo AND code = a_code;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            BEGIN
               SELECT libelle
                 INTO loc_lib
                 FROM v_libelle_bis
                WHERE mnemo = a_mnemo AND code = a_code;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  IF (a_retour IS NOT NULL)
                  THEN
                     RAISE NO_DATA_FOUND;
                  ELSE
                     NULL;
                  END IF;
            END;
      END;

      RETURN (loc_lib);
   END f_lib;


   FUNCTION f_lib_entite (a_etendue IN NUMBER, a_clef IN NUMBER)
      RETURN VARCHAR2
   IS
      lib_entite   VARCHAR2 (70);
   BEGIN
      -- INTERMEDIAIRE
      IF (a_etendue = 8)
      THEN
         SELECT interm.nom
           INTO lib_entite
           FROM interm
          WHERE interm.numindiv = a_clef;
      END IF;

      -- CONTRAT
      IF (a_etendue = 2)
      THEN
         SELECT grnts.refcie
           INTO lib_entite
           FROM grnts
          WHERE grnts.numgar = a_clef;
      END IF;

      -- PERSONNE
      IF (a_etendue = 0)
      THEN
         SELECT indvs.nom || ' ' || indvs.prenom
           INTO lib_entite
           FROM indvs
          WHERE indvs.numindiv = a_clef;
      END IF;

      -- PRODUIT
      IF (a_etendue = 7)
      THEN
         SELECT produit.libelle
           INTO lib_entite
           FROM produit
          WHERE produit.numprod = a_clef;
      END IF;

      -- SOUSCRIPTEUR
      IF (a_etendue = 3)
      THEN
         SELECT indvs.nom || ' ' || indvs.prenom
           INTO lib_entite
           FROM indvs
          WHERE indvs.numindiv = a_clef
            AND EXISTS (SELECT 1
                          FROM client
                         WHERE indvs.numindiv = client.numindiv);
      END IF;

      -- SINISTRE PREVOYANCE
      IF (a_etendue = 15)
      THEN
         SELECT sin_prev.nosin
           INTO lib_entite
           FROM sin_prev
          WHERE sin_prev.nosin = a_clef;
      END IF;

      -- ADHESION
      IF (a_etendue = 13)
      THEN
         SELECT ref_ext
           INTO lib_entite
           FROM adhe_cntrt
          WHERE adhe_cntrt.idadhesion = a_clef;
      END IF;

      -- GARANTIE
      BEGIN
         IF (a_etendue = 25)
         THEN
            SELECT libelle
              INTO lib_entite
              FROM formule
             WHERE formule.numfor = a_clef;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT libelle
              INTO lib_entite
              FROM garanties
             WHERE garanties.numfor = a_clef;
      END;

      -- ADHESION COLLECTIVE
      IF (a_etendue = 24)
      THEN
         SELECT refcie
           INTO lib_entite
           FROM adhe_collective
          WHERE adhe_collective.numgar = a_clef;
      END IF;

      RETURN lib_entite;
   END f_lib_entite;

   FUNCTION F_LIB_SENS_BY_MNEMO (
       a_mnemo IN VARCHAR2,
       a_code IN NUMBER
   ) RETURN NUMBER
   IS
     REP_SENS NUMBER := null;
   BEGIN

        SELECT SENS INTO REP_SENS FROM LIBELLE WHERE MNEMO = a_mnemo
        AND CODE = a_code;

        RETURN REP_SENS;

   EXCEPTION
      WHEN OTHERS THEN
         PK_trace.P_INS_journal_adm (
                  I_nom_traitement => 'PK_LIBELLE.F_LIB_SENS_BY_MNEMO',
                  I_session  => SID,
                  I_niv_msg  => 3,
                  I_msg_adm  => substr(sqlerrm,1,132),
                  I_idligne  => 1);
         RETURN null;
   END F_LIB_SENS_BY_MNEMO;




END pk_libelle;
/
