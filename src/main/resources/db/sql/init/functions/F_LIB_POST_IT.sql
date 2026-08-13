CREATE FUNCTION ARTHUS."F_LIB_POST_IT" (a_etendue IN NUMBER, a_cle_unique IN NUMBER)
   RETURN VARCHAR2
IS
   loc_lib   VARCHAR2 (70);
BEGIN
   -- GARANTIE
   IF (a_etendue = 0)
   THEN
      SELECT v_gar.numfor || ' - ' || v_gar.refcie
        INTO loc_lib
        FROM v_gar
       WHERE v_gar.etendue = 2 AND v_gar.numfor = a_cle_unique;
   END IF;

   -- GARANTIE
   IF (a_etendue = 0)
   THEN
      SELECT v_gar.clef || ' (No de Produit)'
        INTO loc_lib
        FROM v_gar
       WHERE v_gar.etendue = 7 AND v_gar.numfor = a_cle_unique;
   END IF;

   -- INTERMEDIAIRE
   IF (a_etendue = 18)
   THEN
      SELECT interm.nom
        INTO loc_lib
        FROM interm
       WHERE interm.numindiv = a_cle_unique;
   END IF;

   -- CONTRAT
   IF (a_etendue = 1)
   THEN
      SELECT grnts.refcie
        INTO loc_lib
        FROM grnts
       WHERE grnts.numgar = a_cle_unique;
   -- PERSONNE
   ELSIF (a_etendue = 2)
   THEN
      SELECT indvs.nom || ' ' || indvs.prenom
        INTO loc_lib
        FROM indvs
       WHERE indvs.numindiv = a_cle_unique;
   -- ADHERENT
   ELSIF (a_etendue = 3)
   THEN
      SELECT DISTINCT indvs.nom || ' ' || indvs.prenom
                 INTO loc_lib
                 FROM indvs, adhe_cntrt
                WHERE adhe_cntrt.numadhe = a_cle_unique
                  AND indvs.numindiv = adhe_cntrt.numadhe;
   -- AFFILIE
   ELSIF (a_etendue = 4)
   THEN
      SELECT DISTINCT indvs.nom || ' ' || indvs.prenom
                 INTO loc_lib
                 FROM indvs, adhe_cntrt_membre
                WHERE adhe_cntrt_membre.numindiv = a_cle_unique
                  AND indvs.numindiv = adhe_cntrt_membre.numindiv;
   -- PRODUIT
   ELSIF (a_etendue = 5)
   THEN
      SELECT produit.libelle
        INTO loc_lib
        FROM produit
       WHERE produit.numprod = a_cle_unique;
   -- SOUSCRIPTEUR
   ELSIF (a_etendue = 6)
   THEN
      SELECT indvs.nom || ' ' || indvs.prenom
        INTO loc_lib
        FROM indvs
       WHERE indvs.numindiv = a_cle_unique
         AND EXISTS (SELECT 1
                       FROM client
                      WHERE indvs.numindiv = client.numindiv);
   -- ORGANISME D'ASSURANCE
   ELSIF (a_etendue = 7)
   THEN
      SELECT orgns.nom
        INTO loc_lib
        FROM orgns
       WHERE orgns.numorg = a_cle_unique;
   -- SOCIETE DE GESTION
   ELSIF (a_etendue = 8)
   THEN
      SELECT societe.nom
        INTO loc_lib
        FROM societe
       WHERE societe.numindiv = a_cle_unique;
   -- UTILISATEUR
   ELSIF (a_etendue = 9)
   THEN
      SELECT utilisateurs.pseudo
        INTO loc_lib
        FROM utilisateurs
       WHERE utilisateurs.numutil = a_cle_unique;
   -- SINISTRE PREVOYANCE
   ELSIF (a_etendue = 10)
   THEN
      SELECT sin_prev.nosin
        INTO loc_lib
        FROM sin_prev
       WHERE sin_prev.nosin = a_cle_unique;
   -- VARIABLE CONTEXTUELLE
   ELSIF (a_etendue = 11)
   THEN
      SELECT nom_variable
        INTO loc_lib
        FROM def_variable
       WHERE def_variable.idvariable = a_cle_unique;
   -- ADHESION
   ELSIF (a_etendue = 12)
   THEN
      SELECT ref_ext
        INTO loc_lib
        FROM adhe_cntrt
       WHERE adhe_cntrt.idadhesion = a_cle_unique;
   -- PORTE EXTERNE
   ELSIF (a_etendue = 13)
   THEN
      SELECT libelle
        INTO loc_lib
        FROM libelle
       WHERE libelle.mnemo = 'PORTE' AND libelle.code = a_cle_unique;
   -- FORMULES DE CALCUL
   ELSIF (a_etendue = 14)
   THEN
      SELECT libelle
        INTO loc_lib
        FROM v_lble_ext
       WHERE v_lble_ext.mnemo = 'V_FRMLVAR' AND v_lble_ext.code = a_cle_unique;
   -- GARANTIE
   ELSIF (a_etendue = 15)
   THEN
      SELECT NVL (gar_cntrt.libelle, frmls.libelle)
        INTO loc_lib
        FROM gar_cntrt, frmls
       WHERE frmls.numfor = a_cle_unique AND gar_cntrt.numfor(+) =
                                                                  a_cle_unique
      UNION
      SELECT NVL (gar_cntrt.libelle, gar.libelle)
        FROM gar_cntrt, gar
       WHERE gar.numfor = a_cle_unique AND gar_cntrt.numfor(+) = a_cle_unique;
   -- RECOURS
   ELSIF (a_etendue = 16)
   THEN
      SELECT recours.ref_ext
        INTO loc_lib
        FROM recours
       WHERE recours.numrecours = a_cle_unique;
   -- PROPOSITION
   ELSIF (a_etendue = 19)
   THEN
      SELECT proposition.refext
        INTO loc_lib
        FROM proposition
       WHERE proposition.idpropo = a_cle_unique;
   -- PROSPECT FOURNISSEUR TIERS-PAYANT.
   ELSIF (a_etendue IN (20, 21, 22))
   THEN
      SELECT indvs.nom || ' ' || indvs.prenom
        INTO loc_lib
        FROM indvs
       WHERE indvs.numindiv = a_cle_unique;
   -- POST_IT Dossier Sante (Reférence Dossier)
   ELSIF (a_etendue = 23)
   THEN
      SELECT ref_dossier
        INTO loc_lib
        FROM dossier_sante
       WHERE dossier_sante.num_dossier = a_cle_unique;
   -- POST_IT ADHESION COLLECTIVE
   ELSIF (a_etendue = 24)
   THEN
      SELECT refcie
        INTO loc_lib
        FROM adhe_collective
       WHERE adhe_collective.numgar = a_cle_unique;
    -- POST_IT PRET
   ELSIF (a_etendue = 25)
   THEN
      SELECT ref_ext
        INTO loc_lib
        FROM pret
       WHERE pret.idpret = a_cle_unique;
     elsif ( a_etendue = 26)
   then
	SELECT libelle
    into	loc_lib
	FROM libformath WHERE nummath =a_cle_unique;
   --prestations ?
   ELSIF ( a_etendue = 27)
   then
	loc_lib:='';
   --prestations externes => non accessible depuis interface
   ELSIF ( a_etendue = 28)
   then
	loc_lib:='';
   --zone territoriale
   ELSIF ( a_etendue = 29)
   then
	SELECT libelle
    into	loc_lib
	FROM COD_ZONE_GEO WHERE numzone =a_cle_unique;
   END IF;

   RETURN loc_lib;
END f_lib_post_it;
