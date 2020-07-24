package com.app.workit.view.ui.common.inbox;

import android.os.Bundle;

import android.view.View;
import android.widget.TextView;
import androidx.annotation.Nullable;

import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.LinearLayoutManager;
import butterknife.BindView;
import butterknife.ButterKnife;
import com.app.workit.R;
import com.app.workit.data.model.InBox;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.InBoxListAdapter;
import com.app.workit.view.callback.IAdapterItemClickListener;
import com.app.workit.view.ui.base.BaseActivity;
import com.app.workit.view.ui.common.chat.ChatActivity;
import com.app.workit.view.ui.customview.BaseRecyclerView;

import javax.inject.Inject;

public class InboxActivity extends BaseActivity implements IAdapterItemClickListener {
    @BindView(R.id.inbox_messages)
    BaseRecyclerView inboxBaseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    @Inject
    ViewModelFactory viewModelFactory;
    private InboxViewModel inboxViewModel;
    private InBoxListAdapter inBoxListAdapter;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_inbox);
        ButterKnife.bind(this);
        setToolbarTitle(R.string.inbox);
        inboxViewModel = ViewModelProviders.of(this, viewModelFactory).get(InboxViewModel.class);

    }

    @Override
    protected void initView() {
        initInBox();
        inboxViewModel.getInboxLiveData().observe(this, inBoxNetworkResponseList -> {
            switch (inBoxNetworkResponseList.status) {
                case LOADING:
                    showLoading();
                    break;
                case ERROR:
                    hideLoading();
                    showErrorPrompt(inBoxNetworkResponseList.message);
                    break;
                case SUCCESS:
                    hideLoading();
                    inBoxListAdapter.updateList(inBoxNetworkResponseList.response);
                    break;
            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        inboxViewModel.getInboxMessages();
    }

    private void initInBox() {
        inboxBaseRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        inboxBaseRecyclerView.setEmptyView(this, emptyView, R.string.no_messages_found);

        inBoxListAdapter = new InBoxListAdapter(this, userInfo.getUserId());
        inBoxListAdapter.setiAdapterItemClickListener(this);
        inboxBaseRecyclerView.setAdapter(inBoxListAdapter);

    }

    @Override
    public void onAdapterItemClick(View v, int position) {
        InBox inBox = inBoxListAdapter.getMessagesInBoxes().get(position);
        if (userInfo.getUserId().equalsIgnoreCase(inBox.getReceiver())) {
            startActivity(ChatActivity.createIntent(this, inBox.getJobId(), inBox.getSender(), inBox.getSenderName(), inBox.getSenderImage()));
        } else {
            startActivity(ChatActivity.createIntent(this, inBox.getJobId(),
                    inBox.getReceiver(), inBox.getReceiverName(), inBox.getReceiverImage()));
        }

    }
}
