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
		DrawerLayout drawer = findViewById(R.id.drawer_layout);
		ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
				  this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
		drawer.addDrawerListener(toggle);
		toggle.syncState();
		NavigationView navigationView = findViewById(R.id.anav_view);
		navigationView.setNavigationItemSelectedListener(this);

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


		// Make all Intents
		this.makeIntents(AViewCalendar.this);
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
		Intent intent = null;
		// False is navigateUpTo, True is startActivity
		boolean navOrStart = true;

		((DrawerLayout) findViewById(R.id.drawer_layout)).closeDrawer(GravityCompat.START);

		if (id == R.id.aLogoutMenu) {
			intent = signOut;
			navOrStart = false;
		} else if (id == R.id.aMenuMenu) {
			intent = menu;
			navOrStart = false;
		} else if (id == R.id.aCountHoursMenu)
			intent = countHours;
		else if (id == R.id.aViewCalendarMenu)
			intent = aviewCalendar;
		else if (id == R.id.aReviseHoursMenu)
			intent = reviseHours;
		else if (id == R.id.aAddJobMenu)
			intent = addJob;
		else if (id == R.id.aAddClientMenu)
			intent = addClient;
		else if (id == R.id.aEditEmpMenu)
			intent = editWorker;
		else if (id == R.id.aEditClientMenu)
			intent = editClient;

		addExtras(intent);

		if (navOrStart)
			startActivity(intent);
		else
			navigateUpTo(intent);

		return true;
	}

	public void avcDidPressSchedule (View view) {
		Intent intent = new Intent(AViewCalendar.this, ASchedule.class);
		addExtras(intent);
		intent.putExtra("date", selectedDate);
		startActivity(intent);
	}

	public void avcDidPressTimelines (View view) {
		Intent intent = new Intent(AViewCalendar.this, AViewJobTime.class);
		addExtras(intent);
		intent.putExtra("date", selectedDate);
		startActivity(intent);
	}
}
