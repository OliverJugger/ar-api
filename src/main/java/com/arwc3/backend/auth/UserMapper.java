package com.arwc3.backend.auth;

import com.arwc3.backend.generated.model.CurrentUser;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface UserMapper {

    CurrentUser toCurrentUser(AppUser appUser);
}
