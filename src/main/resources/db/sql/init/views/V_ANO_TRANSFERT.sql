CREATE FORCE VIEW ARTHUS.V_ANO_TRANSFERT AS
Select	adhe_cntrt.numgar,
	adhe_cntrt.numadhe,
	adhe_cntrt.idadhesion,
	indvs.prenom||' '||indvs.nom nom
From	indvs,adhe_cntrt
Where	Not Exists (select 1 from histo_transfert
		where histo_transfert.old_numgar=adhe_cntrt.numgar
		and histo_transfert.numindiv=adhe_cntrt.numadhe
		)
And	adhe_cntrt.date_fin_adhe is null
and 	indvs.numindiv=adhe_cntrt.numadhe
GO
CREATE OR REPLACE PUBLIC SYNONYM V_ANO_TRANSFERT FOR ARTHUS.V_ANO_TRANSFERT
