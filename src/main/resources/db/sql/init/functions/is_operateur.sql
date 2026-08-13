CREATE function ARTHUS.is_operateur (
				a_char in varchar
				)
Return number
as
	operateur		varchar2(26);
BEGIN
operateur := '()+-*/#<=>&|.,%0123456789 ';
return (instr(operateur, a_char));
END;
