CREATE FORCE VIEW ARTHUS.V_LIB_FACT AS
select	4						codope,
	qttc_global.numquit				numfact,
	'Quittance N° '||qttc_global.numquit||
		' Echéance '||
		to_char(qttc_global.debut,'dd/mm/yyyy')	libelle,
	'qg03'						codapli
from	qttc_global
union
select	facture.codope					codope,
	facture.numfact					numfact,
	'Attente de commission N° '||facture.numfact	libelle,
	''						codapli
from	facture
where	facture.codope = 7
union
select	12,
	dcptcie.numdcptcie,
	'Demande de remboursement de prestation N° '||
		dcptcie.numdcptcie,
	'gdr1'
from	dcptcie
GO
CREATE OR REPLACE PUBLIC SYNONYM V_LIB_FACT FOR ARTHUS.V_LIB_FACT
