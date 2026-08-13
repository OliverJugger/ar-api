CREATE FORCE VIEW ARTHUS.V_DEF_NIVEAU AS
Select	def_niveau.base,
	def_niveau.cle_possible,
	libelle.code	cle
From	def_niveau,
	libelle
Where	mnemo = 'CLE_BASE'
and	code = def_niveau.cle_possible
Union
Select	libelle.code,
	libelle.code,
	libelle.sens
From	libelle
Where	mnemo = 'CLE_BASE'
Union
Select	def_niveau.base,
	sous_def_niveau.cle_possible,
	libelle.code
From	def_niveau,
	def_niveau	sous_def_niveau,
	libelle
Where	def_niveau.cle_possible = sous_def_niveau.base
and	mnemo = 'CLE_BASE'
and	code = sous_def_niveau.cle_possible
GO
CREATE OR REPLACE PUBLIC SYNONYM V_DEF_NIVEAU FOR ARTHUS.V_DEF_NIVEAU
