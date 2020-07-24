package com.app.workit.view.ui.common.banking;

import android.graphics.Color;
import android.os.Bundle;
import android.util.Pair;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;

import com.github.razir.progressbutton.ButtonTextAnimatorExtensionsKt;
import com.github.razir.progressbutton.DrawableButton;
import com.github.razir.progressbutton.DrawableButtonExtensionsKt;
import com.github.razir.progressbutton.ProgressButtonHolderKt;
import com.app.workit.R;
import com.app.workit.data.local.DataManager;
import com.app.workit.data.model.UserInfo;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.model.Bank;
import com.app.workit.model.BankAccountType;
import com.app.workit.util.AppConstants;
import com.app.workit.util.FormValidatorUtil;
import com.app.workit.util.Helper;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.ui.base.BaseDialogFragment;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;

import java.util.HashMap;
import java.util.List;

import javax.inject.Inject;

import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.Unbinder;
import kotlin.Unit;

public class AddBankDialogFragment extends BaseDialogFragment {

    @BindView(R.id.et_full_name)
    WorkItEditText fullName;
    @BindView(R.id.et_id_number)
    WorkItEditText idNumber;
    @BindView(R.id.spinner_banks)
    Spinner bankSpinner;
    @BindView(R.id.spinner_account_type)
    Spinner accountTypeSpinner;
    @BindView(R.id.et_account_number)
    WorkItEditText accountNumber;
    @BindView(R.id.btn_save)
    Button btnSave;

    @Inject
    DataManager dataManager;
    @Inject
    ViewModelFactory viewModelFactory;
    BankViewModel bankViewModel;

    private IBankSelectionCallback iBankSelectionCallback;
    private List<Bank> banks;
    private List<BankAccountType> accountTypes;
    private BankAccountType selectedAccountType;
    private Bank selectedBank;
    private UserInfo userInfo;
    private Unbinder unbinder;


    public static AddBankDialogFragment newInstance() {

        Bundle args = new Bundle();

        AddBankDialogFragment fragment = new AddBankDialogFragment();
        fragment.setArguments(args);
        return fragment;
    }

    public void setiBankSelectionCallback(IBankSelectionCallback iBankSelectionCallback) {
        this.iBankSelectionCallback = iBankSelectionCallback;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(STYLE_NORMAL, R.style.AppTheme);
    }

    @Override
    protected void initViewsForFragment(View view) {
        userInfo = dataManager.loadUser();

        bankViewModel = ViewModelProviders.of(this, viewModelFactory).get(BankViewModel.class);

        bankViewModel.getAddBankLiveData().observe(getViewLifecycleOwner(), new Observer<NetworkResponse<String>>() {
            @Override
            public void onChanged(NetworkResponse<String> stringNetworkResponse) {
                switch (stringNetworkResponse.status) {
                    case LOADING:
                        showBtnProgress(btnSave);
                        break;
                    case ERROR:
                        hideBtnProgress(btnSave);
                        showErrorPrompt(stringNetworkResponse.message);
                        break;
                    case SUCCESS:
                        iBankSelectionCallback.onBankAdded();
                        dismiss();
                        break;
                }
            }
        });
        //Bind Button
        initProgressButton();
        banks = Helper.getBanks(getContext());
        accountTypes = Helper.getAccountTypes(getContext());
        initBank();
        initAccountType();


    }

    private void initProgressButton() {
        ProgressButtonHolderKt.bindProgressButton(this, btnSave);
        ButtonTextAnimatorExtensionsKt.attachTextChangeAnimator(btnSave, textChangeAnimatorParams -> {
            textChangeAnimatorParams.setFadeInMills(300);
            textChangeAnimatorParams.setFadeOutMills(300);
            return Unit.INSTANCE;
        });
    }

    private void showBtnProgress(final Button button) {
        DrawableButtonExtensionsKt.showProgress(button, progressParams -> {
            progressParams.setButtonText(getString(R.string.loading));
            progressParams.setProgressColor(Color.WHITE);
            progressParams.setGravity(DrawableButton.GRAVITY_CENTER);
            return Unit.INSTANCE;
        });
        button.setEnabled(false);

    }

    private void hideBtnProgress(final Button button) {
        button.setEnabled(true);
        DrawableButtonExtensionsKt.hideProgress(button, R.string.finish);
    }

    private void initAccountType() {
        ArrayAdapter<BankAccountType> bankAccountTypeArrayAdapter = new ArrayAdapter<>(getContext(), R.layout.item_default_spinner, accountTypes);
        accountTypeSpinner.setAdapter(bankAccountTypeArrayAdapter);
        accountTypeSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectedAccountType = accountTypes.get(position);

            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

    }

    private void initBank() {
        ArrayAdapter<Bank> banksAdapter = new ArrayAdapter<>(getContext(), R.layout.item_default_spinner, banks);
        bankSpinner.setAdapter(banksAdapter);
        bankSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                selectedBank = banks.get(position);

            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }


    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.activity_bank, container, false);
        unbinder = ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        unbinder.unbind();
    }

    @OnClick(R.id.btn_back)
    public void onBack() {
        dismiss();
    }

    @OnClick(R.id.btn_save)
    public void onSave() {
        Pair<Boolean, EditText> formValid = FormValidatorUtil.isFormValid(idNumber, fullName, accountNumber);
        boolean isValid = formValid.first;
        EditText invalidField = formValid.second;
        if (isValid) {
            if (selectedAccountType.getId() == 0) {
                showErrorPrompt(getString(R.string.field_required, getString(R.string.account_type)));
                return;
            }
            if (selectedBank.getId() == 0) {
                showErrorPrompt(getString(R.string.field_required, getString(R.string.select_your_bank)));
                return;
            }
            HashMap<String, Object> params = new HashMap<>();
            params.put(AppConstants.K_USER_ID, userInfo.getUserId());
            params.put(AppConstants.K_RUT, idNumber.getText().toString().trim());
            params.put(AppConstants.K_FULL_NAME, fullName.getText().toString().trim());
            params.put(AppConstants.K_BANK, selectedBank.getBankName());
            params.put(AppConstants.K_ACCOUNT_TYPE, selectedAccountType.getName());
            params.put(AppConstants.K_ACCOUNT_NUMBER, accountNumber.getText().toString().trim());
            bankViewModel.addBank(params);
        } else {
            invalidField.requestFocus();
            showErrorPrompt(getString(R.string.field_required, invalidField.getHint()));
        }


    }

    public interface IBankSelectionCallback {
        void onBankAdded();

    }
}
