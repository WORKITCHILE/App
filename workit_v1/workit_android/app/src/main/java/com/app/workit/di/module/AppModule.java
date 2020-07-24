package com.app.workit.di.module;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.storage.FirebaseStorage;
import com.app.workit.di.ApplicationContext;
import com.app.workit.di.scope.AppScope;
import com.app.workit.util.AppConstants;

import dagger.Module;
import dagger.Provides;

@Module(includes = ViewModelModule.class)
public class AppModule {

    @Provides
    @ApplicationContext
    public Application provideApplication(Application application) {
        return application;
    }


    @Provides
    @ApplicationContext
    public Context provideContext(Application application) {
        return application.getApplicationContext();
    }


    @Provides
    @AppScope
    public SharedPreferences provideSharedPrefs(Application application) {
        return application.getSharedPreferences(AppConstants.WORK_IT_PREF, Context.MODE_PRIVATE);
    }

    @Provides
    @AppScope
    public FirebaseAuth provideFirebaseAuth() {
        return FirebaseAuth.getInstance();
    }

    @Provides
    @AppScope
    public FirebaseStorage provideFireBaseStorage() {
        return FirebaseStorage.getInstance();
    }

//    @Provides
//    @AppScope
//    public PlacesClient providePlacesClient(Application application) {
//        return Places.createClient(application);
//
//    }

    //    @Provides
//    @Singleton
//    fun provideFirebaseFirestore(): FirebaseFirestore? {
//        return FirebaseFirestore.getInstance()
//    }
//
//    @Provides
//    fun provideSharedPrefs(application: Application): SharedPreferences? {
//        return application.getSharedPreferences("mbuddy-prefs", Context.MODE_PRIVATE)
//    }
}
