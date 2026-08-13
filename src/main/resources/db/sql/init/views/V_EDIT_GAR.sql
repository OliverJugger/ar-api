CREATE FORCE VIEW ARTHUS.V_EDIT_GAR AS
SELECT NVL (produit.numprod, gar_cntrt.numgar) numprodgar,
          NVL (produit.numprod, 0) numprod, NVL (gar_cntrt.numgar, 0) numgar,
          DECODE (produit.numprod,
                  NULL, 'Contrat ' || grnts.refcie,
                  'Produit ' || produit.libelle
                 ) lib_numprodgar,
          frmls.numfor numfor, frmls.libelle lib_numfor,
          calcul.rubrique rubrique, a.libelle lib_rubrique,
          calcul.codfrais codfrais, b.libelle lib_codfrais,
          calcul.datapli calc_datapli,
          TO_CHAR (calcul.datapli, 'dd/mm/yy') calc_edatapli,
          calcul.datper calc_datper,
          TO_CHAR (calcul.datper, 'dd/mm/yy') calc_edatper,
          calcul.nummath nummath, libformath.libelle lib_nummath,
          calcul.x VARIABLE,
		  calcul.y VARIABLE2
     FROM frmls,
          produit,
          grnts,
          gar_cntrt,
          calcul,
          libformath,
          --defrub,
		  
          natfrais a,
          natfrais b
    WHERE gar_cntrt.numfor(+) = frmls.numfor
      AND grnts.numgar(+) = gar_cntrt.numgar
      AND produit.numprod(+) = frmls.numprod
      AND calcul.numfor = frmls.numfor
      --AND defrub.numfor = frmls.numfor
      AND calcul.nummath = libformath.nummath
      AND a.codfrais = calcul.rubrique
      --AND a.codfrais = defrub.codfrais
      --AND b.rubrique = defrub.codfrais
      AND b.codfrais = calcul.codfrais
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EDIT_GAR FOR ARTHUS.V_EDIT_GAR
