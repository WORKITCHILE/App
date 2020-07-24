package com.app.workit.view.ui.hire.workschedule;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;

import com.app.workit.data.model.ScheduleResponse;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.JobRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

public class WorkScheduleViewModel extends BaseViewModel {

    private JobRepository jobRepository;
    private MutableLiveData<NetworkResponseList<ScheduleResponse>> jobsLiveData = new MutableLiveData<>();

    public WorkScheduleViewModel(JobRepository jobRepository, Application application) {
        super(application);
        this.jobRepository = jobRepository;
    }

    public MutableLiveData<NetworkResponseList<ScheduleResponse>> getJobsLiveData() {
        return jobsLiveData;
    }

    public void getCalendarJobs(long timeStamp) {
        jobsLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(jobRepository.getCalendarJobs(timeStamp)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<ScheduleResponse>>() {
                    @Override
                    public void accept(StandardResponseList<ScheduleResponse> jobStandardResponseList) throws Exception {
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
