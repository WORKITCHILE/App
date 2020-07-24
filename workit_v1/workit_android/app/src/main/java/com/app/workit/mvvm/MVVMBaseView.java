package com.app.workit.mvvm;

import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.NetworkResponseList;

public interface MVVMBaseView {
    <T> void render(NetworkResponse<T> networkResponse, Class<T> clazz);

    <T> void render(NetworkResponseList<T> networkResponseList, Class<T> clazz);
}
