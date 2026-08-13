CREATE function ARTHUS.F_CPTA_DATE_ENCAISMT (I_numencaismt    In Number)
Return 		DATE
As			loc_date		date;
			loc_bdx		Number;
			loc_encaismt  	encaismt%ROWTYPE;
BEGIN

BEGIN
	select 	*
	into 		loc_encaismt
	from 		encaismt
	where 	numencaismt	= 	I_numencaismt;
END;

BEGIN
	Select	f_cpta_en(I_numencaismt)
	Into		loc_bdx
	From		dual;
	Exception When No_data_found then loc_bdx := 1;
END;

if loc_bdx= 1 then
	loc_date 	:= loc_encaismt.datpay;
else
	BEGIN
		select  remise_globale.daterem
		into 	loc_date
		from 	remise_globale,
				remise_banque
		where 	remise_banque.numencaismt	=	I_numencaismt
		and     remise_globale.numremise	=	remise_banque.numremise
		union
		select  remise_prelev.date_prelev
		from 	prelevement,
				remise_prelev
		where 	prelevement.numencaismt		=	I_numencaismt
		and     prelevement.numremise		=	remise_prelev.numremise;
	END;
end if;

if	loc_date is null then
	loc_date	:= (sysdate + 365);
end if;

RETURN loc_date;

END	F_CPTA_DATE_ENCAISMT;
