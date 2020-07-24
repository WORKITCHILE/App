package com.app.workit.mvvm;

import android.app.Application;

import androidx.lifecycle.ViewModel;

import com.app.workit.R;
import com.app.workit.data.network.RetrofitException;
import com.app.workit.data.network.StandardResponse;

import java.io.IOException;

import io.reactivex.ObservableTransformer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.schedulers.Schedulers;

public abstract class BaseViewModel extends ViewModel {

    protected CompositeDisposable compositeDisposable = new CompositeDisposable();
    private Application application;

    public BaseViewModel(Application application) {
        this.application = application;
    }


    @Override
    protected void onCleared() {
        super.onCleared();
        compositeDisposable.clear();
    }

    protected <T> ObservableTransformer<T, T> applySchedulers() {

        return upstream -> upstream.subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread());
    }

    protected String parseError(Throwable throwable) throws IOException {
        try {
            if (throwable instanceof RetrofitException) {
                RetrofitException throwableError = (RetrofitException) throwable;

                if (throwableError.getKind() == RetrofitException.Kind.NETWORK) {

                    return application.getString(R.string.please_connect_to_your_network);

                } else if (throwableError.getKind() == RetrofitException.Kind.UNEXPECTED) {
                    return application.getString(R.string.some_error);
                } else {
                    if (throwableError.getResponse().code() == 400) {
                        //400 Errors
                        StandardResponse response = throwableError.getErrorBodyAs(StandardResponse.class);
                        return response.getMessage();
                    } else if (throwableError.getResponse().code() == 404) {

                        return throwableError.getResponse().message();
                    } else if (throwableError.getResponse().code() == 401) {
                        StandardResponse response = throwableError.getErrorBodyAs(StandardResponse.class);
                        return response.getMessage();
                    } else {
                        //500 Errors
                        return application.getString(R.string.some_error);
                    }
                }

            }
        } catch (Exception e) {
            return e.getMessage();

        }


        return "";
    }
}
