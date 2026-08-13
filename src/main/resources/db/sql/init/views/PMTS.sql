CREATE FORCE VIEW ARTHUS.PMTS AS
select grnts.numgar,
	grnts.refcie,
	grnts.numcli,
	grnts.numorg,
        orgns.nom orgnom,
        dcpt.modpmt,
	dcpt.numdec,
	dcpt.numbene,
	dcpt.numbque,
	dcpt.refpmt,
	dcpt.monnaie,
	dcpt.datpay,
        dcpt.typbene,
	dcpt.montant
   from dcpt,grnts,orgns
  where dcpt.refpmt is not null
    and grnts.numgar = dcpt.numgar
    and orgns.numorg = grnts.numorg
GO
CREATE OR REPLACE PUBLIC SYNONYM PMTS FOR ARTHUS.PMTS
