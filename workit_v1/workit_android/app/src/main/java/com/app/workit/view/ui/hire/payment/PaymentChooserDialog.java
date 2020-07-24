package com.app.workit.view.ui.hire.payment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.Unbinder;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.app.workit.R;
import com.app.workit.util.AppConstants;

public class PaymentChooserDialog extends BottomSheetDialogFragment {
    private Unbinder unbinder;
    private PaymentChooserCallback paymentChooserCallback;
    @BindView(R.id.available_balance)
    TextView avalBalance;


    public void setPaymentChooserCallback(PaymentChooserCallback paymentChooserCallback) {
        this.paymentChooserCallback = paymentChooserCallback;
    }

    public static PaymentChooserDialog newInstance(String credits) {

        Bundle args = new Bundle();
        args.putString(AppConstants.K_CREDITS, credits);
        PaymentChooserDialog fragment = new PaymentChooserDialog();
        fragment.setArguments(args);
        return fragment;
    }


    @Override
    public void onDestroy() {
        super.onDestroy();
        unbinder.unbind();
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_choose_payment, container, false);
        unbinder = ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        if (getArguments() != null) {
            String credits = getArguments().getString(AppConstants.K_CREDITS);
            avalBalance.setText(getString(R.string.available_bal, credits));
        }

    }

    @OnClick(R.id.pay_via_wallet)
    public void onPayViaWallet() {
        dismiss();
        paymentChooserCallback.onWalletSelected();
    }


    public interface PaymentChooserCallback {
        void onWalletSelected();
    }
}
