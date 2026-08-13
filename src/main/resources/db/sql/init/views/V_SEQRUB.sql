CREATE FORCE VIEW ARTHUS.V_SEQRUB AS
select	numfor,
	codfrais,
	sequence,
	def
from	seqrub
union
select	frmls.numfor,
	natfrais.codfrais,
	1,
	natfrais.libelle
from	frmls,natfrais
where	(frmls.numfor,natfrais.codfrais) not in
		(select numfor,codfrais from seqrub)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SEQRUB FOR ARTHUS.V_SEQRUB
