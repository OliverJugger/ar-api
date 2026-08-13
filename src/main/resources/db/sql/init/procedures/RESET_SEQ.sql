CREATE PROCEDURE ARTHUS.RESET_SEQ (p_seq IN VARCHAR2) IS

/*============================================================================*/
/* PROCEDURE    : RESET_SEQ.sql                                               */
/* Domaine      : Technique                                                   */
/* Version      : V1.0                                                        */
/* Auteur       : ABO                                                         */
/* Création     : 20/01/2012                                                  */
/* Description  : Réinitialisation d'une séquence à 0                         */
/*============================================================================*/
/* Evolution    :                                                             */
/* Auteur       :                                                             */
/* Date         :                                                             */
/* Commentaire  :                                                             */
/*============================================================================*/
/* Correction   : trigramme / date / commentaire                              */
/*============================================================================*/
    lock_status integer;
    curr_val integer;
BEGIN
   -- lock_status := dbms_lock.REQUEST(lockhandle => my_lock_handle, lockmode => dbms_lock.x_mode);

    execute immediate 'alter sequence  '||p_seq||' minvalue 0';
    execute immediate 'select '||p_seq||'.nextval from dual' into curr_val ;
    execute immediate 'alter sequence '||p_seq||' increment by -' || curr_val ;
    execute immediate 'select '||p_seq||'.nextval from dual' into curr_val ;
    execute immediate 'alter sequence '||p_seq||' increment by 1';

   -- lock_status := dbms_lock.release(lockhandle => my_lock_handle);
END RESET_SEQ;
/
