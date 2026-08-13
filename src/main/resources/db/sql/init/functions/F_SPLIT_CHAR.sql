CREATE FUNCTION ARTHUS.F_SPLIT_CHAR(p_list VARCHAR2,p_pos NUMBER, p_sep IN VARCHAR2)
RETURN VARCHAR2 IS

	v_list varchar2(32767) := p_sep || p_list;
	pos_deb NUMBER;
	pos_fin NUMBER;

BEGIN
	pos_deb := instr(v_list, p_sep, 1, p_pos);
	IF pos_deb > 0 THEN
		pos_fin := instr( v_list, p_sep, 1, p_pos + 1);
		IF pos_fin = 0 THEN
			pos_fin := length(v_list) + 1;
		END IF;
		RETURN(substr(v_list, pos_deb + 1, pos_fin - pos_deb - 1));
	ELSE
		RETURN NULL;
	END IF;
END F_SPLIT_CHAR;
