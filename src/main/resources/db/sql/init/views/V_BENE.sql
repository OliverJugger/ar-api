CREATE FORCE VIEW ARTHUS.V_BENE AS
select	1 typbene,
	'L''assuré' lib_bene,
	indvs.numindiv numbene,
	indvs.nom||' '||indvs.prenom nombene
from	indvs
union
select	2 ,
	'L''organisme T.P.',
	tierspayant.numtp numbene,
	tierspayant.nom
from	tierspayant
union
select	3 ,
	'Le fournisseur',
	tiers.numtiers numbene,
	tiers.nom
from	tiers
union
select	5 ,
	'Le courtier',
	societe.numsoc numbene,
	societe.refsoc||' '||societe.nom
from	societe
GO
CREATE OR REPLACE PUBLIC SYNONYM V_BENE FOR ARTHUS.V_BENE
