package com.app.workit.view.ui.work.search;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.Job;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.JobRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

import java.util.HashMap;
import java.util.List;

public class SearchViewModel extends BaseViewModel {

    private JobRepository jobRepository;
    private MutableLiveData<NetworkResponseList<Job>> jobsLiveData = new MutableLiveData<>();


    public SearchViewModel(JobRepository jobRepository, Application application) {
        super(application);
        this.jobRepository = jobRepository;
    }

    public MutableLiveData<NetworkResponseList<Job>> getJobsLiveData() {
        return jobsLiveData;
    }

    public void getPostedJobs(HashMap<String, Object> params) {
        jobsLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(jobRepository.getWorkerPostedJobs(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<Job>>() {
                    @Override
                    public void accept(StandardResponseList<Job> jobStandardResponseList) throws Exception {
                        jobsLiveData.postValue(NetworkResponseList.success(jobStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        jobsLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));
    }

    public void getPostedJobs(String userID, List<String> params) {
        jobsLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(jobRepository.getWorkerPostedJobs(userID, params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<Job>>() {
                    @Override
                    public void accept(StandardResponseList<Job> jobStandardResponseList) throws Exception {
                        jobsLiveData.postValue(NetworkResponseList.success(jobStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        jobsLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));
    }

}
