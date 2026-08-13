CREATE PROCEDURE ARTHUS.FETCH_FORMULE(a_numfor in number, a_etendue in number, a_clef in number, a_debut in date) is
  Cursor fetch_formule is
     Select idformule
     From   frml_prest
     Where  valide = 'O'
     and    a_debut between debut and nvl(fin, a_debut)
     and    numfor = a_numfor
     Union
     Select idformule
     From   frml_reval
     Where  valide = 'O'
     and    a_debut between debut and nvl(fin, a_debut)
     and    numfor = a_numfor
     Union
     Select idformule
     From   frml_dedu
     Where  valide = 'O'
     and    a_debut between debut and nvl(fin, a_debut)
     and    numfor = a_numfor
     ;
  loc_idformule fetch_formule%Rowtype;
BEGIN

  For loc_idformule in fetch_formule
  loop
 --  pk_trace.p_trace_and_log('FORM',null,'numfor : '||a_numfor||'formule:'||loc_idformule.idformule,SID,3,false);
     Cre_variable(a_idformule => loc_idformule.idformule,
                  a_etendue   => a_etendue,
                  a_clef      => a_clef,
                  a_debut     => a_debut,
                  a_numgar    => Null,
                  a_fin       => Null
                  );
  end loop;
END FETCH_FORMULE;
/
