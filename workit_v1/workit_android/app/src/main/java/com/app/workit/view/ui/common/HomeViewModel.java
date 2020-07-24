package com.app.workit.view.ui.common;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.ProfileRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

import java.util.HashMap;

public class HomeViewModel extends BaseViewModel {

    private final ProfileRepository profileRepository;
    private MutableLiveData<NetworkResponse<String>> userRoleLiveData = new MutableLiveData<>();
    public HomeViewModel(ProfileRepository profileRepository, Application application) {
        super(application);
        this.profileRepository = profileRepository;

    }

    public MutableLiveData<NetworkResponse<String>> getUserRoleLiveData() {
        return userRoleLiveData;
    }


    public void changeUserRole(HashMap<String, Object> params) {
        userRoleLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(profileRepository.changeUserRole(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        userRoleLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        userRoleLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }
}
