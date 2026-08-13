CREATE FORCE VIEW ARTHUS.V_LBLE_EXT AS
SELECT mnemo, code, libelle, sens, tableau, '' codapli
     FROM lble_ext
   UNION
/*
COMPTE ==> Comptes de trésorerie de la société (sens = société)
*/
   SELECT 'COMPTE', compte.numcpte, compte.libcompte || ' ' || compte.compte,
          compte.numsoc, '', 'so12'
     FROM compte
    WHERE TYPE = 1
   UNION
/*
COMPTA ==> Comptes comptables de la société
sens = société
*/
   SELECT 'COMPTA', compte.numcpte,
          compte.libcompte || ' ' || compte.cmpt_gene, compte.numsoc, '',
          'so25'
     FROM compte
    WHERE TYPE = 2
   UNION
/*
V_CPT_ENC ==> Comptes de trésorerie autorisés pour les opération donnant lieu à encaissement par opération
Sens = opération autorisée sur le compte
*/
   SELECT 'V_CPT_ENC', compte.numcpte,
          compte.libcompte || ' ' || compte.compte, ope.code, '', ''
     FROM lble ope, compte
    WHERE TYPE = 1
      AND ope.mnemo = 'OPE_ENC'
      AND f_compte_ope (ope.code, compte.numcpte) = 0
   UNION
/*
V_CPT_EN2 ==> Comptes comptables autorisés pour les opération donnant lieu à encaissement par opération
Sens = opération autorisée sur le compte
*/
   SELECT ALL 'V_CPT_EN2', compte.numcpte,
              compte.libcompte || ' ' || compte.compte, ope.code, '', ''
         FROM lble ope, compte
        WHERE (    compte.TYPE = 2
               AND ope.mnemo = 'OPE_ENC'
               AND f_compte_ope (ope.code, compte.numcpte) = 0
              )
   UNION
/*
V_COMPTE ==> Comptes de trésorerie pour lequels une opération a été autorisée, et ce lorsque l'opération est une opération sensée donner lieu à un décaissment (selection des OPE dont le sens = -1)
Sens = opération autorisée sur le compte
*/
   SELECT 'V_COMPTE', compte.numcpte,
          compte.libcompte || ' ' || compte.compte, ope.code, '', ''
     FROM lble ope, compte
    WHERE TYPE = 1
      AND ope.mnemo = 'OPE'
      AND ope.sens = -1
      AND f_compte_ope (ope.code, compte.numcpte) = 0
   UNION
/*
V_COMPTA ==> Comptes comptables pour lequels une opération a été autorisée, et ce lorsque l'opération est une opération sensée donner lieu à un décaissment (selection des OPE dont le sens = -1)
Sens = opération autorisée sur le compte
*/
   SELECT 'V_COMPTA', compte.numcpte,
          compte.libcompte || ' ' || compte.compte, ope.code, '', ''
     FROM lble ope, compte
    WHERE TYPE = 2
      AND ope.mnemo = 'OPE'
      AND ope.sens = -1
      AND f_compte_ope (ope.code, compte.numcpte) = 0
   UNION
/*
V_MOPM ==> Moyens de paiement
sens = -1 = Décaissements, 1 = Encaissements
tableau = ?
*/
   SELECT 'V_MOPM', code, libelle, -1, tableau, ''
     FROM libelle
    WHERE mnemo = 'MOPM' AND code > 0
   UNION
   SELECT 'V_MOPM', code, libelle, 1, tableau, ''
     FROM libelle
    WHERE mnemo = 'MREGL'
   UNION
/*
V_PMT ==> Modes de règlement décaissement par opération et comptes de trésorerie
Sens = opération autorisée sur le compte concaténée avec le compte
*/
   SELECT 'V_PMT', lble.code, lble.libelle,
          TO_NUMBER (ope.code || compte.numcpte), '', ''
     FROM lble, libelle ope, compte
    WHERE lble.mnemo = 'MOPM'
      AND TYPE = 1
      AND ope.mnemo = 'OPE'
      AND ope.sens = -1
      AND f_pmt_compte (ope.code, compte.numcpte, lble.code) = 0
   UNION
/*
V_PMT_OD ==> Modes de règlement décaissement par opération et comptes comptables
Sens = opération autorisée sur le compte concaténée avec le compte
*/
   SELECT 'V_PMT_OD', lble.code, lble.libelle,
          TO_NUMBER (ope.code || compte.numcpte), '', ''
     FROM lble, libelle ope, compte
    WHERE lble.mnemo = 'MOPM'
      AND TYPE = 2
      AND ope.mnemo = 'OPE'
      AND ope.sens = -1
      AND f_pmt_compte (ope.code, compte.numcpte, lble.code) = 0
   UNION
/*
V_MREGL ==> Modes de règlement encaissement par opération et comptes de trésorerie
Sens = opération autorisée sur le compte concaténée avec le compte
*/
   SELECT 'V_MREGL', lble.code, lble.libelle,
          TO_NUMBER (ope.code || compte.numcpte), '', ''
     FROM lble, libelle ope, compte
    WHERE lble.mnemo = 'MREGL'
      AND TYPE = 1
      AND ope.mnemo = 'OPE_ENC'
      AND f_pmt_compte (ope.code, compte.numcpte, lble.code) = 0
   UNION
/*
V_MREGL_OD ==> Modes de règlement encaissement par opération et comptes comptables
Sens = opération autorisée sur le compte concaténée avec le compte
*/
   SELECT 'V_MREGL_OD', lble.code, lble.libelle,
          TO_NUMBER (ope.code || compte.numcpte), '', ''
     FROM lble, libelle ope, compte
    WHERE lble.mnemo = 'MREGL'
      AND TYPE = 2
      AND ope.mnemo = 'OPE_ENC'
      AND f_pmt_compte (ope.code, compte.numcpte, lble.code) = 0
/*
Mis en commentaire par GLB le 05/02/2007
Semble n'avoir aucun interêt (utiisé dans les traitements CNRA)
union
select   'V_PMT1',
   lble.code,
   lble.libelle,
   to_number(ope.code||compte.numcpte),
   '',
   ''
From  lble,
   libelle ope,
   compte
where lble.mnemo='MOPMT'
and   type=1
and   ope.mnemo='OPE'
and   ope.sens =-1
and   f_pmt_compte(ope.code,compte.numcpte,lble.code)=0
*/
   UNION
   SELECT 'BPRE', numremise,
          'Bdx Compte Nø' || numcpte || ' - ' || nombre || ' Prélèvements.',
          -numremise, '', 'pre7'
     FROM remise_prelev
   UNION
   SELECT 'BPREV', numremise,
          'Bdx Compte Nø' || numcpte || ' - ' || nombre || ' prélèvements.',
          -numremise, '', 'pre7'
     FROM remise_prelev
    WHERE remise_prelev.valide = 'O' AND remise_prelev.datdisk IS NULL
   UNION
   SELECT 'BPREA', numremise,
          'Bdx Compte Nø' || numcpte || ' - ' || nombre || ' prélèvements.',
          -numremise, '', 'pre7'
     FROM remise_prelev
    WHERE remise_prelev.valide = 'O'
      AND remise_prelev.dataccuse IS NULL
      AND remise_prelev.datdisk IS NOT NULL
   UNION
   SELECT 'BVIR', numremise,
          'Bdx Compte Nø' || numcpte || ' - ' || nombre || ' virements.',
          -numremise, '', 'vr07'
     FROM remise_vire
   UNION
   SELECT 'BVIROP', numremise,
          'Bdx Compte Nø' || numcpte || ' - ' || nombre || ' virements.',
          -numremise, '', ''
     FROM remise_op
   UNION
   SELECT 'BVIRV', numremise,
          'Bdx Compte Nø' || numcpte || ' - ' || nombre || ' virements.',
          -numremise, '', 'vr07'
     FROM remise_vire
    WHERE remise_vire.valide = 'O' AND remise_vire.datdisk IS NULL
   UNION
   SELECT 'CMPT', v_remise_compta.idcompta,
             'bordereau Nø '
          || v_remise_compta.idcompta
          || ' du '
          || v_remise_compta.edatcompta
          || ' '
          || v_remise_compta.nomsoc,
          -v_remise_compta.idcompta, '', ''
     FROM v_remise_compta
    WHERE idcompta > 0
   UNION
   SELECT 'RCMPT', v_remise_compta.idcompta,
             'bordereau Nø '
          || v_remise_compta.idcompta
          || ' du '
          || v_remise_compta.edatcompta
          || ' '
          || v_remise_compta.nomsoc,
          -v_remise_compta.idcompta, '', ''
     FROM remise_compta_globale, v_remise_compta
    WHERE remise_compta_globale.idcompta = v_remise_compta.idcompta
      AND remise_compta_globale.transmission IS NOT NULL
   UNION
   SELECT 'BDX_FN', num_bord,
             'Bdx. de fiches navettes Nø'
          || num_bord
          || ' - '
          || nombre
          || ' Fiches navettes',
          -num_bord, '', ''
     FROM remise_prest
    WHERE remise_prest.datedit IS NULL
   UNION
   SELECT 'GRP_GAR', grp_gar.numgrpgar, grp_gar.libelle, grp_gar.clef, '1',
          ''
     FROM grp_gar
    WHERE etendue = 2 AND valide = 'O'
   UNION
   SELECT 'GRNTS', contrat_ref.numgar, contrat_ref.refcie, contrat_ref.numgar,
          '1', 'gc01'
     FROM contrat_ref
    WHERE EXISTS (
             SELECT 1
               FROM util_soc
              WHERE util_soc.numsoc = contrat_ref.numinterm
                AND util_soc.numutil = f_numutil)
   UNION
   SELECT 'ORGN', pers_organisme.numorg, indvs.nom, TO_NUMBER (''), '7',
          'gr05'
     FROM pers_organisme, indvs
    WHERE pers_organisme.ROLE = 2 AND indvs.numindiv = pers_organisme.numindiv
   UNION
   SELECT 'ORGNS', tmp_organisme.numorg, tmp_organisme.nom, TO_NUMBER (''),
          '7', 'gr01'
     FROM tmp_organisme
    WHERE tmp_organisme.ROLE = 1
   UNION
   SELECT 'PROD', produit.numprod, produit.libelle, TO_NUMBER (''), '5',
          'pr07'
     FROM produit
   UNION
   SELECT 'RBVIRV', numremise,
          'Bdx Compte Nø' || numcpte || ' - ' || nombre || ' virements.',
          -numremise, '', 'vr07'
     FROM remise_vire
    WHERE remise_vire.valide = 'O'
      AND remise_vire.datdisk > TO_DATE ('01010001', 'ddmmyyyy')
   UNION
   SELECT 'REMIS', remise_globale.numremise,
          'Remise ' || compte.libcompte || ' le '
          || d2e (remise_globale.daterem),
          -remise_globale.numremise, '', ''
     FROM compte, remise_globale
    WHERE compte.numcpte = remise_globale.numcpte
   UNION
   SELECT 'TRT', traite.numtr, traite.libinttr, traite.numreass, '', 'rs10'
     FROM traite
   UNION
   SELECT 'V_EXP', 0, 'Bordereau de remise provisoire', -99999999, '', ''
     FROM lble_ext
    WHERE mnemo = 'V_EXP' AND code = -2
   UNION
   SELECT 'V_EXP', remise_externe.numremise,
             'Exportation '
          || libelle.libelle
          || ' du '
          || TO_CHAR (remise_externe.date_remise, 'dd/mm/yy'),
          -remise_externe.numremise, '', ''
     FROM remise_externe, libelle
    WHERE libelle.code = remise_externe.numporte AND libelle.mnemo = 'PORTE'
   UNION
   SELECT 'REVERS', reversement.idrevers,
             'Reversement Nø '
          || reversement.idrevers
          || ' '
          || indvs.nom
          || ' du '
          || TO_CHAR (reversement.datrevers, 'dd/mm/yyyy'),
          -reversement.idrevers, '', ''
     FROM reversement, pers_organisme, indvs
    WHERE pers_organisme.numorg = reversement.numorg
      AND indvs.numindiv = pers_organisme.numindiv
   UNION
   SELECT 'SOUSC', indvs.numindiv, indvs.nom || ' ' || indvs.prenom, 0, '',
          'pe19'
     FROM indvs
    WHERE EXISTS (SELECT 1
                    FROM client
                   WHERE client.numindiv = indvs.numindiv)
   UNION
   SELECT 'TRPNT', pers_tierspayant.numtp, indvs.nom, 0, '', ''
     FROM pers_tierspayant, indvs
    WHERE indvs.numindiv = pers_tierspayant.numindiv
   UNION
   SELECT 'TYPE', code, libelle, 0, '',
          DECODE (code,
                  1, 'va08',
                  2, 'va08',
                  3, 'va08',
                  4, 'va07',
                  5, 'va04',
                  6, 'gr03'
                 )
     FROM lble
    WHERE code IN (1, 2, 3, 4, 5, 6) AND mnemo = 'TYPE_FONC'
   UNION
   SELECT 'USER', util.numutil, util.pseudo, 0, '9', 'gu04'
     FROM util
   UNION
   SELECT 'V_FRMLVAR', 0, 'Création d''une nouvelle formule', -1, '', 'va05'
     FROM lble_ext
    WHERE mnemo = 'V_FRMLVAR' AND code = -2
   UNION
   SELECT 'V_FRMLVAR', def_formule.idformule, def_formule.libelle,
          def_formule.etendue, '14', 'va05'
     FROM def_formule
   UNION
   SELECT 'V_LIBFOR', 0, 'Création d''une nouvelle formule', -1, '', 'gr11'
     FROM lble_ext
    WHERE mnemo = 'V_LIBFOR' AND code = -2
   UNION
   SELECT 'V_LIBFOR', libformath.nummath, libformath.libelle, 0, '', 'gr11'
     FROM libformath
   UNION
   SELECT 'V_PORTE', porte_param.numporte, lble_porte.libelle, -1, '13',
          'pe01'
     FROM porte_param, libelle lble_porte
    WHERE lble_porte.mnemo = 'PORTE'
          AND porte_param.numporte = lble_porte.code
   UNION
   SELECT 'V_PRCH', numpc,
             numindiv
          || ' - Etbl. '
          || numtiers
          || ' Hspt. '
          || TO_CHAR (datehospi, 'dd/mm/yy'),
          0, '', ''
     FROM prch
    WHERE datedit IS NULL AND typedest != 4
   UNION
   SELECT 'V_PRCH2', numpc,
             numindiv
          || ' - Etbl. '
          || numtiers
          || ' Hspt. '
          || TO_CHAR (datehospi, 'dd/mm/yy'),
          0, '', ''
     FROM prch
    WHERE datedit IS NOT NULL AND typedest != 4
   UNION
   SELECT 'V_RECOURS', recours.numrecours,
          'No ' || recours.numrecours || ' - ' || indvs.nom, TO_NUMBER (''),
          '', 'rec1'
     FROM pers_organisme, recours, indvs
    WHERE pers_organisme.numorg = recours.numorg
      AND indvs.numindiv = pers_organisme.numindiv
   UNION
   SELECT 'V_IMP', porte_remise.numremise,
             'Importation '
          || lble_porte.libelle
          || ' du '
          || TO_CHAR (porte_remise.dateremise, 'DD/MM/YYYY'),
          -porte_remise.numremise, '', 'pe07'
     FROM porte_remise, libelle lble_porte
    WHERE lble_porte.mnemo = 'PORTE'
      AND porte_remise.numporte = lble_porte.code
      AND lble_porte.code NOT IN (20, 21, 25)
   UNION
   SELECT 'VDCIE', dcptcie.numdcptcie,
             DECODE (dcptcie.TYPE, 1, 'Mal. ', 2, 'Prev. ')
          || pers_societe.abrege
          || '-'
          || indvs.nom
          || '-'
          || ' du '
          || TO_CHAR (datefin, 'dd/mm/yyyy'),
          dcptcie.TYPE, '', 'gdr1'
     FROM dcptcie, pers_societe, pers_organisme, indvs
    WHERE dcptcie.numsoc = pers_societe.numsoc
      AND dcptcie.numorg = pers_organisme.numorg
      AND indvs.numindiv = pers_organisme.numindiv
   UNION
   SELECT 'VDCIE2', dcptcie.numdcptcie,
             'Prev. '
          || pers_societe.abrege
          || '-'
          || indvs.nom
          || '-'
          || ' du '
          || TO_CHAR (datefin, 'dd/mm/yyyy'),
          TO_NUMBER (''), '', 'gdr2'
     FROM dcptcie, pers_societe, pers_organisme, indvs
    WHERE dcptcie.numsoc = pers_societe.numsoc
      AND dcptcie.numorg = pers_organisme.numorg
      AND dcptcie.TYPE = 2
      AND indvs.numindiv = pers_organisme.numindiv
   UNION
   SELECT 'VDCIE1', dcptcie.numdcptcie,
             'Mal. '
          || pers_societe.abrege
          || '-'
          || indvs.nom
          || '-'
          || ' du '
          || TO_CHAR (datefin, 'dd/mm/yyyy'),
          TO_NUMBER (''), '', 'gdr1'
     FROM dcptcie, pers_societe, pers_organisme, indvs
    WHERE dcptcie.numsoc = pers_societe.numsoc
      AND dcptcie.numorg = pers_organisme.numorg
      AND dcptcie.TYPE = 1
      AND indvs.numindiv = pers_organisme.numindiv
   UNION
   SELECT 'TABLEAU', TO_NUMBER (lib_tableau.tableau), lib_tableau.nom_tableau,
          TO_NUMBER (''), '', 'va04'
     FROM lib_tableau
    WHERE type_tableau = 1
   UNION
   SELECT 'DBLE_TAB', TO_NUMBER (lib_tableau.tableau),
          lib_tableau.nom_tableau, TO_NUMBER (''), '', 'va06'
     FROM lib_tableau
    WHERE type_tableau = 2
   UNION
   SELECT 'VDDED', dcptdedu.numdec,
             'Bdx de'
          || ' '
          || lble.libelle
          || ' '
          || 'au'
          || ' '
          || TO_CHAR (dcptdedu.fin, 'dd/mm/yyyy'),
          TO_NUMBER (''), '', 'gdp1'
     FROM dcptdedu, lble
    WHERE lble.mnemo = 'DEDU' AND lble.code = dcptdedu.typdedu
   UNION
   SELECT 'V_SOC', pers_societe.numsoc, indvs.nom, 0, '8', 'so10'
     FROM pers_societe, indvs
    WHERE indvs.numindiv = pers_societe.numindiv
   UNION
   SELECT 'VSOC', pers_societe.numsoc, indvs.nom, 0, '8', 'so10'
     FROM pers_societe, indvs
    WHERE indvs.numindiv = pers_societe.numindiv
      AND EXISTS (
             SELECT 1
               FROM util_soc
              WHERE util_soc.numsoc = pers_societe.numsoc
                AND util_soc.numutil = f_numutil)
   UNION
   SELECT 'INTERM', pers_intermediaire.numindiv,
          indvs.nom || ' ' || indvs.prenom, 0, '8', 'pr21'
     FROM pers_intermediaire, indvs
    WHERE indvs.numindiv = pers_intermediaire.numindiv
      AND EXISTS (SELECT 1
                    FROM apporteur
                   WHERE apporteur.numindiv = pers_intermediaire.numindiv)
   UNION
   SELECT 'DELEG', indvs.numindiv, indvs.nom || ' ' || indvs.prenom, 0, '8',
          'pr21'
     FROM indvs, contrat
    WHERE indvs.numindiv = contrat.delegataire AND contrat.gest_cotis = 2
   UNION
   SELECT 'ALL_VAR', def_variable.idvariable,
          def_variable.nom_variable || ' ' || def_variable.lib_variable, 0,
          '', 'va07'
     FROM def_variable
   UNION
   SELECT 'VAR_C', def_variable.idvariable,
          def_variable.nom_variable || ' ' || def_variable.lib_variable, 0,
          '', 'va07'
     FROM def_variable
    WHERE statique = 'C'
   UNION
   SELECT 'SYMB', codmon, symbole, 0, '', ''
     FROM monnaie
   UNION
   SELECT 'DEVISE', codmon, libelle, 0, '', ''
     FROM monnaie
   UNION
   SELECT 'PAYS', codpays, nom, 0, '', ''
     FROM pays
   UNION
   SELECT 'FRML', gar_cntrt.numfor,
             gar_cntrt.nomgar
          || ' '
          || 'Contrat'
          || ' '
          || contrat.numgar
          || ' '
          || contrat.refcie,
          0, '', ''
     FROM gar_cntrt, contrat
    WHERE gar_cntrt.numgar = contrat.numgar
   UNION
   SELECT 'V_NIVEAU', def_niveau.cle, libelle.libelle, def_niveau.base, '',
          ''
     FROM def_niveau, libelle
    WHERE libelle.mnemo = 'NIVEAU' AND libelle.code = def_niveau.cle
   UNION
   SELECT 'OPE_GEST', 0, 'Toutes opérations', 0, '', ''
     FROM libelle
    WHERE mnemo = 'TYPE_CRRR' AND code = -2
   UNION
   SELECT 'OPE_GEST', libelle.code, libelle.libelle, 0, '', ''
     FROM libelle
    WHERE libelle.mnemo = 'TYPE_CRRR' AND libelle.code NOT IN (0, 99)
   UNION
   SELECT 'LIENS', libelle.code, libelle.libelle, 0, '', ''
     FROM libelle
    WHERE libelle.mnemo = 'TYAD' AND libelle.code > 0
   UNION
   SELECT 'LIENS', 0, 'Chef de famille', 0, '', ''
     FROM lble_ext
    WHERE lble_ext.mnemo = 'LIENS'
   UNION
   SELECT 'DEF_BENE', libelle.code, libelle.libelle, 0, '', ''
     FROM libelle
    WHERE libelle.mnemo = 'TYAD' AND libelle.code > 0
   UNION
   SELECT 'TYPE_BENE', libelle.code, libelle.libelle, 0, '', ''
     FROM libelle
    WHERE libelle.mnemo = 'TYAD' AND libelle.code > 0
   UNION
   SELECT 'TYPE_BENE', 0, 'L''assuré lui même', 0, '', ''
     FROM lble_ext
    WHERE lble_ext.mnemo = 'TYPE_BENE'
   UNION
   SELECT 'TYPE_BENE', 99, 'Tierce personne', 0, '', ''
     FROM lble_ext
    WHERE lble_ext.mnemo = 'TYPE_BENE'
   UNION
   SELECT 'INT_EXP', def_porte.idporte, def_porte.libelle, 0, '', 'it01'
     FROM def_porte
    WHERE def_porte.sens = 2
   UNION
   SELECT 'INT_IMP', def_porte.idporte, def_porte.libelle, 0, '', 'it03'
     FROM def_porte
    WHERE def_porte.sens = 1
   UNION
   SELECT 'CONT_PRET', contrat.numgar, contrat.refcie, 0, '1', 'gc01'
     FROM contrat
    WHERE type_contrat = 3
   UNION
   SELECT 'V_ETATPRT', lble.code, lble.libelle, 0, '', ''
     FROM lble
    WHERE mnemo = 'ETATPRT' AND sens = 1
   UNION
   SELECT 'V_TYPCOMM', 0, 'Non rémunéré', 0, '', ''
     FROM lble_ext
    WHERE mnemo = 'V_TYPCOMM'
   UNION
   SELECT 'V_TYPCOMM', lble.code, lble.libelle, 0, '', ''
     FROM lble
    WHERE mnemo = 'TYPRETRO' AND code > 0
   UNION
   SELECT 'V_TYP_DEST', lble.code, lble.libelle, 0, '', ''
     FROM lble
    WHERE mnemo = 'TYPE_DEST' AND code > 0 AND code != 3
   UNION
   SELECT 'B_RETRO', retrocession.idrevers,
             'Nø '
          || retrocession.idrevers
          || ' du '
          || d2e (retrocession.datrevers)
          || ' - '
          || interm.nom,
          0, '', ''
     FROM indvs interm, retrocession
    WHERE retrocession.numindiv = interm.numindiv
   UNION
   SELECT 'V_DEST', lble.code, lble.libelle, 0, '', ''
     FROM lble
    WHERE mnemo = 'RGLTDEST' AND code > 0 AND code != 4
   UNION
   SELECT 'V_PHYS', lble.code, lble.libelle, lble.sens, '', ''
     FROM lble
    WHERE mnemo = 'DON_PHYS' AND tableau IS NULL
   UNION
   SELECT 'V_PHYS_3', lble.code, lble.libelle, lble.sens, '', ''
     FROM lble
    WHERE mnemo = 'DON_PHYS' AND sens = 3
   UNION
   SELECT 'V_ENT', lble.code, lble.libelle, lble.sens, '', ''
     FROM lble
    WHERE mnemo = 'ENT_PHYS' AND sens = 0
   UNION
   SELECT 'BQUE_2', pers_banque.numindiv, indvs.nom,
          TO_NUMBER (pers_banque.codbque), '', ''
     FROM pers_banque, indvs
    WHERE indvs.numindiv = pers_banque.numindiv AND pers_banque.TYPE = 2
   UNION
   SELECT 'CHQ_MAN', cheq.numchq, ' Chéquier compte ' || cpte.libcompte,
          cheq.numcpte, NULL, ''
     FROM chequier cheq, compte cpte
    WHERE NVL (cheq.fin, SYSDATE + 1) > SYSDATE
      AND cpte.numcpte = cheq.numcpte
      AND cheq.papid = 'Manuel'
   UNION
   SELECT 'CHQ_AUTO', cheq.numchq, ' Chéquier compte ' || cpte.libcompte,
          cheq.numcpte, NULL, ''
     FROM chequier cheq, compte cpte
    WHERE NVL (cheq.fin, SYSDATE + 1) > SYSDATE
      AND cpte.numcpte = cheq.numcpte
      AND cheq.papid != 'Manuel'
   UNION
   SELECT 'REASS', pers_reass.numreass, indvs.nom || ' ' || indvs.prenom,
          TO_NUMBER (''), '20', 'rs60'
     FROM pers_reass, indvs
    WHERE indvs.numindiv = pers_reass.numreass
   UNION
   SELECT 'P_NATION', pays.codpays, pays.nationalite, 0, '', ''
     FROM pays
   UNION
   SELECT 'L_COMPTAB', pers_centrepayeur.numindiv,
          indvs.nom || ' ' || indvs.prenom nomcentre, 0, '', ''
     FROM pers_centrepayeur, indvs
    WHERE pers_centrepayeur.TYPE = 1
      AND pers_centrepayeur.numindiv = indvs.numindiv
      AND indvs.TYPE = 2
   UNION
   SELECT 'ASSURPRINC', indvs.numindiv,
          indvs.nom || ' ' || indvs.prenom nomassure, 0, '', ''
     FROM indvs
    WHERE indvs.numindiv = indvs.numassu
   UNION
   SELECT 'L_BARREAUX', pers_avocat.numindiv,
          indvs.nom || ' ' || indvs.prenom nombarreau, 0, '', ''
     FROM pers_avocat, indvs
    WHERE pers_avocat.numindiv = indvs.numindiv AND pers_avocat.TYPE = 1
   UNION
   SELECT 'L_CABINETS', pers_avocat.numindiv,
          indvs.nom || ' ' || indvs.prenom nomcabinet, 0, '', ''
     FROM pers_avocat, indvs
    WHERE pers_avocat.numindiv = indvs.numindiv AND pers_avocat.TYPE = 2
   UNION
   SELECT 'LANGUE', langue.codlangue, langue.libelle, 0, '', ''
     FROM langue
   UNION
   SELECT DISTINCT 'O_PMT', remise_op_detail.numvirement,
                   remise_op_detail.intitule, 0, '', 'vr14'
              FROM remise_op_detail
             WHERE remise_op_detail.numvirement NOT IN (
                                             SELECT releve_compte.num_ecriture
                                               FROM releve_compte)
   UNION
   SELECT 'DEST_TYPE', code, libelle, 0, '', ''
     FROM libelle
    WHERE code IN (0, 3, 5, 10, 15) AND mnemo = 'ROLE'
   UNION
   SELECT 'ADHEC', contrat.numgar, contrat.refcie, contrat.numgar, '1',
          'gc11'
     FROM contrat
    WHERE numgar <> numgar_ref
      AND EXISTS (
             SELECT 1
               FROM util_soc
              WHERE util_soc.numsoc = contrat.numinterm
                AND util_soc.numutil = f_numutil)
   UNION
   SELECT 'CODOPECPTA', compta_ope.code, compta_ope.libelle, compta_ope.sens,
          '', ''
     FROM compta_ope
   UNION
   SELECT   'INTER', interlocuteur, ARTHUS.pk_personne.f_nom (interlocuteur, 30, 0),
            numindiv, '17', 'pe38'
       FROM interlocuteur
   GROUP BY numindiv, interlocuteur
    UNION
    -- etat du partenariat
   SELECT MNEMO,CODE,'partenariat '||LIBELLE, SENS, TABLEAU, CODAPLI
      FROM libelle
      WHERE MNEMO = 'ET_PART'
  UNION
   SELECT 'ET_PART',-1,'partenariat invalide',null,'',''
      FROM DUAL
  UNION
   SELECT 'ET_PART',-2,'pas de fiche partenaire',null,'',''
      FROM DUAL
  UNION
   SELECT 'FX_PRDG', idprdgflux, nomflux,0, '','gt01'
     FROM PRDGFLUX
   UNION
   SELECT 'C_VENTIL',SENS,LIBELLE, CODE, TABLEAU, CODAPLI
      FROM libelle
      WHERE MNEMO = 'VENTIL'
   UNION
   SELECT distinct 'DSN_COLL',contrat.college,libelle.LIBELLE, contrat.numcli, to_char(porte_contrat.numporte), ''
      FROM contrat, libelle, porte_contrat, porte_param
      WHERE libelle.MNEMO = 'COLLEGE'
	  AND libelle.code = contrat.college
    AND porte_contrat.numgar =contrat.numgar
    AND porte_contrat.numporte = porte_param.numporte
    AND porte_param.nat_porte=4
   UNION
   SELECT 'CONTE_DDE',CODE,LIBELLE, SENS, TABLEAU, CODAPLI
   FROM libelle
   WHERE MNEMO = 'CONTE'
   AND CODE IN (SELECT sens FROM LIBELLE WHERE mnemo='TYPERAPPEL' AND code<>-2 union select 19 from dual) -- EXTANET EVO3 CLI 05/04/2018 Ajout du contexte 19 pour les pièces télétrans
   UNION
    SELECT 'MAIL_TEXTE', id_texte, '['||SUJET_MSG ||']['|| To_CHAR(SUBSTR( CORPS_MSG, 0, 3999 ))||']' , id_texte, '', ''
    FROM MAIL_TEXTE
   UNION
   SELECT 'GARS', numfor, 'Garanties santé Nø ' || numfor,
           null, '', ''
     FROM gar_cntrt
    WHERE valide = 'O'
    AND type=1
   UNION
   SELECT 'GARP', numfor, 'Garanties prévoyance Nø ' || numfor,
           null, '', ''
     FROM gar_cntrt
    WHERE valide = 'O'
    AND type=2
GO
CREATE OR REPLACE PUBLIC SYNONYM V_LBLE_EXT FOR ARTHUS.V_LBLE_EXT
