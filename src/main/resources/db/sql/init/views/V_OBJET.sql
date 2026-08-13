CREATE FORCE VIEW ARTHUS.V_OBJET AS
Select
	to_number(sin_prev.nosin) entite,
	'Sinistre  n° '||sin_prev.nosin||' '||
	'du'||' '||to_char(sin_prev.datesurv,'dd/mm/yyyy') libelle,
	2 contexte
From	sin_prev
Union
Select	adhe_cntrt.idadhesion,
	'Adhésion n° '||adhe_cntrt.idadhesion||' '||
	'du'||' '||to_char(adhe_cntrt.date_adhe,'dd/mm/yyyy'),
	4
From	adhe_cntrt
Union
Select	proposition.idpropo,
	'Proposition n° '||proposition.idpropo||' '||
	'du'||' '||d2e(j2d(f_etat_propo(idpropo,sysdate,3))),
	14
From	proposition
Union
Select	contrat.numgar,
	'Contrat n° '||contrat.numgar||' '||
	'du'||' '||to_char(contrat.datsous,'dd/mm/yyyy'),
	8
From contrat
GO
CREATE OR REPLACE PUBLIC SYNONYM V_OBJET FOR ARTHUS.V_OBJET
