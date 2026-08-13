CREATE Function ARTHUS.F_type_couv(I_numsin     In number,
 I_numdossier In varchar2,
 I_numligne   In Number
		)
Return Number
Is
L_ret	    Number;  --1 =Que Oblg, 2= Que Compl, 3=Oblg de C/O, 4= C de C/O, 5 = dernière C
L_numdec    number;

Cursor C_LIGNES IS
	select numsin_sntr
	from   sntr_dossier
	where  num_dossier=I_numdossier
	and    numligne=I_numligne
	and    numsin_sntr<>I_numsin
	order by numsin_sntr desc;

Rec_Lignes C_LIGNES%Rowtype;

maxnumsin number;

BEGIN


    Open C_LIGNES;
	Fetch C_LIGNES Into Rec_Lignes;
	If ( C_LIGNES%NotFound ) then
		select decode(F_Frmls_COMPL(numgar,numfor),1,2,1)
		into L_ret
		from sinistre
		where numsin=I_numsin;

	else
	    select decode(F_Frmls_COMPL(numgar,numfor),1,4,3), numdec
		into L_ret, L_numdec
		from sinistre
		where numsin=I_numsin;

		if (L_ret = 4) then --and (Rec_Lignes.numsin_sntr < I_numsin) then

		    select max(numsin)
			into   maxnumsin
			from   sntr,sntr_dossier
			where  sntr.numsin=sntr_dossier.numsin_sntr
			and    num_dossier=I_numdossier
			and    numligne=I_numligne
			and    F_Frmls_COMPL(numgar,numfor)=1
			and    sntr.numdec= L_numdec;

			if maxnumsin=I_numsin then
				L_ret:=5;
			end if;

		end if;


	End if;
    Close C_LIGNES;

Return( L_ret);
END;
