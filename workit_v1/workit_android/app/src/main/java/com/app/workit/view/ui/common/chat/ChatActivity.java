package com.app.workit.view.ui.common.chat;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;
import android.widget.ViewSwitcher;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.LinearLayoutManager;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import butterknife.OnTextChanged;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.google.firebase.database.*;
import com.app.workit.R;
import com.app.workit.data.model.Chat;
import com.app.workit.util.AppConstants;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.ChatListAdapter;
import com.app.workit.view.ui.base.MainBaseActivity;
import com.app.workit.view.ui.customview.BaseRecyclerView;
import com.app.workit.view.ui.customview.edittext.WorkItEditText;
import com.theartofdev.edmodo.cropper.CropImage;
import com.theartofdev.edmodo.cropper.CropImageView;
import de.hdodenhof.circleimageview.CircleImageView;

import javax.inject.Inject;
import java.util.ArrayList;
import java.util.List;

public class ChatActivity extends MainBaseActivity {

    @BindView(R.id.chat_list_view)
    BaseRecyclerView chatBaseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    @BindView(R.id.view_switcher)
    public ViewSwitcher viewSwitcher;
    @BindView(R.id.input_chat)
    WorkItEditText inputChat;
    @BindView(R.id.chat_user_name)
    TextView chatUserName;
    @BindView(R.id.chat_avatar)
    CircleImageView chatAvatar;
    @BindView(R.id.chat_user_type)
    TextView chatUserType;
    @Inject
    ViewModelFactory viewModelFactory;
    private ChatViewModel chatViewModel;
    private ChatListAdapter chatListAdapter;
    private FirebaseDatabase firebaseDatabase;
    private DatabaseReference databaseReference;
    private Query lastQueryReference;
    private boolean isMessageListAdded;
    private String chatId = "";
    private String receiverId = "";


    public static Intent createIntent(Context context, String chatId, String receiverID, String userName, String userAvatar, String jobName) {
        return new Intent(context, ChatActivity.class)
                .putExtra(AppConstants.K_CHAT_ID, chatId)
                .putExtra(AppConstants.K_RECEIVER_ID, receiverID)
                .putExtra(AppConstants.K_RECEIVER_NAME, userName)
                .putExtra(AppConstants.K_RECEIVER_AVATAR, userAvatar)
                .putExtra(AppConstants.K_JOB_NAME, jobName);
    }

    public static Intent createIntent(Context context, String chatId, String receiverID, String userName, String userAvatar) {
        return new Intent(context, ChatActivity.class)
                .putExtra(AppConstants.K_CHAT_ID, chatId)
                .putExtra(AppConstants.K_RECEIVER_ID, receiverID)
                .putExtra(AppConstants.K_RECEIVER_NAME, userName)
                .putExtra(AppConstants.K_RECEIVER_AVATAR, userAvatar);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_chat);
        ButterKnife.bind(this);
        chatViewModel = ViewModelProviders.of(this, viewModelFactory).get(ChatViewModel.class);
    }

    @Override
    protected void initView() {
        chatId = getIntent().getStringExtra(AppConstants.K_CHAT_ID);
        receiverId = getIntent().getStringExtra(AppConstants.K_RECEIVER_ID);
        initProfile();
        initFirebase();
        initChatList();
        initListeners();
    }

    private void initProfile() {
        String receiverName = getIntent().getStringExtra(AppConstants.K_RECEIVER_NAME);
        String receiverAvatar = getIntent().getStringExtra(AppConstants.K_RECEIVER_AVATAR);
        String jobName = getIntent().getStringExtra(AppConstants.K_JOB_NAME);

        chatUserType.setText(jobName == null ? " " : jobName);
        chatUserName.setText(receiverName);
        Glide.with(this).load(receiverAvatar).apply(new RequestOptions()
                .error(R.drawable.rotate_spinner)
                .centerCrop().placeholder(R.drawable.rotate_spinner)).into(chatAvatar);
    }


    private void initFirebase() {
        firebaseDatabase = FirebaseDatabase.getInstance();
        databaseReference = firebaseDatabase.getReference(AppConstants.FIREBASE_DATABASE.K_MESSAGE).child(chatId);
        lastQueryReference = databaseReference.limitToLast(1);
    }

    private void initChatList() {
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(this);
        linearLayoutManager.setStackFromEnd(true);
        chatBaseRecyclerView.setLayoutManager(linearLayoutManager);
//        chatBaseRecyclerView.setEmptyView(this, emptyView, R.string.start_sending_message);

        chatListAdapter = new ChatListAdapter(this, receiverId);
        chatBaseRecyclerView.setAdapter(chatListAdapter);
    }

    @OnClick(R.id.iv_back)
    public void onBack() {
        onBackPressed();
    }

    @OnClick(R.id.send_attachment)
    public void onSendAttachment() {

    }

    @OnTextChanged(value = R.id.input_chat, callback = OnTextChanged.Callback.AFTER_TEXT_CHANGED)
    public void nameChanged(CharSequence text) {
        //do stuff
    }

    @OnClick(R.id.send_chat)
    public void sendChatMessage() {
        if (inputChat.getText().toString().trim().isEmpty()) {
            return;
        }
        Chat chat = new Chat();
        chat.setType(AppConstants.CHAT_TYPE.MESSAGE);
        chat.setMessage(inputChat.getText().toString().trim());
        chat.setRead_status(0);
        chat.setTime(System.currentTimeMillis() / 1000);
        chat.setSender_id(receiverId);
        chat.setReceiver_id(userInfo.getUserId());

        chat.setSender(userInfo.getUserId());
        chat.setReceiver(receiverId);
        chat.setSender_type(userInfo.getType());
        chat.setReceiver_type(userInfo.getType().equalsIgnoreCase(AppConstants.USER_TYPE.HIRE) ? AppConstants.USER_TYPE.WORK : AppConstants.USER_TYPE.HIRE);
        chat.setLast_message(chat.getMessage());
        chat.setLast_message_by(userInfo.getUserId());
        chat.setMessageType(AppConstants.CHAT_TYPE.MESSAGE);
        chat.setJob_id(chatId);
        //ID
        String key = databaseReference.push().getKey();
        chat.setId(key);
        databaseReference.child(key).setValue(chat);
        inputChat.setText("");
        chatViewModel.sendMessage(chat);
    }

    private void initListeners() {

        lastQueryReference.addChildEventListener(new ChildEventListener() {
            @Override
            public void onChildAdded(@NonNull DataSnapshot dataSnapshot, @Nullable String s) {
                try {
                    if (isMessageListAdded) {

                        chatListAdapter.addToEnd(createChat(dataSnapshot), true);
                    }

                } catch (Exception e) {
                    Log.d(getClass().getSimpleName(), e.getMessage());
                }
            }

            @Override
            public void onChildChanged(@NonNull DataSnapshot dataSnapshot, @Nullable String s) {
                Log.d(getClass().getSimpleName(), "some");
                if (isMessageListAdded) {
                    chatListAdapter.update(createChat(dataSnapshot));
                }

            }

            @Override
            public void onChildRemoved(@NonNull DataSnapshot dataSnapshot) {

            }

            @Override
            public void onChildMoved(@NonNull DataSnapshot dataSnapshot, @Nullable String s) {

            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        });
        databaseReference.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dShot) {
                try {
                    List<Chat> chatList = new ArrayList<>();
                    Iterable<DataSnapshot> children = dShot.getChildren();
                    for (DataSnapshot childSnapshot : children) {
                        chatList.add(createChat(childSnapshot));
                    }
                    chatListAdapter.addToEnd(chatList, true);
                    isMessageListAdded = true;

                    setLoadingState(false);
                } catch (Exception e) {
                    setLoadingState(false);
                    showMessage(e.getMessage());
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {

            }
        });
    }

    private Chat createChat(DataSnapshot snapshot) {
        Chat chat = new Chat();
        //Set Message
        String message = snapshot.hasChild("message") ? snapshot.child("message").getValue().toString() : null;
        chat.setMessage(message);
        // Sender
        String senderId = snapshot.child("sender_id").getValue().toString();
        chat.setSender_id(senderId);
        //Receiver
        String receiverId = snapshot.child("receiver_id").getValue().toString();
        chat.setReceiver_id(receiverId);
        //Time
        long createdAt = Long.parseLong(snapshot.hasChild("time") ? snapshot.child("time").getValue().toString() : "0");
        chat.setTime(createdAt);
        //Type
        int type = Math.toIntExact(snapshot.child("type").getValue(Long.class));
        chat.setType(type);
        //Id
        String id = snapshot.child("id").getValue().toString();
        chat.setId(id);
        //Set Seen By
        //Check For Received Message
        int readStatus = Integer.parseInt(snapshot.hasChild(AppConstants.CHAT_DATA.IS_SEEN) ? snapshot.child(AppConstants.CHAT_DATA.IS_SEEN).getValue().toString() : "0");
        chat.setRead_status(readStatus);
        //TODO CHANGE THIS LATER
        if (!receiverId.equalsIgnoreCase(userInfo.getUserId())) {
            //Check For Outgoing message
            databaseReference.child(snapshot.getKey()).child(AppConstants.CHAT_DATA.IS_SEEN).setValue(1);
        }

        return chat;
    }

    @Override
    public void setLoadingState(boolean state) {
        viewSwitcher.setDisplayedChild(state ? 0 : 1);

    }

    @OnClick(R.id.send_attachment)
    public void onAttachment() {
        CropImage.activity()
                .setGuidelines(CropImageView.Guidelines.ON)
                .start(this);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == CropImage.CROP_IMAGE_ACTIVITY_REQUEST_CODE) {
            CropImage.ActivityResult result = CropImage.getActivityResult(data);
            if (resultCode == RESULT_OK) {
                Uri resultUri = result.getUri();

//                profileViewModel.uploadProfilePicture(resultUri, uploadPath);


            } else if (resultCode == CropImage.CROP_IMAGE_ACTIVITY_RESULT_ERROR_CODE) {
                Exception error = result.getError();
            }
        }
    }
}
