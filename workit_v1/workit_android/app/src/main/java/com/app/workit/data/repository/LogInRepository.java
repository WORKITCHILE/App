package com.app.workit.data.repository;

import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.APIService;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.di.scope.AppScope;

import javax.inject.Inject;

import io.reactivex.Observable;

@AppScope
public class LogInRepository {
    private APIService apiService;

    @Inject
    public LogInRepository(APIService apiService) {
        this.apiService = apiService;
    }

    public Observable<StandardResponse<UserInfo>> getProfile(String token) {
        return apiService.getProfile(token);
    }

    public Observable<StandardResponse<UserInfo>> socialLogin(int type, String token) {
        return apiService.socialLogin(type,token);
    }


}
