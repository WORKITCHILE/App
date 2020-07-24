package com.app.workit.data.repository;

import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.Job;
import com.app.workit.data.model.ScheduleResponse;
import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.APIService;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.network.StandardResponseList;

import java.util.HashMap;
import java.util.List;

import javax.inject.Inject;

import io.reactivex.Observable;


public class JobRepository {

    private APIService apiService;
    private UserInfo userInfo;

    @Inject
    public JobRepository(DataManager dataManager, APIService apiService) {
        this.apiService = apiService;
        userInfo = dataManager.loadUser();
    }

    public Observable<StandardResponseList<String>> postJob(HashMap<String, Object> params) {
        return apiService.postJob(params);
    }

    public Observable<StandardResponseList<String>> repostJob(HashMap<String, Object> params) {
        return apiService.repostJob(params);
    }

    public Observable<StandardResponseList<String>> editJob(HashMap<String, Object> params) {
        return apiService.editJob(params);
    }

    public Observable<StandardResponseList<Job>> getPostedJobs() {
        return apiService.getPostedJobs(userInfo.getUserId());
    }

    public Observable<StandardResponseList<Job>> getRunningJobsOwner() {
        return apiService.getRunningJobOwner(userInfo.getUserId());
    }

    public Observable<StandardResponseList<Job>> getRunningJobsVendor() {
        return apiService.getRunningJobVendor(userInfo.getUserId());
    }

    public Observable<StandardResponseList<Job>> getHistoryJobsVendor() {
        return apiService.getHistoryJobsVendor(userInfo.getUserId());
    }

    public Observable<StandardResponseList<Job>> getHistoryJobsOwner() {
        return apiService.getHistoryJobsOwner(userInfo.getUserId());
    }

    public Observable<StandardResponseList<Job>> getWorkerPostedJobs(HashMap<String, Object> params) {
        return apiService.getWorkerPostedJobs(params);
    }

    public Observable<StandardResponseList<Job>> getWorkerPostedJobs(String userID, List<String> subCategoryID) {
        return apiService.getWorkerPostedJobs(userID, subCategoryID);
    }

    public Observable<StandardResponse<Job>> getSingleJobOwner(String jobId) {
        return apiService.getSingleJobOwner(userInfo.getUserId(), jobId);
    }

    public Observable<StandardResponse<Job>> getSingleJobWorker(String jobId) {
        return apiService.getSingleJobWorker(userInfo.getUserId(), jobId);
    }

    public Observable<StandardResponseList<ScheduleResponse>> getCalendarJobs(long timeStamp) {
        return apiService.getCalendarJobs(userInfo.getUserId(), timeStamp);
    }


    public Observable<StandardResponseList<String>> cancelJobOwner(HashMap<String, Object> params) {
        return apiService.cancelJobOwner(params);
    }

    public Observable<StandardResponseList<String>> cancelJobWorker(HashMap<String, Object> params) {
        return apiService.cancelJobWorker(params);
    }

    public Observable<StandardResponseList<String>> startJobWorker(HashMap<String, Object> params) {
        return apiService.startJobWorker(params);
    }

    public Observable<StandardResponseList<String>> startJobOwner(HashMap<String, Object> params) {
        return apiService.startJobOwner(params);
    }

    public Observable<StandardResponseList<String>> releaseJobPayment(HashMap<String, Object> params) {
        return apiService.releasePayment(params);
    }

}
