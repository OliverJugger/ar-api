CREATE FORCE VIEW ARTHUS.V_CALLTRT AS
SELECT idglob		        idglob,
         type_calcul            type_calcul,
         numtr                  numtr,
         dtdebut                dtdebut,
         dtfin                  dtfin,
         date_calcul            date_calcul,
	 valide			valide,
	 validation		validation,
         montant                montant
  FROM   result_reass
  where  numav is null
  and    type_calcul in (7,8,9)
-- Donnees niveau appel avenant
-- type cotisations reassurance
  UNION
  SELECT -1          idglob,
         7              type_calcul,
         numtr          numtr,
         dtdebut        dtdebut,
         dtfin          dtfin,
         to_date(null)  date_calcul,
	 valide			valide,
	 validation		validation,
         sum(montant)   montant
  FROM   result_reass
  where  type_calcul = 7
  and    numav is not null
  GROUP BY
	numtr,
	dtdebut,
	dtfin,
	valide,
	validation
  UNION
-- type prestations reassurance (prevoyance)
  SELECT -1          idglob,
         8              type_calcul,
         numtr          numtr,
         dtdebut        dtdebut,
         dtfin          dtfin,
         to_date(null)  date_calcul,
	 valide			valide,
	 validation		validation,
         sum(montant)   montant
  FROM   result_reass
  where  type_calcul = 8
  and    numav is not null
  GROUP BY
	numtr,
	dtdebut,
	dtfin,
	valide,
	validation
  UNION
-- type prestations reassurance (sante)
  SELECT -1          idglob,
         9              type_calcul,
         numtr          numtr,
         dtdebut        dtdebut,
         dtfin          dtfin,
         to_date(null)  date_calcul,
	 valide			valide,
	 validation		validation,
         sum(montant)   montant
  FROM   result_reass
  where  type_calcul = 9
  and    numav is not null
  GROUP BY
	numtr,
	dtdebut,
	dtfin,
	valide,
	validation
GO
CREATE OR REPLACE PUBLIC SYNONYM V_CALLTRT FOR ARTHUS.V_CALLTRT
