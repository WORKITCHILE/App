package com.app.workit.view.ui.hire.singlejob;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.Job;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.BidRepository;
import com.app.workit.data.repository.JobRepository;
import com.app.workit.mvvm.BaseViewModel;
import com.app.workit.util.AppConstants;
import io.reactivex.functions.Consumer;

import javax.inject.Inject;
import java.util.HashMap;

public class SingleJobViewModel extends BaseViewModel {

    private final JobRepository jobRepository;
    private final MutableLiveData<NetworkResponse<Job>> jobInfoLiveData = new MutableLiveData<>();
    private final BidRepository bidRepository;
    private MutableLiveData<NetworkResponse<String>> bidLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> jobCancelLiveData = new MutableLiveData<>();

    @Inject
    public SingleJobViewModel(JobRepository jobRepository, BidRepository bidRepository, Application application) {
        super(application);
        this.bidRepository = bidRepository;
        this.jobRepository = jobRepository;
    }

    public MutableLiveData<NetworkResponse<String>> getJobCancelLiveData() {
        return jobCancelLiveData;
    }

    public MutableLiveData<NetworkResponse<Job>> getJobInfoLiveData() {
        return jobInfoLiveData;
    }

    public MutableLiveData<NetworkResponse<String>> getBidLiveData() {
        return bidLiveData;
    }

    public void postBid(HashMap<String, Object> params) {
        bidLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(bidRepository.postBidWorker(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        bidLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));

                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        bidLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }

    public void cancelBid(HashMap<String, Object> params) {
        bidLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(bidRepository.cancelBidWorker(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        bidLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));

                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        bidLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }

    public void getJobInfo(String jobId, String type) {
        jobInfoLiveData.postValue(NetworkResponse.loading());
        if (type.equalsIgnoreCase(AppConstants.USER_TYPE.WORK)) {

            compositeDisposable.add(jobRepository.getSingleJobWorker(jobId)
                    .compose(applySchedulers())
                    .subscribe(jobStandardResponse -> jobInfoLiveData.postValue(NetworkResponse.success(jobStandardResponse.getResponse())),
                            throwable -> jobInfoLiveData.postValue(NetworkResponse.error(parseError(throwable)))));
        } else {
            compositeDisposable.add(jobRepository.getSingleJobOwner(jobId)
                    .compose(applySchedulers())
                    .subscribe(jobStandardResponse -> jobInfoLiveData.postValue(NetworkResponse.success(jobStandardResponse.getResponse())),
                            throwable -> jobInfoLiveData.postValue(NetworkResponse.error(parseError(throwable)))));
        }

    }

    public void cancelJob(HashMap<String, Object> params) {
        jobCancelLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(jobRepository.cancelJobOwner(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        jobCancelLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        jobCancelLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }
}
