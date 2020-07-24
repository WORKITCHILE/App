package com.app.workit.view.ui.common.credits;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.Credit;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.CreditRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

import java.util.HashMap;

public class CreditsViewModel extends BaseViewModel {

    private CreditRepository creditRepository;
    private MutableLiveData<NetworkResponse<Credit>> creditsLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> addCreditLiveData = new MutableLiveData<>();

    public CreditsViewModel(CreditRepository creditRepository, Application application) {
        super(application);
        this.creditRepository = creditRepository;
    }


    public MutableLiveData<NetworkResponse<String>> getAddCreditLiveData() {
        return addCreditLiveData;
    }

    public MutableLiveData<NetworkResponse<Credit>> getCreditsLiveData() {
        return creditsLiveData;
    }

    public void addCredit(HashMap<String, Object> params) {
        addCreditLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(creditRepository.addCredit(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        addCreditLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        addCreditLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }

    public void getCredits() {
        creditsLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(creditRepository.getCredits()
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponse<Credit>>() {
                    @Override
                    public void accept(StandardResponse<Credit> creditStandardResponseList) throws Exception {
                        creditsLiveData.postValue(NetworkResponse.success(creditStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        creditsLiveData.postValue(NetworkResponse.error(parseError(throwable)));

                    }
                }));
    }
}
