CREATE FORCE VIEW ARTHUS.V_APPLI_CONTEXTE AS
Select	appli_contexte.codapli,
	appli_contexte.fonction,
	nvl(appli_contexte.libelle, appli_descript.nom) 	nom,
	appli_contexte.ordre,
	appli_contexte.ss_ordre,
	appli_contexte.action,
	appli_contexte.cle1,
	appli_contexte.cle2,
	appli_contexte.cle3,
	appli_contexte.champ,
	appli_contexte.condition,
	appli_contexte.trig,
	appli_contexte.trig_exit,
	appli_descript.version,
	nvl(appli_descript.prog, lower(appli_contexte.codapli)) prog
From	appli_contexte,
	appli_descript
Where	appli_contexte.codapli = appli_descript.codapli
and	Exists (
	select 	1
	from	profil
	where	appli_contexte.codapli	= profil.codapli
	and	profil.profil	= f_profil( f_numutil )
	)
and	Not Exists (
	select 	1
	from	appli_client
	where	appli_client.codapli = appli_contexte.codapli
	and	(appli_client.fonction = appli_contexte.fonction
		 Or
		appli_client.fonction = 'TOUS')
	and	appli_client.client = f_client
	)
GO
CREATE OR REPLACE PUBLIC SYNONYM V_APPLI_CONTEXTE FOR ARTHUS.V_APPLI_CONTEXTE
