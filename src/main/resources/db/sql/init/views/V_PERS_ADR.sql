CREATE FORCE VIEW ARTHUS.V_PERS_ADR AS
Select 	pers_adresse.idadresse,
	pers_adresse.codpos,
	indvs.numindiv,
        indvs.type,
	indvs.nom,
	indvs.prenom,
	nvl(indvs.codcourrier1,0) codc1,
	decode(pers_adresse.type,3,adr_internationale.adr5,pers_adresse.ville) ville
From	indvs,pers_adresse,adr_internationale
Where	pers_adresse.numindiv=indvs.numindiv
And     pers_adresse.idadresse=adr_internationale.idadresse(+)
And	pers_adresse.codope=0
And	pers_adresse.numgar=0
And	pers_adresse.defaut='O'
And	pers_adresse.debut=(select max(histo.debut)
		            from pers_adresse histo
		            where histo.numindiv=pers_adresse.numindiv
			    and histo.codope=0
			    and histo.numgar=0
			    and histo.defaut='O'
			    and histo.debut<=sysdate
			    )
And not exists( select 1 from pers_adresse a
		 where a.numindiv=indvs.numindiv
		 and a.codope=11
		 and a.defaut='N'
		 and a.numgar=0
		 and a.debut<=sysdate
		)
Union
Select 	pers_adresse.idadresse,
	pers_adresse.codpos,
	indvs.numindiv,
        indvs.type,
	indvs.nom,
	indvs.prenom,
	nvl(indvs.codcourrier1,0),
	decode(pers_adresse.type,3,adr_internationale.adr5,pers_adresse.ville)
From	indvs,indvs assu,pers_adresse,adr_internationale
Where	pers_adresse.numindiv=assu.numindiv
And     pers_adresse.idadresse=adr_internationale.idadresse(+)
And 	assu.numindiv=indvs.numassu
And	pers_adresse.codope=0
And	pers_adresse.numgar=0
And	pers_adresse.defaut='O'
And not exists (select 1 from pers_adresse adr
		where adr.numindiv=indvs.numindiv
		and adr.defaut='O'
		and adr.codope=0
		and adr.numgar=0
		)
And	pers_adresse.debut=(select max(histo.debut)
				from pers_adresse histo
				where histo.numindiv=assu.numindiv
				and histo.codope=0
				and histo.numgar=0
				and histo.defaut='O'
				and histo.debut<=sysdate
			    )
And not exists( select 1 from pers_adresse a
		 where a.numindiv=assu.numindiv
		 and a.codope=11
		 and a.defaut='N'
		 and a.numgar=0
		 and a.debut<=sysdate
		)
Union
Select	pers_adresse.idadresse,
	pers_adresse.codpos,
	indvs.numindiv,
        indvs.type,
	indvs.nom,
	indvs.prenom,
	nvl(indvs.codcourrier1,0),
	decode(pers_adresse.type,3,adr_internationale.adr5,pers_adresse.ville)
From	indvs,pers_adresse,adr_internationale
Where	pers_adresse.numindiv=indvs.numindiv
And     pers_adresse.idadresse=adr_internationale.idadresse(+)
And	pers_adresse.codope=11
And	pers_adresse.defaut='N'
And	pers_adresse.numgar=0
And	pers_adresse.debut=(select max(histo.debut)
				from pers_adresse histo
				where histo.numindiv=pers_adresse.numindiv
				and histo.codope=11
				and histo.defaut='N'
				and histo.numgar=0
				and histo.debut<=sysdate
			    )
GO
CREATE OR REPLACE PUBLIC SYNONYM V_PERS_ADR FOR ARTHUS.V_PERS_ADR
