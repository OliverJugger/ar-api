CREATE FORCE VIEW ARTHUS.V_NUMMATH AS
Select  	gar_cntrt.numgar		numgar,
	gar_cntrt.numfor		numfor,
	defrub.codfrais		fam_code,
	a.libelle			fam_lib,
	defrub.datapli		fam_datpli,
	defrub.datper		fam_datper,
	calcul.codfrais		act_code,
	b.libelle			act_lib,
	calcul.datapli		act_datapli,
	calcul.datper		act_datper,
	calcul.nummath		act_nummath,
	libformath.libelle		nummath_lib,
	calcul.X			act_x
from    	gar_cntrt,
	calcul,
	libformath,
	defrub,
	natfrais a,
	natfrais b
where  	 gar_cntrt.numfor        	= calcul.numfor
and     	defrub.numfor          	 = calcul.numfor
and     	calcul.nummath          	= libformath.nummath
and     	a.rubrique              		= defrub.codfrais
and    	 a.codfrais              		= defrub.codfrais
and     	b.rubrique              		= defrub.codfrais
and     	b.codfrais              		= calcul.codfrais
GO
CREATE OR REPLACE PUBLIC SYNONYM V_NUMMATH FOR ARTHUS.V_NUMMATH
