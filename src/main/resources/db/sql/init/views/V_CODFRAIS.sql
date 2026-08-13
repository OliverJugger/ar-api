CREATE FORCE VIEW ARTHUS.V_CODFRAIS AS
SELECT 2 etendue, grnts.numgar clef, grnts.refcie, gar_cntrt.nomgar nomgar,
          gar_cntrt.numfor numfor, gar_cntrt.libelle libgar,
          gar_cntrt.datapli datapli, gar_cntrt.datper datper,
          gar_cntrt.valide valide, gar_cntrt.TYPE typfor,
          ntfrs.codfrais rubrique, ntfrs.libelle lib_rubrique,
          codfrais.codfrais, codfrais.libelle lib_codfrais
     FROM gar_cntrt, grnts, ntfrs, v_ntfrs_ext codfrais
    WHERE grnts.numgar = gar_cntrt.numgar
      AND ntfrs.TYPE = 1
      AND codfrais.TYPE = 2
      AND codfrais.rubrique = ntfrs.codfrais
   UNION
   SELECT 2 etendue, grnts.numgar clef, grnts.refcie, '' nomgar, 0 numfor,
          'Toutes Garanties' libgar, SYSDATE, SYSDATE, '' valide, 0 typfor,
          ntfrs.codfrais, ntfrs.libelle, codfrais.codfrais,
          codfrais.libelle lib_codfrais
     FROM grnts, ntfrs, v_ntfrs_ext codfrais
    WHERE ntfrs.TYPE = 1
      AND codfrais.TYPE = 2
      AND codfrais.rubrique = ntfrs.codfrais
   UNION
   SELECT 7, produit.numprod, produit.libelle, '', 0, 'Toutes Garanties',
          SYSDATE, SYSDATE, '', 0, ntfrs.codfrais, ntfrs.libelle,
          codfrais.codfrais, codfrais.libelle lib_codfrais
     FROM produit, ntfrs, v_ntfrs_ext codfrais
    WHERE ntfrs.TYPE = 1
      AND codfrais.TYPE = 2
      AND codfrais.rubrique = ntfrs.codfrais
   UNION
   SELECT 7, produit.numprod, produit.libelle, frmls.nomgar, frmls.numfor,
          frmls.libelle, NVL (frmls.debut, produit.deffet), frmls.fin,
          frmls.valide, 1, ntfrs.codfrais, ntfrs.libelle, codfrais.codfrais,
          codfrais.libelle lib_codfrais
     FROM produit, frmls, ntfrs, v_ntfrs_ext codfrais
    WHERE frmls.numprod = produit.numprod
      AND ntfrs.TYPE = 1
      AND codfrais.TYPE = 2
      AND codfrais.rubrique = ntfrs.codfrais
   UNION
   SELECT 7, produit.numprod, produit.libelle, gar.nomgar, gar.numfor,
          gar.libelle, gar.debut, gar.fin, gar.valide, 2, '', '', '', ''
     FROM produit, gar
    WHERE produit.numprod = gar.cle
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CODFRAIS FOR ARTHUS.V_CODFRAIS
