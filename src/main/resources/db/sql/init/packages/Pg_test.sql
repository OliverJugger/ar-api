CREATE OR REPLACE PACKAGE ARTHUS.Pg_test AS
 PROCEDURE P_MIchel (I_numedit IN number);
 --
 FUNCTION F_michel(I_numedit IN number) RETURN VARCHAR2;
END;
/

CREATE OR REPLACE PACKAGE BODY ARTHUS.Pg_test AS
 PROCEDURE P_Michel (I_numedit IN number) IS
    BEGIN
      NULL;
    END;
--
 FUNCTION F_michel(I_numedit IN number) RETURN VARCHAR2
 IS
 L_retour VARCHAR2(50);
 BEGIN
   L_retour := 'RETOUR FONCTION MICHEL';
   RETURN(L_retour);
 END;
END;
/
