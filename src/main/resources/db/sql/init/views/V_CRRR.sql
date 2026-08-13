CREATE FORCE VIEW ARTHUS.V_CRRR AS
select
produit.numprod numero,
produit.libelle,
7 contexte
from produit
union
select
contrat.numgar,
contrat.refcie,
2
from contrat
union
select
to_number(sin.nosin),
indvs.nom||' '||indvs.prenom,
11
from sin,indvs
where sin.numindiv=indvs.numindiv
union
select
indvs.numindiv,
indvs.nom||' '||indvs.prenom,
0
from indvs
union
select 0,
'Toutes Entités',
0
from dual
union
select 0,
'Toutes Entités',
4
from dual
union
select 0,
'Toutes Entités',
3
from dual
union
select
numfor,
libelle,
6
from gar
union
select
numfor,
libelle,
6
from frmls
union
select
numfor,
libelle,
10
from gar_cntrt
union
select
numindiv,
nom||' '||prenom,
12
from indvs
union
select
numfor,
libelle,
10
from frmls
union
select
numfor,
libelle,
10
from gar
union
select 0,
'Toutes Entités',
99
from dual
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CRRR FOR ARTHUS.V_CRRR
