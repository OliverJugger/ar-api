CREATE function ARTHUS.f_gar_unitcalc(I_numgar IN NUMBER, I_numfor IN NUMBER, I_param In NUMBER default 1)
	RETURN NUMBER
	AS
		f_nbunitcalc    number;
		f_unitcalc     number;
		f_typeunitcalc number;


	BEGIN

		 Select nbunitcalc, unitcalc, typeunitcalc
		 Into f_nbunitcalc,f_unitcalc, f_typeunitcalc
		 From frmls
		 Where numfor=pk_qttc.F_SEL_numfor(I_numgar,I_numfor)
		 Union
		 Select nbunitcalc, unitcalc, typeunitcalc
		 from garanties
		 Where numfor=pk_qttc.F_SEL_numfor(I_numgar,I_numfor);

	IF I_param = 1 then -- Retour du nombre d'unité

		RETURN f_nbunitcalc;

	ELSIF I_param = 2 then -- Retour du code de l'unité;

		RETURN f_unitcalc;

	ELSE                   --  sinon retour du type de l'unité

		RETURN f_typeunitcalc;

	END IF;


END f_gar_unitcalc;
