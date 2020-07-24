package com.app.workit.view.adapter;

import android.content.Context;
import android.text.format.DateUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.app.workit.R;
import com.app.workit.data.model.Notification;
import com.app.workit.data.model.RatingReview;

import java.util.ArrayList;
import java.util.List;

import butterknife.BindView;
import butterknife.ButterKnife;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import de.hdodenhof.circleimageview.CircleImageView;

public class NotificationListAdapter extends RecyclerView.Adapter<NotificationListAdapter.NotificationHolder> {

    private Context mContext;
    private List<Notification> notifications;

    public NotificationListAdapter(Context mContext) {
        this.mContext = mContext;
        notifications = new ArrayList<>();
    }

    public void updateList(List<Notification> newNotifications) {
        if (notifications.isEmpty()) {
            notifications.addAll(newNotifications);
            notifyItemRangeInserted(0, newNotifications.size());
        } else {
            int oldSize = notifications.size();
            notifications.clear();
            notifyItemRangeRemoved(0, oldSize);
            notifications.addAll(newNotifications);
            notifyItemRangeInserted(0, newNotifications.size());

        }
    }

    @NonNull
    @Override
    public NotificationHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new NotificationHolder(LayoutInflater.from(mContext).inflate(R.layout.item_notification, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull NotificationHolder holder, int position) {
        try {
            Notification notification = notifications.get(position);
            holder.title.setText(notification.getNotificationBody());
            long now = System.currentTimeMillis();
            CharSequence relativeTimeSpanString = DateUtils.getRelativeTimeSpanString(notification.getCreatedAt(), now, DateUtils.DAY_IN_MILLIS);
            holder.date.setText(relativeTimeSpanString);
            holder.sender.setText(notification.getSenderName());
            Glide.with(mContext).load(notification.getSenderImage()).apply(new RequestOptions()
                    .error(R.drawable.rotate_spinner)
                    .centerCrop().placeholder(R.drawable.rotate_spinner)).into(holder.avatar);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int getItemCount() {
        return notifications.size();
    }

    public class NotificationHolder extends RecyclerView.ViewHolder {
        @BindView(R.id.date)
        TextView date;
        @BindView(R.id.title)
        TextView title;
        @BindView(R.id.sender)
        TextView sender;
        @BindView(R.id.avatar)
        CircleImageView avatar;

        public NotificationHolder(@NonNull View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }
    }
}
