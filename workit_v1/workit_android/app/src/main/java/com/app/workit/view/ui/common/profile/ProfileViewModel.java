package com.app.workit.view.ui.common.profile;

import android.app.Application;

import android.net.Uri;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.ProfileRepository;
import com.app.workit.data.repository.UploadImageRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

import javax.inject.Inject;
import java.util.HashMap;

public class ProfileViewModel extends BaseViewModel {


    private final ProfileRepository profileRepository;
    private final UploadImageRepository uploadImageRepository;
    private MutableLiveData<NetworkResponse<String>> uploadMutableLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> updateProfileLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<UserInfo>> getProfileLiveData = new MutableLiveData<>();

    @Inject
    public ProfileViewModel(ProfileRepository profileRepository, UploadImageRepository uploadImageRepository, Application application) {
        super(application);
        this.uploadImageRepository = uploadImageRepository;
        this.profileRepository = profileRepository;
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


    public MutableLiveData<NetworkResponse<String>> getUploadMutableLiveData() {
        return uploadMutableLiveData;
    }

    public MutableLiveData<NetworkResponse<String>> getUpdateProfileLiveData() {
        return updateProfileLiveData;
    }

    public MutableLiveData<NetworkResponse<UserInfo>> getGetProfileLiveData() {
        return getProfileLiveData;
    }

    public void getProfile() {
        getProfileLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(profileRepository.getProfile()
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponse<UserInfo>>() {
                    @Override
                    public void accept(StandardResponse<UserInfo> userInfoStandardResponse) throws Exception {
                        getProfileLiveData.postValue(NetworkResponse.success(userInfoStandardResponse.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        getProfileLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }

    public void saveProfile(HashMap<String, Object> params) {
        updateProfileLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(profileRepository.saveProfile(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        updateProfileLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        updateProfileLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }

}
