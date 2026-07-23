package com.bdl.epbs_fund_api.services.audit;

import com.bdl.epbs_fund_api.model.entities.CommonRevision;
import com.bdl.utils.exceptions.ResourceNotFoundException;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.SneakyThrows;
import lombok.extern.log4j.Log4j2;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.history.Revision;
import org.springframework.data.history.Revisions;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.history.RevisionRepository;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import static com.bdl.epbs_fund_api.utils.DateUtils.toOffsetDateTime;

@Log4j2
@Service
public abstract class EntityAuditService<R extends JpaRepository<E, Integer> & RevisionRepository<E, Integer, Integer>, E, D> {

    public R repository;

    @Autowired
    public EntityAuditService(R repository) {
        this.repository = repository;
    }
    
    protected E getEntityFromRevision(final Integer entityId, final Integer revisionId) {
    	return this.repository.findRevision(entityId, revisionId)
    			.map(Revision::getEntity)
    			 .orElseThrow(() -> new ResourceNotFoundException("Entity " + entityId + " or revision " + revisionId + " not found"));
    }

    protected List<RevisionDTO<D>> getRevisionsByUUid(final Integer id) {
        log.info("Get revisions for id: " + id);
        final Revisions<Integer, ?> revisions = this.repository.findRevisions(id);
        return revisions.getContent().stream()
                .map(rev -> buildRevision((Revision<Integer, E>) rev)).collect(Collectors.toList());
    }

    protected List<RevisionDiffItemDTO> getRevisionsDiff(final Integer entityId, final List<Integer> revisionIds) {
        log.info("Get revisions diff for id: " + entityId + " and revisions: " + revisionIds.toString());
        final List<Revision<Integer, ?>> revisions = revisionIds.stream()
        		.map(revisionId -> this.repository.findRevision(entityId, revisionId))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toList());

        final List<RevisionDTO<D>> revisionDTOS = revisions.stream()
                .map(rev -> buildRevision((Revision<Integer, E>) rev)).collect(Collectors.toList());

        if (!CollectionUtils.isEmpty(revisionIds)) {
            final List<Field> fields = getFields(getRevisionDtoInstance().getEntity());
            return fields.stream().map(fieldName -> this.getRevisionValues(fieldName, revisionDTOS)).collect(Collectors.toList());
        }

        return Collections.emptyList();
    }

    private RevisionDiffItemDTO getRevisionValues(final Field field, final List<RevisionDTO<D>> revisions) {
        final RevisionDiffItemDTO revisionDiffItem = new RevisionDiffItemDTO();
        final String fieldName = field.getAnnotation(JsonProperty.class).value();
        revisionDiffItem.setFieldName(fieldName == null ? field.getName() : fieldName);
        revisionDiffItem.setRevisionValues(revisions.stream()
                .map(revision -> buildRevisionValue(field, revision))
                .collect(Collectors.toList()));
        return revisionDiffItem;
    }

    @SneakyThrows
    private RevisionValueDTO buildRevisionValue(final Field field, final RevisionDTO<D> revision) {
        final RevisionValueDTO revisionValue = new RevisionValueDTO();
        revisionValue.setRevisionId(revision.getMetadata().getNumber());
        revisionValue.setDate(revision.getMetadata().getDate());
        field.setAccessible(true);
        revisionValue.setValue(field.get(revision.getEntity()));
        return revisionValue;
    }

    private List<Field> getFields(final Object entity) {
        List<Field> fields = new ArrayList<>();
        Class clazz = entity.getClass();
        while (clazz != Object.class) {
            fields.addAll(Arrays.asList(clazz.getDeclaredFields()));
            clazz = clazz.getSuperclass();
        }
        return fields;
    }

    private RevisionDTO<D> buildRevision(final Revision<Integer, E> revision) {
        final RevisionDTO<D> dto = getRevisionDtoInstance();
        final RevisionMetadataDTO metadataDTO = new RevisionMetadataDTO();
        metadataDTO.setUsername(((CommonRevision) revision.getMetadata().getDelegate()).getUserName());
        revision.getRevisionNumber().ifPresent(metadataDTO::setNumber);
        revision.getMetadata().getRevisionInstant()
                .ifPresent(instant -> metadataDTO.setDate(toOffsetDateTime(instant)));
        dto.setMetadata(metadataDTO);
        mapChild(dto, revision);
        return dto;
    }

    protected abstract RevisionDTO<D> getRevisionDtoInstance();

    protected abstract void mapChild(RevisionDTO<D> revisionDto, Revision<Integer, E> revision);

}
