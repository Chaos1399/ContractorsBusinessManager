package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.widget.CalendarView;

import java.text.ParseException;
import java.util.Date;

public class EViewCalendar extends EmpSuperclass
        implements NavigationView.OnNavigationItemSelectedListener {

    CalendarView calendar;
    long selectedDate;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_eview_calendar);
        Toolbar toolbar = findViewById(R.id.evcToolbar);
        setSupportActionBar(toolbar);
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();
        NavigationView navigationView = findViewById(R.id.enav_view);
        navigationView.setNavigationItemSelectedListener(this);

        calendar = findViewById(R.id.evcCalendar);
        calendar.setOnDateChangeListener(new CalendarView.OnDateChangeListener() {
            @Override
            public void onSelectedDayChange(@NonNull CalendarView view, int year, int month, int dayOfMonth) {
                try {
                    Date date = df.parse((month + 1) + "/" + dayOfMonth + "/" + (year - 2000));
                    selectedDate = date.getTime();
                } catch (ParseException e) {
                    e.printStackTrace();
                }
            }
        });
        selectedDate = new Date().getTime();
    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else {
            menu = new Intent(this, EMenu.class);
            addExtras(menu);
            navigateUpTo(menu);
        }
    }

    // Drawer Item Selected
    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        int id = item.getItemId();
        Intent intent = null;

        ((DrawerLayout) findViewById(R.id.drawer_layout)).closeDrawer(GravityCompat.START);

        if (id == R.id.eLogoutMenu) {
            auth.signOut();
            intent = signOut;
        } else if (id == R.id.eMenuMenu) {
            intent = menu;
        } else if (id == R.id.editProfileMenu) {
            intent = editProfile;
        } else if (id == R.id.clockInMenu) {
            intent = clockIn;
        } else if (id == R.id.viewCalendarEMenu) {
            intent = viewCalendar;
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

    public void evcDidPressViewSchedule (View view) {
        Intent viewSched = new Intent (this, EViewSchedule.class);
        addExtras(viewSched);
        viewSched.putExtra("selectedDate", selectedDate);
        startActivity(viewSched);
    }
}
