package com.bdl.epbs_fund_api.services.impl;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.history.Revision;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.bdl.epbs_fund_api.mappings.RelRelatedEntityLegalPersonMapper;
import com.bdl.epbs_fund_api.model.RelRelatedEntityLegalPersonDTO;
import com.bdl.epbs_fund_api.model.relations.RelRelatedEntityLegalPerson;
import com.bdl.epbs_fund_api.repositories.RelRelatedEntityLegalPersonRepository;
import com.bdl.epbs_fund_api.services.audit.EntityLinkedToTaskAuditService;
import com.bdl.epbs_fund_api.services.audit.RelRelatedEntityAuditDTO;
import com.bdl.epbs_fund_api.services.audit.RevisionDTO;
import com.bdl.utils.exceptions.ResourceNotFoundException;

@Service
public class RelRelatedEntityLegalPersonService extends EntityLinkedToTaskAuditService<RelRelatedEntityLegalPersonRepository, RelRelatedEntityLegalPerson, RelRelatedEntityAuditDTO> {

  private final RelRelatedEntityLegalPersonMapper relRelatedEntityLegalPersonMapper;
  private final RelRelatedEntityLegalPersonRepository relRelatedEntityLegalPersonRepository;

  public RelRelatedEntityLegalPersonService(
      RelRelatedEntityLegalPersonMapper relRelatedEntityLegalPersonMapper,
      RelRelatedEntityLegalPersonRepository relRelatedEntityLegalPersonRepository) {
    super(relRelatedEntityLegalPersonRepository);
    this.relRelatedEntityLegalPersonMapper = relRelatedEntityLegalPersonMapper;
    this.relRelatedEntityLegalPersonRepository = relRelatedEntityLegalPersonRepository;
  }

  public List<RelRelatedEntityLegalPersonDTO> getRelRelatedEntitiesLegalPerson(Integer lpSourceId) {
    return relRelatedEntityLegalPersonRepository.findByLegalPersonSourceId(lpSourceId).stream()
        .map(relRelatedEntityLegalPersonMapper::toDTO)
        .toList();
  }

  public RelRelatedEntityLegalPersonDTO getRelRelatedEntitiesLegalPersonById(Integer id) {
    return relRelatedEntityLegalPersonRepository
        .findById(id)
        .map(relRelatedEntityLegalPersonMapper::toDTO)
        .orElseThrow(() -> new ResourceNotFoundException("Related Entity " + id + " not found"));
  }

  public RelRelatedEntityLegalPersonDTO createRelRelatedEntityLegalPerson(
      RelRelatedEntityLegalPersonDTO relRelatedEntityLegalPersonDTO) {
    return Optional.of(relRelatedEntityLegalPersonDTO)
        .map(relRelatedEntityLegalPersonMapper::toEntity)
        .map(relRelatedEntityLegalPersonRepository::save)
        .map(relRelatedEntityLegalPersonMapper::toDTO)
        .orElse(null);
  }

  public RelRelatedEntityLegalPersonDTO updateRelRelatedEntityLegalPerson(
      Integer id, RelRelatedEntityLegalPersonDTO relRelatedEntityLegalPersonDTO) {
    return relRelatedEntityLegalPersonRepository
        .findById(id)
        .map(
            entity ->
                relRelatedEntityLegalPersonMapper.toEntity(entity, relRelatedEntityLegalPersonDTO))
        .map(relRelatedEntityLegalPersonRepository::save)
        .map(relRelatedEntityLegalPersonMapper::toDTO)
        .orElseThrow(
            () ->
                new ResourceNotFoundException(
                    "RelRelatedEntityLegalPerson with id " + id + "not found"));
  }

  @Transactional
  public RelRelatedEntityLegalPersonDTO updateRelRelatedEntityLegalPersonLinkTask(
      Integer relRelatedEntityId, UUID taskUid) {
    relRelatedEntityLegalPersonRepository.linkTask(relRelatedEntityId, taskUid.toString());
    return relRelatedEntityLegalPersonMapper.toDTO(
        relRelatedEntityLegalPersonRepository.findById(relRelatedEntityId).orElse(null));
  }

  public void deleteRelRelatedEntityLegalPersonById(Integer id) {
    relRelatedEntityLegalPersonRepository.deleteById(id);
  }

  public void deleteRelRelatedEntityLegalPersonAlreadyInAvaloq(Integer id) {
    List<Integer> relIdsToDelete =
        relRelatedEntityLegalPersonRepository.findByLegalPersonSourceId(id).stream()
            .filter(rel -> rel.getTaskUid() == null && rel.getIsAvaloq())
            .map(RelRelatedEntityLegalPerson::getId)
            .toList();

    relRelatedEntityLegalPersonRepository.deleteAllById(relIdsToDelete);
  }

  @Override
  protected RevisionDTO<RelRelatedEntityAuditDTO> getRevisionDtoInstance() {
    return null;
  }

  @Override
  protected void mapChild(
      RevisionDTO<RelRelatedEntityAuditDTO> revisionDto,
      Revision<Integer, RelRelatedEntityLegalPerson> revision) {
    throw new UnsupportedOperationException();
  }
}
