CREATE FORCE VIEW ARTHUS.V_ASSURE AS
SELECT adhe_cntrt.numadhe numindiv,
          codc1.libelle || ' ' || indvs.nom || ' ' || indvs.prenom nomassu,
          adhe_cntrt.idadhesion num_adhesion, adhe_cntrt.numgar numgar,
          indvs.typassu, indvs.typadr, adhe_cntrt.date_adhe datnais,
          TO_CHAR (adhe_cntrt.date_adhe, 'dd/mm/yyyy') dateff,
          adhe_cntrt.ref_ext lib_adhesion
     FROM indvs, adhe_cntrt, libelle codc1
    WHERE codc1.code(+) = indvs.codcourrier1
      AND codc1.mnemo(+) = 'CODC1'
      AND adhe_cntrt.numadhe = indvs.numindiv
   UNION
   SELECT indvs.numindiv,
          codc1.libelle || ' ' || indvs.nom || ' ' || indvs.prenom nomassu,
          adhe_cntrt_membre.idadhesion num_adhesion, 0 numgar, indvs.typassu,
          indvs.typadr, indvs.datnais,
          TO_CHAR (indvs.datnais, 'dd/mm/yyyy') dateff,
          tyad.libelle lib_adhesion
     FROM indvs, adhe_cntrt_membre, libelle codc1, libelle tyad
    WHERE codc1.code(+) = indvs.codcourrier1
      AND codc1.mnemo(+) = 'CODC1'
-- and   indvs.typassu > 1
      AND adhe_cntrt_membre.numindiv = indvs.numindiv
      AND tyad.code(+) = indvs.typadr
      AND tyad.mnemo(+) = 'TYAD'
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ASSURE FOR ARTHUS.V_ASSURE
