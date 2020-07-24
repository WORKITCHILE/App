package com.app.workit.view.ui.hire;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.Job;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.repository.JobRepository;
import com.app.workit.mvvm.BaseViewModel;

import javax.inject.Inject;

public class HireViewModel extends BaseViewModel {

    private final JobRepository jobRepository;
    private MutableLiveData<NetworkResponseList<Job>> postedJobsLiveData = new MutableLiveData<>();

    @Inject
    public HireViewModel(JobRepository jobRepository, Application application) {
        super(application);
        this.jobRepository = jobRepository;
    }


    public MutableLiveData<NetworkResponseList<Job>> getPostedJobsLiveData() {
        return postedJobsLiveData;
    }

    public void getPostedJobs() {
        postedJobsLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(jobRepository.getPostedJobs()
                .compose(applySchedulers())
                .subscribe(jobStandardResponseList -> postedJobsLiveData.postValue(NetworkResponseList.success(jobStandardResponseList.getResponse())),
                        throwable -> postedJobsLiveData.postValue(NetworkResponseList.error(parseError(throwable)))));
    }
}
