import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import {DashboardComponent} from './components/dashboard/dashboard.component';
import {UsersComponent} from './components/users/users.component';
import {JobsComponent} from './components/jobs/jobs.component';
import {HomeComponent} from './components/home/home.component';
import {CategoryComponent} from '@app/components/category/category/category.component';
import {SubcategoryComponent} from '@app/components/subcategory/subcategory/subcategory.component';
import {AddSubcategoryComponent} from '@app/components/subcategory/subcategory/add-subcategory.component';
import {AddCategoryComponent} from '@app/components/category/category/add-category.component';
import {LoginComponent} from '@app/components/login/login.component';
import {AuthGuardService} from '@app/core/guards/auth.guard.service';
import {SingleUserComponent} from '@app/components/users/single-user/single-user.component';
import {SingleJobComponent} from '@app/components/jobs/single-job/single-job.component';
import {SupportComponent} from '@app/components/support/support.component';
import {AddTAndCComponent} from '@app/components/cme/add-t-and-c/add-t-and-c.component';
import {AddPrivacyPolicyComponent} from '@app/components/cme/add-privacy-policy/add-privacy-policy.component';
import {EditUserComponent} from '@app/components/users/edit-user/edit-user.component';
import {EditCategoryComponent} from '@app/components/category/edit-category/edit-category.component';
import {EditSubcategoryComponent} from '@app/components/subcategory/edit-subcategory/edit-subcategory.component';
import {AllBidsComponent} from '@app/components/bids/all-bids/all-bids.component';
import {RatingsReviewComponent} from '@app/components/ratings-review/ratings-review.component';


const routes: Routes = [
  {path: '', redirectTo: 'dashboard', pathMatch: 'full'},
  {path: 'login', component: LoginComponent},
  { path: 'dashboard', component: DashboardComponent, canActivate: [AuthGuardService],
    children: [
      {path: '', component: HomeComponent},
      {path: 'users', component: UsersComponent},
      {path: 'edit-user/:doc_id', component: EditUserComponent},
      {path: 'single-user/:doc_id', component: SingleUserComponent},
      {path: 'jobs', component: JobsComponent},
      {path: 'all-bids', component: AllBidsComponent},
      {path: 'single-job/:doc_id', component: SingleJobComponent},
      {path: 'categories', component: CategoryComponent},
      {path: 'edit-category/:doc_id', component: EditCategoryComponent},
      {path: 'edit-subcategory/:doc_id', component: EditSubcategoryComponent},
      {path: 'add-category', component: AddCategoryComponent},
      {path: 'subcategories', component: SubcategoryComponent},
      {path: 'add-subcategory', component: AddSubcategoryComponent},
      {path: 'support', component: SupportComponent},
      {path: 't&c', component: AddTAndCComponent},
      {path: 'privacy', component: AddPrivacyPolicyComponent},
      {path: 'ratings', component: RatingsReviewComponent},
    ]
  }
];

@NgModule({
  declarations: [],
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
