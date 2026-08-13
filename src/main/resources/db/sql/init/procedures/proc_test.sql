CREATE procedure ARTHUS.proc_test (
				a_arg1 in number,
				a_arg2 in out varchar2)
is
	dummy			number;
BEGIN
a_arg2 := 'proc_test Ok';
END;
/
