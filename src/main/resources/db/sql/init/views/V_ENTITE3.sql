CREATE FORCE VIEW ARTHUS.V_ENTITE3 AS
select	0 etendue,
	indvs.numindiv cle_unique,
	indvs.nom||' '||indvs.prenom lib_cle_unique,
	to_char(indvs.qualite) cle_secondaire,
	indvs.numindiv numfor,
	'ENT_4' mnemo
from	indvs
union
select	2,
	contrat_ref.numgar,
	'Le contrat '||contrat_ref.numgar,
	contrat_ref.refcie,
	contrat_ref.numgar,
	'ENT_2'
from	contrat_ref
union
select	3,
	indvs.numindiv,
	'Le souscripteur '||indvs.nom||' '||indvs.prenom,
	to_char(indvs.qualite),
	indvs.numindiv,
	'ENT_3'
from	indvs
where	exists (select	1
		from	client
		where	indvs.numindiv = client.numindiv)
union
select	4,
	indvs.numindiv,
	'L''assuré '||indvs.nom||' '||indvs.prenom,
	to_char(indvs.qualite),
	indvs.numindiv,
	'ENT_4'
from	indvs
union
select	5,
	orgns.numorg,
	orgns.nom,
	orgns.nom,
	orgns.numorg,
	'ENT_5'
from	orgns
union
select	7,
	produit.numprod,
	produit.libelle,
	to_char(produit.numprod),
	produit.numprod,
	'ENT_7'
from	produit
union
select	8,
	interm.numinterm,
	interm.nom,
	interm.refinterm,
	interm.numinterm,
	'ENT_8'
from	interm
union
select	9,
	societe.numsoc,
	societe.nom,
	societe.refsoc,
	societe.numsoc,
	'ENT_9'
from	societe
Union
select	13,
	adhe_cntrt.idadhesion,
	'L''adhésion '||adhe_cntrt.ref_ext,
	adhe_cntrt.ref_ext,
	adhe_cntrt.idadhesion,
	'ENT_13'
from	adhe_cntrt
union
select	12,
	indvs.numindiv,
	'L''assuré '||indvs.nom||' '||indvs.prenom,
	to_char(indvs.qualite),
	indvs.numindiv,
	'ENT_12'
from	indvs
union
select 24,
       adhe_collective.numgar,
       'L''adhésion collective '||adhe_collective.numgar,
       adhe_collective.refcie,
       adhe_collective.numgar,
       'ENT_24'
from   adhe_collective
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ENTITE3 FOR ARTHUS.V_ENTITE3
