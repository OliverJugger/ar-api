CREATE FORCE VIEW ARTHUS.V_DECAISMT AS
SELECT decaismt.numdecaismt, decaismt.codope, ope.libelle libope,
          decaismt.modpmt, mopm.libelle libmodpmt, refpmt,
          decaismt.datpay d_datpay,
          TO_CHAR (decaismt.datpay, 'dd/mm/yy') datpay, decaismt.montant,
          decaismt.montant_d, monnaie.symbole, decaismt.numcpte,
          DECODE (decaismt.numutil,
                  -1, 'En attente de validation',
                  DECODE (flagpay,
                          1, compte.libcompte,
                          'En attente d''affectation'
                         )
                 ) libcompte,
          decaismt.numchq, decaismt.numdest numbene,
          indvs.nom || ' ' || indvs.prenom nombene, decaismt.typbene,
          util.nom nomutil, decaismt.debit, decaismt.flagpay,
          decaismt.datedit d_datedit, decaismt.datcomp d_datcomp,
          decaismt.datcompta d_datcompta,
          TO_CHAR (decaismt.datedit, 'dd/mm/yy') datedit,
          TO_CHAR (decaismt.datcomp, 'dd/mm/yy') datcomp,
          TO_CHAR (decaismt.datcompta, 'dd/mm/yy') datcompta,
          decaismt.monnaie, decaismt.monnaie_d,decaismt.numedit
         ,decaismt.idcompta, decaismt.numdcptcie
         , decaismt.numdcptcie_sin
     FROM util, monnaie, compte, libelle mopm, libelle ope, indvs, decaismt
    WHERE util.numutil(+) = decaismt.numutil
      AND compte.numcpte + 0 = decaismt.numcpte
      AND monnaie.codmon + 0 = decaismt.monnaie
      AND ope.code + 0 = decaismt.codope
      AND ope.mnemo = 'OPE'
      AND mopm.code + 0 = decaismt.modpmt
      AND mopm.mnemo = 'MOPM'
      AND indvs.numindiv = decaismt.numdest
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DECAISMT FOR ARTHUS.V_DECAISMT
