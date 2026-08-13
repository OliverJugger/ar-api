CREATE FORCE VIEW ARTHUS.V_GC02 AS
Select	numgar,
	numfor,
	nomgar,
	libelle
From	gar_cntrt
Where	type = 1
and	valide = 'O'
Union
Select	numgar,
	0		numfor,
	'TOUTES'	nomgar,
	'Paramétrage global contrat'		libelle
From	gar_cntrt
Where Exists (
	Select	1
	From	contrat
	Where	contrat.numgar = gar_cntrt.numgar
	)
and Exists (
	Select	1
	From	gar_cntrt	gar_valide
	Where	gar_valide.numgar = gar_cntrt.numgar
	and	gar_valide.type = 1
	and	gar_valide.valide = 'O'
	)
Group By
	numgar
GO
CREATE OR REPLACE PUBLIC SYNONYM V_GC02 FOR ARTHUS.V_GC02
