package com.app.workit.view.ui.common.notification;

import android.app.Application;

import androidx.lifecycle.MutableLiveData;

import com.app.workit.data.model.Notification;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.NotificationRepository;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.mvvm.BaseViewModel;

import io.reactivex.functions.Consumer;

public class NotificationViewModel extends BaseViewModel {

    private NotificationRepository notificationRepository;
    private MutableLiveData<NetworkResponseList<Notification>> notificationsLiveData = new MutableLiveData<>();

    public NotificationViewModel(NotificationRepository notificationRepository, Application application) {
        super(application);
        this.notificationRepository = notificationRepository;
    }

    public MutableLiveData<NetworkResponseList<Notification>> getNotificationsLiveData() {
        return notificationsLiveData;
    }

    public void getNotifications() {
        notificationsLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(notificationRepository.getNotifications()
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<Notification>>() {
                    @Override
                    public void accept(StandardResponseList<Notification> notificationStandardResponseList) throws Exception {
                        notificationsLiveData.postValue(NetworkResponseList.success(notificationStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        notificationsLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));
    }
}
