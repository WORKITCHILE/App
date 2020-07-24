package com.app.workit.view.ui.common.evaluation;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.RatingReview;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.EvaluationRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

public class EvaluationViewModel extends BaseViewModel {

    private EvaluationRepository evaluationRepository;
    private MutableLiveData<NetworkResponseList<RatingReview>> ratingsLiveData = new MutableLiveData<>();

    public EvaluationViewModel(EvaluationRepository evaluationRepository, Application application) {
        super(application);
        this.evaluationRepository = evaluationRepository;
    }

    public MutableLiveData<NetworkResponseList<RatingReview>> getRatingsLiveData() {
        return ratingsLiveData;
    }


    public void getRatings() {
        ratingsLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(evaluationRepository.getRatings()
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<RatingReview>>() {
                    @Override
                    public void accept(StandardResponseList<RatingReview> ratingReviewStandardResponseList) throws Exception {
                        ratingsLiveData.postValue(NetworkResponseList.success(ratingReviewStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        ratingsLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));
    }
}
