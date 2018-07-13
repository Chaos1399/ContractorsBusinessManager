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

public class AViewCalendar extends AdminSuperclass
		implements NavigationView.OnNavigationItemSelectedListener {

	CalendarView calendar;
	long selectedDate;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_aview_calendar);
		Toolbar toolbar = findViewById(R.id.avcToolbar);
		setSupportActionBar(toolbar);

		calendar = findViewById(R.id.avcCalendar);
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

		// Drawer stuff
		DrawerLayout drawer = findViewById(R.id.drawer_layout);
		ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
				this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
		drawer.addDrawerListener(toggle);
		toggle.syncState();
		NavigationView navigationView = findViewById(R.id.nav_view);
		navigationView.setNavigationItemSelectedListener(this);

		// Load passed User, clientList, and employeeList
		Intent toHere = getIntent();
		if (toHere.getExtras() == null) return;
		this.user = bundleToUser(toHere.getExtras().getBundle("user"));
		this.clientList = toHere.getStringArrayListExtra("cList");
		this.employeeList = toHere.getStringArrayListExtra("eList");
		// Make and set up all Intents
		this.makeIntents(AViewCalendar.this);
		this.addExtras();
    }

	@Override
	public void onBackPressed() {
		DrawerLayout drawer = findViewById(R.id.drawer_layout);
		if (drawer.isDrawerOpen(GravityCompat.START)) {
			drawer.closeDrawer(GravityCompat.START);
		} else {
			super.onBackPressed();
		}
	}


	// Drawer Item Selected
	@SuppressWarnings("StatementWithEmptyBody")
	@Override
	public boolean onNavigationItemSelected(@NonNull MenuItem item) {
		int id = item.getItemId();

		((DrawerLayout) findViewById(R.id.drawer_layout)).closeDrawer(GravityCompat.START);

		if (id == R.id.logoutmenu) {
			navigateUpTo(signOut);
		} else if (id == R.id.amenumenu) {
			navigateUpTo(menu);
		} else if (id == R.id.counthoursmenu) {
			startActivity (countHours);
		} else if (id == R.id.revisehoursmenu) {
			startActivity (reviseHours);
		} else if (id == R.id.addjobmenu) {
			startActivity (addJob);
		} else if (id == R.id.addclientmenu) {
			startActivity (addClient);
		} else if (id == R.id.editempmenu) {
			startActivity (editWorker);
		} else if (id == R.id.addempmenu) {
			startActivity (addWorker);
		} else if (id == R.id.editclientmenu) {
			startActivity (editClient);
		}

		return true;
	}


	public void avcDidPressSchedule (View view) {
		Intent intent = new Intent(AViewCalendar.this, ASchedule.class);
		intent.putExtra("user", userToBundle(user));
		intent.putExtra("cList", clientList);
		intent.putExtra("eList", employeeList);
		intent.putExtra("date", selectedDate);
    	startActivity(intent);
	}

	public void avcDidPressTimelines (View view) {
    	Intent intent = new Intent(AViewCalendar.this, ViewJobTime.class);
    	intent.putExtra("user", userToBundle(user));
    	intent.putExtra("cList", clientList);
    	intent.putExtra("eList", employeeList);
    	intent.putExtra("date", selectedDate);
    	startActivity(intent);
	}
}
