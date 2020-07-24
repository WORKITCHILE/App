package com.app.workit.di.module;

import android.app.Application;

import androidx.lifecycle.ViewModel;

import com.app.workit.data.repository.*;
import com.app.workit.di.ApplicationContext;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.common.HomeViewModel;
import com.app.workit.view.ui.common.MainViewModel;
import com.app.workit.view.ui.common.SplashViewModel;
import com.app.workit.view.ui.common.banking.BankViewModel;
import com.app.workit.view.ui.common.chat.ChatViewModel;
import com.app.workit.view.ui.common.credits.CreditsViewModel;
import com.app.workit.view.ui.common.emailverification.EmailVerificationViewModel;
import com.app.workit.view.ui.common.evaluation.EvaluationViewModel;
import com.app.workit.view.ui.common.evaluation.ratereview.RateReviewModel;
import com.app.workit.view.ui.common.history.HistoryJobViewModel;
import com.app.workit.view.ui.common.inbox.InboxViewModel;
import com.app.workit.view.ui.common.login.LogInViewModel;
import com.app.workit.view.ui.common.notification.NotificationViewModel;
import com.app.workit.view.ui.common.profile.ProfileViewModel;
import com.app.workit.view.ui.common.roleselection.RoleSelectionViewModel;
import com.app.workit.view.ui.common.runningjob.JobViewModel;
import com.app.workit.view.ui.common.signup.SignUpViewModel;
import com.app.workit.view.ui.common.support.SupportViewModel;
import com.app.workit.view.ui.common.termsofservice.TermsOfServiceViewModel;
import com.app.workit.view.ui.hire.HireViewModel;
import com.app.workit.view.ui.hire.bid.BidInfoViewModel;
import com.app.workit.view.ui.hire.postjob.PostJobViewModel;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import java.util.Map;

import javax.inject.Provider;

import com.app.workit.view.ui.hire.singlejob.SingleJobViewModel;
import com.app.workit.view.ui.hire.workschedule.WorkScheduleViewModel;
import com.app.workit.view.ui.work.WorkHomeViewModel;
import com.app.workit.view.ui.work.accountsettings.AccountSettingsViewModel;
import com.app.workit.view.ui.work.bids.BidViewModel;
import com.app.workit.view.ui.work.search.SearchViewModel;
import com.app.workit.view.ui.work.search.SubCategoryViewModel;

import com.facebook.login.LoginResult;
import dagger.MapKey;
import dagger.Module;
import dagger.Provides;
import dagger.multibindings.IntoMap;

@Module
public class ViewModelModule {

    @Target(ElementType.METHOD)
    @Retention(RetentionPolicy.RUNTIME)
    @MapKey
    @interface ViewModelKey {
        Class<? extends ViewModel> value();
    }

    @Provides
    ViewModelFactory viewModelFactory(Map<Class<? extends ViewModel>, Provider<ViewModel>> providerMap) {
        return new ViewModelFactory(providerMap);
    }

    @Provides
    @IntoMap
    @ViewModelKey(SignUpViewModel.class)
    ViewModel signUpViewModel(SignUpRepository signUpRepository, UploadImageRepository uploadImageRepository, @ApplicationContext Application application) {
        return new SignUpViewModel(signUpRepository, uploadImageRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(LogInViewModel.class)
    ViewModel logInViewModel(LogInRepository logInRepository, @ApplicationContext Application application) {
        return new LogInViewModel(logInRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(BankViewModel.class)
    ViewModel bankViewModel(BankRepository bankRepository, @ApplicationContext Application application) {
        return new BankViewModel(bankRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(SplashViewModel.class)
    ViewModel splashViewModel(LogInRepository logInRepository, @ApplicationContext Application application) {
        return new SplashViewModel(logInRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(ProfileViewModel.class)
    ViewModel profileViewModel(ProfileRepository profileRepository, UploadImageRepository uploadImageRepository, @ApplicationContext Application application) {
        return new ProfileViewModel(profileRepository, uploadImageRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(PostJobViewModel.class)
    ViewModel postJobViewModel(JobRepository jobRepository, CategoryRepository categoryRepository, UploadImageRepository uploadImageRepository, @ApplicationContext Application application) {
        return new PostJobViewModel(jobRepository, categoryRepository, uploadImageRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(RoleSelectionViewModel.class)
    ViewModel roleSelectionViewModel(ProfileRepository profileRepository, @ApplicationContext Application application) {
        return new RoleSelectionViewModel(profileRepository, application);
    }


    @Provides
    @IntoMap
    @ViewModelKey(HireViewModel.class)
    ViewModel hireViewModel(JobRepository jobRepository, @ApplicationContext Application application) {
        return new HireViewModel(jobRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(SingleJobViewModel.class)
    ViewModel singleJobViewModel(JobRepository jobRepository, BidRepository bidRepository, @ApplicationContext Application application) {
        return new SingleJobViewModel(jobRepository, bidRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(EmailVerificationViewModel.class)
    ViewModel emailVerificationViewModel(ProfileRepository profileRepository, @ApplicationContext Application application) {
        return new EmailVerificationViewModel(profileRepository, application);
    }


    @Provides
    @IntoMap
    @ViewModelKey(HomeViewModel.class)
    ViewModel homeViewModel(ProfileRepository profileRepository, @ApplicationContext Application application) {
        return new HomeViewModel(profileRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(WorkHomeViewModel.class)
    ViewModel workHomeViewModel(CategoryRepository categoryRepository, @ApplicationContext Application application) {
        return new WorkHomeViewModel(categoryRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(SubCategoryViewModel.class)
    ViewModel subCategoryViewModel(CategoryRepository categoryRepository, @ApplicationContext Application application) {
        return new SubCategoryViewModel(categoryRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(SearchViewModel.class)
    ViewModel searchViewModel(JobRepository jobRepository, @ApplicationContext Application application) {
        return new SearchViewModel(jobRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(BidViewModel.class)
    ViewModel bidViewModel(BidRepository bidRepository, @ApplicationContext Application application) {
        return new BidViewModel(bidRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(BidInfoViewModel.class)
    ViewModel bidInfoViewModel(BidRepository bidRepository, JobRepository jobRepository, PaymentRepository paymentRepository, EvaluationRepository evaluationRepository, @ApplicationContext Application application) {
        return new BidInfoViewModel(bidRepository, jobRepository, paymentRepository, evaluationRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(CreditsViewModel.class)
    ViewModel creditViewModel(CreditRepository creditRepository, @ApplicationContext Application application) {
        return new CreditsViewModel(creditRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(JobViewModel.class)
    ViewModel jobViewModel(JobRepository jobRepository, @ApplicationContext Application application) {
        return new JobViewModel(jobRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(HistoryJobViewModel.class)
    ViewModel historyJobViewModel(JobRepository jobRepository, @ApplicationContext Application application) {
        return new HistoryJobViewModel(jobRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(EvaluationViewModel.class)
    ViewModel evaluationViewModel(EvaluationRepository evaluationRepository, @ApplicationContext Application application) {
        return new EvaluationViewModel(evaluationRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(ChatViewModel.class)
    ViewModel chatViewModel(InBoxRepository inBoxRepository, @ApplicationContext Application application) {
        return new ChatViewModel(inBoxRepository, application);
    }


    @Provides
    @IntoMap
    @ViewModelKey(InboxViewModel.class)
    ViewModel inboxViewModel(InBoxRepository inBoxRepository, @ApplicationContext Application application) {
        return new InboxViewModel(inBoxRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(SupportViewModel.class)
    ViewModel supportViewModel(SupportRepository supportRepository, @ApplicationContext Application application) {
        return new SupportViewModel(supportRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(WorkScheduleViewModel.class)
    ViewModel workScheduleViewModel(JobRepository jobRepository, @ApplicationContext Application application) {
        return new WorkScheduleViewModel(jobRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(TermsOfServiceViewModel.class)
    ViewModel termsOfServiceViewModel(ProfileRepository profileRepository, @ApplicationContext Application application) {
        return new TermsOfServiceViewModel(profileRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(NotificationViewModel.class)
    ViewModel notificationViewModel(NotificationRepository notificationRepository, @ApplicationContext Application application) {
        return new NotificationViewModel(notificationRepository, application);
    }


    @Provides
    @IntoMap
    @ViewModelKey(MainViewModel.class)
    ViewModel mainViewModel(LogInRepository logInRepository, @ApplicationContext Application application) {
        return new MainViewModel(logInRepository, application);
    }


    @Provides
    @IntoMap
    @ViewModelKey(RateReviewModel.class)
    ViewModel rateReviewModel(EvaluationRepository evaluationRepository, @ApplicationContext Application application) {
        return new RateReviewModel(evaluationRepository, application);
    }

    @Provides
    @IntoMap
    @ViewModelKey(AccountSettingsViewModel.class)
    ViewModel accountSettingsViewModel(CreditRepository creditRepository, @ApplicationContext Application application) {
        return new AccountSettingsViewModel(creditRepository, application);
    }

}
