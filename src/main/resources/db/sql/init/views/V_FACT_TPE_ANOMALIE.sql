CREATE FORCE VIEW ARTHUS.V_FACT_TPE_ANOMALIE AS
select	/*+  RULE */
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
		3 etat
from suivi_fact_tpe a
where 	a.codevefac	= 30
and 	not exists ( select /*+  ALL_ROWS */ null
                     from 	suivi_fact_tpe
                     where 	idfactpe = a.idfactpe
                     and 	codevefac between 35 and 60 )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FACT_TPE_ANOMALIE FOR ARTHUS.V_FACT_TPE_ANOMALIE
