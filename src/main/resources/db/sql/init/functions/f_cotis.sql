CREATE function ARTHUS.f_cotis	(a_numgar in number,
					a_idadhesion in number,
					a_numindiv in number,
					a_exo_debut in number,
					a_exo_fin in number,
					a_flag in number
					)
		RETURN	number
as
	montant number default 0;
BEGIN
	Begin
	If (a_idadhesion!=0) then
	Select sum(mt_ttc)
	Into montant
	From qttc_global
	where qttc_global.idadhesion=a_idadhesion
	And qttc_global.numindiv=a_numindiv
	And (
		(a_flag=1 and qttc_global.type_qttc !=3)
		or
		(a_flag=2 and qttc_global.type_qttc=3)
		or
		(a_flag=3 and qttc_global.type_qttc in(1,2,3))
		or
		(a_flag=4 and nvl(qttc_global.mt_affec,0)!=0)
	    )
	And
		to_char(qttc_global.debut,'yyyy') between a_exo_debut and
			nvl(a_exo_fin,a_exo_debut)
	And	qttc_global.comptant!='R'
		;
	Else
	Select sum(mt_ttc)
	Into montant
	From qttc_global
	Where qttc_global.numgar=a_numgar
	And qttc_global.numindiv=a_numindiv
	And (
		(a_flag=1 and qttc_global.type_qttc !=3)
		or
		(a_flag=2 and qttc_global.type_qttc=3)
		or
		(a_flag=3 and qttc_global.type_qttc in(1,2,3))
		or
		(a_flag=4 and nvl(qttc_global.mt_affec,0)!=0)
	    )
	And
		to_char(qttc_global.debut,'yyyy') between a_exo_debut and
			nvl(a_exo_fin,a_exo_debut)
	And	qttc_global.comptant!='R';
	End if;
	End;
RETURN nvl(montant,0);
end;
