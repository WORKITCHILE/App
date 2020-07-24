package com.app.workit.view.ui.common.evaluation.ratereview;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.EvaluationRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

import java.util.HashMap;

public class RateReviewModel extends BaseViewModel {

    private EvaluationRepository evaluationRepository;
    private MutableLiveData<NetworkResponse<String>> evaluateLiveData = new MutableLiveData<>();

    public RateReviewModel(EvaluationRepository evaluationRepository, Application application) {
        super(application);
        this.evaluationRepository = evaluationRepository;
    }

    public MutableLiveData<NetworkResponse<String>> getEvaluateLiveData() {
        return evaluateLiveData;
    }

    public void rateUser(HashMap<String, Object> params) {
        evaluateLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(evaluationRepository.rateUser(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        evaluateLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        evaluateLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }
}
