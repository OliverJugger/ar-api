CREATE FORCE VIEW ARTHUS.V_FILE_EDITION AS
select
	file_edition.numedit,
	file_edition.numbatch,
	file_edition.editid,
	file_edition.papid,
	file_edition.impid,
	file_edition.userid,
	file_edition.nb_ex,
	file_edition.date_demande,
	file_edition.date_execute,
	file_edition.execute,
	file_edition.condense,
	file_edition.status,
	file_edition.nb_page,
	file_edition.nb_ligne,
	file_edition.numdmnde,
	file_batch.batchid
from	file_edition,
	file_batch
where	file_batch.numbatch	=	file_edition.numbatch
GO
CREATE OR REPLACE PUBLIC SYNONYM V_FILE_EDITION FOR ARTHUS.V_FILE_EDITION
