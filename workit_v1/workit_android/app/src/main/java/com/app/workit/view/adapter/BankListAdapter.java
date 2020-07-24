package com.app.workit.view.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.app.workit.R;
import com.app.workit.data.model.InBox;
import com.app.workit.model.Bank;
import com.app.workit.util.Timing;
import com.app.workit.view.callback.IAdapterItemClickListener;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import org.w3c.dom.Text;

import java.util.ArrayList;
import java.util.List;

public class BankListAdapter extends RecyclerView.Adapter<BankListAdapter.BankHolder> {

    private Context mContext;
    private List<Bank> banks;
    private IAdapterItemClickListener iAdapterItemClickListener;

    public void setiAdapterItemClickListener(IAdapterItemClickListener iAdapterItemClickListener) {
        this.iAdapterItemClickListener = iAdapterItemClickListener;
    }

    public BankListAdapter(Context mContext) {
        this.mContext = mContext;
        banks = new ArrayList<>();
    }


    public void updateList(List<Bank> newBanks) {
        if (banks.isEmpty()) {
            banks.addAll(newBanks);
            notifyItemRangeInserted(0, newBanks.size());
        } else {
            int oldSize = banks.size();
            banks.clear();
            notifyItemRangeRemoved(0, oldSize);
            banks.addAll(newBanks);
            notifyItemRangeInserted(0, newBanks.size());

        }

    }

    @NonNull
    @Override
    public BankHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new BankHolder(LayoutInflater.from(mContext).inflate(R.layout.item_bank, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull BankHolder holder, int position) {
        try {
            Bank bank = banks.get(position);
            holder.bankName.setText(bank.getBankName());
            holder.userName.setText(mContext.getString(R.string.txt_bank_username, bank.getUserName()));
            holder.accountNumber.setText(mContext.getString(R.string.txt_account_number, bank.getAccountNumber()));
            holder.accountType.setText(mContext.getString(R.string.txt_account_type, bank.getAccountType()));
            holder.rutNumber.setText(mContext.getString(R.string.txt_rut_number, bank.getrUT()));
            holder.addedOn.setText(mContext.getString(R.string.txt_added_on, Timing.getTimeInString(bank.getCreatedAt(), Timing.TimeFormats.DD_MMM_YYYY)));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int getItemCount() {
        return banks.size();
    }

    public class BankHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        @BindView(R.id.bankName)
        TextView bankName;
        @BindView(R.id.userName)
        TextView userName;
        @BindView(R.id.accountNumber)
        TextView accountNumber;
        @BindView(R.id.accountType)
        TextView accountType;
        @BindView(R.id.rutNumber)
        TextView rutNumber;
        @BindView(R.id.addedOn)
        TextView addedOn;
        @BindView(R.id.edit_bank_details)
        FloatingActionButton fabEdit;

        public BankHolder(@NonNull View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
            fabEdit.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {

        }
    }
}

