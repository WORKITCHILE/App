package com.app.workit.view.ui.work.search;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.lifecycle.ViewModelProviders;
import androidx.recyclerview.widget.LinearLayoutManager;
import butterknife.BindView;
import butterknife.ButterKnife;
import butterknife.OnClick;
import com.app.workit.R;
import com.app.workit.data.model.CommonCheckBoxItem;
import com.app.workit.data.model.SubCategory;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.util.AppConstants;
import com.app.workit.util.ViewModelFactory;
import com.app.workit.view.adapter.CheckBoxListAdapter;
import com.app.workit.view.callback.IAdapterItemCheckChangeListener;
import com.app.workit.view.ui.base.BaseActivity;
import com.app.workit.view.ui.customview.BaseRecyclerView;

import javax.inject.Inject;
import java.util.ArrayList;

public class SubCategoryActivity extends BaseActivity implements IAdapterItemCheckChangeListener {
    @BindView(R.id.rv_subcategory)
    BaseRecyclerView subCategoriesBaseRecyclerView;
    @BindView(R.id.empty_view)
    TextView emptyview;
    private CheckBoxListAdapter checkBoxListAdapter;
    private SubCategoryViewModel subCategoryViewModel;
    private ArrayList<String> selectedSubIds = new ArrayList<>();
    @Inject
    ViewModelFactory viewModelFactory;
    private ArrayList<CommonCheckBoxItem> commonCheckBoxItems = new ArrayList<>();

    public static Intent createIntent(Context context, String categoryId, String categoryName) {
        return new Intent(context, SubCategoryActivity.class)
                .putExtra(AppConstants.K_CATEGORY_ID, categoryId)
                .putExtra(AppConstants.K_CATEGORY_NAME, categoryName);
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sub_category);
        ButterKnife.bind(this);
        String categoryName = getIntent().getStringExtra(AppConstants.K_CATEGORY_NAME);
        setToolbarTitle(categoryName == null ? "" : categoryName);
        subCategoryViewModel = ViewModelProviders.of(this, viewModelFactory).get(SubCategoryViewModel.class);
    }

    @Override
    protected void initView() {
        initCategories();

    }

    private void initCategories() {
        String categoryId = getIntent().getStringExtra(AppConstants.K_CATEGORY_ID);

        subCategoriesBaseRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        subCategoriesBaseRecyclerView.setEmptyView(this, emptyview, R.string.no_data_found);
        checkBoxListAdapter = new CheckBoxListAdapter(this);
        checkBoxListAdapter.setiCheckChangeListener(this);
        subCategoriesBaseRecyclerView.setAdapter(checkBoxListAdapter);


        subCategoryViewModel.getSubCategories(categoryId);
        subCategoryViewModel.getCategoriesLiveData().observe(this, new Observer<NetworkResponseList<SubCategory>>() {
            @Override
            public void onChanged(NetworkResponseList<SubCategory> subCategoryNetworkResponseList) {
                switch (subCategoryNetworkResponseList.status) {
                    case LOADING:
                        showLoading();
                        break;
                    case ERROR:
                        hideLoading();
                        showErrorPrompt(subCategoryNetworkResponseList.message);
                        break;
                    case SUCCESS:
                        hideLoading();
                        commonCheckBoxItems.clear();
                        commonCheckBoxItems.addAll(subCategoryNetworkResponseList.response);
                        checkBoxListAdapter.updateList(commonCheckBoxItems);
                        break;
                }
            }
        });

    }


    @OnClick(R.id.btn_next)
    public void onNext() {
        if (!selectedSubIds.isEmpty()) {
            startActivity(SearchActivity.createIntent(this, selectedSubIds));
        }

    }

    @Override
    public void onItemCheckChange(View v, int position, boolean isChecked) {
        CommonCheckBoxItem commonCheckBoxItem = checkBoxListAdapter.getCommonCheckBoxItems().get(position);
        //Category ID Selection
        if (isChecked) {
            selectedSubIds.add(commonCheckBoxItem.getId());
        } else {
            selectedSubIds.remove(position);
        }

    }
}
