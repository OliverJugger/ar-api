CREATE FORCE VIEW ARTHUS.V_TYPE_INFO AS
Select 	typ_valeur.libelle,
	typ_valeur.code		donnee,
	typ_info.code		Type
From	libelle	typ_valeur,
	libelle	typ_info
Where	typ_info.code in ( 4, 6 )
and	typ_info.mnemo = 'TYPE_FONC'
and	typ_valeur.code = 1
and	typ_valeur.mnemo = 'TYP_VALEUR'
Union
Select 	typ_valeur.libelle,
	typ_valeur.code		donnee,
	typ_info.code		Type
From	libelle	typ_valeur,
	libelle	typ_info
Where	typ_info.code = 5
and	typ_info.mnemo = 'TYPE_FONC'
and	typ_valeur.code in ( 1, 2 )
and	typ_valeur.mnemo = 'TYP_VALEUR'
Union
Select 	typ_valeur.libelle,
	typ_valeur.code		donnee,
	typ_info.code		Type
From	libelle	typ_valeur,
	libelle	typ_info
Where	typ_info.code = 7
and	typ_info.mnemo = 'TYPE_FONC'
and	typ_valeur.code in ( 1, 2, 3 )
and	typ_valeur.mnemo = 'TYP_VALEUR'
GO
CREATE OR REPLACE PUBLIC SYNONYM V_TYPE_INFO FOR ARTHUS.V_TYPE_INFO
