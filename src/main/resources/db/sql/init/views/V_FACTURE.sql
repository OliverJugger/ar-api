CREATE FORCE VIEW ARTHUS.V_FACTURE AS
SELECT facture.codope, facture.numfact, facture.numcli, qttc_global.numgar,
          qttc_global.numindiv, qttc_global.fin, facture.montant,
          facture.montant_d, facture.monnaie, facture.monnaie_d,
          facture.mregl, facture.echeance, qttc_global.debut datfact,
          TO_CHAR (facture.datfact, 'dd/mm/yy') edatfact,
          f_totaffec (facture.numfact, facture.codope) mt_affec,
          f_totaffec_d (facture.numfact, facture.codope) mt_affec_d,
             'Contrat n° '
          || qttc_global.numgar
          || ' Eché. '
          || TO_CHAR (qttc_global.debut, 'dd/mm/yyyy') libelle,
          indvs.nom || ' ' || indvs.prenom nomcli, 'qg03' codapli
     FROM facture, qttc_global, indvs
    WHERE NOT EXISTS (
             SELECT 1
               FROM facture_regul
              WHERE facture_regul.codope = facture.codope
                AND facture_regul.numfact_regul = facture.numfact)
      AND NOT EXISTS (
             SELECT 1
               FROM qttc_global
              WHERE facture.codope = 4
                AND qttc_global.numquit = facture.numfact
                AND qttc_global.type_qttc = 3)
      AND qttc_global.numquit(+) = facture.numfact
      AND indvs.numindiv = facture.numcli
      AND facture.codope = 4
   UNION
   SELECT facture.codope, facture.numfact, facture.numcli, 0 numgar,
          0 numindiv, TO_DATE ('') fin, facture.montant, facture.montant_d,
          facture.monnaie, facture.monnaie_d, facture.mregl, facture.echeance,
          facture.datfact, TO_CHAR (facture.datfact, 'dd/mm/yy') edatfact,
          f_totaffec (facture.numfact, facture.codope) mt_affec,
          f_totaffec_d (facture.numfact, facture.codope) mt_affec_d,
          DECODE (facture.codope,
                  7,  'Bdx comm. n° '
                   || reversement.idrevers
                   || ' du '
                   || TO_CHAR (reversement.datrevers, 'dd/mm/yyyy'),
                  9,  'Décaissement n° '
                   || pnul.numdecaismt
                   || ' du '
                   || TO_CHAR (pnul.datannul, 'dd/mm/yyyy'),
                  12, 'Bdx remb. prest. '
                   || DECODE (dcptcie.TYPE, 1, 'santé ', 2, 'prév.')
                   || ' n° '
                   || dcptcie.numdcptcie
                   || ' du '
                   || TO_CHAR (dcptcie.datcreat, 'dd/mm/yyyy'),
                  18, 'Bdx E.C. n° '
                   || remise_ec.numbdx
                   || ' du '
                   || TO_CHAR (remise_ec.date_crea, 'dd/mm/yyyy')
                 ) libelle,
          indvs.nom || ' ' || indvs.prenom nomcli,
          DECODE (facture.codope,
                  7, 'de42',
                  9, 'rg11',
                  12, DECODE (dcptcie.TYPE, 1, 'gdr1', 2, 'gdr6'),
                  18, 'ec01',
                  NULL
                 ) codapli
     FROM facture, indvs, reversement, dcptcie, remise_ec, pnul
    WHERE facture.codope IN (7, 9, 12, 18)
      AND NOT EXISTS (
             SELECT 1
               FROM reversement
              WHERE reversement.idrevers = facture.numfact
                AND reversement.valide = 'N')
      AND NOT EXISTS (
             SELECT 1
               FROM remise_ec
              WHERE remise_ec.numbdx = facture.numfact
                AND remise_ec.valide = 'N')
      AND NOT EXISTS (
             SELECT 1
               FROM dcptcie
              WHERE dcptcie.numdcptcie = facture.numfact
                AND dcptcie.valide = 'N')
      AND reversement.idrevers(+) = facture.numfact
      AND dcptcie.numdcptcie(+) = facture.numfact
      AND remise_ec.numbdx(+) = facture.numfact
      AND pnul.numdecaismt(+) = facture.numfact
      AND indvs.numindiv = facture.numcli
   UNION
   SELECT facture.codope, facture.numfact, facture.numcli, 0 numgar,
          0 numindiv, TO_DATE ('') fin, facture.montant, facture.montant_d,
          facture.monnaie, facture.monnaie_d, facture.mregl, facture.echeance,
          facture.datfact, TO_CHAR (facture.datfact, 'dd/mm/yy') edatfact,
          facture.montant, facture.montant_d,
             'Régul° par pièce N° '
          || facture_regul.numfact
          || ' le '
          || TO_CHAR (facture_regul.datope, 'dd/mm/yy'),
          indvs.nom || ' ' || indvs.prenom nomcli, 'qg03' codapli
     FROM facture, facture_regul, indvs
    WHERE facture.codope = 4
      AND facture_regul.codope = facture.codope
      AND facture_regul.numfact_regul = facture.numfact
      AND indvs.numindiv = facture.numcli
   UNION
   SELECT affectation.codope, affectation.numaffec, affectation.numcli,
          0 numgar, 0 numindiv, TO_DATE ('') fin, -affectation.montant,
          -affectation.montant_d, affectation.monnaie, affectation.monnaie_d,
          1, TO_DATE (''), affectation.dataffec,
          TO_CHAR (affectation.dataffec, 'dd/mm/yy') edatfact,
          f_totaffec (numaffec, codope) mt_affec,
          f_totaffec_d (numaffec, codope) mt_affec_d,
          DECODE (affectation.codope,
                  1,  'Indu décompte santé n° '
                   || affectation.numaffec
                   || ' du '
                   || TO_CHAR (affectation.dataffec, 'dd/mm/yy'),
                  2,  'Indu décompte prév. n° '
                   || affectation.numaffec
                   || ' du '
                   || TO_CHAR (affectation.dataffec, 'dd/mm/yy'),
                  14, 'Indu prest° délégataire n° '
                   || affectation.numaffec
                   || ' du '
                   || TO_CHAR (affectation.dataffec, 'dd/mm/yy')
                 ),
          indvs.nom || ' ' || indvs.prenom nomcli,
          DECODE (affectation.codope, 1, 'gd01', 2, 'gdp1', 14, 'de21')
     FROM indvs, affectation
    WHERE affectation.montant < 0 AND indvs.numindiv = affectation.numcli
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FACTURE FOR ARTHUS.V_FACTURE
