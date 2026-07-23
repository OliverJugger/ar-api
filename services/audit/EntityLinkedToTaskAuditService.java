package com.bdl.epbs_fund_api.services.audit;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.data.history.Revision;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.history.RevisionRepository;

import com.bdl.epbs_fund_api.model.entities.LinkedToTask;

public abstract class EntityLinkedToTaskAuditService<R extends JpaRepository<E, Integer> & RevisionRepository<E, Integer, Integer>, E extends LinkedToTask, D>
        extends EntityAuditService<R, E, D> {

    public EntityLinkedToTaskAuditService(R repository) {
        super(repository);
    }
    
    protected Integer getRevisionIdFromTaskUuid(final Integer id, final String taskUuid) {
    	 List<? extends Revision<Integer, ?>> revisions = this.repository.findRevisions(id)
         		.stream()
 	            .sorted((o1, o2) -> Integer.compare(o2.getRequiredRevisionNumber(), o1.getRequiredRevisionNumber()))
 	            .collect(Collectors.toList());
    	 
    	return revisions.stream()
                .filter(revision -> {
                    LinkedToTask linkedToTask = (LinkedToTask) revision.getEntity();
                    return Optional.ofNullable(linkedToTask)
                    		.map(revTask -> taskUuid.equalsIgnoreCase(revTask.getTaskUid()))
                    		.orElse(false);
                })
                .findFirst()
                .map(Revision::getRequiredRevisionNumber).orElse(-1);
    }

    protected List<RevisionDiffItemDTO> getRevisionsDiff(final Integer id, final String taskUuid) {
        // sorted revision number desc
        List<? extends Revision<Integer, ?>> revisions = this.repository.findRevisions(id)
        		.stream()
	            .sorted((o1, o2) -> Integer.compare(o2.getRequiredRevisionNumber(), o1.getRequiredRevisionNumber()))
	            .collect(Collectors.toList());

        // find the 2 revisions: the latest one linked to the task
        Integer latestTaskRevision = revisions.stream()
            .filter(revision -> {
                LinkedToTask linkedToTask = (LinkedToTask) revision.getEntity();
                return Optional.ofNullable(linkedToTask)
                		.map(revTask -> taskUuid.equalsIgnoreCase(revTask.getTaskUid()))
                		.orElse(false);
            })
            .findFirst()
            .map(Revision::getRequiredRevisionNumber).orElse(-1);

        // and the one before the task creation
        if (latestTaskRevision > -1) {
            Integer revisionBeforeTask = revisions.stream()
                .filter(revision -> {
                    LinkedToTask linkedToTask = (LinkedToTask) revision.getEntity();
                    return revision.getRequiredRevisionNumber() < latestTaskRevision && !taskUuid.equalsIgnoreCase(linkedToTask.getTaskUid());
                })
                .findFirst()
                .map(Revision::getRequiredRevisionNumber).orElse(-1);

            if (revisionBeforeTask > -1) {
                return this.getRevisionsDiff(id, Arrays.asList(revisionBeforeTask, latestTaskRevision));
            }
        }

        return Collections.emptyList();
    }
}
