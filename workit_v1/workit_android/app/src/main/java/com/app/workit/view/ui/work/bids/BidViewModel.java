package com.app.workit.view.ui.work.bids;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;

import com.app.workit.data.model.Job;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.BidRepository;
import com.app.workit.mvvm.BaseViewModel;

import io.reactivex.functions.Consumer;

public class BidViewModel extends BaseViewModel {

    private MutableLiveData<NetworkResponseList<Job>> bidsLiveData = new MutableLiveData<>();
    private final BidRepository bidRepository;

    public BidViewModel(BidRepository bidRepository, Application application) {
        super(application);
        this.bidRepository = bidRepository;
    }

    public MutableLiveData<NetworkResponseList<Job>> getBidsLiveData() {
        return bidsLiveData;
    }

    public void getAllBids(String type) {
        bidsLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(bidRepository.getAllBids(type)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<Job>>() {
                    @Override
                    public void accept(StandardResponseList<Job> jobStandardResponseList) throws Exception {
                        bidsLiveData.postValue(NetworkResponseList.success(jobStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        bidsLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));
    }
}
