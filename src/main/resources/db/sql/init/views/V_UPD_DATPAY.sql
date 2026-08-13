CREATE FORCE VIEW ARTHUS.V_UPD_DATPAY AS
select
	1						type,
	remise_vire.numremise			numremise,
	remise_vire.datdisk			datpay,
	remise_vire_detail.numdecaismt	numdecaismt,
	decaismt.datpay				old_datpay,
	decaismt.refpmt				old_refpmt,
	decaismt.flagpay				old_flagpay,
	decaismt.numedit				old_numedit,
	decaismt.datedit				old_datedit,
	affectation.dataffec			old_dataffec
from	remise_vire,
	remise_vire_detail,
	decaismt,
	affectation
where	remise_vire.numremise = remise_vire_detail.numremise
and	remise_vire_detail.numdecaismt=decaismt.numdecaismt
and	trunc(decaismt.datpay)!=trunc(remise_vire.datdisk)
and	decaismt.numdecaismt=affectation.numdecaismt
union
select
	2						type,
	remise_op.numremise			numremise,
	remise_op.datvalide			datpay,
	remise_op_detail.numdecaismt		numdecaismt,
	decaismt.datpay				old_datpay,
	decaismt.refpmt				old_refpmt,
	decaismt.flagpay				old_flagpay,
	decaismt.numedit				old_numedit,
	decaismt.datedit				old_datedit,
	affectation.dataffec			old_dataffec
from	remise_op,
	remise_op_detail,
	decaismt,
	affectation
where	remise_op.numremise = remise_op_detail.numremise
and	remise_op_detail.numdecaismt=decaismt.numdecaismt
and	trunc(decaismt.datpay)!=trunc(remise_op.datvalide)
and	decaismt.numdecaismt=affectation.numdecaismt
GO
CREATE OR REPLACE PUBLIC SYNONYM V_UPD_DATPAY FOR ARTHUS.V_UPD_DATPAY
