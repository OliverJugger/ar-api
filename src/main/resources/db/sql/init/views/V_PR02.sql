CREATE FORCE VIEW ARTHUS.V_PR02 AS
SELECT grnts.numinterm numsoc, societe.nom nomsoc, grnts.numgar,
          grnts.refcie, grnts.cellule, grnts.numutil, grnts.numorg, orgns.nom,
          grnts.numprod, produit.libelle libprod, grnts.numcli,
          indvs.nom || ' ' || indvs.prenom libcli, grnts.datsous,
          TO_CHAR (grnts.datsous, 'dd/mm/yy') edatsous, grnts.dateff,
          TO_CHAR (grnts.dateff, 'dd/mm/yy') edateff, grnts.fract,
          histo_contrat.datsai datact, histo_contrat.debut,
          histo_contrat.motif, histo_contrat.etat, etat.libelle libetat,
          fract.libelle libfract, motif.libelle libmotif
     FROM societe,
          contrat grnts,
          histo_contrat,
          orgns,
          indvs,
          libelle motif,
          libelle etat,
          libelle fract,
          produit
    WHERE EXISTS (
             SELECT 1
               FROM util_soc
              WHERE util_soc.numutil = f_numutil
                AND util_soc.numsoc = grnts.numinterm)
      AND societe.numsoc = grnts.numinterm
      AND indvs.numindiv = grnts.numcli
      AND produit.numprod = grnts.numprod
      AND etat.mnemo = 'ET_CONT'
      AND etat.code = histo_contrat.etat
      AND motif.mnemo(+) = 'HISTO_C_' || TO_CHAR (histo_contrat.etat)
      AND motif.code(+) = histo_contrat.motif
      AND fract.mnemo(+) = 'FRAC'
      AND fract.code(+) = grnts.fract
      AND orgns.numorg = grnts.numorg
      AND histo_contrat.numgar = grnts.numgar
      and histo_contrat.Annul = 'N'  -- MUR M0006541
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PR02 FOR ARTHUS.V_PR02
