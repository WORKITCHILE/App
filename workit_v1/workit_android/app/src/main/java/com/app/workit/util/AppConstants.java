package com.app.workit.util;

public interface AppConstants {

    String BASE_URL = "https://us-central1-workit-de544.cloudfunctions.net/app/api/";
    String U_IMAGE_UPLOAD = "https://us-central1-workit-de544.cloudfunctions.net/app/api/upload";
    String K_BEARER = "Bearer";
    String WORK_IT_PREF = "work-it-prefs";

    String U_LOGIN = "users/login";

    String U_SIGN_UP = "users/sign-up";

    String U_CHANGE_USER_ROLE = "users/change-user-role";

    String U_GET_CATEGORIES = "users/get-categories";

    String U_GET_SUBCATEGORIES = "users/get-subcategories";

    String U_GET_CITY = "users/get-cities?state_id=";

    String U_GET_STATE = "users/get-states";

    String U_DELETE_IMAGE = "users/delete-job-image";

    String U_GET_PROFILE = "users/get-profile";

    String U_EDIT_PROFILE = "users/edit-profile";

    String U_RATE_USER = "users/rate-user";

    String U_GET_RATING = "users/get-ratings";

    String U_GET_JOB_DETAIL = "users/get-job/details?job_id=";

    String U_ADD_FCM_TOKEN = "users/add-fcm-token";

    String U_DELETE_FCM_TOKEN = "users/delete-fcm-token";

    String U_SUPPORT = "users/support";

    String U_SEND_CHAT_MESSAGE = "users/save-message-list";

    String U_GET_INBOX = "users/message-list";

    String U_SOCIAL_LOGIN = "users/check-user-exists";

    String U_GET_NOTIFICATION = "users/get-notifications";

    String U_ADD_CREDIT = "users/add-credit";

    String U_GET_CREDIT = "users/get-credits";

    String U_TERMS_CONDITION = "users/get-tnc";

    String U_POST_BANK_DETAIL = "users/add-bank-details";

    String U_SEND_VERIFICATION_MAIL = "users/send-verification-mail";

    String U_VERIFY_OTP = "users/verify-email";

    String U_GET_ACCOUNT_DETAILS = "users/get-bank-details";

    String U_EDIT_BANK_DETAILS = "users/edit-bank-details";

    String U_POST_JOB = "owner/post-job";

    String U_GET_SINGLE_JOB_OWNER = "owner/get-single-job";

    String U_EDIT_JOB = "owner/edit-job";

    String U_BID_ACTION = "owner/bid-action";

    String U_GET_OWNER_RUNNING_JOB = "owner/get-running-jobs";

    String U_GET_OWNER_POSTED_JOBS = "owner/get-posted-jobs";

    String U_OWNER_START_JOB = "owner/start-approval";

    String U_CANCEL_JOB = "owner/cancel-job";

    String U_OWNER_JOB_PAYMENT = "owner/job-payment";

    String U_RELEASE_JOB_PAYMENT = "owner/release-job-payment";

    String U_GET_OWNER_COMPLETED_JOBS = "owner/get-completed-jobs";

    String U_GET_VENDOR_COMPLETED_JOB = "vendor/get-completed-jobs";

    String U_GET_VENDOR_RUNNING_JOB = "vendor/get-running-jobs";

    String U_GET_WORKER_POSTED_JOB = "vendor/get-posted-jobs";

    String U_GET_SINGLE_JOB_VENDOR = "vendor/get-single-job?user_id=";

    String U_PLACE_BID = "vendor/place-bid";

    String U_CANCEL_BID = "vendor/cancel-bid";

    String U_GET_SINGLE_BID_WORKER = "vendor/get-single-bid";

    String U_GET_SINGLE_JOB_WORKER = "vendor/get-single-job";

    String U_GET_ALL_BID = "vendor/get-all-bids";

    String U_JOB_ACTION = "vendor/job-action";

    String U_VERIFY_MAIL = "users/send-verification-mail";

    String U_FORGOT_PASS = "users/send-reset-mail";

    String U_CHANGE_PASS = "users/reset-password";

    String U_USER_CALENDER_JOBS = "users/get-calender-jobs";

    String U_OWNER_REPOST_JOB = "owner/manage-job-repost";

    String U_OWNER_JOB_APPROVAL = "owner/start-approval";

    String U_VENDOR_CANCEL_JOB = "vendor/cancel-job";

    String U_VENDOR_CANCEL_BID = "vendor/cancel-bid";

    //Keys
    String K_EMAIL = "email";
    String K_PROFILE_DESCRIPTION = "profile_description";
    String K_NAME = "name";
    String K_FATHER_LAST_NAME = "father_last_name";
    String K_MOTHER_LAST_NAME = "mother_last_name";
    String K_OCCUPATION = "occupation";
    String K_ID_NUMBER = "id_number";
    String K_DATE_OF_BIRTH = "date_of_birth";
    String K_ADDRESS = "address";
    String K_MOBILE = "contact_number";
    String K_PASSWORD = "password";
    String K_NATIONALITY = "nationality";
    String K_ID_IMAGE_1 = "id_image1";
    String K_ID_IMAGE_2 = "id_image2";
    String K_PROFILE_PICTURE = "profile_picture";
    String K_FCM_TOKEN = "fcm_token";
    String K_CREDITS = "credits";
    String K_GOOGLE_HANDLE = "google_handle";
    String K_FACEBOOK_HANDLE = "facebook_handle";
    String K_USER_ID = "user_id";
    String K_UID = "uid";
    String K_RUT = "RUT";
    String K_FULL_NAME = "full_name";
    String K_BANK = "bank";
    String K_ACCOUNT_TYPE = "account_type";
    String K_ACCOUNT_NUMBER = "account_number";
    String K_TITLE = "title";
    String K_TYPE = "type";
    String K_JOB_NAME = "job_name";
    String K_JOB_DESCRIPTION = "job_description";
    String K_JOB_ADDRESS = "job_address";
    String K_JOB_APPROACH = "job_approach";
    String K_CATEGORY_NAME = "category_name";
    String K_CATEGORY_ID = "category_id";
    String K_SUB_CATEGORY_NAME = "subcategory_name";
    String K_SUB_CATEGORY_ID = "subcategory_id";
    String K_WORK_DATE = "job_date";
    String K_JOB_TIME = "job_time";
    String K_INITIAL_AMOUNT = "initial_amount";
    String K_IMAGES = "images";
    String K_LATITUDE = "latitude";
    String K_LONGITUDE = "longitude";
    long LOCATION_UPDATE_TIME_INTERVAL = 4000;
    float LOCATION_UPDATE_MIN_DISTANCE = 10;
    String K_JOB_LATITUDE = "job_address_latitude";
    String K_JOB_LOGITUDE = "job_address_longitude";
    String K_JOB_ID = "job_id";
    String K_VERIFICATION_CODE = "verification_code";
    String K_YES = "yes";
    String K_NO = "no";
    String K_ADDRESS_LATITUDE = "address_latitude";
    String K_ADDRESS_LONGITUDE = "address_longitude";
    String K_PRICE = "price";
    String K_DISTANCE = "distance";
    String K_SEARCH = "search";
    String K_CURRENT_LATITUDE = "current_latitude";
    String K_CURRENT_LONGITUDE = "current_longitude";
    String K_VENDOR_ID = "vendor_id";
    String K_COUNTER_OFFER_AMOUNT = "counteroffer_amount";
    String K_COMMENT = "comment";
    String K_SUB_TITLE = "sub_title";
    String K_ACTION = "action";
    String K_BID_ID = "bid_id";
    String K_BID = "bid";
    String K_DATA = "data";
    String K_STATUS = "status";
    String K_AMOUNT = "amount";
    String K_VENDOR_NAME = "vendor_name";
    String K_JOB_AMOUNT = "job_amount";
    String K_PAYMENT_OPTION = "payment_option";
    String K_TRANSACTIOON_ID = "transaction_id";
    String K_JOB = "job";
    String K_CHAT_ID = "chat_id";
    String K_RECEIVER_ID = "receiver_id";
    String K_RECEIVER_NAME = "receiver_name";
    String K_RECEIVER_AVATAR = "receiver_avatar";
    String K_RATE_FROM = "rate_from";
    String K_RATE_FROM_NAME = "rate_from_name";
    String K_RATE_TO = "rate_to";
    String K_RATE_TO_NAME = "rate_to_name";
    String K_RATING = "rating";
    String K_RATE_FROM_TYPE = "rate_from_type";
    String K_RATE_TO_TYPE = "rate_to_type";
    String K_CONTACT_OUTSIDE = "contact_outside";
    String K_MESSAGE = "message";
    String K_REPOST = "repost";


    public interface USER_TYPE {

        final String HIRE = "HIRE";
        String WORK = "WORK";
        int WORK_INFO = 2;
        int HIRE_INFO = 1;
    }

    public interface DrawerOptions {

        int NOTIFICATIONS = 1;
        int EVALUATIONS = 2;
        int RUNNING_JOBS = 3;
        int HISTORY = 4;
        int INBOX = 5;
        int SHARE_APP = 6;
        int SUPPORT = 7;
        int CREDITS = 8;
        int ACCOUNT_SETTINGS = 9;
        int TERMS_OF_SERVICE = 10;
        int MY_BIDS = 11;
        int LOGOUT = 12;
        int WORK_SCHEDULE = 13;
    }

    public interface UPLOAD_PATH {
        String profileImagePath = "profile_images";
        String documentImagePath = "id_images";
        String jobImagePath = "job_images";
    }

    public interface IMAGE_TYPE {
        int PROFILE = 1;
        int ID_PICTURE1 = 2;
        int ID_PICTURE2 = 3;
    }

    public interface DIALOG_TYPE {
        int SUCCESS = 1;
        int CONFIRMATION = 2;
        int CREDIT_ADD = 3;
    }

    public interface REQUEST_CODES {
        int POST_JOB = 12;
        int REQUEST_ACCESS_LOCATION = 13;
        int SINGLE_JOB = 42;
        int EDIT_JOB = 44;
    }

    public interface ACTIONS {
        String POST_JOB = "post_job";
        String EDIT_JOB = "edit_job";
        String VIEW_MAP = "view_map";
        String RATE_USER = "rate_user";
        String SOCIAL_SIGNUP = "social_sign_up";
    }

    public interface BID_STATUS {
        String POSTED = "POSTED";
        String REJECTED = "REJECTED";
        String ACCEPTED = "ACCEPTED";
    }

    public interface JOB_STATUS {
        String POSTED = "POSTED";
        String CLOSED = "CLOSED";
        String ACCEPTED = "ACCEPTED";
        String REJECTED = "REJECTED";
        String STARTED = "STARTED";
        String FINISHED = "FINISHED";
        String PAID = "PAID";
        String CANCELED = "CANCELED";
    }

    public interface PAYMENT_OPTION {
        String WALLET = "WALLET";
    }

    public interface CHAT_DATA {
        String IS_SEEN = "read_status";
    }

    public interface FIREBASE_DATABASE {
        String K_MESSAGE = "messages";
    }

    public interface CHAT_TYPE {
        int MESSAGE = 1;
    }

    public interface NOTIFICATION_TYPE {
        int BID_PLACED = 2;
        int BID_ACCEPTED = 3;
        int BID_REJECTED = 4;
        int JOB_STARTED = 5;
        int JOB_FINISHED = 6;
        int PAYMENT_RELEASED = 7;
        int START_JOB_NOTIFY_45_MIN_BEFORE = 8; //To Worker
        int NEW_MESSAGE_RECEIVED = 9;
        int START_JOB_NOTIFY_5_MIN_BEFORE = 10; //To Worker
        int JOB_STARTED_NOTIFY_45_MIN_BEFORE = 11; //To Owner
        int JOB_STARTED_NOTIFY_5_MIN_BEFORE = 12; // To Owner
        int JOB_CANCELED_BY_OWNER = 13; //To Worker
        int JOB_CANCELED_BY_WORKER = 14; //To Owner
        int RATING_RECEIVED = 15;
        int JOB_START_APPROVAL = 16; //To Worker
    }

    public interface LOGIN_TYPE {
        int GOOGLE = 1;
        int FACEBOOK = 2;
    }
}
