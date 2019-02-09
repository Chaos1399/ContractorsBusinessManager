package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.MenuItem;
import android.view.View;

public class EMenu extends EmpSuperclass
        implements NavigationView.OnNavigationItemSelectedListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_emenu);

        Toolbar toolbar = findViewById(R.id.emToolbar);
        setSupportActionBar(toolbar);
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();
        NavigationView navigationView = findViewById(R.id.enav_view);
        navigationView.setNavigationItemSelectedListener(this);

        makeIntents(this);
        createNotificationChannel();
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            addExtras(signOut);
            startActivity(signOut);
        }
    }

    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        int id = item.getItemId();
        Intent intent = null;

        ((DrawerLayout) findViewById(R.id.drawer_layout)).closeDrawer(GravityCompat.START);

        if (id == R.id.eLogoutMenu) {
            auth.signOut();
            intent = signOut;
        }else if (id == R.id.editProfileMenu) {
            intent = editProfile;
        } else if (id == R.id.clockInMenu) {
            intent = clockIn;
        } else if (id == R.id.viewScheduleEMenu) {
            intent = viewSchedule;
        } else if (id == R.id.pphMenu) {
            intent = payPeriodHistory;
        } else if (id == R.id.timeBankMenu) {
            intent = timeBank;
        }

        if (intent != null) {
            addExtras(intent);
            startActivity(intent);
        }

        return true;
    }

    public void emenuDidPressLogout (View view) {
        auth.signOut();
        navigateUpTo(signOut);
    }
    public void emenuDidPressEditEmp (View view) {
        addExtras(editProfile);
        startActivity(editProfile);
    }
    public void emenuDidPressClockIn (View view) {
        addExtras(clockIn);
        startActivity(clockIn);
    }
    public void emenuDidPressViewSchedule (View view) {
        addExtras(viewSchedule);
        startActivity(viewSchedule);
    }
    public void emenuDidPressPayHistory (View view) {
        addExtras(payPeriodHistory);
        startActivity(payPeriodHistory);
    }
    public void emenuDidPressTimeBank (View view) {
        addExtras(timeBank);
        startActivity(timeBank);
    }
}