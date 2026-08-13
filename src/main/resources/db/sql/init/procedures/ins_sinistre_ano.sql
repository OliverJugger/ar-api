CREATE procedure ARTHUS.ins_sinistre_ano(
			numporte	in number,
			numano		in number,
			numsin		in number,
			datano		in date,
			etatano		in number,
			numremise	in number)
as
begin
	insert into sinistre_ano(
			numporte,
			numano,
			numsin,
			datano,
			etatano,
			numremise)
	values(
			numporte,
			numano,
			numsin,
			datano,
			etatano,
			numremise);
end ins_sinistre_ano;
/
