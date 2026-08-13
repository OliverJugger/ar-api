CREATE FORCE VIEW ARTHUS.VD_SOCIETE AS
select "NUMINDIV","REFSOC","QUALITE","NOM","NOMJF","PRENOM","ADR1","ADR2","CODPOS","VILLE","CODPAYS","TEL","FAX","CREATION","MAJ","NUMSOC","NUMINTERM","ENTETE","ABREGE","LIEU" from societe
where numsoc in (select numsoc from util_soc
                 where  numutil = f_numutil
		 and	defaut is not null)
GO
CREATE OR REPLACE PUBLIC SYNONYM VD_SOCIETE FOR ARTHUS.VD_SOCIETE
