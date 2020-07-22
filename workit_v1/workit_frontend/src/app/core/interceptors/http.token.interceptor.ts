import {HttpEvent, HttpHandler, HttpInterceptor, HttpRequest} from '@angular/common/http';
import {Injectable} from '@angular/core';
import {Observable} from 'rxjs';
import {LocalStorageService} from '@services/local-storage.service';
import {environment} from '@environments/environment';

@Injectable()
export class HttpTokenInterceptor implements HttpInterceptor {
  constructor(public localStorage: LocalStorageService) {
  }

  intercept(request: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    request = request.clone({
      setHeaders: {
        Authorization: `Bearer ${this.localStorage.getValue(environment.authKey, false)}`
      }
    });
    return next.handle(request);
  }
}
