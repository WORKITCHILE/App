package com.app.workit.model;

import androidx.annotation.NonNull;

public class BankAccountType {
    public String name;
    public int id;

    public BankAccountType(String name, int id) {
        this.name = name;
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    @NonNull
    @Override
    public String toString() {
        return name;
    }
}
