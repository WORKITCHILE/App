import {BrowserModule} from '@angular/platform-browser';
import {NgModule} from '@angular/core';
import {CoreModule} from '@app/core/core.module';
import {FormsModule, ReactiveFormsModule} from '@angular/forms';
import {HttpClientModule} from '@angular/common/http';
import {SnotifyModule, SnotifyPosition, SnotifyService} from 'ng-snotify';
import {AppRoutingModule} from './app-routing.module';
import {AppComponent} from './app.component';
import {DashboardComponent} from './components/dashboard/dashboard.component';
import {JobsComponent} from './components/jobs/jobs.component';
import {UsersComponent} from './components/users/users.component';
import {HomeComponent} from './components/home/home.component';
import { SubcategoryComponent } from './components/subcategory/subcategory/subcategory.component';
import { CategoryComponent } from './components/category/category/category.component';
import { AddSubcategoryComponent } from './components/subcategory/subcategory/add-subcategory.component';
import { AddCategoryComponent } from './components/category/category/add-category.component';
import { LoginComponent } from './components/login/login.component';
import {environment} from '@environments/environment';
import {AngularFireModule} from '@angular/fire';
import {AngularFireDatabaseModule} from '@angular/fire/database';
import {AngularFireMessagingModule} from '@angular/fire/messaging';
import {AngularFireAuthModule} from '@angular/fire/auth';
import {NgxPaginationModule} from 'ngx-pagination';
import { SingleUserComponent } from './components/users/single-user/single-user.component';
import { SingleJobComponent } from './components/jobs/single-job/single-job.component';
import {AngularFireStorageModule} from '@angular/fire/storage';
import { SupportComponent } from './components/support/support.component';
import { AddTAndCComponent } from './components/cme/add-t-and-c/add-t-and-c.component';
import { AddPrivacyPolicyComponent } from './components/cme/add-privacy-policy/add-privacy-policy.component';
import { AddAboutUsComponent } from './components/cme/add-about-us/add-about-us.component';
import {EditorModule} from '@tinymce/tinymce-angular';
import { EditUserComponent } from './components/users/edit-user/edit-user.component';
import { EditCategoryComponent } from './components/category/edit-category/edit-category.component';
import { EditSubcategoryComponent } from './components/subcategory/edit-subcategory/edit-subcategory.component';
import {HighchartsChartModule} from 'highcharts-angular';
import { AllBidsComponent } from './components/bids/all-bids/all-bids.component';
import { RatingsReviewComponent } from './components/ratings-review/ratings-review.component';
import {FilterPipe} from '@app/core/pipes/filter.pipe';
import {ChartModule} from 'angular-highcharts';



export const ToastConfig = {
  global: {
    newOnTop: true,
    maxOnScreen: 8,
    maxAtPosition: 8,
    filterDuplicates: false
  },
  toast: {
    type: 'error',
    showProgressBar: false,
    timeout: 5000,
    closeOnClick: true,
    pauseOnHover: true,
    bodyMaxLength: 150,
    titleMaxLength: 16,
    backdrop: -1,
    icon: null,
    iconClass: null,
    html: null,
    position: SnotifyPosition.centerBottom,
    animation: {enter: 'fadeIn', exit: 'fadeOut', time: 400}
  },
  type: {
    prompt: {
      timeout: 0,
      closeOnClick: false,
      buttons: [
        {text: 'Ok', action: null, bold: true},
        {text: 'Cancel', action: null, bold: false},
      ],
      placeholder: 'Enter answer here...',
      type: 'prompt',
    },
    confirm: {
      timeout: 0,
      closeOnClick: false,
      buttons: [
        {text: 'Ok', action: null, bold: true},
        {text: 'Cancel', action: null, bold: false},
      ],
      type: 'confirm',
    },
    simple: {
      type: 'simple'
    },
    success: {
      type: 'success'
    },
    error: {
      showProgressBar: false,
      timeout: 5000,
      type: 'error'
    },
    warning: {
      type: 'warning'
    },
    info: {
      type: 'info'
    },
    async: {
      pauseOnHover: false,
      closeOnClick: false,
      timeout: 0,
      showProgressBar: false,
      type: 'async'
    }
  }
};

@NgModule({
  declarations: [
    AppComponent,
    DashboardComponent,
    JobsComponent,
    UsersComponent,
    HomeComponent,
    SubcategoryComponent,
    CategoryComponent,
    AddSubcategoryComponent,
    AddCategoryComponent,
    LoginComponent,
    SingleUserComponent,
    SingleJobComponent,
    SupportComponent,
    AddTAndCComponent,
    AddPrivacyPolicyComponent,
    AddAboutUsComponent,
    EditUserComponent,
    EditCategoryComponent,
    EditSubcategoryComponent,
    AllBidsComponent,
    RatingsReviewComponent,
    FilterPipe
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    CoreModule,
    HttpClientModule,
    SnotifyModule,
    FormsModule,
    ChartModule,
    HighchartsChartModule,
    NgxPaginationModule,
    ReactiveFormsModule,
    AngularFireAuthModule,
    AngularFireStorageModule,
    AngularFireMessagingModule,
    AngularFireDatabaseModule,
    AngularFireModule.initializeApp(environment.firebase),
    EditorModule,

  ],
  providers: [
    {provide: 'SnotifyToastConfig', useValue: ToastConfig},
    SnotifyService
  ],
  bootstrap: [AppComponent]
})
export class AppModule {
}
