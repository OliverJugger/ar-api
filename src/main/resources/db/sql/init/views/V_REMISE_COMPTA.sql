CREATE FORCE VIEW ARTHUS.V_REMISE_COMPTA AS
Select	remise_compta.idcompta,
	remise_compta.numsoc,
	pers_societe.abrege		nomsoc,
	remise_compta.datcompta,
	d2e( remise_compta.datcompta ) 	edatcompta,
	d2e( min(remise_compta.debut) ) edebut,
	d2e( max(remise_compta.fin) ) 	efin,
	sum(remise_compta.debit) 	debit,
	sum(remise_compta.credit) 	credit,
	sum(remise_compta.nombre) 	nombre
From	pers_societe,
	remise_compta
Where	pers_societe.numsoc	= remise_compta.numsoc
Group by
	remise_compta.idcompta,
	remise_compta.numsoc,
	pers_societe.abrege,
	remise_compta.datcompta,
	d2e( remise_compta.datcompta )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REMISE_COMPTA FOR ARTHUS.V_REMISE_COMPTA
