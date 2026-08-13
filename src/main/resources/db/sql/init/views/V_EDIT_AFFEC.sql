CREATE FORCE VIEW ARTHUS.V_EDIT_AFFEC AS
select	distinct
	decaismt.numedit,
	decaismt.codope,
	decaismt.numcpte,
	decaismt.modpmt,
	to_char(file_edition.date_execute,'dd/mm/yyyy') datedit,
	file_edition.papid,
	decaismt.numedit|| ' - ' ||nvl(lib_edition.editlib, typ_edition.editlib) editlib
from	decaismt, file_edition, typ_edition, lib_edition
where	decaismt.refpmt is null
and	file_edition.numedit = decaismt.numedit
and	file_edition.status  = 2
and	typ_edition.editid = file_edition.editid
and	file_edition.numedit = lib_edition.numedit(+)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EDIT_AFFEC FOR ARTHUS.V_EDIT_AFFEC
