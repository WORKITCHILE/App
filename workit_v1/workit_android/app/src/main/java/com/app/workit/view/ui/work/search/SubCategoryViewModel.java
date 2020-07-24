package com.app.workit.view.ui.work.search;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;

import com.app.workit.data.model.SubCategory;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.CategoryRepository;
import com.app.workit.mvvm.BaseViewModel;

import io.reactivex.functions.Consumer;

public class SubCategoryViewModel extends BaseViewModel {

    private CategoryRepository categoryRepository;
    private MutableLiveData<NetworkResponseList<SubCategory>> categoriesLiveData = new MutableLiveData<>();

    public SubCategoryViewModel(CategoryRepository categoryRepository, Application application) {
        super(application);
        this.categoryRepository = categoryRepository;
    }

    public MutableLiveData<NetworkResponseList<SubCategory>> getCategoriesLiveData() {
        return categoriesLiveData;
    }

    public void getSubCategories(String categoryId) {
        categoriesLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(categoryRepository.getSubCategories(categoryId)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<SubCategory>>() {
                    @Override
                    public void accept(StandardResponseList<SubCategory> subCategoryStandardResponseList) throws Exception {
                        categoriesLiveData.postValue(NetworkResponseList.success(subCategoryStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        categoriesLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));
    }
}
