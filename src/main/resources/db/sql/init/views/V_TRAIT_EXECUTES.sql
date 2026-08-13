CREATE FORCE VIEW ARTHUS.V_TRAIT_EXECUTES AS
select 	1			origine,
	file_edition.editid	nom_prog,
	substr(f_typ_edition(file_edition.editid,2),1,80)	lib_prog,
	substr(file_edition.batchid,1,8)	nom_trait,
	file_edition.date_execute	der_exec
from 	file_edition
union all
select  2			origine,
	file_archive.editid	nom_prog,
	substr(f_typ_edition(file_archive.editid,2),1,80)	lib_prog,
	substr(f_typ_edition(file_archive.editid,1),1,8)	nom_trait,
	file_archive.date_execute	der_exec
from 	file_archive
union all
select	3			origine,
	typ_edition.editid     	nom_prog,
	typ_edition.editlib     lib_prog,
	typ_edition.batchid     nom_trait,
	sysdate          der_exec
from    typ_edition
where   typ_edition.editid not in       (
					select  editid
					from    file_edition
					)
and     typ_edition.editid not in       (
					select  editid
					from    file_archive
					)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TRAIT_EXECUTES FOR ARTHUS.V_TRAIT_EXECUTES
