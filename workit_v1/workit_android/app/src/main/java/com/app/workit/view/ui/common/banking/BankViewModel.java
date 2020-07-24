package com.app.workit.view.ui.common.banking;

import android.app.Application;

import androidx.lifecycle.MutableLiveData;

import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.BankRepository;
import com.app.workit.mvvm.BaseViewModel;

import java.util.HashMap;

import javax.inject.Inject;

import io.reactivex.functions.Consumer;

public class BankViewModel extends BaseViewModel {

    private final BankRepository bankRepository;
    private MutableLiveData<NetworkResponse<String>> addBankLiveData = new MutableLiveData<>();

    @Inject
    public BankViewModel(BankRepository bankRepository, Application application) {
        super(application);
        this.bankRepository = bankRepository;
    }

    public MutableLiveData<NetworkResponse<String>> getAddBankLiveData() {
        return addBankLiveData;
    }

    public void addBank(HashMap<String, Object> params) {
        addBankLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(bankRepository.addBank(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        addBankLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        addBankLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }
}
