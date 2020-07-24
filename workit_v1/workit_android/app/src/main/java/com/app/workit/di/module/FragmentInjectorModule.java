package com.app.workit.di.module;

import com.app.workit.view.ui.common.banking.AddBankDialogFragment;
import com.app.workit.view.ui.common.dialog.CommonDialog;
import com.app.workit.view.ui.common.evaluation.ReviewsDialogFragment;
import com.app.workit.view.ui.hire.HireHomeFragment;
import com.app.workit.view.ui.hire.job.PostedJobFragment;
import com.app.workit.view.ui.hire.job.ReceivedJobFragment;
import com.app.workit.view.ui.hire.workschedule.WorkScheduleFragment;
import com.app.workit.view.ui.hire.workschedule.WorkScheduleInfoFragment;
import com.app.workit.view.ui.work.WorkHomeFragment;

import com.app.workit.view.ui.work.accountsettings.AccountSettingsFragment;
import com.app.workit.view.ui.work.accountsettings.CreditsFragment;
import com.app.workit.view.ui.work.bids.ActiveBidFragment;
import com.app.workit.view.ui.work.bids.RejectedBidFragment;
import com.app.workit.view.ui.work.bids.RunningJobFragment;
import dagger.Module;
import dagger.android.ContributesAndroidInjector;

@Module
public abstract class FragmentInjectorModule {

    @ContributesAndroidInjector
    abstract AddBankDialogFragment contributeAddBankDialogFragment();

    @ContributesAndroidInjector
    abstract CommonDialog contributeCommonDialogFragment();

    @ContributesAndroidInjector
    abstract HireHomeFragment contributeHireHomeFragment();

    @ContributesAndroidInjector
    abstract WorkHomeFragment contributeWorkHomeFragment();

    @ContributesAndroidInjector
    abstract ActiveBidFragment contributeActiveFragment();

    @ContributesAndroidInjector
    abstract RejectedBidFragment contributeRejectedBidFragment();

    @ContributesAndroidInjector
    abstract RunningJobFragment contributeRunningJobFragment();

    @ContributesAndroidInjector
    abstract PostedJobFragment contributePostedJobFragment();

    @ContributesAndroidInjector
    abstract ReceivedJobFragment contributeReceivedJobFragment();

    @ContributesAndroidInjector
    abstract ReviewsDialogFragment contributeReviewsDialogFragment();

    @ContributesAndroidInjector
    abstract WorkScheduleFragment contributeWorkScheduleFragment();

    @ContributesAndroidInjector
    abstract WorkScheduleInfoFragment contributeWorkScheduleInfoFragment();

    @ContributesAndroidInjector
    abstract CreditsFragment contributeCreditsFragment();

    @ContributesAndroidInjector
    abstract AccountSettingsFragment contributeAccountSettingsFragment();
}
