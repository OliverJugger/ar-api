CREATE FORCE VIEW ARTHUS.V_ADHE_AUTO AS
SELECT	a.numgar,
        a.refcie,
        b.numfor,
        b. nomgar,
	b.libelle,
	b.nat_risq,
	a.mode_gestion,
	a.typgar
FROM    contrat a,garanties b
WHERE   a.numgar=b.cle
AND	b.nat_risq in(5,6)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ADHE_AUTO FOR ARTHUS.V_ADHE_AUTO
