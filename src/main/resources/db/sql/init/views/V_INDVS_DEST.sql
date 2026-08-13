CREATE FORCE VIEW ARTHUS.V_INDVS_DEST AS
select	numindiv				numindiv,
	ARTHUS.pk_personne.f_nom_inv (numindiv,30,1)	nom_dest
from	indvs
GO
CREATE OR REPLACE PUBLIC SYNONYM V_INDVS_DEST FOR ARTHUS.V_INDVS_DEST
