CREATE FORCE VIEW ARTHUS.V_LIB_OPE_MODPMT AS
select	lib_ope.code				codope,
	lib_ope.libelle				lib_ope,
	decode(lib_ope.sens,
		1,lib_mpmt.code,
		-1,lib_mopm.code)		modpmt,
	decode(lib_ope.sens,
		1,lib_mpmt.libelle,
		-1,lib_mopm.libelle)			lib_modpmt
from	libelle lib_ope,
	libelle lib_mpmt,
	libelle lib_mopm
where	lib_ope.mnemo='OPE'
and	lib_mpmt.mnemo='MPMT'
and	lib_mopm.mnemo='MOPM'
and	lib_ope.code > 0
and	lib_ope.sens in (-1,1)
and	lib_mpmt.code > 0
and	lib_mpmt.code = decode(lib_ope.sens,1,lib_mpmt.code,1)
and	lib_mopm.code > 0
and	lib_mopm.code = decode(lib_ope.sens,-1,lib_mopm.code,1)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_LIB_OPE_MODPMT FOR ARTHUS.V_LIB_OPE_MODPMT
