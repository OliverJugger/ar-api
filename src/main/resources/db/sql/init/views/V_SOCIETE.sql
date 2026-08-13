CREATE FORCE VIEW ARTHUS.V_SOCIETE AS
select "NUMINDIV","REFSOC","QUALITE","NOM","NOMJF","PRENOM","ADR1","ADR2","CODPOS","VILLE","CODPAYS","TEL","FAX","CREATION","MAJ","NUMSOC","NUMINTERM","ENTETE","ABREGE","LIEU" from societe
where exists (select numsoc from util_soc
               where numutil = f_numutil
		 and util_soc.numsoc = societe.numsoc)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_SOCIETE FOR ARTHUS.V_SOCIETE
