CREATE OR REPLACE package ARTHUS.pk_types is
	type t_table is table of number
		index by binary_integer;
end pk_types;
/
