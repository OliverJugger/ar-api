package com.bdl.epbs_fund_api.utils;

import java.util.List;
import java.util.Optional;

import com.bdl.epbs_fund_api.model.CheckDataObjectTypeDTO;
import com.bdl.epbs_fund_api.model.EpbsMinimalObjectDTO;
import com.bdl.epbs_fund_api.model.FundDTO;
import com.bdl.epbs_fund_api.model.LegalPersonDTO;
import com.bdl.epbs_fund_api.model.LegalPersonItemDTO;
import com.bdl.epbs_fund_api.model.NaturalPersonDTO;
import com.bdl.epbs_fund_api.model.RelRelatedEntityDTO;
import com.bdl.epbs_fund_api.model.RelRelatedIndividualDTO;
import com.bdl.epbs_fund_api.model.RelationUnprocessableErrorDTO;
import com.bdl.epbs_fund_api.model.SubFundDTO;
import com.bdl.epbs_fund_api.model.UCIEntityTypeEnumDTO;
import com.bdl.epbs_fund_api.model.UCIEntityWithNameDTO;
import com.bdl.epbs_fund_api.model.UnprocessableErrorObjectDTO;
import com.bdl.utils.exceptions.ResourceNotFoundException;

public class CheckDataUtils {

    private CheckDataUtils() {}

    public static Optional<UnprocessableErrorObjectDTO> makeUnprocessableErrorObjectDTO(RelRelatedEntityDTO re, List<String> errorCodes) {
        return errorCodes.isEmpty()
                ? Optional.empty()
                : Optional.of(new UnprocessableErrorObjectDTO()
                .minimalObject(buildMinimalRelatedEntityUciEntity(re))
                .relation(buildRelation(re))
                .errorCodes(errorCodes));
    }

    public static Optional<UnprocessableErrorObjectDTO> makeUnprocessableErrorObjectDTO(RelRelatedIndividualDTO ri, List<String> errorCodes) {
        return errorCodes.isEmpty()
                ? Optional.empty()
                : Optional.of(new UnprocessableErrorObjectDTO()
                    .minimalObject(buildMinimalRelatedIndividual(ri))
                    .relation(buildRelation(ri))
                    .errorCodes(errorCodes));
    }

    private static EpbsMinimalObjectDTO buildMinimalRelatedEntityUciEntity(RelRelatedEntityDTO relRelatedEntity) {
        return new EpbsMinimalObjectDTO()
                .id(relRelatedEntity.getId())
                .type(CheckDataObjectTypeDTO.RELATED_ENTITY.getValue());
    }

    private static EpbsMinimalObjectDTO buildMinimalRelatedIndividual(RelRelatedIndividualDTO relatedIndividual) {
        return new EpbsMinimalObjectDTO()
                .id(relatedIndividual.getId())
                .type(CheckDataObjectTypeDTO.RELATED_INDIVIDUAL.getValue());
    }

    private static RelationUnprocessableErrorDTO buildRelation(RelRelatedEntityDTO relatedEntity) {
        return new RelationUnprocessableErrorDTO()
                .source(getEntityMinimalObjectFromRelatedEntity(relatedEntity.getRelUciLegalPerson().getLegalPerson()))
                .type(relatedEntity.getRelatedEntityType())
                .target(buildMinimalUciEntity(relatedEntity.getRelUciLegalPerson().getUciEntity()));
    }

    private static RelationUnprocessableErrorDTO buildRelation(RelRelatedIndividualDTO relatedIndividual) {
        return new RelationUnprocessableErrorDTO()
                .source(buildMinimalNaturalPerson(relatedIndividual.getNaturalPerson()))
                .type(relatedIndividual.getRelatedIndividualType())
                .target(getEntityMinimalObjectFromRelatedIndividual(relatedIndividual));
    }

    private static EpbsMinimalObjectDTO getEntityMinimalObjectFromRelatedEntity(LegalPersonItemDTO legalPerson) {
        return new EpbsMinimalObjectDTO()
                .id(legalPerson.getId())
                .objectName(legalPerson.getLegalName())
                .type(CheckDataObjectTypeDTO.LEGAL_PERSON.getValue());
    }

    private static EpbsMinimalObjectDTO getEntityMinimalObjectFromRelatedIndividual(RelRelatedIndividualDTO relatedIndividual) {
        return Optional.ofNullable(relatedIndividual.getLegalPerson())
                .map(CheckDataUtils::buildMinimalLegalPerson)
                .orElseGet(() -> Optional.ofNullable(relatedIndividual.getFund())
                        .map(CheckDataUtils::buildMinimalFund)
                        .orElseGet(() -> Optional.ofNullable(relatedIndividual.getSubFund())
                                .map(CheckDataUtils::buildMinimalSubFund)
                                .orElseThrow(() -> new ResourceNotFoundException("Could not find entity linked to natural person in related individual"))));
    }

    private static EpbsMinimalObjectDTO buildMinimalFund(FundDTO fundDTO) {
        return new EpbsMinimalObjectDTO()
                .id(fundDTO.getFundId())
                .objectName(fundDTO.getLegalName())
                .type(CheckDataObjectTypeDTO.FUND.getValue());
    }

    private static EpbsMinimalObjectDTO buildMinimalSubFund(SubFundDTO subFundDTO) {
        return new EpbsMinimalObjectDTO()
                .id(subFundDTO.getId())
                .objectName(subFundDTO.getLegalName())
                .type(CheckDataObjectTypeDTO.SUB_FUND.getValue());
    }

    private static EpbsMinimalObjectDTO buildMinimalUciEntity(UCIEntityWithNameDTO uciEntity) {
        Optional<CheckDataObjectTypeDTO> checkDataObjectType = fromUciEntityTypeIntlId(uciEntity.getType().getIntlId());
        return new EpbsMinimalObjectDTO()
                .id(uciEntity.getId())
                .objectName(uciEntity.getLegalNameOrName())
                .type(checkDataObjectType.map(CheckDataObjectTypeDTO::getValue).orElse(null));
    }

    private static Optional<CheckDataObjectTypeDTO> fromUciEntityTypeIntlId(String uciEntityTypeIntlId) {
        if (uciEntityTypeIntlId.equals(UCIEntityTypeEnumDTO.FUND.getValue())) {
            return Optional.of(CheckDataObjectTypeDTO.FUND);
        }
        if (uciEntityTypeIntlId.equals(UCIEntityTypeEnumDTO.SUBFUND.getValue())) {
            return Optional.of(CheckDataObjectTypeDTO.SUB_FUND);
        }
        return Optional.empty();
    }

    private static EpbsMinimalObjectDTO buildMinimalNaturalPerson(NaturalPersonDTO naturalPerson) {
        return new EpbsMinimalObjectDTO()
                .id(naturalPerson.getId())
                .objectName(naturalPerson.getFirstName() + " " + naturalPerson.getLastName())
                .type(CheckDataObjectTypeDTO.NATURAL_PERSON.getValue());
    }


    private static EpbsMinimalObjectDTO buildMinimalLegalPerson(LegalPersonDTO legalPerson) {
        return new EpbsMinimalObjectDTO()
                .id(legalPerson.getId())
                .objectName(legalPerson.getLegalName())
                .type(CheckDataObjectTypeDTO.LEGAL_PERSON.getValue());
    }
}
