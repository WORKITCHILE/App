
import UIKit

struct SplashContent {
    var backgroundImage: String?
    var icon: String?
    var title: String?
    var content: String?
}

struct Response: Codable {
    var message: String?
    var status: Int?
}

enum MenuAction {
    case open
    case action
}

struct MenuObject {
    var image: UIImage?
    var name: String?
    var action: MenuAction?
    var data : [String: String]
}

struct LoginResponse: Codable {
    var data:UserInfo?
    var message: String?
    var status: Int?
}

struct SocialLogin: Codable {
    var data : UserInfo?
    var message: String?
    var status: Int?
}

struct UserInfo: Codable {
    var token: String?
    var email: String?
    var status: String?
    var type: String?
    var is_email_verified:Int?
    var father_last_name: String?
    var mother_last_name: String?
    var is_bank_details_added: Int?
    var address: String?
    var address_number: String?
    var address_reference: String?
    var profile_picture: String?
    var nationality: String?
    var occupation: String?
    var contact_number: String?
    var name: String?
    var rating: String?
    var profile_description: String?
    var id_image1: String?
    var id_image2: String?
    var id_number: String?
    var average_rating: String?
    var user_id: String?
    var background_document: String?
}

struct GetCategory: Codable {
    var data = [GetCategoryResponse]()
    var message: String?
    var status: Int?
}

struct GetCategoryResponse: Codable{
    var category_image: String?
    var created_at: Int?
    var category_name: String?
    var category_id: String?
}


struct GetWorkers: Codable {
    var data = [UserInfo]()
    var message: String?
    var status: Int?
}


struct GetSubcategory: Codable {
    var data = [GetSubcategoryResponse]()
    var message: String?
    var status: Int?
}

struct GetSubcategoryResponse: Codable{
    var subcategory_image: String?
    var category_id: String?
    var subcategory_name: String?
    var subcategory_id: String?
}

struct GetState: Codable{
    var data = [GetStateResponse]()
    var message:String?
    var status: Int?
}

struct GetStateResponse: Codable{
    var state_name: String?
    var state_id: String?
}

struct GetCity: Codable{
    var data = [GetCityResponse]()
    var message: String?
    var status: Int?
}

struct GetCityResponse: Codable {
    var state_name: String?
    var city_name: String?
    var city_id: String?
    var state_id: String?
}

struct GetJob: Codable {
    var data : [GetJobResponse]
    var message: String?
    var status: Int?
}



struct GetJobResponse: Codable{
    var job_amount: String?
    var is_reposted:Int?
    var status: String?
    var owner_status: String?
    var vendor_status: String?
    var job_id: String?
    var user_name: String?
    var user_image: String?
    var vendor_image: String?
    var vendor_name: String?
    var vendor_average_rating: String?
    var user_average_rating: String?
    var vendor_rating: String?
    var owner_rating : String?
    var vendor_rated: Int?
    var owner_rated: Int?
    var job_vendor_id: String?
    var user_id: String?
    var user_occupation: String?
    var vendor_occupation: String?
    var vendor_dob: Int?
    var user_dob: Int?
    var job_description: String?
    var comment: String?
    var is_bid_placed: Int?
    var bid_count: Int?
    var initial_amount: Double?
    var images : [String]?
    var job_time: Int?
    var job_city: String?
    var job_state: String?
    var job_address: String?
    var started_by: String?
    var job_name: String?
    var subcategory_id: String?
    var subcategory_name: String?
    var job_address_longitude: Double?
    var job_address_latitude: Double?
    var category_name: String?
    var service_amount: String?
    var counteroffer_amount: String?
    var job_date: String?
    var job_approach: String?
    var canceled_by: String?
    var created_at: Int?
    var my_bid:BidResponse?
    var bids:[BidResponse]?
}

struct BidResponse: Codable {
    var owner_status: String?
    var job_id: String?
    var bid_id: String?
    var vendor_id: String?
    var vendor_occupation: String?
    var vendor_dob: Int?
    var vendor_name: String?
    var vendor_image: String?
    var vendor_status: String?
    var vendor_average_rating: String?
    var comment: String?
    var counteroffer_amount: String?
}

struct GetSingleJob: Codable{
    var data : GetJobResponse
    var message: String?
    var status: Int?
}

struct GetProfile: Codable {
    var data = UserInfo()
    var message: String?
    var status: Int?
}

struct ChatResponse: Codable {
    var id: String?
    var message: String?
    var read_satus: Int?
    var receiver_id: String?
    var sender_id: String?
    var time: Int?
    var type: Int?
}

struct GetRating: Codable {
    var data = [GetRatingResponse]()
    var message: String?
    var status: Int?
}

struct GetRatingResponse: Codable {
    var rate_from_type: String?
    var rate_from_image: String?
    var rate_from_name: String?
    var job_approach: String?
    var job_amount: String?
    var rate_to_image: String?
    var job_city: String?
    var job_time:Int?
    var job_state:String?
    var comment: String?
    var job_address: String?
    var rate_from: String?
    var contact_outside: String?
    var rate_to_name: String?
    var rate_to_type: String?
    var job_name: String?
    var job_id: String?
    var rating: String?
    var job_description: String?
    var rate_to: String?
    var job_date: String?
    var rating_id: String?
}

struct GetInbox: Codable{
    var data = [InboxResponse]()
    var message: String?
    var status: Int?
}


struct InboxResponse: Codable{
    var receiver_name: String?
    var sender_image: String?
    var receiver_type: String?
    var created_at: Int?
    var sender_type: String?
    var job_id: String?
    var receiver_image: String?
    var receiver: String?
    var sender_name: String?
    var last_message_by: String?
    var sender: String?
    var last_message: String?
}

struct GetNotification: Codable {
    var data: [GetNotificationResponse]?
    var message: String?
    var stauts: Int?
}

struct GetNotificationResponse: Codable {
    var notification_type: Int?
    var notification_body: String?
    var sender_name: String?
    var job_id: String?
    var sender_image: String?
    var sender_id: String?
    var created_at: Int?
    var receiver_id: String?
    var notification_id: String?
}

struct GetPaymentResponse : Codable {
    var status: String?
    var id : String?
    var url : String?
}

struct GetTransaction: Codable {
    var data : GetTransactionResponse?
    var payment: GetPaymentResponse?
    var message: String?
    var status: Int?
}

struct GetTransactionResponse: Codable {
    var credits: String?
    var transactions: [TransactionDetail]?
    
}

struct TransactionDetail: Codable{
    var user_name: String?
    var opposite_user: String?
    var user_image: String?
    var transaction_type: String?
    var created_at: Int?
    var user_id: String?
    var job_id: String?
    var commission: String?
    var transaction_id: String?
    var transaction_for: String?
    var payment_option: String?
    var amount: String?
}

struct GetTNC: Codable {
    var data: GetTNCResponse?
    var message: String?
    var status: Int?
}

struct GetTNCResponse: Codable {
    var terms_and_conditions: String?
    var created_at: Int?
}


struct GetAccounts: Codable {
    var data = [GetAccountsDetail]()
    var message: String?
    var status: Int?
}

struct GetAccountsDetail: Codable {
    var user_id: String?
    var updated_at: Int?
    var account_number: String?
    var user_name: String?
    var RUT: String?
    var full_name: String?
    var created_at: Int?
    var account_type: String?
    var bank: String?
    var bank_detail_id: String?
}

struct CalendarJobs: Codable{
    var data = [CalendarJobsResponse]()
    var message:String?
    var status:Int?
}

struct CalendarJobsResponse: Codable{
    var job_data : [GetJobResponse]?
}



