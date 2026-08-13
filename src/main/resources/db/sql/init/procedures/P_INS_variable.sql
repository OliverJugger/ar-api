CREATE procedure ARTHUS.P_INS_variable (
		I_Idvariable	IN Number,
		I_Etendue	IN Number,
		I_Clef	IN Number,
		I_Statique	IN Varchar2 Default 'O',
		I_Debut	IN	Date,
		I_Fin	IN	date Default Null,
		I_Valide	IN Varchar2 Default 'O',
		I_Valeur	IN Number,
		I_Numgar 	IN Number
	)
AS
BEGIN
Insert Into val_variable (
	Idvariable,
	Etendue,
	Clef,
	Statique,
	Debut,
	Fin,
	Valide,
	Valeur,
	Numgar )
Values (
	I_Idvariable,
	I_Etendue,
	I_Clef,
	I_Statique,
	I_Debut,
	I_Fin,
	I_Valide,
	I_Valeur,
	I_Numgar );
END P_INS_variable;
/
