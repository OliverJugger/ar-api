CREATE FORCE VIEW ARTHUS.V_SIN_REGLES AS
Select	contrat.numgar				numgar,
	contrat.refcie				refcie,
	repartition.idadhesion			idadhesion,
	dossier_sinistre.numindiv		numindiv,
	dossier_sinistre.iddossier		iddossier,
	dossier_sinistre.debut			debut,
	sntr_prev.nosin 			nosin,
	sntr_prev.survenance			survenance,
	sntr_prev.fin				fin,
	sntr_prev.creation			creation,
	v_histo_jours.numdec 			numdec,
	sum(v_histo_jours.mtprest) 		mtprest,
	sum(v_histo_jours.mtreval) 		mtreval,
	sum(v_histo_jours.mtdedu) 		mtdedu,
	sum(v_histo_jours.mtprest_d) 		mtprest_d,
	sum(v_histo_jours.mtreval_d) 		mtreval_d,
	sum(v_histo_jours.mtdedu_d) 		mtdedu_d,
	decaismt.numdecaismt 			numdecaismt,
	v_histo_jours.numbene 			numbene,
	decaismt.datpay				datpay,
	decaismt.montant 			montant
FROM    contrat,
	dossier_sinistre,
	sntr_prev,
	repartition,
	v_histo_jours,
	gar_cntrt,
	affectation,
	decaismt
Where   contrat.numgar=gar_cntrt.numgar
And     dossier_sinistre.iddossier=sntr_prev.iddossier
And     sntr_prev.nosin=repartition.nosin
And     repartition.numfor=gar_cntrt.numfor
And     v_histo_jours.idrepartition=repartition.idrepartition
And     v_histo_jours.numdec=affectation.numaffec
And     affectation.numdecaismt=decaismt.numdecaismt
And     decaismt.codope=2
And     decaismt.montant>0
Group by
	contrat.numgar,
	contrat.refcie,
	dossier_sinistre.iddossier,
	dossier_sinistre.debut,
	dossier_sinistre.numindiv,
	repartition.idadhesion,
	sntr_prev.nosin,
	sntr_prev.survenance,
	sntr_prev.fin,
	sntr_prev.creation,
	v_histo_jours.numdec,
	decaismt.numdecaismt,
	v_histo_jours.numbene,
	decaismt.datpay,
	decaismt.montant
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SIN_REGLES FOR ARTHUS.V_SIN_REGLES
