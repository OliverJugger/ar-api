CREATE FORCE VIEW ARTHUS.V_CTR_MONTANT AS
Select sum(sinistre.mtreel)montant,numdec
from sinistre
where numdec<>0
group by numdec
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CTR_MONTANT FOR ARTHUS.V_CTR_MONTANT
