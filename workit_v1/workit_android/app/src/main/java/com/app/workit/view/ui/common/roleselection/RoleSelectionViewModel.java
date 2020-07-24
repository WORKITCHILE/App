package com.app.workit.view.ui.common.roleselection;

import android.app.Application;

import androidx.lifecycle.MutableLiveData;

import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.ProfileRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

import javax.inject.Inject;
import java.util.HashMap;

public class RoleSelectionViewModel extends BaseViewModel {

    private final ProfileRepository profileRepository;
    private MutableLiveData<NetworkResponse<String>> changeUserRoleLiveData = new MutableLiveData<>();

    @Inject
    public RoleSelectionViewModel(ProfileRepository profileRepository, Application application) {
        super(application);
        this.profileRepository = profileRepository;
    }

    public MutableLiveData<NetworkResponse<String>> getChangeUserRoleLiveData() {
        return changeUserRoleLiveData;
    }


    public void changeUserRole(HashMap<String, Object> params) {
        changeUserRoleLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(profileRepository.changeUserRole(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        changeUserRoleLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        changeUserRoleLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }

}
