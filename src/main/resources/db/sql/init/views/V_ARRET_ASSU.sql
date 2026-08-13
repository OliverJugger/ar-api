CREATE FORCE VIEW ARTHUS.V_ARRET_ASSU AS
select       dossier_sinistre.numindiv,
		arret.idarret,
		arret.nosin,
		arret.debut,
		arret.fin,
		arret.traite,
		arret.continu,
		arret.base_regime,
		arret.base_autre,
		arret.base_calcul,
		arret.creation,
		arret.maj,
		arret.numutil,
		arret.type,
		arret.periode
	from	dossier_sinistre,
	        sntr_prev,
		arret
	where	arret.nosin = sntr_prev.nosin
	and	sntr_prev.iddossier=dossier_sinistre.iddossier
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ARRET_ASSU FOR ARTHUS.V_ARRET_ASSU
