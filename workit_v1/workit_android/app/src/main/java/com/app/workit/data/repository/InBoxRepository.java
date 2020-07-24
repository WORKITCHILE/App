package com.app.workit.data.repository;

import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.Chat;
import com.app.workit.data.model.InBox;
import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.APIService;
import com.app.workit.data.network.StandardResponseList;
import io.reactivex.Observable;

import javax.inject.Inject;

public class InBoxRepository {

    private final UserInfo userinfo;
    private APIService apiService;

    @Inject
    public InBoxRepository(DataManager dataManager, APIService apiService) {
        this.apiService = apiService;
        this.userinfo = dataManager.loadUser();
    }

    public Observable<StandardResponseList<String>> sendMessage(Chat chat) {
        return apiService.sendMessage(chat);
    }

    public Observable<StandardResponseList<InBox>> getInboxMessages() {
        return apiService.getInboxMessages(userinfo.getUserId());
    }


}
