package com.app.workit.view.ui.common.login;

import android.app.Application;

import androidx.lifecycle.MutableLiveData;

import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.repository.LogInRepository;
import com.app.workit.mvvm.BaseViewModel;

import javax.inject.Inject;

import io.reactivex.functions.Consumer;

public class LogInViewModel extends BaseViewModel {

    private final LogInRepository loginRepository;
    private MutableLiveData<NetworkResponse<UserInfo>> responseLiveData = new MutableLiveData<>();

    @Inject
    public LogInViewModel(LogInRepository loginRepository, Application application) {
        super(application);
        this.loginRepository = loginRepository;
    }

    public MutableLiveData<NetworkResponse<UserInfo>> getResponseLiveData() {
        return responseLiveData;
    }

    public void getProfile(String idToken) {
        responseLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(loginRepository.getProfile(idToken)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponse<UserInfo>>() {
                    @Override
                    public void accept(StandardResponse<UserInfo> userInfoStandardResponse) throws Exception {
                        responseLiveData.postValue(NetworkResponse.success(userInfoStandardResponse.getResponse(), userInfoStandardResponse.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        responseLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));

    }


}
