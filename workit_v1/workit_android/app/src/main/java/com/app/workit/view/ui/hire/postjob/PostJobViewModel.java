package com.app.workit.view.ui.hire.postjob;

import android.app.Application;
import android.net.Uri;

import androidx.lifecycle.MutableLiveData;

import com.app.workit.data.model.Category;
import com.app.workit.data.model.Job;
import com.app.workit.data.model.SubCategory;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.CategoryRepository;
import com.app.workit.data.repository.JobRepository;
import com.app.workit.data.repository.UploadImageRepository;
import com.app.workit.mvvm.BaseViewModel;

import java.util.HashMap;

import javax.inject.Inject;

import io.reactivex.functions.Consumer;

public class PostJobViewModel extends BaseViewModel {

    private final JobRepository jobRepository;
    private final CategoryRepository categoryRepository;
    private final UploadImageRepository uploadImageRepository;
    private MutableLiveData<NetworkResponseList<SubCategory>> subCategoryLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponseList<String>> postJobLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponseList<Category>> categoryLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> uploadMutableLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> repostJobLiveData = new MutableLiveData<>();
    private final MutableLiveData<NetworkResponse<Job>> jobInfoLiveData = new MutableLiveData<>();


    @Inject
    public PostJobViewModel(JobRepository jobRepository, CategoryRepository categoryRepository, UploadImageRepository uploadImageRepository, Application application) {
        super(application);
        this.jobRepository = jobRepository;
        this.categoryRepository = categoryRepository;
        this.uploadImageRepository = uploadImageRepository;
    }

    public MutableLiveData<NetworkResponseList<String>> getPostJobLiveData() {
        return postJobLiveData;
    }

    public MutableLiveData<NetworkResponse<String>> getUploadMutableLiveData() {
        return uploadMutableLiveData;
    }

    public MutableLiveData<NetworkResponseList<Category>> getCategoryLiveData() {
        return categoryLiveData;
    }

    public MutableLiveData<NetworkResponseList<SubCategory>> getSubCategoryLiveData() {
        return subCategoryLiveData;
    }

    public MutableLiveData<NetworkResponse<Job>> getJobInfoLiveData() {
        return jobInfoLiveData;
    }

    public MutableLiveData<NetworkResponse<String>> getRepostJobLiveData() {
        return repostJobLiveData;
    }

    public void uploadImage(Uri fileURI, String childPath) {
        uploadImageRepository.uploadImage(fileURI, childPath);
        compositeDisposable.add(uploadImageRepository.getUploadSubject()
                .subscribe(new Consumer<NetworkResponse<String>>() {
                    @Override
                    public void accept(NetworkResponse<String> stringNetworkResponse) throws Exception {
                        uploadMutableLiveData.postValue(stringNetworkResponse);
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        uploadMutableLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }


    public void getSubCategories(String id) {
        subCategoryLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(categoryRepository.getSubCategories(id)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<SubCategory>>() {
                    @Override
                    public void accept(StandardResponseList<SubCategory> subCategoryStandardResponseList) throws Exception {
                        subCategoryLiveData.postValue(NetworkResponseList.success(subCategoryStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        subCategoryLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));

    }

    public void getCategories() {
        categoryLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(categoryRepository.getCategories()
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<Category>>() {
                    @Override
                    public void accept(StandardResponseList<Category> categoryStandardResponseList) throws Exception {
                        categoryLiveData.postValue(NetworkResponseList.success(categoryStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        categoryLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));

    }

    public void postJob(HashMap<String, Object> params) {
        postJobLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(jobRepository.postJob(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        postJobLiveData.postValue(NetworkResponseList.success(stringStandardResponseList.getResponse(), stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        postJobLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));
    }


    public void repostJob(HashMap<String, Object> params) {
        repostJobLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(jobRepository.repostJob(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        repostJobLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        repostJobLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }



    public void editJob(HashMap<String, Object> params) {
        postJobLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(jobRepository.editJob(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        postJobLiveData.postValue(NetworkResponseList.success(stringStandardResponseList.getResponse(), stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        postJobLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));
    }

    public void getJobInfo(String jobId) {
        jobInfoLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(jobRepository.getSingleJobOwner(jobId)
                .compose(applySchedulers())
                .subscribe(jobStandardResponse -> jobInfoLiveData.postValue(NetworkResponse.success(jobStandardResponse.getResponse())),
                        throwable -> jobInfoLiveData.postValue(NetworkResponse.error(parseError(throwable)))));
    }
}
