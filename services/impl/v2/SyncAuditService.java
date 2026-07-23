package com.bdl.epbs_fund_api.services.impl.v2;

import jakarta.transaction.Transactional;
import org.apache.commons.collections4.CollectionUtils;

import java.util.List;

public interface SyncAuditService {

    /**
     * Methode utilisee par le batch pour resynchro la table audit avec la table actuelle
     * (ex: sous fond, investment geography ne se resynchro pas si jamais eu d'audit)
     * la synchro ne fonctionne pas si une suppression n'a pas été auditée -> script, ou ignore
     */
    @Transactional
    default void synchronizeWithLastRevision() {
        List<Integer> desynchronizedIds = getDesynchronizedIds();

        if (!CollectionUtils.isEmpty(desynchronizedIds)) {
            forceAudit(desynchronizedIds);
        }
    }

    List<Integer> getDesynchronizedIds();

    void forceAudit(List<Integer> desynchronizedIds);
}
