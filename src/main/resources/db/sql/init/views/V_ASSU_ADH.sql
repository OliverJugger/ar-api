CREATE FORCE VIEW ARTHUS.V_ASSU_ADH AS
select distinct adhesion.numgar,
		  assu.numindiv,
		  assu.nom,
 		  assu.prenom,
		  contrat.refcie
	from assu,contrat,adhesion
	where adhesion.numgar=contrat.numgar
	and adhesion.numindiv=assu.numindiv
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ASSU_ADH FOR ARTHUS.V_ASSU_ADH
