CREATE procedure ARTHUS.test_donnee
As
	loc_t_donnee 	pk_donnee.donnee;
BEGIN
pk_donnee.charge_donnee( 1, 82, loc_t_donnee );
dbms_output.put_line( 'Donnee 1 : '|| loc_t_donnee(1) );
dbms_output.put_line( 'Donnee 2 : '|| loc_t_donnee(2) );
dbms_output.put_line( 'Donnee 3 : '|| loc_t_donnee(3) );
dbms_output.put_line( 'Donnee 4 : '|| loc_t_donnee(4) );
dbms_output.put_line( 'Donnee 5 : '|| loc_t_donnee(5) );
dbms_output.put_line( 'Donnee 6 : '|| loc_t_donnee(6) );
END;
/
