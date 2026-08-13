CREATE procedure ARTHUS.ins_vs_reprise (
					a_type in number,
					a_contexte in number,
					a_date in date default sysdate,
					a_idrepartition in number default null)
is
Cursor fetch_repartition is
	Select 	repartition.idrepartition,
		repartition.nosin,
		repartition_bene.numbene,
		repartition_bene.numbene_dest,
		repartition.numfor
	From	repartition_bene,repartition
	Where	repartition.idrepartition=repartition_bene.idrepartition
	And	repartition.idrepartition=nvl(a_idrepartition,
						repartition.idrepartition)
	;
loc_repartition fetch_repartition%Rowtype;
BEGIN
	For loc_repartition in fetch_repartition
	Loop
	Begin
	INSERT INTO pieces(
		contexte,
		entite,
		numfor,
		numbene,
		numindiv_dest,
		idrepartition,
		nopiece,
		delai,
		period,
		bloc,
		dateenreg,
		dateavis,
		daterecep
		)
	SELECT	distinct
		a_contexte,
		loc_repartition.nosin,
		param_pieces.numfor,
		loc_repartition.numbene,
		loc_repartition.numbene_dest,
		loc_repartition.idrepartition,
		to_number(param_pieces.nopiece),
		param_pieces.delai,
		param_pieces.period,
		param_pieces.bloc,
		trunc(sysdate),
		'01-oct-1999',
		'01-oct-1999'
	FROM 	param_pieces
	WHERE	type_piece=a_contexte
	AND	entite=100
	AND	contexte=decode(a_contexte,3,7,decode(a_type,1,7,2))
	AND	param_pieces.numfor=loc_repartition.numfor
	AND 	not exists(
			select	1
			from	pieces
			where	idrepartition	= loc_repartition.idrepartition
			and	numbene	= loc_repartition.numbene
			and	numindiv_dest=loc_repartition.numbene_dest
			and	nopiece = to_number(param_pieces.nopiece)
			and	contexte=a_contexte
			and 	entite=loc_repartition.nosin
			and	pieces.numfor=loc_repartition.numfor
		)
;
	Exception When No_data_found then Null;
	End;
	End loop;
END;
/
