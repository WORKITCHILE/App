package com.app.workit.view.ui.work;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import android.widget.TextView;

import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.GridLayoutManager;

import butterknife.BindView;
import com.app.workit.R;
import com.app.workit.data.model.Category;
import com.app.workit.model.rxevent.RxRefreshAction;
import com.app.workit.util.RxBus;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.CategoryListAdapter;
import com.app.workit.view.callback.IAdapterItemClickListener;
import com.app.workit.view.ui.base.MainBaseFragment;

import butterknife.ButterKnife;
import butterknife.Unbinder;
import com.app.workit.view.ui.customview.BaseRecyclerView;
import com.app.workit.view.ui.work.search.SubCategoryActivity;

import javax.inject.Inject;

public class WorkHomeFragment extends MainBaseFragment implements IAdapterItemClickListener {

    private Unbinder unbinder;
    @BindView(R.id.rv_categories)
    BaseRecyclerView categoriesRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyView;
    private CategoryListAdapter categoryListAdapter;

    @Inject
    ViewModelFactory viewModelFactory;
    private WorkHomeViewModel workHomeViewModel;

    public static WorkHomeFragment newInstance() {

        Bundle args = new Bundle();

        WorkHomeFragment fragment = new WorkHomeFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        unbinder.unbind();
    }

    @Override
    protected void initViewsForFragment(View view) {
        workHomeViewModel = ViewModelProviders.of(this, viewModelFactory).get(WorkHomeViewModel.class);
        initCategories();
    }

    private void initCategories() {
        categoriesRecyclerView.setLayoutManager(new GridLayoutManager(getmContext(), 2));

        // categoriesRecyclerView.setEmptyView(getmContext(), emptyView, R.string.no_data_found);

        categoryListAdapter = new CategoryListAdapter(getmContext());
        categoryListAdapter.setiAdapterItemClickListener(this);
        categoriesRecyclerView.setAdapter(categoryListAdapter);

        workHomeViewModel.getCategories();
        workHomeViewModel.getCategoryMutableLiveData().observe(getViewLifecycleOwner(), categoryNetworkResponseList -> {
            switch (categoryNetworkResponseList.status) {
                case LOADING:
                    RxBus.getInstance().setEvent(new RxRefreshAction(true));
                    break;
                case ERROR:
                    RxBus.getInstance().setEvent(new RxRefreshAction(false));
                    showErrorPrompt(categoryNetworkResponseList.message);
                    break;
                case SUCCESS:
                    RxBus.getInstance().setEvent(new RxRefreshAction(false));
                    categoryListAdapter.updateList(categoryNetworkResponseList.response);
                    if (categoryNetworkResponseList.response.isEmpty()) {
                        emptyView.setVisibility(View.VISIBLE);
                    } else {
                        emptyView.setVisibility(View.GONE);
                    }
                    break;
            }
        });

    }

    @Override
    protected View inflateFragmentView(LayoutInflater inflater, ViewGroup container) {
        View view = inflater.inflate(R.layout.fragment_work_home, container, false);
        unbinder = ButterKnife.bind(this, view);
        return view;
    }

    @Override
    public void onAdapterItemClick(View v, int position) {
        Category category = categoryListAdapter.getCategories().get(position);
        startActivity(SubCategoryActivity.createIntent(getmContext(), category.getCategoryId(),category.getCategoryName()));

    }
}
