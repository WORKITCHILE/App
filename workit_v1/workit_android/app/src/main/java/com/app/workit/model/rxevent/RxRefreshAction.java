package com.app.workit.model.rxevent;

public class RxRefreshAction {
    private int type;
    private boolean isRefresh;

    public RxRefreshAction(int type, boolean isRefresh) {
        this.type = type;
        this.isRefresh = isRefresh;
    }

    public RxRefreshAction(boolean isRefresh) {
        this.isRefresh = isRefresh;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public boolean isRefresh() {
        return isRefresh;
    }

    public void setRefresh(boolean refresh) {
        isRefresh = refresh;
    }
}
