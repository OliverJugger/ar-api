CREATE FORCE VIEW ARTHUS.V_QTTC_ANO AS
select	numgar,
	numindiv,
	numfor,
	to_char(debut,'dd/mm/yy') edebut,
	to_char(fin,'dd/mm/yy') efin,
	decode(sqlerr,'',
		libelle.libelle,
		'Erreur système n° '||sqlerr) lib_erreur
from	qttc_ano,
	libelle
where	libelle.mnemo (+) = 'ANOCALC'
and	libelle.code = qttc_ano.errno
GO
CREATE OR REPLACE PUBLIC SYNONYM V_QTTC_ANO FOR ARTHUS.V_QTTC_ANO
