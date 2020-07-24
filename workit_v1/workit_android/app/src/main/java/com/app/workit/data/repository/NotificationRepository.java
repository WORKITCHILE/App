package com.app.workit.data.repository;

import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.Notification;
import com.app.workit.data.network.APIService;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.network.StandardResponseList;

import javax.inject.Inject;

import io.reactivex.Observable;

public class NotificationRepository {

    private final DataManager dataManager;
    private APIService apiService;

    @Inject
    public NotificationRepository(DataManager dataManager, APIService apiService) {
        this.apiService = apiService;
        this.dataManager = dataManager;
    }

    public Observable<StandardResponseList<Notification>> getNotifications() {
        return apiService.getNotifications(dataManager.getToken());
    }
}
