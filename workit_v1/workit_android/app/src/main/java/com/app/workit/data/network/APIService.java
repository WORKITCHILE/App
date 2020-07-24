package com.app.workit.data.network;

import com.app.workit.data.model.*;
import com.app.workit.model.Bank;
import com.app.workit.util.AppConstants;

import java.util.HashMap;
import java.util.List;

import io.reactivex.Observable;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.POST;
import retrofit2.http.Query;

public interface APIService {

    @POST(AppConstants.U_SIGN_UP)
    Observable<StandardResponseList<String>> signUp(@Body HashMap<String, Object> params);

    @GET(AppConstants.U_GET_PROFILE)
    Observable<StandardResponse<UserInfo>> getProfile(@Query("user_id") String token);

    @POST(AppConstants.U_IMAGE_UPLOAD)
    Observable<StandardResponseList<String>> uploadImage(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_POST_BANK_DETAIL)
    Observable<StandardResponseList<String>> addBank(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_EDIT_PROFILE)
    Observable<StandardResponseList<String>> editProfile(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_POST_JOB)
    Observable<StandardResponseList<String>> postJob(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_EDIT_JOB)
    Observable<StandardResponseList<String>> editJob(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_CHANGE_USER_ROLE)
    Observable<StandardResponseList<String>> changeUserRole(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_SEND_VERIFICATION_MAIL)
    Observable<StandardResponseList<String>> sendVerificationMail(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_VERIFY_OTP)
    Observable<StandardResponseList<String>> verifyEmail(@Body HashMap<String, Object> params);

    @GET(AppConstants.U_GET_CATEGORIES)
    Observable<StandardResponseList<Category>> getCategories();

    @GET(AppConstants.U_GET_SUBCATEGORIES)
    Observable<StandardResponseList<SubCategory>> getSubCategory(@Query("category_id") String id);

    @GET(AppConstants.U_GET_OWNER_POSTED_JOBS)
    Observable<StandardResponseList<Job>> getPostedJobs(@Query("user_id") String userId);

    @GET(AppConstants.U_GET_OWNER_RUNNING_JOB)
    Observable<StandardResponseList<Job>> getRunningJobOwner(@Query("user_id") String userId);

    @GET(AppConstants.U_GET_VENDOR_RUNNING_JOB)
    Observable<StandardResponseList<Job>> getRunningJobVendor(@Query("user_id") String userId);

    @GET(AppConstants.U_GET_OWNER_COMPLETED_JOBS)
    Observable<StandardResponseList<Job>> getHistoryJobsOwner(@Query("user_id") String userId);

    @GET(AppConstants.U_GET_VENDOR_COMPLETED_JOB)
    Observable<StandardResponseList<Job>> getHistoryJobsVendor(@Query("user_id") String userId);

    @POST(AppConstants.U_GET_WORKER_POSTED_JOB)
    Observable<StandardResponseList<Job>> getWorkerPostedJobs(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_GET_WORKER_POSTED_JOB)
    Observable<StandardResponseList<Job>> getWorkerPostedJobs(@Query("user_id") String userId, @Query("subcategory_id") List<String> subCategoryIds);

    @POST(AppConstants.U_PLACE_BID)
    Observable<StandardResponseList<String>> postBidWorker(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_CANCEL_BID)
    Observable<StandardResponseList<String>> cancelBidWorker(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_RATE_USER)
    Observable<StandardResponseList<String>> rateUser(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_OWNER_START_JOB)
    Observable<StandardResponseList<String>> startJobOwner(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_CANCEL_JOB)
    Observable<StandardResponseList<String>> cancelJobOwner(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_VENDOR_CANCEL_JOB)
    Observable<StandardResponseList<String>> cancelJobWorker(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_BID_ACTION)
    Observable<StandardResponseList<String>> ownerBidAction(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_OWNER_JOB_PAYMENT)
    Observable<StandardResponseList<String>> paymentForJob(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_SEND_CHAT_MESSAGE)
    Observable<StandardResponseList<String>> sendMessage(@Body Chat params);

    @POST(AppConstants.U_RELEASE_JOB_PAYMENT)
    Observable<StandardResponseList<String>> releasePayment(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_SUPPORT)
    Observable<StandardResponseList<String>> querySupport(@Body HashMap<String, Object> params);

    @GET(AppConstants.U_GET_SINGLE_JOB_OWNER)
    Observable<StandardResponse<Job>> getSingleJobOwner(@Query("user_id") String userId, @Query("job_id") String jobId);

    @GET(AppConstants.U_GET_SINGLE_JOB_WORKER)
    Observable<StandardResponse<Job>> getSingleJobWorker(@Query("user_id") String userId, @Query("job_id") String jobId);

    @GET(AppConstants.U_GET_SINGLE_BID_WORKER)
    Observable<StandardResponse<Bid>> getSingleBidWorker(@Query("bid_id") String bidID, @Query("job_id") String jobId);

    @GET(AppConstants.U_GET_ALL_BID)
    Observable<StandardResponseList<Job>> getAllBids(@Query("user_id") String userId, @Query("type") String type);

    @GET(AppConstants.U_GET_INBOX)
    Observable<StandardResponseList<InBox>> getInboxMessages(@Query("user_id") String userId);

    @GET(AppConstants.U_GET_RATING)
    Observable<StandardResponseList<RatingReview>> getRatings(@Query("user_id") String userId);

    @GET(AppConstants.U_GET_CREDIT)
    Observable<StandardResponse<Credit>> getCredits(@Query("user_id") String userId);

    @GET(AppConstants.U_TERMS_CONDITION)
    Observable<StandardResponse<TermsAndCondition>> getTermsAndCondition(@Query("user_id") String userId);

    @GET(AppConstants.U_GET_NOTIFICATION)
    Observable<StandardResponseList<Notification>> getNotifications(@Query("user_id") String userId);

    @GET(AppConstants.U_USER_CALENDER_JOBS)
    Observable<StandardResponseList<ScheduleResponse>> getCalendarJobs(@Query("user_id") String userId, @Query("month") long timeStamp);

    @POST(AppConstants.U_ADD_CREDIT)
    Observable<StandardResponseList<String>> addCredit(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_OWNER_REPOST_JOB)
    Observable<StandardResponseList<String>> repostJob(@Body HashMap<String, Object> params);

    @POST(AppConstants.U_JOB_ACTION)
    Observable<StandardResponseList<String>> startJobWorker(@Body HashMap<String, Object> params);

    @GET(AppConstants.U_SOCIAL_LOGIN)
    Observable<StandardResponse<UserInfo>> socialLogin(@Query("type") int type, @Query("social_handle") String socialHandle);

    @GET(AppConstants.U_GET_ACCOUNT_DETAILS)
    Observable<StandardResponseList<Bank>> getBankDetails(@Query("user_id") String userId);

}
