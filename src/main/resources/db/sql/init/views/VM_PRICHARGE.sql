CREATE FORCE VIEW ARTHUS.VM_PRICHARGE AS
SELECT numpc cle,
             '"'
          || v_pricharge.numsoc
          || '";"'
          || v_pricharge.numpc
          || '";"'
          || v_pricharge.numindiv
          || '";"'
          || v_pricharge.numassu
          || '";"'
          || v_pricharge.numtiers
          || '";"'
          || v_pricharge.numentree
          || '";' ligne1,
             '"'
          || v_pricharge.edatehospi
          || '";"'
          || v_pricharge.edatedit
          || '";"'
          || v_pricharge.refcie_indiv
          || '";"'
          || v_pricharge.nom_indiv
          || '";"'
          || v_pricharge.prenom_indiv
          || '";"'
          || v_pricharge.edatnais_indiv
          || '";"'
          || v_pricharge.matorg_indiv
          || '";' ligne2,
             '"'
          || v_pricharge.refcie_assu
          || '";"'
          || v_pricharge.nom_assu
          || '";"'
          || v_pricharge.prenom_assu
          || '";"'
          || v_pricharge.matorg_assu
          || '";' ligne3,
             '"'
          || v_pricharge.nom_tiers
          || '";"'
          || v_pricharge.adr1_tiers
          || '";"'
          || v_pricharge.adr2_tiers
          || '";"'
          || v_pricharge.codpos_tiers
          || '";"'
          || v_pricharge.ville_tiers
          || '";' ligne4,
             '"'
          || v_pricharge.numgar
          || '";"'
          || v_pricharge.refcie_contrat
          || '";"'
          || v_pricharge.cli_nom
          || '";"'
          || v_pricharge.cli_prenom
          || '";' ligne5,
             '"'
          || v_pricharge.dest_nom
          || '";"'
          || v_pricharge.dest_prenom
          || '";"'
          || v_pricharge.dest_adr1
          || '";"'
          || v_pricharge.dest_adr2
          || '";"'
          || v_pricharge.dest_codpos
          || '";"'
          || v_pricharge.dest_ville
          || '"' ligne6
     FROM v_pricharge
GO
CREATE OR REPLACE PUBLIC SYNONYM VM_PRICHARGE FOR ARTHUS.VM_PRICHARGE
