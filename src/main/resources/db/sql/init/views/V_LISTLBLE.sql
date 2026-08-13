CREATE FORCE VIEW ARTHUS.V_LISTLBLE AS
select	a.mnemo,
	substr(to_char(a.code),1,2) code,
	substr(a.libelle,1,max(length(b.libelle))) libelle
from lble a,lble b
where a.mnemo = b.mnemo
group by a.mnemo,a.code,a.libelle
GO
CREATE OR REPLACE PUBLIC SYNONYM V_LISTLBLE FOR ARTHUS.V_LISTLBLE
