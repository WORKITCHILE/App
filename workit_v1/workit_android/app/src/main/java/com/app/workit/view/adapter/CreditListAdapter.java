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
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.app.workit.R;
import com.app.workit.data.model.Transaction;
import com.app.workit.util.Timing;
import de.hdodenhof.circleimageview.CircleImageView;

import java.util.ArrayList;
import java.util.List;

public class CreditListAdapter extends RecyclerView.Adapter<CreditListAdapter.CreditHolder> {

    private Context context;
    private List<Transaction> credits;

    public CreditListAdapter(Context context) {
        this.context = context;
        credits = new ArrayList<>();
    }

    public List<Transaction> getCredits() {
        return credits;
    }

    public void updateList(List<Transaction> newCredits) {
        credits.clear();
        credits.addAll(newCredits);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public CreditHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new CreditHolder(LayoutInflater.from(context).inflate(R.layout.item_credit, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull CreditHolder holder, int position) {
        try {
            Transaction transaction = credits.get(position);
            holder.crediterName.setText(transaction.getOppositeUser() == null ? transaction.getUserName() : transaction.getOppositeUser().toString());
            holder.creditStatus.setText(transaction.getTransactionFor());
            holder.date.setText(Timing.getTimeInStringWithoutStamp(transaction.getCreatedAt(), Timing.TimeFormats.DD_MM_YYYY));
            holder.creditValue.setText(context.getString(R.string.price_in_dollar, transaction.getAmount()));
            Glide.with(context).load(transaction.getUserImage()).apply(new RequestOptions()
                    .error(R.drawable.rotate_spinner)
                    .centerCrop().placeholder(R.drawable.rotate_spinner)).into(holder.avatar);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int getItemCount() {
        return credits.size();
    }

    public class CreditHolder extends RecyclerView.ViewHolder {
        @BindView(R.id.avatar)
        CircleImageView avatar;
        @BindView(R.id.crediter_name)
        TextView crediterName;
        @BindView(R.id.date)
        TextView date;
        @BindView(R.id.credit_value)
        TextView creditValue;
        @BindView(R.id.credit_status)
        TextView creditStatus;

        public CreditHolder(@NonNull View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }
}
