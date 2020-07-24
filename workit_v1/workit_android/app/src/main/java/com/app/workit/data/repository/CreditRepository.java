package com.app.workit.data.repository;

import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.Credit;
import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.APIService;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.model.Bank;
import io.reactivex.Observable;

import javax.inject.Inject;
import java.util.HashMap;

public class CreditRepository {
    private final UserInfo userInfo;
    private APIService apiService;

    @Inject
    public CreditRepository(DataManager dataManager, APIService apiService) {
        this.apiService = apiService;
        userInfo = dataManager.loadUser();
    }

    public Observable<StandardResponse<Credit>> getCredits() {
        return apiService.getCredits(userInfo.getUserId());
    }

    public Observable<StandardResponseList<Bank>> getBankDetails() {
        return apiService.getBankDetails(userInfo.getUserId());
    }

    public Observable<StandardResponseList<String>> addCredit(HashMap<String, Object> params) {
        return apiService.addCredit(params);
    }
}
