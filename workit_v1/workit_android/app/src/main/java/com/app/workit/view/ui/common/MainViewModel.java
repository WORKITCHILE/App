package com.app.workit.view.ui.common;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.LogInRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

public class MainViewModel extends BaseViewModel {

    private LogInRepository logInRepository;
    private MutableLiveData<NetworkResponse<UserInfo>> loginLiveData = new MutableLiveData<>();

    public MainViewModel(LogInRepository logInRepository, Application application) {
        super(application);
        this.logInRepository = logInRepository;
    }

    public MutableLiveData<NetworkResponse<UserInfo>> getLoginLiveData() {
        return loginLiveData;
    }

    public void socialLogin(int type, String token) {
        loginLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(logInRepository.socialLogin(type, token)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponse<UserInfo>>() {
                    @Override
                    public void accept(StandardResponse<UserInfo> stringStandardResponseList) throws Exception {
                        loginLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        loginLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }
}
