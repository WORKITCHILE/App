package com.app.workit.view.ui.common.chat;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.Chat;
import com.app.workit.data.network.NetworkResponse;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.InBoxRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

public class ChatViewModel extends BaseViewModel {
    private InBoxRepository inBoxRepository;
    private MutableLiveData<NetworkResponse<String>> sentLiveData = new MutableLiveData<>();

    public ChatViewModel(InBoxRepository inBoxRepository, Application application) {
        super(application);
        this.inBoxRepository = inBoxRepository;
    }

    public MutableLiveData<NetworkResponse<String>> getSentLiveData() {
        return sentLiveData;
    }

    public void sendMessage(Chat chat) {
        sentLiveData.postValue(NetworkResponse.loading());
        compositeDisposable.add(inBoxRepository.sendMessage(chat)
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<String>>() {
                    @Override
                    public void accept(StandardResponseList<String> stringStandardResponseList) throws Exception {
                        sentLiveData.postValue(NetworkResponse.success(stringStandardResponseList.getMessage()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        sentLiveData.postValue(NetworkResponse.error(parseError(throwable)));
                    }
                }));
    }
}
