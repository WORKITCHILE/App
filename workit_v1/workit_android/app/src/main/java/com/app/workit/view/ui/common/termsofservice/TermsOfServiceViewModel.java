package com.app.workit.view.ui.common.termsofservice;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.TermsAndCondition;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.repository.ProfileRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

public class TermsOfServiceViewModel extends BaseViewModel {

    private ProfileRepository profileRepository;
    private MutableLiveData<NetworkResponse<TermsAndCondition>> termsAndConditionLiveData = new MutableLiveData<>();

    public TermsOfServiceViewModel(ProfileRepository profileRepository, Application application) {
        super(application);
        this.profileRepository = profileRepository;
    }

    public MutableLiveData<NetworkResponse<TermsAndCondition>> getTermsAndConditionLiveData() {
        return termsAndConditionLiveData;
    }

    public void getTermsOfService() {
        termsAndConditionLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(profileRepository.getTnC()
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponse<TermsAndCondition>>() {
                    @Override
                    public void accept(StandardResponse<TermsAndCondition> termsAndConditionStandardResponse) throws Exception {
                        termsAndConditionLiveData.postValue(NetworkResponse.success(termsAndConditionStandardResponse.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        termsAndConditionLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }
}
