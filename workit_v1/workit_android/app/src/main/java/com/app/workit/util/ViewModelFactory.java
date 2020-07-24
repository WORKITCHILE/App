package com.app.workit.util;

import androidx.annotation.NonNull;
import androidx.lifecycle.ViewModel;
import androidx.lifecycle.ViewModelProvider;

import java.util.Map;

import javax.inject.Inject;
import javax.inject.Provider;

public class ViewModelFactory implements ViewModelProvider.Factory {

    private final Map<Class<? extends ViewModel>, Provider<ViewModel>> mProviderMap;

    @Inject
    public ViewModelFactory(Map<Class<? extends ViewModel>, Provider<ViewModel>> mProviderMap) {
        this.mProviderMap = mProviderMap;
    }

    @SuppressWarnings("unchecked")
    @NonNull
    @Override
    public <T extends ViewModel> T create(@NonNull Class<T> modelClass) {
//        return (T) mProviderMap.get(modelClass).get();
        ViewModel viewModel = mProviderMap.get(modelClass).get();
        if (viewModel == null) {
            for (Map.Entry<Class<? extends ViewModel>, Provider<ViewModel>> entry : mProviderMap.entrySet()) {
                if (modelClass.isAssignableFrom(entry.getKey())) {
                    viewModel = (T) entry.getValue();
                    break;
                }
            }
        }
        if (viewModel == null) {
            throw new IllegalArgumentException("Unknown model class " + modelClass);
        }

        try {
            return (T) viewModel;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
