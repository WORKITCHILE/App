package com.app.workit.view.ui.work;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.Category;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.CategoryRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

public class WorkHomeViewModel extends BaseViewModel {

    private CategoryRepository categoryRepository;
    private MutableLiveData<NetworkResponseList<Category>> categoryMutableLiveData = new MutableLiveData<>();

    public WorkHomeViewModel(CategoryRepository categoryRepository, Application application) {
        super(application);
        this.categoryRepository = categoryRepository;
    }


    public MutableLiveData<NetworkResponseList<Category>> getCategoryMutableLiveData() {
        return categoryMutableLiveData;
    }

    public void getCategories() {
        categoryMutableLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(categoryRepository.getCategories()
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<Category>>() {
                    @Override
                    public void accept(StandardResponseList<Category> categoryStandardResponseList) throws Exception {
                        categoryMutableLiveData.postValue(NetworkResponseList.success(categoryStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        categoryMutableLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));
    }
}
