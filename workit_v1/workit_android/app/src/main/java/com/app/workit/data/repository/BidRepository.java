package com.app.workit.data.repository;

import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.Bid;
import com.app.workit.data.model.Job;
import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.APIService;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.network.StandardResponseList;
import io.reactivex.Observable;

import javax.inject.Inject;
import java.util.HashMap;

public class BidRepository {
    private final UserInfo userInfo;
    private APIService apiService;

    @Inject
    public BidRepository(DataManager dataManager, APIService apiService) {
        this.apiService = apiService;
        userInfo = dataManager.loadUser();
    }

    public Observable<StandardResponseList<String>> postBidWorker(HashMap<String, Object> params) {
        return apiService.postBidWorker(params);
    }

    public Observable<StandardResponseList<String>> cancelBidWorker(HashMap<String, Object> params) {
        return apiService.cancelBidWorker(params);
    }

    public Observable<StandardResponseList<Job>> getAllBids(String type) {
        return apiService.getAllBids(userInfo.getUserId(), type);
    }

    public Observable<StandardResponse<Bid>> getSingleBidWorker(String bidID, String jobID) {
        return apiService.getSingleBidWorker(bidID, jobID);
    }


    public Observable<StandardResponseList<String>> acceptBidOwner(HashMap<String, Object> params) {
        return apiService.ownerBidAction(params);
    }


}
