package com.app.workit.view.ui.common;

import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.Switch;
import android.widget.TextView;

import androidx.annotation.LayoutRes;
import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.widget.AppCompatRatingBar;
import androidx.appcompat.widget.Toolbar;
import androidx.core.view.GravityCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import butterknife.OnClick;
import com.app.workit.view.ui.common.termsofservice.TermsOfServiceActivity;
import com.app.workit.view.ui.work.accountsettings.AccountSettingsActivity;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.app.workit.R;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.UserInfo;
import com.app.workit.model.DrawerItem;
import com.app.workit.util.AppConstants;
import com.app.workit.util.Helper;
import com.app.workit.util.UIHelper;
import com.app.workit.view.adapter.DrawerAdapter;
import com.app.workit.view.callback.IAdapterItemClickListener;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.common.credits.CreditsActivity;
import com.app.workit.view.ui.common.evaluation.EvaluationActivity;
import com.app.workit.view.ui.common.history.HistoryActivity;
import com.app.workit.view.ui.common.inbox.InboxActivity;
import com.app.workit.view.ui.common.notification.NotificationActivity;
import com.app.workit.view.ui.common.profile.ProfileActivity;
import com.app.workit.view.ui.common.runningjob.RunningJobActivity;
import com.app.workit.view.ui.common.support.SupportActivity;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import javax.inject.Inject;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.Unbinder;
import com.app.workit.view.ui.hire.workschedule.WorkScheduleActivity;
import com.app.workit.view.ui.work.bids.BidsActivity;
import de.hdodenhof.circleimageview.CircleImageView;

public abstract class CommonDrawerActivity extends MainBaseActivity implements IAdapterItemClickListener {
    //--------------Globals----------------------------
    protected ArrayList<DrawerItem> baseItems = new ArrayList<>();
    boolean doubleBackToExitPressedOnce = false;
    //--------------Views------------------------------
    @BindView(R.id.profile_image)
    CircleImageView profileImage;
    @BindView(R.id.tv_user_name)
    TextView userName;
    @BindView(R.id.rb_user_rating)
    AppCompatRatingBar ratingBar;
    @BindView(R.id.drawer_layout)
    DrawerLayout drawerLayout;
    @BindView(R.id.rv_navigation_items)
    RecyclerView drawerOptions;
    @BindView(R.id.switch_role)
    public Switch switchRole;
    @BindView(R.id.fl_base_container)
    protected FrameLayout frameLayout;

    private TextView mBusinessName;
    protected ActionBarDrawerToggle actionBarDrawerToggle;
    protected UserInfo userInfoModel;
    protected boolean isHomeAsUp = false;
    private Unbinder unbinder;


    @Inject
    DataManager dataManager;

    private DrawerAdapter drawerAdapter;

    protected abstract void onRoleChanged(boolean isChecked);

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //     super.setContentView(R.layout.m_navigation_drawer_layout);
    }

    @Override
    public void setContentView(@LayoutRes int layoutResID) {
        super.setContentView(layoutResID);

        userInfoModel = dataManager.loadUser();
        onCreateDrawer();
    }


    private void onCreateDrawer() {

        unbinder = ButterKnife.bind(this);


        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        Objects.requireNonNull(getSupportActionBar()).setDisplayShowTitleEnabled(false);

        if (userInfoModel != null) {
            userName.setText(userInfoModel.getName());
            ratingBar.setRating(Float.parseFloat(userInfoModel.getAverageRating()));
            Glide.with(this).load(userInfoModel.getProfilePicture()).apply(new RequestOptions()
                    .error(R.drawable.no_image_available)
                    .centerCrop().placeholder(R.drawable.rotate_spinner)).into(profileImage);

            switchRole.setChecked(userInfoModel.getType().equalsIgnoreCase(AppConstants.USER_TYPE.WORK));
        }
        switchRole.setOnCheckedChangeListener((buttonView, isChecked) -> {
            userInfoModel.setType(isChecked ? AppConstants.USER_TYPE.WORK : AppConstants.USER_TYPE.HIRE);
            dataManager.saveUser(userInfoModel);
            if (buttonView.isPressed()) {
                List<DrawerItem> items;
                if (isChecked) {
                    items = Helper.getDrawerOptionsWork(this);
                } else {
                    items = Helper.getDrawerOptionsHire(this);
                }
                drawerAdapter.updateList(items);
                onRoleChanged(isChecked);
                closeDrawer();
            }
        });
//        updateDisposable = RxBus.getInstance().getEvents().subscribe(o -> {
//            if (o instanceof UpdateAccountAction) {
//                UpdateAccountAction updateAccountAction = (UpdateAccountAction) o;
//                userName.setText(updateAccountAction.getName() != null ? updateAccountAction.getName() : userInfoModel.getName());
//                userEmail.setText(updateAccountAction.getEmail() != null ? updateAccountAction.getEmail() : userInfoModel.getEmail());
//                Glide.with(this).load(AppConstants.IMAGE_URL + (updateAccountAction.getImage() != null ? updateAccountAction.getImage() : userInfoModel.getProfileImage())).apply(new RequestOptions()
//                        .error(R.drawable.no_image_available)
//                        .centerCrop().placeholder(R.drawable.no_image_available)).into(profileImage);
//            }
//        });
//        if (userInfoModel != null) {
//            if (userInfoModel.getType() == AppConstants.USER_TYPE.GUEST) {
//                userName.setText(R.string.guest);
//                userEmail.setVisibility(View.GONE);
//                containerRating.setVisibility(View.GONE);
//            } else {
//                userName.setText(userInfoModel.getName());
//                userEmail.setText(userInfoModel.getEmail());
//                ratingBar.setRating(Float.parseFloat(userInfoModel.getRating()));
//                ratingUser.setText(getString(R.string.rating_value, Float.parseFloat(userInfoModel.getRating())));
//            }
//
//
//            if (mBusinessName != null && userInfoModel.getBusinessName() != null) {
//                mBusinessName.setText(userInfoModel.getBusinessName());
//            }
//            Glide.with(this).load(userInfoModel.getProfileImage()).apply(new RequestOptions()
//                    .error(R.drawable.no_image_available)
//                    .centerCrop().placeholder(R.drawable.no_image_available)).into(profileImage);
//
//        }
        actionBarDrawerToggle = new ActionBarDrawerToggle(this, drawerLayout, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        actionBarDrawerToggle.setDrawerIndicatorEnabled(false);

        actionBarDrawerToggle.setHomeAsUpIndicator(R.drawable.ic_button);
        drawerLayout.addDrawerListener(actionBarDrawerToggle);
        actionBarDrawerToggle.setToolbarNavigationClickListener(v -> {

            if (isHomeAsUp) {
                onBackPressed();
            } else {
                drawerLayout.openDrawer(GravityCompat.START);
            }

        });


        //SetUp Drawer Options

        createDrawerOptions();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unbinder.unbind();
//        updateDisposable.dispose();
    }


    private void createDrawerOptions() {
        baseItems.clear();
        try {
            switch (userInfoModel.getType()) {
                default:
                case AppConstants.USER_TYPE.HIRE:
                    baseItems.addAll(Helper.getDrawerOptionsHire(this));
                    break;
                case AppConstants.USER_TYPE.WORK:
                    baseItems.addAll(Helper.getDrawerOptionsWork(this));
                    break;
            }
        } catch (Exception e) {

        }
        //Adding child
        drawerOptions.setLayoutManager(new

                LinearLayoutManager(this));
        drawerOptions.setNestedScrollingEnabled(true);
        drawerAdapter = new DrawerAdapter(this, R.layout.item_drawer, baseItems);
        drawerAdapter.setiAdapterItemClickListener(this);
        drawerOptions.setAdapter(drawerAdapter);
        drawerAdapter.notifyDataSetChanged();
    }

    @Override
    protected void onPostCreate(@Nullable Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        actionBarDrawerToggle.syncState();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        actionBarDrawerToggle.syncState();
    }


    @Override
    public void onBackPressed() {
        if (drawerLayout.isDrawerOpen(GravityCompat.START)) {
            drawerLayout.closeDrawer(GravityCompat.START);
        } else {
            if (this instanceof HomeActivity) {
                //Checking for fragment count on backstack
                if (getSupportFragmentManager().getBackStackEntryCount() > 0) {
                    getSupportFragmentManager().popBackStack();
                } else if (!doubleBackToExitPressedOnce) {
                    this.doubleBackToExitPressedOnce = true;
                    showMessage(R.string.please_press_back_again_to_exit);
                    new Handler().postDelayed(() -> doubleBackToExitPressedOnce = false, 2000);
                } else {
                    super.onBackPressed();

                }
            } else {
                super.onBackPressed();
            }

        }


    }


    @OnClick(R.id.header_navBar)
    public void onProfile() {
        UIHelper.getInstance().switchActivity(this, ProfileActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
        if (drawerLayout.isDrawerOpen(GravityCompat.START)) {
            drawerLayout.closeDrawer(GravityCompat.START);

        }
    }

    @Override
    public void onAdapterItemClick(View v, int position) {
        switch (baseItems.get(position).getId()) {
            case AppConstants.DrawerOptions.NOTIFICATIONS:
                UIHelper.getInstance().switchActivity(this, NotificationActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
                break;
            case AppConstants.DrawerOptions.INBOX:
                UIHelper.getInstance().switchActivity(this, InboxActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
                break;
            case AppConstants.DrawerOptions.EVALUATIONS:
                UIHelper.getInstance().switchActivity(this, EvaluationActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
                break;
            case AppConstants.DrawerOptions.RUNNING_JOBS:
                UIHelper.getInstance().switchActivity(this, RunningJobActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
                break;
            case AppConstants.DrawerOptions.HISTORY:
                UIHelper.getInstance().switchActivity(this, HistoryActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
                break;
            case AppConstants.DrawerOptions.SUPPORT:
                UIHelper.getInstance().switchActivity(this, SupportActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
                break;
            case AppConstants.DrawerOptions.CREDITS:
                UIHelper.getInstance().switchActivity(this, CreditsActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
                break;
            case AppConstants.DrawerOptions.ACCOUNT_SETTINGS:
                UIHelper.getInstance().switchActivity(this, AccountSettingsActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
                break;
            case AppConstants.DrawerOptions.MY_BIDS:
                UIHelper.getInstance().switchActivity(this, BidsActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
                break;
            case AppConstants.DrawerOptions.WORK_SCHEDULE:
                UIHelper.getInstance().switchActivity(this, WorkScheduleActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
                break;
            case AppConstants.DrawerOptions.TERMS_OF_SERVICE:
                UIHelper.getInstance().switchActivity(this, TermsOfServiceActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, false);
                break;
            case AppConstants.DrawerOptions.LOGOUT:
                onLogOUt();
                break;
        }

        closeDrawer();
    }

    private void closeDrawer() {
        if (drawerLayout.isDrawerOpen(GravityCompat.START)) {
            drawerLayout.closeDrawer(GravityCompat.START);

        }
    }

    protected abstract void onLogOUt();

}
