package com.app.workit.view.ui.hire.bid;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.Bid;
import com.app.workit.data.model.Job;
import com.app.workit.data.model.RatingReview;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.network.StandardResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.BidRepository;
import com.app.workit.data.repository.EvaluationRepository;
import com.app.workit.data.repository.JobRepository;
import com.app.workit.data.repository.PaymentRepository;
import com.app.workit.mvvm.BaseViewModel;
import com.app.workit.util.AppConstants;
import io.reactivex.functions.Consumer;

import java.util.HashMap;

public class BidInfoViewModel extends BaseViewModel {

    private final PaymentRepository paymentRepository;
    private final JobRepository jobRepository;
    private final EvaluationRepository evaluationRepository;
    private BidRepository bidRepository;
    private MutableLiveData<NetworkResponse<Bid>> bidInfoLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> acceptBidLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> jobActionLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> paymentLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> jobCancelLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> startJobOwnerLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<String>> releaseLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponseList<RatingReview>> reviewsLiveData = new MutableLiveData<>();
    private MutableLiveData<NetworkResponse<Job>> jobInfoLiveData = new MutableLiveData<>();

    public BidInfoViewModel(BidRepository bidRepository, JobRepository jobRepository, PaymentRepository paymentRepository, EvaluationRepository evaluationRepository, Application application) {
        super(application);
        this.evaluationRepository = evaluationRepository;
        this.jobRepository = jobRepository;
        this.paymentRepository = paymentRepository;
        this.bidRepository = bidRepository;
    }

    public MutableLiveData<NetworkResponse<String>> getJobActionLiveData() {
        return jobActionLiveData;
    }

    public MutableLiveData<NetworkResponseList<RatingReview>> getReviewsLiveData() {
        return reviewsLiveData;
    }

    public MutableLiveData<NetworkResponse<String>> getPaymentLiveData() {
        return paymentLiveData;
    }

    public MutableLiveData<NetworkResponse<String>> getJobCancelLiveData() {
        return jobCancelLiveData;
    }

    public MutableLiveData<NetworkResponse<String>> getAcceptBidLiveData() {
        return acceptBidLiveData;
    }

    public MutableLiveData<NetworkResponse<Bid>> getBidInfoLiveData() {
        return bidInfoLiveData;
    }

    public MutableLiveData<NetworkResponse<String>> getStartJobOwnerLiveData() {
        return startJobOwnerLiveData;
    }

    public MutableLiveData<NetworkResponse<String>> getReleaseLiveData() {
        return releaseLiveData;
    }


    public MutableLiveData<NetworkResponse<Job>> getJobInfoLiveData() {
        return jobInfoLiveData;
    }

    public void getJobInfo(String jobId) {
        jobInfoLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(jobRepository.getSingleJobOwner(jobId)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponse<Job>>() {
                    @Override
                    public void accept(StandardResponse<Job> jobStandardResponse) throws Exception {
                        jobInfoLiveData.postValue(NetworkResponse.success(jobStandardResponse.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        jobInfoLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }

    public void bidAction(HashMap<String, Object> params) {
        acceptBidLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(bidRepository.acceptBidOwner(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        acceptBidLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        acceptBidLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }

    public void jobAction(HashMap<String, Object> params) {
        jobActionLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(jobRepository.startJobWorker(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        jobActionLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        jobActionLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }


    public void getBidInfo(String jobID, String bidID) {
        bidInfoLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(bidRepository.getSingleBidWorker(bidID, jobID)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponse<Bid>>() {
                    @Override
                    public void accept(StandardResponse<Bid> bidStandardResponse) throws Exception {
                        bidInfoLiveData.postValue(NetworkResponse.success(bidStandardResponse.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        bidInfoLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }


    public void paymentForJob(HashMap<String, Object> params) {
        paymentLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(paymentRepository.paymentForJob(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        paymentLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        paymentLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }

    public void cancelJob(HashMap<String, Object> params, String type) {
        jobCancelLiveData.postValue(NetworkResponse.loading());
        if (type.equalsIgnoreCase(AppConstants.USER_TYPE.HIRE)) {
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
        } else {
            compositeDisposable.add(jobRepository.cancelJobWorker(params)
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

    public void releaseJobPayment(HashMap<String, Object> params) {
        releaseLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(jobRepository.releaseJobPayment(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        releaseLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        releaseLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }

    public void getRatings(String vendorID) {
        reviewsLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(evaluationRepository.getRatings(vendorID)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<RatingReview>>() {
                    @Override
                    public void accept(StandardResponseList<RatingReview> ratingReviewStandardResponseList) throws Exception {
                        reviewsLiveData.postValue(NetworkResponseList.success(ratingReviewStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        reviewsLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));
    }


    public void approveJobOwner(HashMap<String, Object> params) {
        startJobOwnerLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(jobRepository.startJobOwner(params)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        startJobOwnerLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        startJobOwnerLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }
}
