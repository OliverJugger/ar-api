package com.bdl.epbs_fund_api.utils;

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.List;

public class ReflectionOverrideUtils extends org.springframework.util.ReflectionUtils {
	
	public static final List<Field> getConstantFieldsFor(Class<?> clazz) {
		
		List<Field> fields = Arrays.asList(clazz.getDeclaredFields());
		return fields.stream()
			.filter(f->Modifier.isPublic(f.getModifiers()))
			.filter(f->Modifier.isFinal(f.getModifiers()))
			.filter(f->Modifier.isStatic(f.getModifiers()))
			.toList();
	}

	private ReflectionOverrideUtils() {}

}
