CREATE FORCE VIEW ARTHUS.VM_ENTETE AS
select	9			type,
	'No_Soc;No_prise_en_charge;No_Assure;No_Assure_princ;No_etablisement;No_Entree;'				ligne1,
	'Date_Hospitalisation;Date_Edition;Ref_ext_Assure;Nom_Assure;Prenom_assure;Date_Nais_Assure;Mat_Assure;'			ligne2,
	'Ref_ext_Assure_Princ;Nom_assure_Princ;Prenom_Assure_Princ;Mat_Assure_Princ;'				ligne3,
	'Etab_Nom;Etab_Adr1;Etab_Adr2;Etab_Codpos;Etab_Ville;'	ligne4,
	'No_Contrat;No_Police;Client_Nom;Client_Prenom;'	ligne5,
	'Dest_nom;Dest_Prenom;Dest_Adr1;Dest_Adr2;Dest_Codpos;Dest_Ville' ligne6
from dual
GO
CREATE OR REPLACE PUBLIC SYNONYM VM_ENTETE FOR ARTHUS.VM_ENTETE
