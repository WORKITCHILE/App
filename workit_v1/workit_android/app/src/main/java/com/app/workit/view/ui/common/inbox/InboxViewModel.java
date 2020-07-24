package com.app.workit.view.ui.common.inbox;

import android.app.Application;
import androidx.lifecycle.MutableLiveData;
import com.app.workit.data.model.InBox;
import com.app.workit.data.network.NetworkResponseList;
import com.app.workit.data.network.StandardResponseList;
import com.app.workit.data.repository.InBoxRepository;
import com.app.workit.mvvm.BaseViewModel;
import io.reactivex.functions.Consumer;

public class InboxViewModel extends BaseViewModel {

    private InBoxRepository inBoxRepository;
    private MutableLiveData<NetworkResponseList<InBox>> inboxLiveData = new MutableLiveData<>();

    public InboxViewModel(InBoxRepository inBoxRepository, Application application) {
        super(application);
        this.inBoxRepository = inBoxRepository;
    }

    public MutableLiveData<NetworkResponseList<InBox>> getInboxLiveData() {
        return inboxLiveData;
    }

    public void getInboxMessages() {
        inboxLiveData.postValue(NetworkResponseList.loading());
        compositeDisposable.add(inBoxRepository.getInboxMessages()
                .compose(applySchedulers())
                .subscribe(new Consumer<StandardResponseList<InBox>>() {
                    @Override
                    public void accept(StandardResponseList<InBox> inBoxStandardResponseList) throws Exception {
                        inboxLiveData.postValue(NetworkResponseList.success(inBoxStandardResponseList.getResponse()));
                    }
                }, new Consumer<Throwable>() {
                    @Override
                    public void accept(Throwable throwable) throws Exception {
                        inboxLiveData.postValue(NetworkResponseList.error(parseError(throwable)));
                    }
                }));
    }
}
