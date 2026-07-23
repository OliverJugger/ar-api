package com.bdl.epbs_fund_api.services.access;

import java.lang.reflect.Method;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;

import com.bdl.epbs_fund_api.authentication.UserService;
import com.bdl.security.utils.SecurityUtils;
import com.bdl.utils.exceptions.ForbiddenException;

import lombok.RequiredArgsConstructor;

@Aspect
@RequiredArgsConstructor
@Component
public class HasAccessAspect {

    private final UserService userService;

    @Before("@annotation(HasAccess)")
    public void throwErrorIfNoAccessRightsOrProceed(JoinPoint joinPoint) {
        final String role = getRole(joinPoint);

        if (!userService.hasAccessRights(role)) {
            throw new ForbiddenException(String.format("User [%s] has no functional access rights for [%s]", SecurityUtils.getCurrentPrincipal(), role));
        }
    }

    private String getRole(JoinPoint joinPoint) {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        HasAccess annotation = method.getAnnotation(HasAccess.class);
        return annotation.value();
    }
}

