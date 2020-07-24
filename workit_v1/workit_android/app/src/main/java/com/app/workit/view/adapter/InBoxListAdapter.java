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
import com.app.workit.data.model.InBox;
import com.app.workit.util.Timing;
import com.app.workit.view.callback.IAdapterItemClickListener;
import de.hdodenhof.circleimageview.CircleImageView;

import java.util.ArrayList;
import java.util.List;

public class InBoxListAdapter extends RecyclerView.Adapter<InBoxListAdapter.InBoxHolder> {

    private final String selfUserId;
    private Context mContext;
    private List<InBox> messagesInBoxes;
    private IAdapterItemClickListener iAdapterItemClickListener;

    public void setiAdapterItemClickListener(IAdapterItemClickListener iAdapterItemClickListener) {
        this.iAdapterItemClickListener = iAdapterItemClickListener;
    }

    public InBoxListAdapter(Context mContext, String selfUserId) {
        this.mContext = mContext;
        this.selfUserId = selfUserId;
        messagesInBoxes = new ArrayList<>();
    }

    public void updateList(List<InBox> newInBoxes) {
        if (messagesInBoxes.isEmpty()) {
            messagesInBoxes.addAll(newInBoxes);
            notifyItemRangeInserted(0, newInBoxes.size());
        } else {
            int oldSize = messagesInBoxes.size();
            messagesInBoxes.clear();
            notifyItemRangeRemoved(0, oldSize);
            messagesInBoxes.addAll(newInBoxes);
            notifyItemRangeInserted(0, newInBoxes.size());

        }

    }

    @NonNull
    @Override
    public InBoxHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new InBoxHolder(LayoutInflater.from(mContext).inflate(R.layout.item_inbox, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull InBoxHolder holder, int position) {
        try {
            InBox inBox = messagesInBoxes.get(position);
            if (selfUserId.equalsIgnoreCase(inBox.getLastMessageBy())) {
                Glide.with(mContext).load(inBox.getSenderImage()).apply(new RequestOptions()
                        .error(R.drawable.rotate_spinner)
                        .centerCrop().placeholder(R.drawable.rotate_spinner)).into(holder.avatar);

                holder.message.setText(inBox.getLastMessage());
                holder.userName.setText(inBox.getSenderName());
                holder.date.setText(Timing.getTimeInStringWithoutStamp(inBox.getCreatedAt(), Timing.TimeFormats.DD_MM_YYYY));
            } else {
                Glide.with(mContext).load(inBox.getSenderImage()).apply(new RequestOptions()
                        .error(R.drawable.rotate_spinner)
                        .centerCrop().placeholder(R.drawable.rotate_spinner)).into(holder.avatar);

                holder.message.setText(inBox.getLastMessage());
                holder.userName.setText(inBox.getSenderName());
                holder.date.setText(Timing.getTimeInStringWithoutStamp(inBox.getCreatedAt(), Timing.TimeFormats.DD_MM_YYYY));
            }


        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<InBox> getMessagesInBoxes() {
        return messagesInBoxes;
    }

    @Override
    public int getItemCount() {
        return messagesInBoxes.size();
    }

    public class InBoxHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        @BindView(R.id.avatar)
        CircleImageView avatar;
        @BindView(R.id.userName)
        TextView userName;
        @BindView(R.id.message)
        TextView message;
        @BindView(R.id.date)
        TextView date;

        public InBoxHolder(@NonNull View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
            itemView.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            if (iAdapterItemClickListener == null) return;
            iAdapterItemClickListener.onAdapterItemClick(v, getAdapterPosition());
        }
    }
}
