package com.app.workit.view.ui.common.support;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.SupportRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

import java.util.HashMap;

public class SupportViewModel extends BaseViewModel {

    private SupportRepository supportRepository;
    private MutableLiveData<NetworkResponse<String>> supportLiveData = new MutableLiveData<>();

    public SupportViewModel(SupportRepository supportRepository, Application application) {
        super(application);
        this.supportRepository = supportRepository;
    }

    public MutableLiveData<NetworkResponse<String>> getSupportLiveData() {
        return supportLiveData;
    }

    public void support(HashMap<String, Object> params) {
        supportLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(supportRepository.querySupport(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        supportLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        supportLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }

}
