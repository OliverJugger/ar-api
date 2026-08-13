CREATE FORCE VIEW ARTHUS.V_FACT_TPE_REJETAMC AS
select
		codadeli,
		numfact,
		numremise_import,
		numremise_export,
		datfact,
		codbenefinsee,
		codbenefcle,
		datnaibenef,
		codtypfact,
		datreceptor,
		datlimiamc,
		numcompos,
		codamcdet,
		idcptebq,
		reffin,
		typavireg,
		codevefac,
		montant,
		idfactpe,
		rangbenef,
		user_forcage,
		dattrait,
		8 etat
from suivi_fact_tpe a
where 	a.codevefac	= 70
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FACT_TPE_REJETAMC FOR ARTHUS.V_FACT_TPE_REJETAMC
