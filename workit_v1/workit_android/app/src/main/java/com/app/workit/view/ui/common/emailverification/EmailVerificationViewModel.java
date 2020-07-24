package com.app.workit.view.ui.common.emailverification;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;

import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.ProfileRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

import java.util.HashMap;

public class EmailVerificationViewModel extends BaseViewModel {

    private final ProfileRepository profileRepository;
    private MutableLiveData<NetworkResponse<String>> verifyEmailLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> sendOtpLiveData = new MutableLiveData<>();

    public EmailVerificationViewModel(ProfileRepository profileRepository, Application application) {
        super(application);
        this.profileRepository = profileRepository;
    }

    public MutableLiveData<NetworkResponse<String>> getVerifyEmailLiveData() {
        return verifyEmailLiveData;
    }

    public MutableLiveData<NetworkResponse<String>> getSendOtpLiveData() {
        return sendOtpLiveData;
    }


    public void sendVerificationOTP(HashMap<String, Object> params) {
        sendOtpLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(profileRepository.sendVerificationEmail(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        sendOtpLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        sendOtpLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }


    public void verifyEmail(HashMap<String, Object> params) {
        verifyEmailLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(profileRepository.verifyEmail(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        verifyEmailLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        verifyEmailLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }
}
