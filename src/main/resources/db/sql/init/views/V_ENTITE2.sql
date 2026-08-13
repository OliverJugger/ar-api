CREATE FORCE VIEW ARTHUS.V_ENTITE2 AS
SELECT 1 etendue, gar_cntrt.numfor cle_unique,
          grnts.refcie || ' (No de Police)' lib_cle_unique,
          TO_CHAR (grnts.numgar) cle_secondaire, gar_cntrt.numfor numfor,
          'ENT_1' mnemo
     FROM gar_cntrt, grnts
    WHERE grnts.numgar = gar_cntrt.numgar
   UNION
   SELECT 0, indvs.numindiv, indvs.nom || ' ' || indvs.prenom,
          TO_CHAR (indvs.qualite), indvs.numindiv, 'ENT_4'
     FROM indvs
   UNION
   SELECT 2, grnts.numgar, grnts.refcie, grnts.refcie, grnts.numgar, 'ENT_2'
     FROM grnts
   UNION
   SELECT 3, indvs.numindiv, indvs.nom || ' ' || indvs.prenom,
          TO_CHAR (indvs.qualite), indvs.numindiv, 'ENT_3'
     FROM indvs
    WHERE EXISTS (SELECT 1
                    FROM client
                   WHERE indvs.numindiv = client.numindiv)
   UNION
   SELECT 4, indvs.numindiv, indvs.nom || ' ' || indvs.prenom,
          TO_CHAR (indvs.qualite), indvs.numindiv, 'ENT_4'
     FROM indvs
    WHERE indvs.typassu = 1
   UNION
   SELECT 5, orgns.numorg, orgns.nom, orgns.nom, orgns.numorg, 'ENT_5'
     FROM orgns
   UNION
   SELECT 6, frmls.numfor, TO_CHAR (produit.numprod) || ' (No de Produit)',
          TO_CHAR (produit.numprod), frmls.numfor, 'ENT_6'
     FROM produit, frmls
    WHERE frmls.numprod = produit.numprod
   UNION
   SELECT 6, gar.numfor, TO_CHAR (produit.numprod) || ' (No de Produit)',
          TO_CHAR (produit.numprod), gar.numfor, 'ENT_6'
     FROM produit, gar
    WHERE produit.numprod = gar.cle
   UNION
   SELECT 7, produit.numprod, produit.libelle, TO_CHAR (produit.numprod),
          produit.numprod, 'ENT_7'
     FROM produit
   UNION
   SELECT 8, interm.numindiv, interm.nom, interm.refinterm, interm.numinterm,
          'ENT_8'
     FROM interm
   UNION
   SELECT 9, societe.numsoc, societe.nom, societe.refsoc, societe.numsoc,
          'ENT_9'
     FROM societe
   UNION
   SELECT 10 etendue, grp_gar.numgrpgar cle_unique,
          grp_gar.clef || ' (No de Produit)',
          TO_CHAR (grp_gar.clef) cle_secondaire, grp_gar.numgrpgar, 'ENT_10'
     FROM grp_gar
    WHERE grp_gar.etendue = 7
   UNION
   SELECT 11 etendue, grp_gar.numgrpgar cle_unique,
          grp_gar.clef || ' (No de Police)',
          TO_CHAR (grp_gar.clef) cle_secondaire, grp_gar.numgrpgar, 'ENT_11'
     FROM grp_gar
    WHERE grp_gar.etendue = 2
   UNION
   SELECT 12, indvs.numindiv, indvs.nom || ' ' || indvs.prenom,
          TO_CHAR (indvs.qualite), indvs.numindiv, 'ENT_12'
     FROM indvs
   UNION
   SELECT 13, adhe_cntrt.idadhesion,
          indvs.nom || ' sur ' || adhe_cntrt.numgar || '-' || contrat.refcie,
          TO_CHAR (adhe_cntrt.idadhesion), adhe_cntrt.idadhesion, 'ENT_13'
     FROM adhe_cntrt, indvs, contrat
    WHERE indvs.numindiv = adhe_cntrt.numadhe
      AND contrat.numgar = adhe_cntrt.numgar
   UNION
   SELECT 14, indvs.numindiv, indvs.nom || ' ' || indvs.prenom,
          TO_CHAR (indvs.qualite), indvs.numindiv, 'ENT_12'
     FROM indvs
    WHERE EXISTS (SELECT 1
                    FROM proposition
                   WHERE proposition.numindiv = indvs.numindiv)
   UNION
   SELECT 24, adhe_collective.numgar, adhe_collective.refcie,
          TO_CHAR (adhe_collective.numgar_ref), adhe_collective.numgar,
          'ENT_24'
     FROM adhe_collective
   UNION
   SELECT 25 etendue, v_gar.numfor cle_unique,
         v_gar.LIBGAR lib_cle_unique,
        TO_CHAR (v_gar.clef) cle_secondaire, v_gar.numfor numfor,
          'ENT_25' mnemo
     FROM v_gar
     WHERE v_gar.numfor <>0
	 UNION
   SELECT 27 etendue, to_number(dossier_sante.num_dossier)  cle_unique,
         dossier_sante.ref_dossier lib_cle_unique,
          TO_CHAR (dossier_sante.numindiv) cle_secondaire, null,
          'ENT_27' mnemo
     FROM dossier_sante
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ENTITE2 FOR ARTHUS.V_ENTITE2
