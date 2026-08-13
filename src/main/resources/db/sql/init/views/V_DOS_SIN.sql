CREATE FORCE VIEW ARTHUS.V_DOS_SIN AS
select dossier_sinistre.iddossier,
       dossier_sinistre.ref_ext,
       dossier_sinistre.numindiv,
       dossier_sinistre.debut,
       dossier_sinistre.fin,
       dossier_sinistre.cloture,
       sntr_prev.nosin,
       sntr_prev.survenance,
       sntr_prev.declaration,
       sntr_prev.norisq,
       sntr_prev.cause,
       sntr_prev.dc_assure,
       histo_sntr_prev.etat
From dossier_sinistre,
     sntr_prev,
     histo_sntr_prev
Where sntr_prev.iddossier=dossier_sinistre.iddossier
And   histo_sntr_prev.nosin=sntr_prev.nosin
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DOS_SIN FOR ARTHUS.V_DOS_SIN
