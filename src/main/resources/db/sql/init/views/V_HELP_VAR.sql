CREATE FORCE VIEW ARTHUS.V_HELP_VAR AS
select 	code,
	'01' novar,
	'numéro de sinistre' lib_var
from	lble
where 	mnemo='TYPE_CRRR'
and	code in(2,6,7)
union
select	code,
	'02',
	'numéro interne d''indiv'
from	lble
where 	mnemo='TYPE_CRRR'
and code in(1,2,3,4,5,6,7,9)
union
select	code,
	'03',
	'numéro du risque'
from	lble
where 	mnemo='TYPE_CRRR'
and	code in(2,6,7)
union
select	code,
	'04',
	'numéro interne de contrat'
from	lble
where	mnemo='TYPE_CRRR'
and code in(1,2,3,4,6,7,9)
union
select	code,
	'05',
	'date de surv du sinistre'
from	lble
where mnemo='TYPE_CRRR'
and	code in(2,6,7)
union
select	code,
	'06',
	'matricule individu'
from	lble
where 	mnemo='TYPE_CRRR'
and code in(1,2,3,4,5,6,7,9)
union
select	code,
	'07',
	'nom de la personne'
from	lble
where 	mnemo='TYPE_CRRR'
and code in(1,2,3,4,5,6,7,9)
union
select	code,
	'08',
	'numero interne du souscr.'
from	lble
where	mnemo='TYPE_CRRR'
and code in(1,2,3,4,5,6,7,9)
union
select	code,
	'09',
	'numero interne du produit'
from	lble
where	mnemo='TYPE_CRRR'
and code in(2,3,4,6,7,8)
union
select	code,
	'10',
	'numero de pec'
from	lble
where mnemo='TYPE_CRRR'
and code=9
union
select	code,
	'11',
	'date d''hospi'
from	lble
where mnemo='TYPE_CRRR'
and code=9
union
select	code,
	'12',
	'numero interne du fournisseur'
from	lble
where mnemo='TYPE_CRRR'
and code=9
union
select	code,
	'13',
	'date de naissance'
from	lble
where	mnemo='TYPE_CRRR'
and code in(1,2,3,4,5,6,7,9)
union
select	b.code,
	'14',
	'libelle de la qualite'
from
	lble b
where	b.mnemo='TYPE_CRRR'
and b.code in(1,2,3,4,5,6,7,9)
union
select	code,
	'15',
	'nom-prenom de la personne'
from	lble
where	mnemo='TYPE_CRRR'
and code in(1,2,3,4,5,6,7,9)
union
select	code,
	'17',
	'date d''effet du contrat'
from	lble
where	mnemo='TYPE_CRRR'
and code in(1,4)
union
select	code,
	'18',
	'date d''echeance du contrat'
from	lble
where mnemo='TYPE_CRRR'
and code in(1,4)
union
select	code,
	'20',
	'date du jour'
from	lble
where	mnemo='TYPE_CRRR'
union
select	code,
	'22',
	'reference du contrat'
from	lble
where	mnemo='TYPE_CRRR'
and code in(1,2,3,4,6,7,9)
union
select	b.code,
	'23',
	'libelle du code civilite'
from	lble b
where	b.mnemo='TYPE_CRRR'
and b.code in(1,2,3,4,5,6,7,9)
union
select	code,
	'99',
	'les personnes couvertes par le contrat'
from
	lble
where	mnemo='TYPE_CRRR'
and code in(1,4)
union
select	code,
	'98',
	'les pieces justificatives'
from
	lble
where	mnemo='TYPE_CRRR'
and code in(2,6,7)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_HELP_VAR FOR ARTHUS.V_HELP_VAR
