CREATE OR REPLACE PACKAGE ARTHUS."PK_NOEMIE"
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_noemie.sql 1.4  01/09/18

   -- PROCEDURES PUBLIQUES  -----------------------------------------
--@pub
--
-- Procedure gerant la conversion Euro / Franc des montants sinistre_porte
--
   PROCEDURE p_conv_devise_ref (
      i_codmon     IN       sinistre_porte.codmon%TYPE,
      i_mtfrais    IN       sinistre_porte.mtfrais%TYPE,
      i_baseremb   IN       sinistre_porte.baseremb%TYPE,
      i_mtremb     IN       sinistre_porte.mtremb%TYPE,
      i_autrb      IN       sinistre_porte.autrb%TYPE,
      i_mtprest    IN       sinistre_porte.mtprest%TYPE,
      o_mtfrais    OUT      sinistre_porte.mtfrais%TYPE,
      o_baseremb   OUT      sinistre_porte.baseremb%TYPE,
      o_mtremb     OUT      sinistre_porte.mtremb%TYPE,
      o_autrb      OUT      sinistre_porte.autrb%TYPE,
      o_mtprest    OUT      sinistre_porte.mtprest%TYPE
   );

--
   FUNCTION f_caisse (
      i_dateremise   IN   porte_remise.dateremise%TYPE,
      i_numindiv     IN   noemie.numindiv%TYPE
   )
      RETURN VARCHAR2;

   PRAGMA RESTRICT_REFERENCES (f_caisse, WNDS, WNPS);

   FUNCTION f_idadhesion (
      i_dateremise   IN   porte_remise.dateremise%TYPE,
      i_numindiv     IN   noemie.numindiv%TYPE
   )
      RETURN NUMBER;

   PRAGMA RESTRICT_REFERENCES (f_idadhesion, WNDS, WNPS);

   FUNCTION f_statut_noemie (
      i_numindiv   IN   NUMBER,
      i_idporte    IN   NUMBER DEFAULT 0
   )
      RETURN VARCHAR2;

   FUNCTION f_saisie_manuelle (
      i_numindiv   IN   sinistre.numindiv%TYPE,
      i_codfrais   IN   sinistre.codfrais%TYPE,
      i_datsin     IN   sinistre.datsin%TYPE,
      i_mtfrais    IN   sinistre.mtfrais%TYPE
   )
      RETURN NUMBER;

   FUNCTION f_saisie_import (
      i_numindiv   IN   sinistre.numindiv%TYPE,
      i_codfrais   IN   sinistre.codfrais%TYPE,
      i_datsin     IN   sinistre.datsin%TYPE
   )
      RETURN BOOLEAN;

   FUNCTION f_double_import (
      i_numindiv   IN   sinistre_porte.numindiv%TYPE,
      i_codfrais   IN   sinistre_porte.codfrais%TYPE,
      i_datsin     IN   sinistre_porte.datsin%TYPE
   )
      RETURN BOOLEAN;

   FUNCTION f_type_porte (i_numporte IN NUMBER)
      RETURN NUMBER;

   PROCEDURE p_sel_porte_adhesion (
      i_numporte     IN       porte_adhesion.numporte%TYPE,
      i_numindiv     IN       porte_adhesion.numindiv%TYPE,
      i_idadhesion   IN       porte_adhesion.idadhesion%TYPE,
      i_transmis     IN       porte_adhesion.transmis%TYPE DEFAULT NULL,
      i_mouvement    IN       porte_adhesion.mouvement%TYPE DEFAULT NULL,
      i_matorg       IN       noemie.matorg%TYPE DEFAULT NULL,
      o_idporte      OUT      porte_adhesion.idporte%TYPE,
      o_transmis     OUT      porte_adhesion.transmis%TYPE,
      o_mouvement    OUT      porte_adhesion.mouvement%TYPE,
      o_type         OUT      porte_adhesion.TYPE%TYPE,
      o_found        OUT      BOOLEAN
   );

   PROCEDURE p_ins_porte_adhesion (
      i_numporte         IN       porte_adhesion.numporte%TYPE,
      i_numindiv         IN       porte_adhesion.numindiv%TYPE,
      i_idadhesion       IN       porte_adhesion.idadhesion%TYPE,
      i_numremise        IN       porte_adhesion.numremise%TYPE DEFAULT 0,
      i_transmis         IN       porte_adhesion.transmis%TYPE DEFAULT 2,
      i_type             IN       porte_adhesion.TYPE%TYPE,
      i_debut            IN       porte_adhesion.debut%TYPE,
      i_mouvement        IN       porte_adhesion.mouvement%TYPE,
      i_fin              IN       porte_adhesion.fin%TYPE,
      i_numsoc           IN       noemie.numsoc%TYPE,
      i_numorg           IN       noemie.numorg%TYPE,
      i_orgbase          IN       noemie.orgbase%TYPE,
      i_caisse           IN       noemie.caisse%TYPE,
      i_centre           IN       noemie.centre%TYPE,
      i_matorg           IN       noemie.matorg%TYPE,
      i_cless            IN       noemie.cless%TYPE,
      i_datnais          IN       noemie.datnais%TYPE,
      i_datnais_regime   IN       noemie.datnais_regime%TYPE,
      i_rang             IN       noemie.rang%TYPE,
      i_natur            IN       noemie.natur%TYPE,
      i_numassu          IN       noemie.numassu%TYPE,
      i_nom              IN       noemie.nom%TYPE,
      i_prenom           IN       noemie.prenom%TYPE,
      i_nomjf            IN       noemie.nomjf%TYPE,
      i_type_contrat     IN       noemie.type_contrat%TYPE DEFAULT '01',
      o_idporte          OUT      porte_adhesion.idporte%TYPE
   );

   PROCEDURE p_upd_noemie (
      i_numporte         IN   noemie.numporte%TYPE,
      i_numindiv         IN   noemie.numindiv%TYPE,
      i_idadhesion       IN   noemie.idadhesion%TYPE,
      i_type             IN   porte_adhesion.TYPE%TYPE,
      i_orgbase          IN   noemie.orgbase%TYPE,
      i_caisse           IN   noemie.caisse%TYPE,
      i_centre           IN   noemie.centre%TYPE,
      i_matorg           IN   noemie.matorg%TYPE,
      i_Oldmatorg        IN   noemie.matorg%TYPE,
      i_cless            IN   noemie.cless%TYPE,
      i_datnais          IN   noemie.datnais%TYPE,
      i_datnais_regime   IN   noemie.datnais_regime%TYPE,
      i_rang             IN   noemie.rang%TYPE,
      i_natur            IN   noemie.natur%TYPE,
      i_numassu          IN   noemie.numassu%TYPE,
      i_nom              IN   noemie.nom%TYPE,
      i_prenom           IN   noemie.prenom%TYPE,
      i_nomjf            IN   noemie.nomjf%TYPE
   );

   PROCEDURE p_ins_sinistre_ano (
      i_numporte    IN   NUMBER,
      i_numano      IN   NUMBER,
      i_numsin      IN   NUMBER,
      i_datano      IN   DATE,
      i_etatano     IN   NUMBER,
      i_numremise   IN   NUMBER
   );

   PROCEDURE p_sel_porte_param (
      i_numporte     IN       porte_param.numporte%TYPE,
      o_rech_indiv   OUT      porte_param.rech_indiv%TYPE,
      o_typbene      OUT      porte_param.typbene%TYPE,
      o_numbene      OUT      porte_param.numbene%TYPE,
      o_fr_rr        OUT      porte_param.fr_rr%TYPE
   );

-- Variables globales publiques -----------------------------------------
   g_numporte     porte_param.numporte%TYPE     := -1;
   g_rech_indiv   porte_param.rech_indiv%TYPE;
   g_typbene      porte_param.typbene%TYPE;
   g_numbene      porte_param.numbene%TYPE;
   g_fr_rr        porte_param.fr_rr%TYPE;
----------------------------------------------------------
-- Types publics -----------------------------------------
----------------------------------------------------------
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS."PK_NOEMIE"
AS
-- Chaine de reconnaissance SCCS
-- @(#)pk_noemie.sql 1.4  01/09/18

   -- -- DECLARATION DES PROCEDURES PRIVEES --------------------------------------
   PROCEDURE p_sel_next_idporte (o_idporte OUT porte_adhesion.idporte%TYPE)
   IS
   BEGIN
      SELECT NVL (MAX (idporte), 0) + 1
        INTO o_idporte
        FROM porte_adhesion;
   END p_sel_next_idporte;

   PROCEDURE p_ins_noemie (
      i_idporte          IN   noemie.idporte%TYPE,
      i_numporte         IN   noemie.numporte%TYPE,
      i_numindiv         IN   noemie.numindiv%TYPE,
      i_numassu          IN   noemie.numassu%TYPE,
      i_idadhesion       IN   noemie.idadhesion%TYPE,
      i_numremise        IN   noemie.numremise%TYPE,
      i_numsoc           IN   noemie.numsoc%TYPE,
      i_numorg           IN   noemie.numorg%TYPE,
      i_orgbase          IN   noemie.orgbase%TYPE,
      i_caisse           IN   noemie.caisse%TYPE,
      i_centre           IN   noemie.centre%TYPE,
      i_matorg           IN   noemie.matorg%TYPE,
      i_natur            IN   noemie.natur%TYPE,
      i_debut            IN   noemie.debut%TYPE,
      i_mouvement        IN   noemie.mouvement%TYPE,
      i_fin              IN   noemie.fin%TYPE,
      i_datnais          IN   noemie.datnais%TYPE,
      i_datnais_regime   IN   noemie.datnais_regime%TYPE,
      i_rang             IN   noemie.rang%TYPE,
      i_cless            IN   noemie.cless%TYPE,
      i_nom              IN   noemie.nom%TYPE,
      i_prenom           IN   noemie.prenom%TYPE,
      i_nomjf            IN   noemie.nomjf%TYPE,
      i_type_contrat     IN   noemie.type_contrat%TYPE
   )
   IS
   BEGIN
      BEGIN
         INSERT INTO noemie
                     (idporte, numporte, numindiv, numassu,
                      idadhesion, numremise, numsoc, numorg,
                      orgbase, caisse, centre, matorg, natur, debut,
                      mouvement, fin, datnais, datnais_regime,
                      rang, cless, nom, prenom, nomjf,
                      type_contrat, creation, maj
                     )
              VALUES (i_idporte, i_numporte, i_numindiv, i_numassu,
                      i_idadhesion, i_numremise, i_numsoc, i_numorg,
                      i_orgbase, i_caisse, i_centre, i_matorg, i_natur, i_debut,
                      i_mouvement, i_fin, i_datnais, i_datnais_regime,
                      i_rang, i_cless, i_nom, i_prenom, i_nomjf,
                      i_type_contrat, TRUNC (SYSDATE), TRUNC (SYSDATE)
                     );
      END;
   END p_ins_noemie;

-- ----------------------------- Fin des declarations des procedures privees --

   -- -- CORPS DES PROCEDURES PUBLIQUES ------------------------------------------
--@corpub
--
-- Procedure gerant la conversion Euro / Franc des montants sinistre_porte
--
   PROCEDURE p_conv_devise_ref (
      i_codmon     IN       sinistre_porte.codmon%TYPE,
      i_mtfrais    IN       sinistre_porte.mtfrais%TYPE,
      i_baseremb   IN       sinistre_porte.baseremb%TYPE,
      i_mtremb     IN       sinistre_porte.mtremb%TYPE,
      i_autrb      IN       sinistre_porte.autrb%TYPE,
      i_mtprest    IN       sinistre_porte.mtprest%TYPE,
      o_mtfrais    OUT      sinistre_porte.mtfrais%TYPE,
      o_baseremb   OUT      sinistre_porte.baseremb%TYPE,
      o_mtremb     OUT      sinistre_porte.mtremb%TYPE,
      o_autrb      OUT      sinistre_porte.autrb%TYPE,
      o_mtprest    OUT      sinistre_porte.mtprest%TYPE
   )
   IS
      cst_tx_euro   CONSTANT CHANGE.valeur%TYPE   := 6.55957;
      l_devise_ref           NUMBER;
      l_franc                NUMBER;
      l_euro                 NUMBER;
   BEGIN
      l_devise_ref := pk_devise.devise_ref;
      l_franc := pk_devise.franc;
      l_euro := pk_devise.euro;

      IF (i_codmon = l_franc)
      THEN
         o_mtfrais := ROUND (i_mtfrais / cst_tx_euro, 2);
         o_baseremb := ROUND (i_baseremb / cst_tx_euro, 2);
         o_mtremb := ROUND (i_mtremb / cst_tx_euro, 2);
         o_autrb := ROUND (i_autrb / cst_tx_euro, 2);
         o_mtprest := ROUND (i_mtprest / cst_tx_euro, 2);
      ELSE
         o_mtfrais := ROUND (i_mtfrais * cst_tx_euro, 2);
         o_baseremb := ROUND (i_baseremb * cst_tx_euro, 2);
         o_mtremb := ROUND (i_mtremb * cst_tx_euro, 2);
         o_autrb := ROUND (i_autrb * cst_tx_euro, 2);
         o_mtprest := ROUND (i_mtprest * cst_tx_euro, 2);
      END IF;
   END p_conv_devise_ref;

--
   FUNCTION f_type_porte (i_numporte IN NUMBER)
      RETURN NUMBER
   IS
      l_type_porte   NUMBER DEFAULT 1;
   BEGIN
      -- SELECT NVL (MIN (2), 1) -- XHUE le 04/08/2010
      SELECT type_circuit
        INTO l_type_porte
        FROM porte_param
       WHERE numporte = i_numporte;

      RETURN l_type_porte;
   END f_type_porte;

   FUNCTION f_statut_noemie (
      i_numindiv   IN   NUMBER,
      i_idporte    IN   NUMBER DEFAULT 0
   )
      RETURN VARCHAR2
   IS
      loc_date_trans   DATE                  DEFAULT SYSDATE;

      CURSOR fetch_objet
      IS
         SELECT      DECODE (rejet_noemie.mouvement,
                             'R', 'Rejet le ',
                             'S', 'Signal° le ',
                             'C', 'Certif° le '
                            )
                  || TO_CHAR (TO_DATE (rejet_noemie.date_rejet, 'ddmmyy'),
                              'dd/mm/yy'
                             )
                  || ' : '
                  || rejet_noemie.libelle statut
             FROM rejet_noemie
            WHERE rejet_noemie.numindiv = i_numindiv
              AND TO_DATE (date_rejet, 'ddmmyy') >= loc_date_trans
         ORDER BY rejet_noemie.numremise DESC;

      loc_objet        fetch_objet%ROWTYPE;
      loc_retour       VARCHAR2 (200)        := 'Non encore acquité ...';
      loc_numremise    BINARY_INTEGER        := 0;
      loc_transmis     BINARY_INTEGER        := 2;
   BEGIN
      IF (i_idporte != 0)
      THEN
         BEGIN
            SELECT numremise, transmis
              INTO loc_numremise, loc_transmis
              FROM porte_adhesion
             WHERE idporte = i_idporte;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         IF (loc_numremise = 0 OR loc_transmis = 2)
         THEN
            RETURN ('Non encore transmis ...');
         ELSE
            BEGIN
               SELECT date_trans
                 INTO loc_date_trans
                 FROM remise_externe
                WHERE numremise = loc_numremise;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
            END;
         END IF;
      END IF;

      FOR loc_objet IN fetch_objet
      LOOP
         IF fetch_objet%FOUND
         THEN
            loc_retour := loc_objet.statut;
            EXIT;
         END IF;
      END LOOP;

      RETURN loc_retour;
   END f_statut_noemie;

   FUNCTION f_caisse (
      i_dateremise   IN   porte_remise.dateremise%TYPE,
      i_numindiv     IN   noemie.numindiv%TYPE
   )
      RETURN VARCHAR2
   IS
      CURSOR c_noemie
      IS
         SELECT noemie.caisse
           FROM remise_externe, noemie
          WHERE remise_externe.date_remise < i_dateremise
            AND remise_externe.numremise = noemie.numremise
            AND noemie.numindiv = i_numindiv;

      rec_c_noemie   c_noemie%ROWTYPE;
   BEGIN
      OPEN c_noemie;

      FETCH c_noemie
       INTO rec_c_noemie;

      CLOSE c_noemie;

      RETURN (rec_c_noemie.caisse);
   END f_caisse;

   FUNCTION f_idadhesion (
      i_dateremise   IN   porte_remise.dateremise%TYPE,
      i_numindiv     IN   noemie.numindiv%TYPE
   )
      RETURN NUMBER
   IS
      CURSOR c_noemie
      IS
         SELECT noemie.idadhesion
           FROM noemie, remise_externe
          WHERE remise_externe.date_remise < i_dateremise
            AND remise_externe.numremise = noemie.numremise
            AND noemie.numindiv = i_numindiv;

      rec_c_noemie   c_noemie%ROWTYPE;
   BEGIN
      OPEN c_noemie;

      FETCH c_noemie
       INTO rec_c_noemie;

      CLOSE c_noemie;

      RETURN (rec_c_noemie.idadhesion);
   END f_idadhesion;

   FUNCTION f_saisie_manuelle (
      i_numindiv   IN   sinistre.numindiv%TYPE,
      i_codfrais   IN   sinistre.codfrais%TYPE,
      i_datsin     IN   sinistre.datsin%TYPE,
      i_mtfrais    IN   sinistre.mtfrais%TYPE
   )
      RETURN NUMBER
   IS
      CURSOR c_sinistre
      IS
         SELECT 1
           FROM sinistre s
          WHERE numindiv = i_numindiv
            AND codfrais = i_codfrais
            AND datsin = i_datsin
            AND mtfrais = i_mtfrais
            AND flagam = 'a'
            AND numsin NOT IN (SELECT numannul
                                 FROM sinistre
                                WHERE numannul = s.numsin);

      rec_c_sinistre   c_sinistre%ROWTYPE;
      l_retour         NUMBER (1)           := 0;
   BEGIN
      OPEN c_sinistre;

      FETCH c_sinistre
       INTO rec_c_sinistre;

      IF c_sinistre%FOUND
      THEN
         l_retour := 1;
      END IF;

      CLOSE c_sinistre;

      RETURN (l_retour);
   END f_saisie_manuelle;

   FUNCTION f_saisie_import (
      i_numindiv   IN   sinistre.numindiv%TYPE,
      i_codfrais   IN   sinistre.codfrais%TYPE,
      i_datsin     IN   sinistre.datsin%TYPE
   )
      RETURN BOOLEAN
   IS
      CURSOR c_sinistre
      IS
         SELECT 1
           FROM sinistre
          WHERE numindiv = i_numindiv
            AND codfrais = i_codfrais
            AND datsin = i_datsin
            AND flagam = 'p';

      rec_c_sinistre   c_sinistre%ROWTYPE;
      l_retour         BOOLEAN              := FALSE;
   BEGIN
      OPEN c_sinistre;

      FETCH c_sinistre
       INTO rec_c_sinistre;

      IF c_sinistre%FOUND
      THEN
         l_retour := TRUE;
      END IF;

      CLOSE c_sinistre;

      RETURN (l_retour);
   END f_saisie_import;

   FUNCTION f_double_import (
      i_numindiv   IN   sinistre_porte.numindiv%TYPE,
      i_codfrais   IN   sinistre_porte.codfrais%TYPE,
      i_datsin     IN   sinistre_porte.datsin%TYPE
   )
      RETURN BOOLEAN
   IS
      CURSOR c_sinistre_porte
      IS
         SELECT 1
           FROM sinistre_porte
          WHERE numindiv = i_numindiv
            AND codfrais = i_codfrais
            AND datsin = i_datsin;

      rec_c_sinistre_porte   c_sinistre_porte%ROWTYPE;
      l_retour               BOOLEAN                    := FALSE;
   BEGIN
      OPEN c_sinistre_porte;

      FETCH c_sinistre_porte
       INTO rec_c_sinistre_porte;

      IF c_sinistre_porte%FOUND
      THEN
         l_retour := TRUE;
      END IF;

      CLOSE c_sinistre_porte;

      RETURN (l_retour);
   END f_double_import;

   PROCEDURE p_sel_porte_adhesion (
      i_numporte     IN       porte_adhesion.numporte%TYPE,
      i_numindiv     IN       porte_adhesion.numindiv%TYPE,
      i_idadhesion   IN       porte_adhesion.idadhesion%TYPE,
      i_transmis     IN       porte_adhesion.transmis%TYPE DEFAULT NULL,
      i_mouvement    IN       porte_adhesion.mouvement%TYPE DEFAULT NULL,
      i_matorg       IN       noemie.matorg%TYPE DEFAULT NULL,
      o_idporte      OUT      porte_adhesion.idporte%TYPE,
      o_transmis     OUT      porte_adhesion.transmis%TYPE,
      o_mouvement    OUT      porte_adhesion.mouvement%TYPE,
      o_type         OUT      porte_adhesion.TYPE%TYPE,
      o_found        OUT      BOOLEAN
   )
   IS
      CURSOR c_porte_adhesion
      IS
           SELECT porte_adhesion.idporte, porte_adhesion.transmis, porte_adhesion.mouvement, porte_adhesion.TYPE
             FROM porte_adhesion,noemie
            WHERE porte_adhesion.numporte = i_numporte
              AND noemie.idporte=porte_adhesion.idporte
              AND noemie.matorg=NVL(i_matorg,noemie.matorg)
              AND porte_adhesion.numindiv = i_numindiv
              AND porte_adhesion.idadhesion = i_idadhesion
              AND porte_adhesion.transmis =
                                     NVL (i_transmis, porte_adhesion.transmis)
              AND porte_adhesion.mouvement =
                                   NVL (i_mouvement, porte_adhesion.mouvement)
         ORDER BY idporte DESC;

      rec_c_porte_adhesion   c_porte_adhesion%ROWTYPE;
   BEGIN
      OPEN c_porte_adhesion;

      FETCH c_porte_adhesion
       INTO rec_c_porte_adhesion;

      IF (c_porte_adhesion%NOTFOUND)
      THEN
         o_found := FALSE;
      ELSE
         o_found := TRUE;
         o_idporte := rec_c_porte_adhesion.idporte;
         o_transmis := rec_c_porte_adhesion.transmis;
         o_mouvement := rec_c_porte_adhesion.mouvement;
         o_type := rec_c_porte_adhesion.TYPE;
      END IF;

      CLOSE c_porte_adhesion;
   END p_sel_porte_adhesion;
/*
   PROCEDURE p_ins_porte_adhesion (
      i_numporte         IN       porte_adhesion.numporte%TYPE,
      i_numindiv         IN       porte_adhesion.numindiv%TYPE,
      i_idadhesion       IN       porte_adhesion.idadhesion%TYPE,
      i_numremise        IN       porte_adhesion.numremise%TYPE DEFAULT 0,
      i_transmis         IN       porte_adhesion.transmis%TYPE DEFAULT 2,
      i_type             IN       porte_adhesion.TYPE%TYPE,
      i_debut            IN       porte_adhesion.debut%TYPE,
      i_mouvement        IN       porte_adhesion.mouvement%TYPE,
      i_fin              IN       porte_adhesion.fin%TYPE,
      i_numsoc           IN       noemie.numsoc%TYPE,
      i_numorg           IN       noemie.numorg%TYPE,
      i_orgbase          IN       noemie.orgbase%TYPE,
      i_caisse           IN       noemie.caisse%TYPE,
      i_centre           IN       noemie.centre%TYPE,
      i_matorg           IN       noemie.matorg%TYPE,
      i_cless            IN       noemie.cless%TYPE,
      i_datnais          IN       noemie.datnais%TYPE,
      i_datnais_regime   IN       noemie.datnais_regime%TYPE,
      i_rang             IN       noemie.rang%TYPE,
      i_natur            IN       noemie.natur%TYPE,
      i_numassu          IN       noemie.numassu%TYPE,
      i_nom              IN       noemie.nom%TYPE,
      i_prenom           IN       noemie.prenom%TYPE,
      i_nomjf            IN       noemie.nomjf%TYPE,
      i_type_contrat     IN       noemie.type_contrat%TYPE DEFAULT '01',
      o_idporte          OUT      porte_adhesion.idporte%TYPE
   )
   IS
      l_idporte   porte_adhesion.idporte%TYPE;

      CURSOR c_list_numassu
          IS
      SELECT indvs_secu.numindiv
        FROM indvs, indvs indvs_secu
       WHERE indvs.numindiv = i_numindiv
         AND ((indvs_secu.matorg = indvs.matorg) OR (indvs_secu.matorg = indvs.matorg2)) -- -- Gestion du double numéro de sécurité social
         AND indvs_secu.natur = 1;


      Rec_list_numassu c_list_numassu%ROWTYPE;

   BEGIN
     p_sel_next_idporte (o_idporte => l_idporte);
     BEGIN
        INSERT INTO porte_adhesion
                    (idporte, numporte, numindiv, idadhesion,
                     numremise, transmis, TYPE, debut, mouvement,
                     fin
                    )
             VALUES (l_idporte, i_numporte, i_numindiv, i_idadhesion,
                     i_numremise, i_transmis, i_type, i_debut, i_mouvement,
                     i_fin
                    );
     END;
    -- Parcours du curseur dans le cas où l assuré possède un double numéro de sécu
    FOR Rec_list_numassu  IN c_list_numassu LOOP
      p_ins_noemie (i_idporte                  => l_idporte,
                    i_numporte                 => i_numporte,
                    i_numindiv                 => i_numindiv,
                    i_numassu                  => Rec_list_numassu.numindiv,
                    i_idadhesion               => i_idadhesion,
                    i_numremise                => i_numremise,
                    i_numsoc                   => i_numsoc,
                    i_numorg                   => i_numorg,
                    i_orgbase                  => i_orgbase,
                    i_caisse                   => i_caisse,
                    i_centre                   => i_centre,
                    i_matorg                   => i_matorg,
                    i_natur                    => i_natur,
                    i_debut                    => i_debut,
                    i_mouvement                => i_mouvement,
                    i_fin                      => i_fin,
                    i_datnais                  => i_datnais,
                    i_datnais_regime           => i_datnais_regime,
                    i_rang                     => i_rang,
                    i_cless                    => i_cless,
                    i_nom                      => i_nom,
                    i_prenom                   => i_prenom,
                    i_nomjf                    => i_nomjf,
                    i_type_contrat             => i_type_contrat
                   );

    END LOOP;

   END p_ins_porte_adhesion;
*/
   PROCEDURE p_ins_porte_adhesion (
      i_numporte         IN       porte_adhesion.numporte%TYPE,
      i_numindiv         IN       porte_adhesion.numindiv%TYPE,
      i_idadhesion       IN       porte_adhesion.idadhesion%TYPE,
      i_numremise        IN       porte_adhesion.numremise%TYPE DEFAULT 0,
      i_transmis         IN       porte_adhesion.transmis%TYPE DEFAULT 2,
      i_type             IN       porte_adhesion.TYPE%TYPE,
      i_debut            IN       porte_adhesion.debut%TYPE,
      i_mouvement        IN       porte_adhesion.mouvement%TYPE,
      i_fin              IN       porte_adhesion.fin%TYPE,
      i_numsoc           IN       noemie.numsoc%TYPE,
      i_numorg           IN       noemie.numorg%TYPE,
      i_orgbase          IN       noemie.orgbase%TYPE,
      i_caisse           IN       noemie.caisse%TYPE,
      i_centre           IN       noemie.centre%TYPE,
      i_matorg           IN       noemie.matorg%TYPE,
      i_cless            IN       noemie.cless%TYPE,
      i_datnais          IN       noemie.datnais%TYPE,
      i_datnais_regime   IN       noemie.datnais_regime%TYPE,
      i_rang             IN       noemie.rang%TYPE,
      i_natur            IN       noemie.natur%TYPE,
      i_numassu          IN       noemie.numassu%TYPE,
      i_nom              IN       noemie.nom%TYPE,
      i_prenom           IN       noemie.prenom%TYPE,
      i_nomjf            IN       noemie.nomjf%TYPE,
      i_type_contrat     IN       noemie.type_contrat%TYPE DEFAULT '01',
      o_idporte          OUT      porte_adhesion.idporte%TYPE
   )
   IS
      l_idporte   porte_adhesion.idporte%TYPE;
   BEGIN
      p_sel_next_idporte (o_idporte => l_idporte);
      o_idporte:=l_idporte;
      BEGIN
         INSERT INTO porte_adhesion
                     (idporte, numporte, numindiv, idadhesion,
                      numremise, transmis, TYPE, debut, mouvement,
                      fin
                     )
              VALUES (l_idporte, i_numporte, i_numindiv, i_idadhesion,
                      i_numremise, i_transmis, i_type, i_debut, i_mouvement,
                      i_fin
                     );
      END;

      p_ins_noemie (i_idporte             => l_idporte,
                    i_numporte            => i_numporte,
                    i_numindiv            => i_numindiv,
                    i_numassu             => i_numassu,
                    i_idadhesion          => i_idadhesion,
                    i_numremise           => i_numremise,
                    i_numsoc              => i_numsoc,
                    i_numorg              => i_numorg,
                    i_orgbase             => i_orgbase,
                    i_caisse              => i_caisse,
                    i_centre              => i_centre,
                    i_matorg              => i_matorg,
                    i_natur               => i_natur,
                    i_debut               => i_debut,
                    i_mouvement           => i_mouvement,
                    i_fin                 => i_fin,
                    i_datnais             => i_datnais,
                    i_datnais_regime      => i_datnais_regime,
                    i_rang                => i_rang,
                    i_cless               => i_cless,
                    i_nom                 => i_nom,
                    i_prenom              => i_prenom,
                    i_nomjf               => i_nomjf,
                    i_type_contrat        => i_type_contrat
                   );
   END p_ins_porte_adhesion;

   PROCEDURE p_upd_noemie (
      i_numporte         IN   noemie.numporte%TYPE,
      i_numindiv         IN   noemie.numindiv%TYPE,
      i_idadhesion       IN   noemie.idadhesion%TYPE,
      i_type             IN   porte_adhesion.TYPE%TYPE,
      i_orgbase          IN   noemie.orgbase%TYPE,
      i_caisse           IN   noemie.caisse%TYPE,
      i_centre           IN   noemie.centre%TYPE,
      i_matorg           IN   noemie.matorg%TYPE,
      i_Oldmatorg        IN   noemie.matorg%TYPE,
      i_cless            IN   noemie.cless%TYPE,
      i_datnais          IN   noemie.datnais%TYPE,
      i_datnais_regime   IN   noemie.datnais_regime%TYPE,
      i_rang             IN   noemie.rang%TYPE,
      i_natur            IN   noemie.natur%TYPE,
      i_numassu          IN   noemie.numassu%TYPE,
      i_nom              IN   noemie.nom%TYPE,
      i_prenom           IN   noemie.prenom%TYPE,
      i_nomjf            IN   noemie.nomjf%TYPE
   )
   IS
   BEGIN

     UPDATE noemie
        SET nom = i_nom,
            prenom = i_prenom,
            datnais = i_datnais,
            datnais_regime = i_datnais_regime,
            rang = i_rang,
            matorg = i_matorg,
            orgbase = i_orgbase,
            caisse = i_caisse,
            centre = i_centre,
            maj = SYSDATE,
            nomjf = i_nomjf,
            natur = i_natur,
            cless = i_cless
      WHERE numremise = 0
        AND mouvement != 'A'
        AND numporte = i_numporte
        AND idadhesion = i_idadhesion
        AND numindiv = i_numindiv
        AND matorg=i_Oldmatorg;

     UPDATE porte_adhesion
        SET TYPE = i_type
      WHERE numremise = 0
        AND mouvement != 'A'
        AND numporte = i_numporte
        AND idadhesion = i_idadhesion
        AND numindiv = i_numindiv
        AND idporte=(select idporte from noemie where numremise = 0
                        AND mouvement != 'A'
                        AND numporte = i_numporte
                        AND idadhesion = i_idadhesion
                        AND numindiv = i_numindiv
                        AND porte_adhesion.idporte=noemie.idporte
                        AND matorg=i_matorg
        );

   END p_upd_noemie;

   PROCEDURE p_ins_sinistre_ano (
      i_numporte    IN   NUMBER,
      i_numano      IN   NUMBER,
      i_numsin      IN   NUMBER,
      i_datano      IN   DATE,
      i_etatano     IN   NUMBER,
      i_numremise   IN   NUMBER
   )
   IS
   BEGIN
      INSERT INTO sinistre_ano
                  (numporte, numano, numsin, datano, etatano,
                   numremise
                  )
           VALUES (i_numporte, i_numano, i_numsin, i_datano, i_etatano,
                   i_numremise
                  );
   END p_ins_sinistre_ano;

   PROCEDURE p_sel_porte_param (
      i_numporte     IN       porte_param.numporte%TYPE,
      o_rech_indiv   OUT      porte_param.rech_indiv%TYPE,
      o_typbene      OUT      porte_param.typbene%TYPE,
      o_numbene      OUT      porte_param.numbene%TYPE,
      o_fr_rr        OUT      porte_param.fr_rr%TYPE
   )
   IS
      CURSOR c_porte
      IS
         SELECT rech_indiv, typbene, numbene, fr_rr
           FROM porte_param
          WHERE porte_param.numporte = i_numporte;

      rec_c_porte   c_porte%ROWTYPE;
   BEGIN
      IF (i_numporte != g_numporte)
      THEN
         OPEN c_porte;

         FETCH c_porte
          INTO rec_c_porte;

         CLOSE c_porte;

         g_numporte := i_numporte;
         g_rech_indiv := rec_c_porte.rech_indiv;
         g_typbene := rec_c_porte.typbene;
         g_numbene := rec_c_porte.numbene;
         g_fr_rr := rec_c_porte.fr_rr;
      END IF;

      o_rech_indiv := g_rech_indiv;
      o_typbene := g_typbene;
      o_numbene := g_numbene;
      o_fr_rr := g_fr_rr;
   END p_sel_porte_param;
-- ---------------------------------- Fin des corps des procedures publiques --

-- -- CORPS DES PROCEDURES PRIVEES --------------------------------------------

-- ------------------------------------ Fin des corps des procedures privees --
END;
/
