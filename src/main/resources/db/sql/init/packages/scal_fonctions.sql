CREATE OR REPLACE package ARTHUS.scal_fonctions is
	type t_table is table of number
		index by binary_integer;
	function f_adhesion_externe(a_idadhesion in number)
		return t_table;
end scal_fonctions;
/

CREATE OR REPLACE package body ARTHUS.scal_fonctions
is
	function f_adhesion_externe(a_idadhesion in number)
		return t_table
	is
		retour t_table;
	begin
		retour(1) := 2;
		retour(2) := 3;
		retour(3) := 0;
		return (retour);
	end f_adhesion_externe;
end scal_fonctions;
/
