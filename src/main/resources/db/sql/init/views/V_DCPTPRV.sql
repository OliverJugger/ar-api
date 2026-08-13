CREATE FORCE VIEW ARTHUS.V_DCPTPRV AS
SELECT decompte_prev.numdec, contrat.numgar,
          TO_CHAR (decompte_prev.datpay, 'dd/mm/yy') datedec,
          decompte_prev.datpay odatedec, contrat.refcie,
          f_numindiv_sin (decompte_prev.numdec) numindiv,
          assure.nom || ' ' || assure.prenom nomassu, assure.matorg,
          decaismt.typbene, NVL (decaismt.numdest,
                                 affectation.numcli) numbene,
          DECODE (decaismt.typbene,
                  1, 'L''assure lui-même',
                  2, 'Bénéficiaires désignés',
                  'Autre'
                 ) lib_bene,
          bene.nom || ' ' || bene.prenom nombene,
          TO_CHAR (decaismt.datpay, 'dd/mm/yy') datpay,
          decaismt.datpay odatpay, libelle.libelle libmodpmt,
          affectation.codope, decaismt.refpmt, decaismt.flagpay,
          affectation.numdecaismt, affectation.montant, monnaie.symbole,
          decaismt.numcpte, decaismt.numchq, decaismt.datedit,
          affectation.montant_d, affectation.monnaie, affectation.monnaie_d, decaismt.modpmt,
          contrat.refcie_chapeau
     FROM decompte_prev,
          contrat,
          adhe_cntrt,
          indvs assure,
          indvs bene,
          monnaie,
          libelle,
          affectation,
          decaismt
    WHERE decompte_prev.idadhesion = adhe_cntrt.idadhesion
      AND adhe_cntrt.numgar = contrat.numgar
      AND assure.numindiv = f_numindiv_sin (decompte_prev.numdec)
      AND decaismt.numbene = bene.numindiv(+)
      AND decompte_prev.numdec = affectation.numaffec
      AND monnaie.codmon = affectation.monnaie
      AND libelle.mnemo(+) = 'MOPM'
      AND libelle.code(+) = decaismt.modpmt
      AND affectation.codope = 2
      AND decaismt.numdecaismt(+) = affectation.numdecaismt
   UNION
-- Les décomptes devant être réglés à un fournisseur
   SELECT decompte_prev.numdec, contrat.numgar,
          TO_CHAR (decompte_prev.datpay, 'dd/mm/yy') datedec,
          decompte_prev.datpay odatedec, contrat.refcie,
          f_numindiv_sin (decompte_prev.numdec) numindiv,
          assure.nom || ' ' || assure.prenom nomassu, assure.matorg,
          TO_NUMBER (''), compte_tiers.numcli numbene,
          'Délégataire prestations prevoyance' lib_bene,
          bene.nom || ' ' || bene.prenom nombene, '', TO_DATE (''), '',
          compte_tiers.codope, TO_NUMBER (''), TO_NUMBER (''), TO_NUMBER (''),
          Decode(compte_tiers.sens, -1, -compte_tiers.montant, compte_tiers.montant), '', TO_NUMBER (''), TO_NUMBER (''),
          TO_DATE (''), Decode(compte_tiers.sens, -1, -compte_tiers.montant_d, compte_tiers.montant_d), compte_tiers.monnaie,
          compte_tiers.monnaie_d, null
          , contrat.refcie_chapeau -- MUR M0004485
     FROM decompte_prev,
          contrat,
          adhe_cntrt,
          indvs assure,
          indvs bene,
          compte_tiers
    WHERE decompte_prev.idadhesion = adhe_cntrt.idadhesion
      AND adhe_cntrt.numgar = contrat.numgar
      AND assure.numindiv = f_numindiv_sin (decompte_prev.numdec)
      AND compte_tiers.numcli = bene.numindiv(+)
      AND decompte_prev.numdec = compte_tiers.cle
      AND compte_tiers.codope = 2
      AND NOT EXISTS (SELECT 1
                        FROM compensation
                       WHERE compensation.idmvt = compte_tiers.idmvt)
   UNION
-- Les décomptes réglés à un fournisseur
   SELECT decompte_prev.numdec, contrat.numgar,
          TO_CHAR (decompte_prev.datpay, 'dd/mm/yy') datedec,
          decompte_prev.datpay odatedec, contrat.refcie,
          f_numindiv_sin (decompte_prev.numdec) numindiv,
          assure.nom || ' ' || assure.prenom nomassu, assure.matorg,
          decaismt.typbene, NVL (decaismt.numdest,
                                 affectation.numcli) numbene,
          DECODE (decaismt.typbene,
                  1, 'L''assure lui-même',
                  2, 'Bénéficiaires désignés',
                  'Autre'
                 ) lib_bene,
          bene.nom || ' ' || bene.prenom nombene,
          TO_CHAR (decaismt.datpay, 'dd/mm/yy') datpay,
          decaismt.datpay odatpay, libelle.libelle libmodpmt,
          compte_tiers.codope, decaismt.refpmt, decaismt.flagpay,
          affectation.numdecaismt, affectation.montant, monnaie.symbole,
          decaismt.numcpte, decaismt.numchq, decaismt.datedit,
          affectation.montant_d, affectation.monnaie, affectation.monnaie_d, decaismt.modpmt
          , contrat.refcie_chapeau -- MUR M0004485
     FROM decompte_prev,
          contrat,
          adhe_cntrt,
          indvs assure,
          indvs bene,
          monnaie,
          libelle,
          compte_tiers,
          affectation,
          decaismt
    WHERE decompte_prev.idadhesion = adhe_cntrt.idadhesion
      AND adhe_cntrt.numgar = contrat.numgar
      AND assure.numindiv = f_numindiv_sin (decompte_prev.numdec)
      AND decaismt.numbene = bene.numindiv(+)
      AND monnaie.codmon = affectation.monnaie
      AND libelle.mnemo(+) = 'MOPM'
      AND libelle.code(+) = decaismt.modpmt
      AND compte_tiers.cle = decompte_prev.numdec
      AND compte_tiers.codope = 2
      AND affectation.codope = 10
      AND decaismt.numdecaismt = affectation.numdecaismt
      AND EXISTS (
             SELECT 1
               FROM compensation, compte_tiers a
              WHERE compensation.idmvt = compte_tiers.idmvt
                AND compensation.idcomp = a.idmvt
                AND a.cle = affectation.numaffec
                AND a.codope = 10)
   UNION
-- Les décomptes devant être réglés à un fournisseur
   SELECT decompte_prev.numdec, contrat.numgar,
          TO_CHAR (decompte_prev.datpay, 'dd/mm/yy') datedec,
          decompte_prev.datpay odatedec, contrat.refcie,
          f_numindiv_sin (decompte_prev.numdec) numindiv,
          assure.nom || ' ' || assure.prenom nomassu, assure.matorg,
          TO_NUMBER (''), compte_tiers.numcli numbene,
          'Délégataire prestations prevoyance' lib_bene,
          bene.nom || ' ' || bene.prenom nombene, '', TO_DATE (''), '',
          compte_tiers.codope, TO_NUMBER (''), TO_NUMBER (''), TO_NUMBER (''),
          Decode(compte_tiers.sens, -1, -compte_tiers.montant, compte_tiers.montant), '', TO_NUMBER (''), TO_NUMBER (''),
          TO_DATE (''), Decode(compte_tiers.sens, -1, -compte_tiers.montant_d, compte_tiers.montant_d), compte_tiers.monnaie,
          compte_tiers.monnaie_d, null
          , contrat.refcie_chapeau -- MUR M0004485
     FROM decompte_prev,
          contrat,
          adhe_cntrt,
          indvs assure,
          indvs bene,
          compte_tiers
    WHERE decompte_prev.idadhesion = adhe_cntrt.idadhesion
      AND adhe_cntrt.numgar = contrat.numgar
      AND assure.numindiv = f_numindiv_sin (decompte_prev.numdec)
      AND compte_tiers.numcli = bene.numindiv(+)
      AND decompte_prev.numdec = compte_tiers.cle
      AND compte_tiers.codope = 2
      AND compte_tiers.idmvt in
              (select idmvt
                from compensation
               where idcomp in
                        (select idmvt
                           from compte_tiers
                           where cle in
                                  (select idaffec
                                     from compte_client
                                     where numencaismt=decompte_prev.numdec
                                       and numcli=compte_tiers.numcli)))
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DCPTPRV FOR ARTHUS.V_DCPTPRV
