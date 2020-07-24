package com.app.workit.view.ui.common.notification;

import android.os.Bundle;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.app.workit.R;
import com.app.workit.data.model.Notification;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.NotificationListAdapter;
import com.app.workit.view.ui.base.BaseActivity;
import com.app.workit.view.ui.customview.BaseRecyclerView;

import javax.inject.Inject;

import butterknife.BindView;
import butterknife.ButterKnife;

public class NotificationActivity extends BaseActivity {

    @BindView(R.id.base_recycler_view)
    BaseRecyclerView notificationBaseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;

    private NotificationListAdapter notificationListAdapter;

    @Inject
    ViewModelFactory viewModelFactory;
    private NotificationViewModel notificationViewModel;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_notifications);
        setToolbarTitle(R.string.notifications);
        ButterKnife.bind(this);
        notificationViewModel = ViewModelProviders.of(this, viewModelFactory).get(NotificationViewModel.class);
    }

    @Override
    protected void initView() {
        initNotifications();
        notificationViewModel.getNotifications();
        notificationViewModel.getNotificationsLiveData().observe(this, notificationNetworkResponseList -> {
            switch (notificationNetworkResponseList.status) {
                case LOADING:
                    showLoading();
                    break;
                case ERROR:
                    hideLoading();
                    showErrorPrompt(notificationNetworkResponseList.message);
                    break;
                case SUCCESS:
                    hideLoading();
                    notificationListAdapter.updateList(notificationNetworkResponseList.response);
                    break;
            }
        });
    }

    private void initNotifications() {
        notificationBaseRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        notificationBaseRecyclerView.setEmptyView(this, emptyView, R.string.no_notifications_found);

        notificationListAdapter = new NotificationListAdapter(this);
        notificationBaseRecyclerView.setAdapter(notificationListAdapter);
    }
}
