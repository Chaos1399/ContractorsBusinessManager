package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.content.Loader;
import android.database.Cursor;
import android.os.Bundle;
import android.view.View;

public class EMenu extends AdminSuperclass {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_emenu);

        //noinspection ConstantConditions
        getActionBar().setTitle("Menu");
    }

    @Override
    public void onLoadFinished(Loader<Cursor> cursorLoader, Cursor cursor) {
        super.onLoadFinished(cursorLoader, cursor);
    }

    public void didPressLogout (View v) {
        Intent intent = new Intent(EMenu.this, Login.class);
        startActivity(intent);
    }
}