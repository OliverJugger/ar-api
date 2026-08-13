CREATE FORCE VIEW ARTHUS.V_GAR_PROD AS
Select  nomgar,
	libelle,
	cle		numprod,
	gar.numfor,
	2		type
from 	gar
where 	valide = 'O'
and	etendue=7
and 	numfor not in (
	Select	grp_gar_def.numfor
	From	grp_gar,
		grp_gar_def
	Where	grp_gar_def.numgrpgar = grp_gar.numgrpgar
	and	grp_gar.etendue = 7
	and	grp_gar.clef = gar.cle
	and	grp_gar_def.numfor = gar.numfor)
union
Select 	nomgar,
	libelle,
	numprod,
	frmls.numfor,
	1
from 	frmls
where 	valide = 'O'
and 	numprod is not null
and 	numfor not in (
	Select	grp_gar_def.numfor
	From	grp_gar,
		grp_gar_def
	Where	grp_gar_def.numgrpgar = grp_gar.numgrpgar
	and	grp_gar.etendue = 7
	and	grp_gar.clef = frmls.numprod
	and	grp_gar_def.numfor = frmls.numfor)
union
Select 	nomgrpgar,
	libelle,
	clef,
	numgrpgar,
	3
from 	grp_gar
where 	valide = 'O'
and 	etendue=7
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GAR_PROD FOR ARTHUS.V_GAR_PROD
