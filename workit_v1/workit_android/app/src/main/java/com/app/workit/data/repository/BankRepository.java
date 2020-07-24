package com.app.workit.data.repository;

import com.app.workit.data.network.APIService;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.di.scope.AppScope;

import java.util.HashMap;

import javax.inject.Inject;

import io.reactivex.Observable;

@AppScope
public class BankRepository {

    private APIService apiService;

    @Inject
    public BankRepository(APIService apiService) {
        this.apiService = apiService;
    }


    public Observable<StandardResponseList<String>> addBank(HashMap<String, Object> params) {
        return apiService.addBank(params);
    }

}
