CREATE FORCE VIEW ARTHUS.V_GAR_REASS AS
SELECT
		distinct traite.numtr clef,
		traite.refexttr libelle,
		'Global traité' libgar,
		traite.datefftr,
		'' valide,
                21	etendue
	FROM	traite,
		avenant
        WHERE	traite.numtr = avenant.numtr
        AND	avenant.valideav = 'O'
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GAR_REASS FOR ARTHUS.V_GAR_REASS
