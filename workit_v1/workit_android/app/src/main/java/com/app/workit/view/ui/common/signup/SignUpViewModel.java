package com.app.workit.view.ui.common.signup;

import android.app.Application;
import android.net.Uri;

import androidx.lifecycle.MutableLiveData;

import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.SignUpRepository;
import com.app.workit.data.repository.UploadImageRepository;
import com.app.workit.mvvm.BaseViewModel;

import java.util.HashMap;

import javax.inject.Inject;

import io.reactivex.functions.Consumer;

public class SignUpViewModel extends BaseViewModel {

    private final UploadImageRepository uploadImageRepository;
    private SignUpRepository signUpRepository;
    private MutableLiveData<NetworkResponse<String>> mutableLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> uploadMutableLiveData = new MutableLiveData<>();

    @Inject
    public SignUpViewModel(SignUpRepository signUpRepository, UploadImageRepository uploadImageRepository
            , Application application) {
        super(application);
        this.signUpRepository = signUpRepository;
        this.uploadImageRepository = uploadImageRepository;
    }

    public MutableLiveData<NetworkResponse<String>> getMutableLiveData() {
        return mutableLiveData;
    }

    public MutableLiveData<NetworkResponse<String>> getUploadMutableLiveData() {
        return uploadMutableLiveData;
    }

    public void uploadProfilePicture(Uri fileURI, String childPath) {
        uploadImageRepository.uploadImage(fileURI, childPath);
        compositeDisposable.add(uploadImageRepository.getUploadSubject()
                .subscribe(new Consumer<NetworkResponse<String>>() {
                    @Override
                    public void accept(NetworkResponse<String> stringNetworkResponse) throws Exception {
                        uploadMutableLiveData.postValue(stringNetworkResponse);
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        uploadMutableLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }


    public void signUp(HashMap<String, Object> params) {
        mutableLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(signUpRepository.signUp(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> userInfoStandardResponse) throws Exception {
                        mutableLiveData.postValue(NetworkResponse.success(userInfoStandardResponse.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        mutableLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }
}
