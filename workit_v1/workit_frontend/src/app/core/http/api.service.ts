import {Injectable} from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {LocalStorageService} from '@services/local-storage.service';
import {Observable} from 'rxjs';

@Injectable()
export class ApiService {

  constructor(private httpClient: HttpClient,
              private storageService: LocalStorageService) {
  }

  // adminLogin(inputData): Observable<any> { // login
  //   return this.httpClient.post('admin-login', inputData);
  // }

  getUsers(pageNo, NoOfEntry): Observable<any> {
    return this.httpClient.get('get-collection-by-name/users/' + pageNo +  '/' + NoOfEntry);
  }
  getSingleUser(Id): Observable<any> {
    return this.httpClient.get('get-single-document-by-id/users/' + Id);
  }
  getJobs(pageNo, NoOfEntry, name): Observable<any> {
    return this.httpClient.get('get-collection-by-name/jobs/' + pageNo +  '/' + NoOfEntry + '/' + name);
  }
  getSingleJob(Id): Observable<any> {
    return this.httpClient.get('get-single-document-by-id/jobs/' + Id);
  }
  /*getBids(pageNo, NoOfEntry): Observable<any> {
    return this.httpClient.get('get-collection-by-name/bids/' + pageNo +  '/' + NoOfEntry);
  }
  getSingleBid(Id): Observable<any> {
    return this.httpClient.get('get-single-document-by-id/bids/' + Id);
  }*/
  getCategories(pageNo, NoOfEntry): Observable<any> {
    return this.httpClient.get('get-collection-by-name/categories/' + pageNo +  '/' + NoOfEntry);
  }
  getSingleCategory(Id): Observable<any> {
    return this.httpClient.get('get-single-document-by-id/categories/' + Id);
  }
  updateCategory(data): Observable<any> {
    return this.httpClient.post('edit-category', data);
  }
  getSubcategories(pageNo, NoOfEntry): Observable<any> {
    return this.httpClient.get('get-collection-by-name/subcategories/' + pageNo +  '/' + NoOfEntry);
  }
  getSingleSubcategory(Id): Observable<any> {
    return this.httpClient.get('get-single-document-by-id/subcategories/' + Id);
  }
  updateSubcategory(data): Observable<any> {
    return this.httpClient.post('edit-subcategory', data);
  }
  getSupport(pageNo, NoOfEntry): Observable<any> {
    return this.httpClient.get('get-collection-by-name/supports/' + pageNo +  '/' + NoOfEntry);
  }
  getCategory(parentId): Observable<any> {
    return this.httpClient.get('get-categories?parent_id=' + parentId);
  }
  addCategory(data): Observable<any> {
    return this.httpClient.post('add-category', data);
  }
  addSubCategory(data): Observable<any> {
    return this.httpClient.post('add-subcategory', data);
  }
  addTnC(data): Observable<any> {
    return this.httpClient.post('tnc', data);
  }
  updateUser(data): Observable<any> {
    return this.httpClient.post('edit-user', data);
  }
  deleteJob(id): Observable<any> {
    return this.httpClient.post('delete-job?job_id=' + id, id);
  }
  deleteUser(id): Observable<any> {
    return this.httpClient.post('delete-user?user_id=' + id, id);
  }
  deleteCategory(data): Observable<any> {
    return this.httpClient.post('delete-category', data);
  }
  deleteSubcategory(data): Observable<any> {
    return this.httpClient.post('delete-subcategory', data);
  }
  getDashboardCounts(): Observable<any> {
    return this.httpClient.get('get-dashboard-counts');
  }
  getAllBids(): Observable<any> {
    return this.httpClient.get('get-all-bids');
  }
  manageAccount(data): Observable<any> {
    return this.httpClient.post('manage-user-account', data);
  }
  getRatings(): Observable<any> {
    return this.httpClient.get('get-ratings');
  }
  getEventHistory(id): Observable<any> {
    return this.httpClient.get('get-event-history?job_id=' +   id);
  }
  getRecentJobs(): Observable<any> {
    return this.httpClient.get('recent-activities-by-collection/jobs');
  }
  getRecentSupport(): Observable<any> {
    return this.httpClient.get('recent-activities-by-collection/support');
  }
  supportAction(data): Observable<any> {
    return this.httpClient.post('support-action', data);
  }
}
