CREATE FORCE VIEW ARTHUS.V_LIBELLE_BIS AS
SELECT mnemo, code, libelle, TO_CHAR (sens) sens, tableau, '' codapli
     FROM lble_bis_ext
   UNION
   SELECT 'ICD9', cod_icd9.code, cod_icd9.libelle, TO_CHAR (0), '', 'gr18'
     FROM cod_icd9
   UNION
   SELECT 'ZONE_GEO', cod_zone_geo.codgeo, cod_zone_geo.libelle, TO_CHAR (0),
          '', 'gr19'
     FROM cod_zone_geo
   UNION
   SELECT 'CRRR1', param_texte.nom_crrr, param_texte.lib_para,
          TO_CHAR (param_texte.code), TO_CHAR (param_texte.idtexte), 'cr01'
     FROM param_texte
    WHERE param_texte.contexte = 99
      AND type_texte = 1
      AND param_texte.numrelance = 0
      AND EXISTS (
             SELECT 1
               FROM texte
              WHERE texte.idtexte = param_texte.idtexte
                AND texte.TYPE = 2
                AND texte.texte IS NOT NULL)
   UNION
   SELECT 'CRRR2', param_texte.nom_crrr || ' ' || param_texte.numrelance,
          param_texte.lib_para, TO_CHAR (param_texte.code),
          TO_CHAR (param_texte.idtexte), 'cr01'
     FROM param_texte
    WHERE param_texte.contexte = 99
      AND type_texte = 1
      AND param_texte.numero = 0
      AND EXISTS (
             SELECT 1
               FROM texte
              WHERE texte.idtexte = param_texte.idtexte
                AND texte.TYPE = 2
                AND texte.texte IS NOT NULL)
   UNION
   SELECT 'CRRR3', param_texte.nom_crrr, param_texte.lib_nom,
          TO_CHAR (param_texte.code), TO_CHAR (param_texte.idtexte), 'cr10'
     FROM param_texte
    WHERE type_texte = 2 AND param_texte.numero = 0
   UNION
   SELECT 'CRRR4', TO_CHAR (param_texte.numrelance), param_texte.lib_para,
          TO_CHAR (param_texte.code), param_texte.nom_crrr, 'cr01'
     FROM param_texte
    WHERE param_texte.contexte = 99
      AND type_texte = 1
      AND param_texte.numero = 0
   UNION
   SELECT 'PARA', param_texte.nom_crrr, param_texte.lib_nom,
          TO_CHAR (param_texte.code), TO_CHAR (param_texte.idtexte), 'cr16'
     FROM param_texte
    WHERE contexte = -99
   UNION
   SELECT 'VAR', def_variable.nom_variable, def_variable.lib_variable,
          TO_CHAR (0), '', 'va07'
     FROM def_variable
   UNION
   SELECT 'V_VAR', def_variable.nom_variable, def_variable.lib_variable,
          TO_CHAR (def_variable.etendue), TO_CHAR (def_variable.idvariable),
          'va07'
     FROM def_variable
    WHERE NOT EXISTS (
                      SELECT 1
                        FROM histo_frmlvar
                       WHERE histo_frmlvar.idvariable =
                                                       def_variable.idvariable)
      AND statique = 'O'
   UNION
   SELECT 'DVAR', def_variable.nom_variable, def_variable.lib_variable,
          DECODE (TO_CHAR (def_variable.etendue),
                  '4', '13',
                  '12', '13',
                  TO_CHAR (def_variable.etendue)
                 ),
          'OPT_VAR', 'plus'
     FROM def_variable
   UNION
   SELECT    'VAR_'
          || SUBSTR (TO_CHAR (DECODE (def_variable.etendue,
                                      4, 13,
                                      12, 13,
                                      def_variable.etendue
                                     ),
                              '00'
                             ),
                     2,
                     2
                    ),
          def_variable.nom_variable, def_variable.lib_variable, TO_CHAR (0),
          '', 'va07'
     FROM def_variable
   UNION
   SELECT 'VAR_' || SUBSTR (TO_CHAR (libelle.code, '00'), 2, 2), '-2',
          'Variables ' || libelle, TO_CHAR (0), '', ''
     FROM libelle
    WHERE mnemo = 'CONTE' AND code >= 0
   UNION
   SELECT 'VBA02', batchid, batchlib, TO_CHAR (0), '', ''
     FROM typ_batch
   UNION
   SELECT 'VACTE', codfrais, libelle, rubrique, '', ''
     FROM natfrais
    WHERE codfrais != rubrique
   UNION
   SELECT 'VRUB', codfrais, libelle, TO_CHAR (0), '', ''
     FROM natfrais
    WHERE codfrais = rubrique
   UNION
   SELECT 'VPRFL', profil, libelle, TO_CHAR (0), '', ''
     FROM lbleprfl
     WHERE ACTIF='O' --seuls les profils actifs remontent dans la liste des choix
   UNION
   SELECT 'VEDIT', editid, editlib, TO_CHAR (0), '', ''
     FROM typ_edition
   UNION
   SELECT 'VECRAN', codapli, nom, TO_CHAR (0), '', ''
     FROM appli
   UNION
   SELECT 'VAPPLI', codapli, nom, TO_CHAR (0), '', ''
     FROM appli_descript
    WHERE TYPE != 1
   UNION
   SELECT 'VLBLE', mnemo, libelle, TO_CHAR (0), '', ''
     FROM libelle_bis
    WHERE code = '-2'
   UNION
   SELECT 'VLBLE', mnemo, libelle, TO_CHAR (0), '', ''
     FROM libelle
    WHERE code = '-2'
   UNION
   SELECT 'V_LBLE_U', mnemo, libelle, TO_CHAR (0), '', ''
     FROM libelle_bis
    WHERE code = '-2' AND sens IN (1, 2)
   UNION
   SELECT 'V_LBLE_U', mnemo, libelle, TO_CHAR (0), '', ''
     FROM libelle
    WHERE code = '-2' AND sens IN (1, 2)
   UNION
   SELECT 'V_LBLE_V', mnemo, libelle, TO_CHAR (0), '', ''
     FROM libelle
    WHERE code = '-2' AND sens = -1
   UNION
   SELECT 'V_LBLE_S', mnemo, libelle, TO_CHAR (0), '', ''
     FROM libelle_bis
    WHERE code = '-2' AND sens = -2
   UNION
   SELECT 'V_LBLE_S', mnemo, libelle, TO_CHAR (0), '', ''
     FROM libelle
    WHERE code = '-2' AND sens = -2
   UNION
   SELECT 'TYPGES', mnemo, libelle, TO_CHAR (0), '', ''
     FROM libelle
    WHERE code = '-2'
   UNION
   SELECT 'CAISSE', caisse, nom, trim(TO_CHAR (regime,'00')), '', 'gt01'
     FROM trpnt
    WHERE type_tiers = 1
   UNION
   SELECT 'ORG', SUBSTR (TO_CHAR (orgns.numorg, '00'), 2, 2), orgns.nom,
          TO_CHAR (0), '', ''
     FROM orgns
    WHERE ROLE = 1
   UNION
   SELECT 'CENTRE', centre, nom, trim(TO_CHAR (regime||caisse,'00000')), '', 'gt01'
     FROM trpnt
    WHERE type_tiers = 2
   UNION
   SELECT 'CODFRAIS', codfrais_reg, libelle, TO_CHAR (regime), '', 'pe13'
     FROM acte_reg
   UNION
   SELECT 'CODFRAIS-C', codfrais, libelle, TO_CHAR (0), '', ''
     FROM ntfrs
    WHERE cnvtn = 'O'
   UNION
   SELECT 'CODFRAISNC', codfrais, libelle, TO_CHAR (0), '', ''
     FROM ntfrs
    WHERE cnvtn = 'N'
   UNION
   SELECT DISTINCT 'REF_CHAP', refcie_chapeau,
                   'Regroupement :' || ' ' || refcie_chapeau, TO_CHAR (0), '',
                   ''
              FROM contrat
   UNION
   SELECT DISTINCT 'REF_CONT', refcie, 'Référence :' || ' ' || refcie,
                   TO_CHAR (0), '', ''
              FROM contrat
   UNION
   SELECT 'GAR_CONT', '-2', 'Garanties du contrat Nø ' || numgar,
          TO_CHAR (numgar), '', ''
     FROM gar_cntrt
    WHERE valide = 'O'
   UNION -- M0004531 : ajout dates debut et fin
   SELECT 'GAR_CONT', nomgar,
   ' Deb ' || substr(d2e(datapli),  1 , 10) || ' Fin ' ||  nvl(substr(d2e(datper),  1 , 10), '__/__/__')
  || ' ' || libelle   as
    libelle, TO_CHAR (numgar), '', ''
     FROM gar_cntrt
    WHERE valide = 'O'
      AND numfor NOT IN (
             SELECT grp_gar_def.numfor
               FROM grp_gar, grp_gar_def
              WHERE grp_gar_def.numgrpgar = grp_gar.numgrpgar
                AND grp_gar.etendue = 2
                AND grp_gar.clef = gar_cntrt.numgar
                AND grp_gar_def.numfor = gar_cntrt.numfor)
   UNION -- M0004531 : ajout dates debut et fin
   SELECT 'GAR_CONT', nomgrpgar,
  ' Deb ' || substr(d2e(datapli),  1 , 10) || ' Fin ' || nvl(substr(d2e(datper),  1 , 10), '__/__/__')
  || ' ' || libelle  as
   libelle, TO_CHAR (clef), '', ''
     FROM grp_gar
    WHERE valide = 'O'
   UNION
   SELECT 'GAR_RISQUE', '-2', 'Garanties du contrat Nø ' || numgar,
          TO_CHAR (numgar), '', ''
     FROM gar_cntrt
    WHERE valide = 'O'
   UNION
   SELECT 'GAR_RISQUE', nomgar, libelle, TO_CHAR (numgar), TO_CHAR(numfor) tableau, ''
     FROM gar_cntrt
    WHERE valide = 'O'
   UNION
   SELECT 'GAR_GRP', nomgrpgar, libelle, TO_CHAR (clef), '', ''
     FROM grp_gar
    WHERE valide = 'O'
   UNION
   SELECT 'GAR_PROD', '-2', 'Garanties du produit Nø ' || numprod,
          TO_CHAR (numprod), '', ''
     FROM produit
   UNION
   SELECT 'GAR_PROD', nomgar, libelle, TO_CHAR (cle), TO_CHAR (gar.numfor),
          ''
     FROM gar
    WHERE valide = 'O'
      AND etendue = 7
      AND numfor NOT IN (
             SELECT grp_gar_def.numfor
               FROM grp_gar, grp_gar_def
              WHERE grp_gar_def.numgrpgar = grp_gar.numgrpgar
                AND grp_gar.etendue = 7
                AND grp_gar.clef = gar.cle
                AND grp_gar_def.numfor = gar.numfor)
   UNION
   SELECT 'GAR_PROD', nomgar, libelle, TO_CHAR (numprod),
          TO_CHAR (frmls.numfor), ''
     FROM frmls
    WHERE valide = 'O'
      AND numprod IS NOT NULL
      AND numfor NOT IN (
             SELECT grp_gar_def.numfor
               FROM grp_gar, grp_gar_def
              WHERE grp_gar_def.numgrpgar = grp_gar.numgrpgar
                AND grp_gar.etendue = 7
                AND grp_gar.clef = frmls.numprod
                AND grp_gar_def.numfor = frmls.numfor)
   UNION
   SELECT 'GAR_PROD', nomgrpgar, libelle, TO_CHAR (clef), TO_CHAR (numgrpgar),
          '1'
     FROM grp_gar
    WHERE valide = 'O' AND etendue = 7
   UNION
   SELECT 'GAR_BASE', nomgar, libelle, TO_CHAR (cle), TO_CHAR (gar.numfor),
          ''
     FROM gar
    WHERE valide = 'O' AND typgar = 1 AND nat_gar = 2 AND etendue IN (2, 7)
   UNION
   SELECT 'MNEMO_TAB', mnemo_tab, nom_tableau, TO_CHAR (0), '', ''
     FROM lib_tableau
    WHERE type_tableau = 1
   UNION
   SELECT 'DOUBLE_TAB', mnemo_tab, nom_tableau, TO_CHAR (0), '', ''
     FROM lib_tableau
    WHERE type_tableau = 2
   UNION
   SELECT 'DON_CONT', libelle_bis.code, libelle_bis.libelle,
          TO_CHAR (def_entite.codope),
          'D_' || f_mnemo_donnee (libelle_bis.sens), 'plus'
     FROM libelle_bis, libelle, def_entite
    WHERE libelle_bis.mnemo = 'DON_BASE'
      AND libelle.mnemo = 'CLE_BASE'
      AND libelle.code >= '0'
      AND libelle_bis.sens = libelle.code
      AND libelle_bis.code >= '0'
      AND libelle_bis.sens = def_entite.cle
      AND def_entite.TYPE = 1
      AND libelle.tableau = 0
   UNION
   SELECT 'DON_TEXT', libelle_bis.code, libelle_bis.libelle,
          TO_CHAR (def_entite.codope),
          'D_' || f_mnemo_donnee (libelle_bis.sens), 'plus'
     FROM libelle_bis, libelle, def_entite
    WHERE libelle_bis.mnemo = 'DON_BASE'
      AND libelle.mnemo = 'CLE_BASE'
      AND libelle.code >= '0'
      AND libelle_bis.sens = libelle.code
      AND libelle_bis.code >= '0'
      AND libelle_bis.sens = def_entite.cle
      AND def_entite.TYPE = 2
      AND libelle.tableau = 0
   UNION
   SELECT 'DON_INF', libelle_bis.code, libelle_bis.libelle,
          TO_CHAR (def_entite.codope),
          'D_' || f_mnemo_donnee (libelle_bis.sens), 'plus'
     FROM libelle_bis, libelle, def_entite
    WHERE libelle_bis.mnemo = 'DON_BASE'
      AND libelle.mnemo = 'CLE_BASE'
      AND libelle.code >= '0'
      AND libelle_bis.sens = libelle.code
      AND libelle_bis.code >= '0'
      AND libelle_bis.sens = def_entite.cle
      AND libelle.tableau > 0
   UNION
   SELECT DISTINCT 'V_CODPOS', codpos, ville, TO_CHAR (0), '', ''
              FROM indvs
   UNION
   SELECT 'IMPID', typ_imprim.impid, typ_imprim.implib,
          NVL (typ_imprim.userid, '-1'), '', 'ba03'
     FROM typ_imprim
   UNION
   SELECT 'PAPID', typ_papier.papid, typ_papier.paplib,
          NVL (typ_papier.impid, '-1'), '', 'ba01'
     FROM typ_papier
   UNION
   SELECT DISTINCT 'ACTE_CONT', calcul.codfrais, natfrais.libelle,
                   TO_CHAR (gar_cntrt.numgar), '', ''
              FROM calcul, natfrais, gar_cntrt
             WHERE natfrais.codfrais = calcul.codfrais
               AND calcul.numfor = gar_cntrt.numfor
               AND gar_cntrt.valide = 'O'
   UNION
   SELECT 'JRNL', journal, journal, TO_CHAR (0), NULL, NULL
     FROM compta_idpiece
     UNION
   SELECT DISTINCT 'DSN_OPTION', GAR_PARAM_DETAIL.CODE_OPTION, GAR_PARAM_DETAIL.LIB_OPTION, TO_CHAR (0), '', ''
     FROM GAR_PARAM_DETAIL
   UNION
   SELECT DISTINCT 'DSN_OPTCNT', GAR_PARAM_DETAIL.CODE_OPTION, GAR_PARAM_DETAIL.LIB_OPTION, to_char(v_GAR_CNTRT.numgar), '', ''
     FROM GAR_PARAM_DETAIL , v_GAR_CNTRT
   WHERE v_GAR_CNTRT.numfor = GAR_PARAM_DETAIL.numfor
GO
CREATE OR REPLACE PUBLIC SYNONYM V_LIBELLE_BIS FOR ARTHUS.V_LIBELLE_BIS
