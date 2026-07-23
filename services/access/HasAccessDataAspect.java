package com.bdl.epbs_fund_api.services.access;

import java.lang.reflect.Method;
import java.util.List;
import java.util.Optional;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.constants.Constants;
import com.bdl.epbs_fund_api.model.entities.LinkedToDataAccess;
import com.bdl.epbs_fund_api.services.TechnicalAccessService;
import com.bdl.epbs_fund_api.services.access.impl.DataProfileService;
import com.bdl.security.utils.SecurityUtils;

import lombok.RequiredArgsConstructor;

@Aspect
@RequiredArgsConstructor
@Component
public class HasAccessDataAspect {

    private final TechnicalAccessService technicalAccessService;
	
	private final DataProfileService dataProfileService;

    @AfterReturning(pointcut="@annotation(HasAccessData)", returning= "result")
    public void canAccessData(JoinPoint joinPoint, Object result) {
    	final Optional<LinkedToDataAccess> resultToOptional = (Optional<LinkedToDataAccess>) result;
    	resultToOptional.ifPresent( object -> {
	        final HasAccessData hasAccessData = this.getHasAccessData(joinPoint);
	        final Integer id = object.getId();
	
	        if (!canAccess(id, hasAccessData.elemTypeIntlId())) {
	            throw new AccessDeniedException(new StringBuilder()
	    				.append("User '")
	        			.append(SecurityUtils.getCurrentPrincipal())
	        			.append("' has no technical access rights for element type '")
	        			.append(hasAccessData.elemTypeIntlId())
	        			.append("' with id : '")
	        			.append(id)
	        			.append("'")
	        			.toString());         		
	        }
    	});
    }
    
    private HasAccessData getHasAccessData(JoinPoint joinPoint) {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        return method.getAnnotation(HasAccessData.class);
    }
	
	private boolean canAccess(Integer elemId, String elemType) {
		List<String> currentDataProfiles = technicalAccessService.getUserProfilesIntId();
		currentDataProfiles.add(Constants.INTL_ID_EPBS_PROFILE_NA);
		List<Integer> accessProfilElemDatas = dataProfileService.getRelAccessProfileElemEpbsFromDataProfile(currentDataProfiles, elemType);
		return accessProfilElemDatas.contains(elemId);
	}
}

