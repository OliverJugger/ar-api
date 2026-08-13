CREATE FORCE VIEW ARTHUS.SIN_PREV AS
SELECT sntr_prev.nosin nosin, dossier_sinistre.numindiv numindiv,
          sntr_prev.norisq norisq, sntr_prev.motif nositu,
          sntr_prev.cause cause, sntr_prev.idcorres numindiv_corres,
          dossier_sinistre.anterieur anterieur, sntr_prev.numutil userid,
          sntr_prev.survenance datesurv,sntr_prev.prischarge, sntr_prev.declaration datedecla,
          sntr_prev.fin datefin, dossier_sinistre.cloture dateclot,
          sntr_prev.numclot numclot, NULL cle_nosin, NULL nositu_init,
          sntr_prev.motif motif,sntr_prev.info_comp1,sntr_prev.info_comp2,priscalc
     FROM dossier_sinistre, sntr_prev
    WHERE sntr_prev.iddossier = dossier_sinistre.iddossier
          WITH CHECK OPTION
GO
CREATE OR REPLACE SYNONYM ARTHUS.SIN FOR ARTHUS.SIN_PREV

GO
CREATE OR REPLACE SYNONYM ARTHUS.TMP_SIN FOR ARTHUS.SIN_PREV

GO
CREATE OR REPLACE PUBLIC SYNONYM SIN FOR ARTHUS.SIN_PREV

GO
CREATE OR REPLACE PUBLIC SYNONYM SIN_PREV FOR ARTHUS.SIN_PREV

GO
CREATE OR REPLACE PUBLIC SYNONYM TMP_SIN FOR ARTHUS.SIN_PREV
