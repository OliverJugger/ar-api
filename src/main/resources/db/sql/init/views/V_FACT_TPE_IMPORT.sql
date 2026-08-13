CREATE FORCE VIEW ARTHUS.V_FACT_TPE_IMPORT AS
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
		1 etat
from suivi_fact_tpe
where 	codevefac	= 10
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FACT_TPE_IMPORT FOR ARTHUS.V_FACT_TPE_IMPORT
