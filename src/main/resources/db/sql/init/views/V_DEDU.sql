CREATE FORCE VIEW ARTHUS.V_DEDU AS
select
	histo_dedu.idhisto,
	histo_dedu.numdec,
	sum(histo_dedu.montant) montant,
	sum(histo_dedu.montant_d) montant_d
from 	histo_dedu
group by histo_dedu.idhisto,
	histo_dedu.numdec
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DEDU FOR ARTHUS.V_DEDU
