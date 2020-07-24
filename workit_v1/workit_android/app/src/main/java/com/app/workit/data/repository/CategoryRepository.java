package com.app.workit.data.repository;

import com.app.workit.data.model.Category;
import com.app.workit.data.model.SubCategory;
import com.app.workit.data.network.APIService;
import com.app.workit.data.network.StandardResponseList;

import javax.inject.Inject;

import io.reactivex.Observable;

public class CategoryRepository {
    private APIService apiService;

    @Inject
    public CategoryRepository(APIService apiService) {
        this.apiService = apiService;
    }

    public Observable<StandardResponseList<Category>> getCategories() {
        return apiService.getCategories();
    }

    public Observable<StandardResponseList<SubCategory>> getSubCategories(String id) {
        return apiService.getSubCategory(id);
    }
}

