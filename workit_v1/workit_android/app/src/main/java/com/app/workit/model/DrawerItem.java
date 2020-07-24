package com.app.workit.model;

public class DrawerItem {
    private final int drawable;
    protected String itemName;
    protected int id;


    public DrawerItem(int id, String itemName, int image) {
        this.itemName = itemName;
        this.id = id;
        this.drawable = image;
    }

    public int getDrawable() {
        return drawable;
    }

    public String getItemName() {
        return itemName;
    }

    public int getId() {
        return id;
    }

}
