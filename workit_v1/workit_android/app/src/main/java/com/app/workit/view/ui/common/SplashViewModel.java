package com.app.workit.view.ui.common;

import android.app.Application;

import androidx.lifecycle.MutableLiveData;

import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.repository.LogInRepository;
import com.app.workit.mvvm.BaseViewModel;

import javax.inject.Inject;

import io.reactivex.functions.Consumer;

public class SplashViewModel extends BaseViewModel {

    private final LogInRepository logInRepository;
    private MutableLiveData<NetworkResponse<UserInfo>> profileLiveData = new MutableLiveData<>();

    @Inject
    public SplashViewModel(LogInRepository logInRepository, Application application) {
        super(application);
        this.logInRepository = logInRepository;
    }

    public MutableLiveData<NetworkResponse<UserInfo>> getProfileLiveData() {
        return profileLiveData;
    }

    public void getProfile(String token) {
        profileLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(logInRepository.getProfile(token)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponse<UserInfo>>() {
                    @Override
                    public void accept(StandardResponse<UserInfo> userInfoStandardResponse) throws Exception {
                        profileLiveData.postValue(NetworkResponse.success(userInfoStandardResponse.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        profileLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }
}
