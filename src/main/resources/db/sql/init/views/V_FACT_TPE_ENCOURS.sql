CREATE FORCE VIEW ARTHUS.V_FACT_TPE_ENCOURS AS
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
		2 etat
from suivi_fact_tpe a
where 	a.codevefac	= 10
and 	not exists ( select /*+  ALL_ROWS */ null
                     from 	suivi_fact_tpe
                     where 	idfactpe = a.idfactpe
                     and 	codevefac between 30 and 60 )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FACT_TPE_ENCOURS FOR ARTHUS.V_FACT_TPE_ENCOURS
