CREATE function ARTHUS.f_message(a_message in varchar2)
		RETURN	varchar2
as
	lib_message varchar2(70);
BEGIN
	begin
	select a_message
	into lib_message
	from dual;
return(lib_message);
	end;
END;
