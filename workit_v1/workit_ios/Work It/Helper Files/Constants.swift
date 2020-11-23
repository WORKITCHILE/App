//
//  Constants.swift
//
//  Created by Manisha  Sharma on 02/01/2019.
//  Copyright © 2019 Qualwebs. All rights reserved.
//

import UIKit

//MARK: Constants
//var primaryColor = UIColor(red: 0/255, green: 88/255, blue: 186/255, alpha: 1)
var darkBlue = UIColor(red: 0/255, green: 9/255, blue: 55/255, alpha: 1)//000937
var lightBlue = UIColor(red: 53/255, green: 152/255, blue: 206/255, alpha: 1)//35C0CE
var purpleColor = UIColor(red: 178/255, green: 70/255, blue: 244/255, alpha: 1)// B246F4
var greenColor = UIColor(red: 0/255, green: 230/255, blue: 118/255, alpha: 1)
var shadowColor = UIColor(red: 227/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1)
let lightYellow = UIColor(red: 255/255, green: 255/255, blue: 224/255, alpha: 1)//FFFFE0
let lightGreen = UIColor(red: 144/255, green: 238/255, blue: 144/255, alpha: 1) //90EE90



//MARK: API Constants
//Base Url
var U_BASE = "https://us-central1-workit-de544.cloudfunctions.net/app/api/"
var U_IMAGE_UPLOAD = "https://us-central1-workit-de544.cloudfunctions.net/app/api/upload"



var U_LOGIN = "users/login"
var U_SEARCH_WORKER = "vendor/get-workers"
var U_SIGN_UP = "users/sign-up"
var U_CHANGE_USER_ROLE = "users/change-user-role"
var U_GET_CATEGORIES = "users/get-categories"
var U_GET_SUBCATEGORIES = "users/get-subcategories?category_id="
var U_GET_CITY = "users/get-cities?state_id="
var U_GET_STATE = "users/get-states"
var U_DELETE_IMAGE = "users/delete-job-image"
var U_GET_PROFILE = "users/get-profile?user_id="
var U_EDIT_PROFILE = "users/edit-profile"
var U_RATE_USER = "users/rate-user"
var U_GET_RATING = "users/get-ratings?user_id="
var U_GET_JOB_DETAIL = "users/get-job/details?job_id="
var U_ADD_FCM_TOKEN = "users/add-fcm-token"
var U_DELETE_FCM_TOKEN = "users/delete-fcm-token"
var U_SUPPORT = "users/support"
var U_SEND_CHAT_MESSAGE = "users/save-message-list"
var U_GET_INBOX = "users/message-list?user_id="
var U_SOCIAL_LOGIN = "/users/check-user-exists?type="
var U_GET_NOTIFICATION = "/users/get-notifications?user_id="
var U_ADD_CREDIT = "users/add-credit"
var U_GET_CREDIT = "users/get-credits?user_id="
var U_POST_PAYMENT = "users/add-payment"
var U_TERMS_CONDITION = "users/get-tnc"
var U_POST_BANK_DETAIL = "users/add-bank-details"
var U_VERIFY_MAIL = "users/send-verification-mail"
var U_VERIFY_OTP = "users/verify-email"
var U_GET_ACCOUNT_DETAILS = "users/get-bank-details?user_id="
var U_EDIT_BANK_DETAILS = "users/edit-bank-details"
var U_FORGOT_PASS = "users/send-reset-mail"
var U_CHANGE_PASS = "users/reset-password"
var U_USER_CALENDER_JOBS = "users/get-calender-jobs"


var U_POST_JOB = "owner/post-job"
var U_GET_SINGLE_JOB_OWNER = "/owner/get-single-job?user_id="
var U_EDIT_JOB = "owner/edit-job"
var U_BID_ACTION = "owner/bid-action"
var U_GET_OWNER_RUNNING_JOB = "owner/get-running-jobs?user_id="
var U_GET_OWNER_POSTED_JOBS = "owner/get-posted-jobs?user_id="
var U_CANCEL_JOB = "owner/cancel-job"

var U_GET_OWNER_COMPLETED_JOBS = "owner/get-completed-jobs?user_id="
var U_OWNER_JOB_PAYMENT = "owner/job-payment"
var U_RELEASE_JOB_PAYMENT = "owner/release-job-payment"
var U_OWNER_REPOST_JOB = "owner/manage-job-repost"
var U_OWNER_JOB_APPROVAL = "owner/start-approval"


var U_GET_VENDOR_COMPLETED_JOB = "vendor/get-completed-jobs?user_id="

var U_GET_VENDOR_RUNNING_JOB = "vendor/get-running-jobs?user_id="
var U_GET_WORKER_POSTED_JOB = "vendor/get-posted-jobs"
var U_GET_SINGLE_JOB_VENDOR = "/vendor/get-single-job?user_id="
var U_VENDOR_CANCEL_JOB = "vendor/cancel-job"
var U_VENDOR_CANCEL_BID = "vendor/cancel-bid"


var U_PLACE_BID = "vendor/place-bid"
var U_GET_SINGLE_JOB_WORKER = "vendor/get-single-job?job_id="
var U_GET_ALL_BID = "vendor/get-all-bids?user_id="
var U_JOB_ACTION = "vendor/job-action"


//Controller id's
var K_SPLASH = "splash"
var K_BOTTOMTAB = "bottom_tab"

//MARK: Constants
var K_CURRENT_USER:String?
var K_WANT_JOB = "WORK"
var K_POST_JOB = "HIRE"
var K_EMAIL = "email"
var K_PASSWORD = "password"
var K_USERNAME = "username"
var K_FIRSTNAME = "first_name"
var K_LASTNAME = "last_name"
var K_ROLETYPE = "role"
var K_ROLEID = "role_id"
var K_LOCATION = "location"
var K_LEAGUEID = "league_id"
var K_SPRINTS = "sprints"
var K_TEAMID = "team_id"
var K_PHONE_NUMBER = "phone_number"
var K_NAME = "name"
var K_PROFILE_PICTURE = "profile_picture"
var K_ACCEPT = "ACCEPTED"
var K_START = "STARTED"
var K_CONFIRM = "CONFIRMED"
var K_REJECT = "REJECTED"
var K_FINISH = "FINISHED"
var K_CANCEL = "CANCELED"
var K_POSTED = "POSTED"
var K_PAID = "PAID"


var K_HISTORY_TAB = "history_screen"
var K_CURRENT_JOB_TAB = "current_job_screen"
var K_RUNNING_JOB_TAB = "running_job_screen"
var K_MYBID_TAB = "my_bid_tab"
var K_CURRENT_TAB = ""

var N_REFRESH_BID_TABLE = "refresh_bid_table"
var N_SELECT_BANK_ACCOUNT = "select_bank_account"
var N_USER_UNAUTHORIZED = "user_unauthorized"

//MARK: User Defaults
var UD_TOKEN = "access_token"
var UD_FCM_TOKEN = "fcm_token"
var UD_USERINFO = "user_info"
var UD_CURRENT_USER = "current_user_type"
var UD_USER_ID = "current_user_id"


