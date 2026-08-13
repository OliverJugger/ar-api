CREATE PROCEDURE ARTHUS."CHARGE_MEMBRE" (
   i_cle      IN       pk_texte.clefs,
   o_donnee   OUT      pk_texte.donnee
)
IS
   CURSOR c_membre
   IS
      SELECT   indvs.numindiv, indvs.refcie, indvs.qualite,
               indvs.codcourrier1, indvs.codcourrier2, indvs.codtitre,
               indvs.nom, indvs.prenom, indvs.adr1, indvs.adr2, indvs.codpos,
               indvs.ville, indvs.codpays, indvs.tel, indvs.fax,
               indvs.datnais, indvs.typassu, indvs.natur,
               indvs.typadr indvs_typadr, indvs.matorg, indvs.cless,
               indvs.regime, indvs.orgbase, indvs.caisse, indvs.guichetorg,
               indvs.cle, indvs.rang, indvs.numassu,
               adhe_cntrt_membre.typadr, adhe_cntrt_membre.numbene
          FROM adhe_cntrt_membre, indvs
         WHERE adhe_cntrt_membre.idadhesion = i_cle (0)
           AND adhe_cntrt_membre.numindiv = i_cle (1)
           AND adhe_cntrt_membre.numindiv = indvs.numindiv
      ORDER BY adhe_cntrt_membre.numindiv;

   rec_c_membre   c_membre%ROWTYPE;
BEGIN
   OPEN c_membre;

   FETCH c_membre
    INTO rec_c_membre;

   CLOSE c_membre;

   o_donnee (1) := rec_c_membre.numindiv;
   o_donnee (2) := rec_c_membre.refcie;
   o_donnee (3) := SUBSTR (pk_libelle.f_lib ('QLTE', rec_c_membre.qualite), 1, 30);
   o_donnee (4) := SUBSTR (pk_libelle.f_lib ('CODC1', rec_c_membre.codcourrier1), 1, 30);
   o_donnee (5) := SUBSTR (pk_libelle.f_lib ('CODC2', rec_c_membre.codcourrier2), 1, 30);
   o_donnee (6) := SUBSTR (pk_libelle.f_lib ('TITRE', rec_c_membre.codtitre), 1, 30);
   o_donnee (7) := SUBSTR (rec_c_membre.nom, 1, 20);
   o_donnee (8) := SUBSTR (rec_c_membre.prenom, 1, 20);
   o_donnee (9) := SUBSTR (rec_c_membre.adr1, 1, 25);
   o_donnee (10) := SUBSTR (rec_c_membre.adr2, 1, 25);
   o_donnee (11) := rec_c_membre.codpos;
   o_donnee (12) := SUBSTR (rec_c_membre.ville, 1, 25);
   o_donnee (13) := SUBSTR (f_pays (rec_c_membre.codpays), 1, 30);
   o_donnee (14) := rec_c_membre.tel;
   o_donnee (15) := rec_c_membre.fax;
   o_donnee (16) := d2e (rec_c_membre.datnais);
   o_donnee (17) := SUBSTR (pk_libelle.f_lib ('TPAS', rec_c_membre.typassu), 1, 30);

   IF (rec_c_membre.natur = 1)
   THEN
      o_donnee (18) := 'Ouvreur de droit';
   ELSIF (rec_c_membre.natur = 2)
   THEN
      o_donnee (18) := 'Ayant-Droit';
   ELSE
      o_donnee (18) := rec_c_membre.natur;
   END IF;

   o_donnee (19) :=
          SUBSTR (pk_libelle.f_lib ('TYAD', rec_c_membre.indvs_typadr), 1, 30);
   o_donnee (20) := rec_c_membre.matorg;
   o_donnee (21) := rec_c_membre.cless;
   o_donnee (22) := SUBSTR (pk_libelle.f_lib ('REGIME', rec_c_membre.regime), 1, 30);
   o_donnee (23) := SUBSTR (pk_libelle.f_lib ('ORGNS', rec_c_membre.orgbase), 1, 30);
   o_donnee (24) := rec_c_membre.caisse;
   o_donnee (25) := rec_c_membre.guichetorg;
   o_donnee (26) := rec_c_membre.cle;
   o_donnee (27) := rec_c_membre.rang;
   o_donnee (28) := rec_c_membre.numassu;
   o_donnee (29) := SUBSTR (pk_libelle.f_lib ('TYAD', rec_c_membre.typadr), 1, 30);
   o_donnee (30) := rec_c_membre.numbene;
END charge_membre;
/
