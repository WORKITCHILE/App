package com.app.workit.data.repository;

import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.TermsAndCondition;
import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.APIService;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.network.StandardResponseList;

import java.util.HashMap;

import javax.inject.Inject;

import io.reactivex.Observable;

public class ProfileRepository {

    private final DataManager dataManager;
    private APIService apiService;

    @Inject
    public ProfileRepository(DataManager dataManager, APIService apiService) {
        this.apiService = apiService;
        this.dataManager = dataManager;
    }

    public Observable<StandardResponse<UserInfo>> getProfile() {
        return apiService.getProfile(dataManager.getToken());
    }


    public Observable<StandardResponseList<String>> saveProfile(HashMap<String, Object> params) {
        return apiService.editProfile(params);
    }

    public Observable<StandardResponseList<String>> changeUserRole(HashMap<String, Object> params) {
        return apiService.changeUserRole(params);
    }

    public Observable<StandardResponseList<String>> sendVerificationEmail(HashMap<String, Object> params) {
        return apiService.sendVerificationMail(params);
    }

    public Observable<StandardResponseList<String>> verifyEmail(HashMap<String, Object> params) {
        return apiService.verifyEmail(params);
    }

    public Observable<StandardResponse<TermsAndCondition>> getTnC() {
        return apiService.getTermsAndCondition(dataManager.getToken());
    }

}
