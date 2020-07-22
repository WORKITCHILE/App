import {NgModule} from '@angular/core';
import {CommonModule} from '@angular/common';
import {HTTP_INTERCEPTORS} from '@angular/common/http';
import {ApiService} from '@app/core/http/api.service';
import {LocalStorageService} from '@services/local-storage.service';
import {ApiPrefixInterceptor} from '@app/core/interceptors/api-prefix.interceptor';
import {HttpTokenInterceptor} from '@app/core/interceptors/http.token.interceptor';
import {AuthGuardService} from '@app/core/guards/auth.guard.service';
import {NoAuthGuardService} from '@app/core/guards/no-auth.guard.service';
import {DigitOnlyDirective} from '@app/core/directives/digit-only.directive';
@NgModule({
  declarations: [DigitOnlyDirective],
  imports: [
    CommonModule
  ],
  exports: [
    DigitOnlyDirective
  ],
  providers: [
    ApiService,
    AuthGuardService,
    NoAuthGuardService,
    LocalStorageService,
    {provide: HTTP_INTERCEPTORS, useClass: ApiPrefixInterceptor, multi: true},
    {provide: HTTP_INTERCEPTORS, useClass: HttpTokenInterceptor, multi: true}
  ]
})
export class CoreModule {
}
