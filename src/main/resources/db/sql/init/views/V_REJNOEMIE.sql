CREATE FORCE VIEW ARTHUS.V_REJNOEMIE AS
select
      	rejet_noemie.numremise,
      	rejet_noemie.numporte,
      	f_siecle(rejet_noemie.date_rejet,'ddmmyy') daterejet,
      	rejet_noemie.matorg,
      	rejet_noemie.cle_ss,
      	rejet_noemie.datnais	datenais,
      	rejet_noemie.rang,
      	nvl( rtrim(rejet_noemie.nom), substr(indvs.nom, 1, 25) )	nom,
      	nvl( rtrim(rejet_noemie.prenom), substr(indvs.prenom, 1, 15) )	prenom,
      	rejet_noemie.numindiv,
      	rejet_noemie.codif,
      	Decode(rejet_noemie.mouvement,
			'R', 1,
			'S', 2,
			'C', 3,
			'I', 4)		mouvement,
      	rejet_noemie.libelle,
      	rejet_noemie.caisse,
      	porte_remise.dateremise 	dateremise,
      	libelle.libelle libporte,
      	rejet_noemie.numremise||' du '|| to_char(
		porte_remise.dateremise, 'dd/mm/yyyy' ) libremise
from	indvs,
	rejet_noemie,
        libelle,
	porte_remise
Where  	indvs.numindiv = rejet_noemie.numindiv
and	libelle.mnemo = 'PORTE'
and   	libelle.code = rejet_noemie.numporte
and   	porte_remise.numremise = rejet_noemie.numremise
GO
CREATE OR REPLACE PUBLIC SYNONYM V_REJNOEMIE FOR ARTHUS.V_REJNOEMIE
