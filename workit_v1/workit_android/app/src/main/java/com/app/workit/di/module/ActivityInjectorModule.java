package com.app.workit.di.module;

import com.app.workit.view.ui.common.evaluation.EvaluationActivity;
import com.app.workit.view.ui.common.HomeActivity;
import com.app.workit.view.ui.common.MainActivity;
import com.app.workit.view.ui.common.chat.ChatActivity;
import com.app.workit.view.ui.common.credits.CreditsActivity;
import com.app.workit.view.ui.common.emailverification.EmailVerificationActivity;
import com.app.workit.view.ui.common.evaluation.ratereview.RateReviewActivity;
import com.app.workit.view.ui.common.history.HistoryActivity;
import com.app.workit.view.ui.common.inbox.InboxActivity;
import com.app.workit.view.ui.common.map.MapActivity;
import com.app.workit.view.ui.common.notification.NotificationActivity;
import com.app.workit.view.ui.common.profile.ProfileActivity;
import com.app.workit.view.ui.common.runningjob.RunningJobActivity;
import com.app.workit.view.ui.common.signup.SignUpActivity;
import com.app.workit.view.ui.common.SplashActivity;
import com.app.workit.view.ui.common.login.LogInActivity;
import com.app.workit.view.ui.common.roleselection.RoleSelectActivity;
import com.app.workit.view.ui.common.support.SupportActivity;
import com.app.workit.view.ui.common.termsofservice.TermsOfServiceActivity;
import com.app.workit.view.ui.hire.bid.BidInfoActivity;
import com.app.workit.view.ui.hire.postjob.PostJobActivity;

import com.app.workit.view.ui.hire.singlejob.SingleJobActivity;
import com.app.workit.view.ui.hire.workschedule.WorkScheduleActivity;
import com.app.workit.view.ui.work.accountsettings.AccountSettingsActivity;
import com.app.workit.view.ui.work.bids.BidsActivity;
import com.app.workit.view.ui.work.search.SearchActivity;
import com.app.workit.view.ui.work.search.SubCategoryActivity;

import dagger.Module;
import dagger.android.ContributesAndroidInjector;

/**
 * Class for placing all activity and fragment class which uses dagger dependency
 */
@Module
public abstract class ActivityInjectorModule {

    @ContributesAndroidInjector
    abstract SignUpActivity contributeSignUpActivity();

    @ContributesAndroidInjector
    abstract SplashActivity contributeSplashActivity();

    @ContributesAndroidInjector
    abstract MainActivity contributeMainActivity();

    @ContributesAndroidInjector
    abstract LogInActivity contributeLoginActivity();

    @ContributesAndroidInjector
    abstract RoleSelectActivity contributeRoleSelectionActivity();

    @ContributesAndroidInjector
    abstract HomeActivity contributeHomeActivity();

    @ContributesAndroidInjector
    abstract NotificationActivity contributeNotificationActivity();

    @ContributesAndroidInjector
    abstract InboxActivity contributeInboxActivity();

    @ContributesAndroidInjector
    abstract EvaluationActivity contributeEvaluationActivity();

    @ContributesAndroidInjector
    abstract RunningJobActivity contributeRunningJobActivity();

    @ContributesAndroidInjector
    abstract HistoryActivity contributeHistoryActivity();

    @ContributesAndroidInjector
    abstract SupportActivity contributeSupportActivity();

    @ContributesAndroidInjector
    abstract CreditsActivity contributeCreditsActivity();

    @ContributesAndroidInjector
    abstract ProfileActivity contributeProfileActivity();

    @ContributesAndroidInjector
    abstract PostJobActivity contributePostJobActivity();

    @ContributesAndroidInjector
    abstract MapActivity contributeMapActivity();

    @ContributesAndroidInjector
    abstract SingleJobActivity contributeSingleJobActivity();

    @ContributesAndroidInjector
    abstract EmailVerificationActivity contributeEmailVerificationActivity();

    @ContributesAndroidInjector
    abstract SubCategoryActivity contributeSubCategoryActivity();


    @ContributesAndroidInjector
    abstract SearchActivity contributeSearchActivity();

    @ContributesAndroidInjector
    abstract BidsActivity contributeBidsActivity();

    @ContributesAndroidInjector
    abstract BidInfoActivity contributeBidInfoActivity();

    @ContributesAndroidInjector
    abstract ChatActivity contributeChatActivity();

    @ContributesAndroidInjector
    abstract WorkScheduleActivity contributeWorkScheduleActivity();

    @ContributesAndroidInjector
    abstract TermsOfServiceActivity contributeTermsOfServiceActivity();

    @ContributesAndroidInjector
    abstract RateReviewActivity contributeRateReviewActivity();

    @ContributesAndroidInjector
    abstract AccountSettingsActivity contributeAccountSettingsActivity();

}
