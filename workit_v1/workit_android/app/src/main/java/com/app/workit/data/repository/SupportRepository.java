package com.app.workit.data.repository;

import com.app.workit.data.network.APIService;
import com.app.workit.data.network.StandardResponseList;
import io.reactivex.Observable;

import javax.inject.Inject;
import java.util.HashMap;

public class SupportRepository {
    private APIService apiService;

    @Inject
    public SupportRepository(APIService apiService) {
        this.apiService = apiService;
    }

    public Observable<StandardResponseList<String>> querySupport(HashMap<String, Object> params) {
        return apiService.querySupport(params);
    }
}
