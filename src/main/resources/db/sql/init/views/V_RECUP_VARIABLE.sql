CREATE FORCE VIEW ARTHUS.V_RECUP_VARIABLE AS
SELECT	distinct
			def_variable.nom_variable,
			val_variable.numgar,
			val_variable.clef,
			decode(def_variable.type,
		'D',to_number(
			to_char(
				to_date(val_variable.valeur,'DD/MM/YY'),
				'j')
			     ),
		'E',to_number(
			to_char(
				to_date(val_variable.valeur,'DDMMYYYY'),
				'j')
			     ),
		       val_variable.valeur
			      ) valeur
		FROM	v_clef_corres2,def_variable,val_variable
		WHERE	val_variable.idvariable   = def_variable.idvariable
		AND	val_variable.clef         = v_clef_corres2.clef
		AND	val_variable.etendue      = v_clef_corres2.etendue
GO
CREATE OR REPLACE PUBLIC SYNONYM V_RECUP_VARIABLE FOR ARTHUS.V_RECUP_VARIABLE
