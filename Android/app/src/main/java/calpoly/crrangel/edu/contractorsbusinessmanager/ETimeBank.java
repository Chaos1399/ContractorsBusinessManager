package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;

public class ETimeBank extends EmpSuperclass {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_etime_bank);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            // Respond to the action bar's Up/Home button
            case android.R.id.home:
                menu = new Intent(this, EMenu.class);
                addExtras(menu);
                navigateUpTo(menu);
                return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
