package com.app.workit.view.ui.common.runningjob;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.Job;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.JobRepository;
import com.app.workit.mvvm.BaseViewModel;
import com.app.workit.util.AppConstants;
import io.reactivex.functions.Consumer;

public class JobViewModel extends BaseViewModel {

    private JobRepository jobRepository;
    private MutableLiveData<NetworkResponseList<Job>> jobsLiveData = new MutableLiveData<>();

    public JobViewModel(JobRepository jobRepository, Application application) {
        super(application);
        this.jobRepository = jobRepository;
    }

    public MutableLiveData<NetworkResponseList<Job>> getJobsLiveData() {
        return jobsLiveData;
    }

    public void getJobs(String type) {
        jobsLiveData.postValue(NetworkResponseList.loading());
        if (type == AppConstants.USER_TYPE.HIRE) {
            compositeDisposable.add(jobRepository.getRunningJobsOwner()
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
        } else {
            compositeDisposable.add(jobRepository.getRunningJobsVendor()
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
}
