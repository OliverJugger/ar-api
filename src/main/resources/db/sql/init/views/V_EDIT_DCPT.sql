CREATE FORCE VIEW ARTHUS.V_EDIT_DCPT AS
select	distinct
	decaismt.numedit,
	decaismt.numcpte,
	to_char(file_edition.date_execute,'dd/mm/yy') datedit,
	file_edition.papid,
	typ_edition.editlib
from	decaismt, file_edition, typ_edition, parametres
where	decaismt.codope	=	2
and	decaismt.refpmt is null
and	decaismt.modpmt = parametres.mdchq
and	file_edition.numedit = decaismt.numedit
and	file_edition.status  = 2
and	typ_edition.editid = file_edition.editid
GO
CREATE OR REPLACE PUBLIC SYNONYM V_EDIT_DCPT FOR ARTHUS.V_EDIT_DCPT
