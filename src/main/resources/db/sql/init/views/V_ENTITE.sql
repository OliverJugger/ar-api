CREATE FORCE VIEW ARTHUS.V_ENTITE AS
select	1 etendue,
	v_gar.numfor cle_unique,
	v_gar.refcie||' (No de Police)' lib_cle_unique,
	to_char(v_gar.clef) cle_secondaire,
	v_gar.numfor numfor,
	'ENT_1' mnemo
from	v_gar
where	v_gar.etendue = 2
union
select	0,
	indvs.numindiv,
	indvs.nom||' '||indvs.prenom,
	to_char(indvs.qualite),
	indvs.numindiv,
	'ENT_4'
from	indvs
union
select	14,
	indvs.numindiv,
	indvs.nom||' '||indvs.prenom,
	to_char(indvs.qualite),
	indvs.numindiv,
	'ENT_4'
from indvs
union
select	2,
	grnts.numgar,
	grnts.refcie,
	grnts.refcie,
	grnts.numgar,
	'ENT_2'
from	grnts
union
select	3,
	indvs.numindiv,
	indvs.nom||' '||indvs.prenom,
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
	indvs.nom||' '||indvs.prenom,
	to_char(indvs.qualite),
	indvs.numindiv,
	'ENT_4'
from	indvs
where	indvs.typassu = 1
union
select	5,
	orgns.numorg,
	orgns.nom,
	orgns.nom,
	orgns.numorg,
	'ENT_5'
from	orgns
union
select	6,
	v_gar.numfor,
	v_gar.clef||' (No de Produit)',
	to_char(v_gar.clef),
	v_gar.numfor,
	'ENT_6'
from	v_gar
where	v_gar.etendue = 7
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
	interm.numindiv,
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
union
select	10 etendue,
	grp_gar.numgrpgar cle_unique,
	grp_gar.clef||' (No de Produit)',
	to_char(grp_gar.clef) cle_secondaire,
	grp_gar.numgrpgar,
	'ENT_10'
from	grp_gar
where	grp_gar.etendue = 7
union
select	11 etendue,
	grp_gar.numgrpgar cle_unique,
	grp_gar.clef||' (No de Police)',
	to_char(grp_gar.clef) cle_secondaire,
	grp_gar.numgrpgar,
	'ENT_11'
from	grp_gar
where	grp_gar.etendue = 2
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ENTITE FOR ARTHUS.V_ENTITE
