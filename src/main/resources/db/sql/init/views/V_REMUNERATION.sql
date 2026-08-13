CREATE FORCE VIEW ARTHUS.V_REMUNERATION AS
Select	v_retrocession.etendue,
	v_retrocession.cle,
	v_retrocession.numbene		numindiv,
	v_retrocession.type_comm,
	v_retrocession.mode_retro	prelev_revers,
	min(v_retrocession.debut)	debut,
	max(v_retrocession.fin)		fin,
	sum(v_retrocession.montant)	montant
From	v_retrocession
Where	v_retrocession.montant != 0
Group By
	v_retrocession.etendue,
	v_retrocession.cle,
	v_retrocession.numbene,
	v_retrocession.type_comm,
	v_retrocession.mode_retro
Having	sum(v_retrocession.montant) != 0
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMUNERATION FOR ARTHUS.V_REMUNERATION
