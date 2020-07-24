package com.app.workit.data.repository;

import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.RatingReview;
import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.APIService;
import com.app.workit.data.network.StandardResponseList;
import io.reactivex.Observable;

import javax.inject.Inject;
import java.util.HashMap;

public class EvaluationRepository {
    private final UserInfo userInfo;
    private APIService apiService;

    @Inject
    public EvaluationRepository(DataManager dataManager, APIService apiService) {
        this.apiService = apiService;
        this.userInfo = dataManager.loadUser();
    }


    public Observable<StandardResponseList<String>> rateUser(HashMap<String, Object> params) {
        return apiService.rateUser(params);
    }

    public Observable<StandardResponseList<RatingReview>> getRatings() {
        return apiService.getRatings(userInfo.getUserId());
    }

    public Observable<StandardResponseList<RatingReview>> getRatings(String vendorID) {
        return apiService.getRatings(vendorID);
    }
}
