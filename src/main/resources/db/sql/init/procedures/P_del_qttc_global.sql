CREATE Procedure ARTHUS.P_del_qttc_global
								(I_numquit	IN	qttc_global.numquit%Type)
IS
/* qg04_adhecoll est utlisé pour savoir si le numgar est une adhesion collective*/
Cursor c_qttc_global IS
	SELECT 	numgar,
			pk_qttc.F_sel_numfor(numgar,1) adhecoll,
			numindiv,
			type_qttc,
			idadhesion
	FROM	qttc_global
	WHERE	numquit = I_numquit;
--
rec_c_qttc_global	c_qttc_global%ROWTYPE;
--
Begin
Open c_qttc_global;
Fetch c_qttc_global into rec_c_qttc_global;
--
if (rec_c_qttc_global.type_qttc = 2) then
	DELETE	qttc_global
	WHERE	idadhesion = rec_c_qttc_global.idadhesion
	AND	type_qttc = 3
	;

	UPDATE 	adhe_cntrt
	SET	(dereche, echesuiv) =
			(select max(qttc_global.debut),
				max(qttc_global.fin)+1
			from	qttc_global
			where	qttc_global.numquit != I_numquit
			and	qttc_global.comptant != 'R'
			and	qttc_global.idadhesion = rec_c_qttc_global.idadhesion
			)
	WHERE	adhe_cntrt.idadhesion = rec_c_qttc_global.idadhesion
	;
--
else
--
	DELETE	qttc_global
	WHERE	numgar = rec_c_qttc_global.numgar
	AND	numindiv = rec_c_qttc_global.numindiv
	AND	type_qttc = 3
	;
	if (rec_c_qttc_global.type_qttc = 1) then

       if (rec_c_qttc_global.adhecoll = 1) then

		UPDATE 	contrat_ref
		SET	(dereche, echesuiv) =
				(select max(qttc_global.debut),
					max(qttc_global.fin)+1
				from	qttc_global
				where	qttc_global.numquit != I_numquit
				and	qttc_global.comptant != 'R'
				and	qttc_global.numgar = rec_c_qttc_global.numgar
				and	qttc_global.numindiv = rec_c_qttc_global.numindiv
				)
		WHERE	contrat_ref.numgar = rec_c_qttc_global.numgar
		;
	   else
		UPDATE 	adhe_collective
		SET	(dereche, echesuiv) =
				(select max(qttc_global.debut),
					max(qttc_global.fin)+1
				from	qttc_global
				where	qttc_global.numquit != I_numquit
				and	qttc_global.comptant != 'R'
				and	qttc_global.numgar = rec_c_qttc_global.numgar
				and	qttc_global.numindiv = rec_c_qttc_global.numindiv
				)
		WHERE	adhe_collective.numgar = rec_c_qttc_global.numgar
		;
		end if;
	end if;
end if;

close c_qttc_global;

DELETE	qttc_global
	WHERE	qttc_global.numquit = I_numquit;

End P_del_qttc_global;
/
