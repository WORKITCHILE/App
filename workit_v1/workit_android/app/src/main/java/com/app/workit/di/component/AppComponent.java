package com.app.workit.di.component;

import android.app.Application;

import com.app.workit.WorkItApp;
import com.app.workit.di.module.ActivityInjectorModule;
import com.app.workit.di.module.AppModule;
import com.app.workit.di.module.FragmentInjectorModule;
import com.app.workit.di.module.RetrofitModule;
import com.app.workit.di.scope.AppScope;
import com.app.workit.view.ui.common.signup.SignUpActivity;

import dagger.BindsInstance;
import dagger.Component;
import dagger.android.AndroidInjectionModule;
import dagger.android.AndroidInjector;
import dagger.android.support.AndroidSupportInjectionModule;

@AppScope
@Component(modules = {AndroidInjectionModule.class, AndroidSupportInjectionModule.class, ActivityInjectorModule.class
        , FragmentInjectorModule.class, AppModule.class
        , RetrofitModule.class})
public interface AppComponent extends AndroidInjector<WorkItApp> {

    @Component.Builder
    interface Builder {
        @BindsInstance
        Builder application(Application application);

        AppComponent build();
    }

    @Override
    void inject(WorkItApp instance);

    void inject(SignUpActivity signUpActivity);
}
