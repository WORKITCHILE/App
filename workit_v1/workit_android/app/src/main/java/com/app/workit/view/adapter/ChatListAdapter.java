package com.app.workit.view.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.app.workit.R;
import com.app.workit.data.model.Chat;
import com.app.workit.util.AppConstants;
import com.app.workit.util.Timing;

import java.util.ArrayList;
import java.util.List;

public class ChatListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private static final int TYPE_SENT_MESSAGE = 1;
    private static final int TYPE_RECEIVED_MESSAGE = 2;
    private Context mContext;
    private List<Chat> baseMessages;
    private String selfUserId;

    public ChatListAdapter(Context mContext, String selfUserId) {
        this.mContext = mContext;
        this.baseMessages = new ArrayList<>();
        this.selfUserId = selfUserId;
    }

    public void updateList(List<Chat> newBaseMessages) {
        baseMessages.clear();
        baseMessages.addAll(newBaseMessages);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        if (viewType == TYPE_SENT_MESSAGE) {
            return new SentHolder(LayoutInflater.from(mContext).inflate(R.layout.item_sent_message, parent, false));
        } else {
            return new ReceivedHolder(LayoutInflater.from(mContext).inflate(R.layout.item_received_message, parent, false));
        }
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        if (getItemViewType(position) == TYPE_SENT_MESSAGE) {
            //Sent Message;
            SentHolder sentHolder = (SentHolder) holder;
            sentHolder.bind(baseMessages.get(position));
        } else {
            ReceivedHolder receivedHolder = (ReceivedHolder) holder;
            receivedHolder.bind(baseMessages.get(position));
        }
    }

    @Override
    public int getItemViewType(int position) {
        if (baseMessages.get(position).getSender_id().equalsIgnoreCase(selfUserId)) {
            return TYPE_SENT_MESSAGE;
        } else {
            return TYPE_RECEIVED_MESSAGE;
        }
    }

    @Override
    public int getItemCount() {
        return baseMessages.size();
    }

    public void addToEnd(Chat chat, boolean last) {
        int oldSize = baseMessages.size();
        baseMessages.add(chat);
        notifyItemRangeChanged(oldSize, baseMessages.size() - oldSize);
        generateDateHeader();
    }

    public void addToEnd(List<Chat> messages, boolean last) {
        baseMessages.clear();
        baseMessages.addAll(messages);
        notifyItemRangeInserted(0, baseMessages.size());
    }

    private void generateDateHeader() {

    }

    public boolean update(Chat message) {
        int position = getMessagePositionById(message.getId());
        if (position >= 0) {
            baseMessages.set(position, message);
            notifyItemChanged(position);
            return true;
        } else {
            return false;
        }

    }

    private int getMessagePositionById(String id) {
        for (int i = 0; i < baseMessages.size(); i++) {
            Chat message = baseMessages.get(i);
            if (message.getId().equalsIgnoreCase(id)) {
                return i;
            }
        }
        return -1;
    }

    class SentHolder extends RecyclerView.ViewHolder {
        @BindView(R.id.sender_message)
        TextView sentMessage;
        @BindView(R.id.sender_message_image)
        ImageView sentMessageImage;
        @BindView(R.id.sent_time)
        TextView sentTime;
        @BindView(R.id.status)
        ImageView status;

        public SentHolder(@NonNull View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }

        public void bind(Chat message) {
            if (message.getType() == AppConstants.CHAT_TYPE.MESSAGE) {
                sentMessageImage.setVisibility(View.GONE);
                sentMessage.setVisibility(View.VISIBLE);

                sentMessage.setText(message.getMessage());
            } else {

                sentMessageImage.setVisibility(View.VISIBLE);
                sentMessage.setVisibility(View.GONE);

                Glide.with(mContext).load(message.getMessage()).apply(new RequestOptions()
                        .error(R.drawable.rotate_spinner)
                        .centerCrop().placeholder(R.drawable.rotate_spinner)).into(sentMessageImage);
            }

            sentTime.setText(Timing.getTimeInString(message.getTime(), Timing.TimeFormats.HH_12));
            status.setImageResource(message.getRead_status() == 1 ? R.drawable.ic_double_check : R.drawable.ic_double_check_disabled);

        }
    }

    class ReceivedHolder extends RecyclerView.ViewHolder {
        @BindView(R.id.receiver_message)
        TextView sentMessage;
        @BindView(R.id.receiver_message_image)
        ImageView receiverMessageImage;
        @BindView(R.id.receiver_time)
        TextView sentTime;

        public ReceivedHolder(@NonNull View itemView) {
            super(itemView);
            ButterKnife.bind(this, itemView);
        }

        public void bind(Chat message) {
            if (message.getType() == AppConstants.CHAT_TYPE.MESSAGE) {
                receiverMessageImage.setVisibility(View.GONE);
                sentMessage.setVisibility(View.VISIBLE);
                sentMessage.setText(message.getMessage());
            } else {
                receiverMessageImage.setVisibility(View.VISIBLE);
                sentMessage.setVisibility(View.GONE);

                Glide.with(mContext).load(message.getMessage()).apply(new RequestOptions()
                        .error(R.drawable.rotate_spinner)
                        .centerCrop().placeholder(R.drawable.rotate_spinner)).into(receiverMessageImage);
            }

            sentTime.setText(Timing.getTimeInString(message.getTime(), Timing.TimeFormats.HH_12));
        }
    }
}
