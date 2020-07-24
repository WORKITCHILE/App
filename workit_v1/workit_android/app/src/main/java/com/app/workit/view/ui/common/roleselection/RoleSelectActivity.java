package com.app.workit.view.ui.common.roleselection;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageButton;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProviders;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.GetTokenResult;
import com.app.workit.R;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.UserInfo;
import com.app.workit.util.AppConstants;
import com.app.workit.util.UIHelper;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.common.HomeActivity;
import com.app.workit.view.ui.common.banking.AddBankDialogFragment;

import javax.inject.Inject;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;

import java.util.HashMap;

public class RoleSelectActivity extends MainBaseActivity implements AddBankDialogFragment.IBankSelectionCallback
        , FirebaseAuth.IdTokenListener {

    UserInfo userInfo;


    @BindView(R.id.iv_back)
    ImageButton back;
    @Inject
    DataManager dataManager;
    @Inject
    ViewModelFactory viewModelFactory;

    RoleSelectionViewModel roleSelectionViewModel;

    public static Intent createIntent(Context context) {
        return new Intent(context, RoleSelectActivity.class);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_role_layout);
        ButterKnife.bind(this);
        back.setVisibility(View.GONE);

        userInfo = dataManager.loadUser();


    }

    @Override
    protected void initView() {
        roleSelectionViewModel = ViewModelProviders.of(this, viewModelFactory).get(RoleSelectionViewModel.class);
        roleSelectionViewModel.getChangeUserRoleLiveData().observe(this, response -> {
            switch (response.status) {
                case LOADING:
                    showLoading();
                    break;
                case ERROR:
                    hideLoading();
                    showErrorPrompt(response.message);
                    break;
                case SUCCESS:
                    hideLoading();
                    dataManager.saveUser(userInfo);
                    UIHelper.getInstance().switchActivity(this, HomeActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, true);
                    break;
            }
        });
    }

    @OnClick(R.id.btn_hire)
    public void onHire() {
        userInfo.setType(AppConstants.USER_TYPE.HIRE);
        switchToType(AppConstants.USER_TYPE.HIRE);
    }

    private void switchToType(String type) {
        HashMap<String, Object> params = new HashMap<>();
        params.put(AppConstants.K_UID, userInfo.getUserId());
        params.put(AppConstants.K_TYPE, type);
        roleSelectionViewModel.changeUserRole(params);
    }

    @OnClick(R.id.btn_work)
    public void onWork() {
        userInfo.setType(AppConstants.USER_TYPE.WORK);
        switchToType(AppConstants.USER_TYPE.WORK);
//        if (userInfo.getIsBankDetailsAdded() != 0) {
//            switchToNext();
//        } else {
//            showAddBankDialog();
//        }

    }

    private void switchToNext() {

        dataManager.saveUser(userInfo);
        UIHelper.getInstance().switchActivity(this, HomeActivity.class, UIHelper.ActivityAnimations.LEFT_TO_RIGHT, null, null, true);
    }

    private void showAddBankDialog() {
        AddBankDialogFragment addBankDialogFragment = AddBankDialogFragment.newInstance();
        addBankDialogFragment.setiBankSelectionCallback(this);
        addBankDialogFragment.show(getSupportFragmentManager(), AddBankDialogFragment.class.getSimpleName());
    }

    @Override
    public void onBankAdded() {
        switchToNext();
    }

    @Override
    public void onIdTokenChanged(@NonNull FirebaseAuth firebaseAuth) {
        firebaseAuth.getCurrentUser().getIdToken(true).addOnCompleteListener(new OnCompleteListener<GetTokenResult>() {
            @Override
            public void onComplete(@NonNull Task<GetTokenResult> task) {

            }
        });
    }
}
