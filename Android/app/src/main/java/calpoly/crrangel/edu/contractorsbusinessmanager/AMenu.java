package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;

import com.google.firebase.auth.FirebaseAuth;

// TODO: Make it check that all employees have the newest payperiod, assign if they don't
public class AMenu extends AdminSuperclass
		  implements NavigationView.OnNavigationItemSelectedListener {
	private FirebaseAuth auth;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_amenu);
		Toolbar toolbar = findViewById(R.id.amToolbar);
		setSupportActionBar(toolbar);

		DrawerLayout drawer = findViewById(R.id.drawer_layout);
		ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
				  this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
		drawer.addDrawerListener(toggle);
		toggle.syncState();

		NavigationView navigationView = findViewById(R.id.anav_view);
		navigationView.setNavigationItemSelectedListener(this);

		makeIntents(AMenu.this);

		auth = FirebaseAuth.getInstance();
	}

	@Override
	public void onBackPressed() {
		DrawerLayout drawer = findViewById(R.id.drawer_layout);
		if (drawer.isDrawerOpen(GravityCompat.START)) {
			drawer.closeDrawer(GravityCompat.START);
		} else {
			addExtras(signOut);
			super.onBackPressed();
		}
	}

	@Override
	public boolean onNavigationItemSelected(@NonNull MenuItem item) {
		int id = item.getItemId();
		Intent intent = null;

		((DrawerLayout) findViewById(R.id.drawer_layout)).closeDrawer(GravityCompat.START);

		if (id == R.id.aLogoutMenu) {
			auth.signOut();
			onBackPressed();
		} else if (id == R.id.aCountHoursMenu) {
			intent = countHours;
		} else if (id == R.id.aViewCalendarMenu) {
			intent = aviewCalendar;
		} else if (id == R.id.aReviseHoursMenu) {
			intent = reviseHours;
		} else if (id == R.id.aAddJobMenu) {
			intent = addJob;
		} else if (id == R.id.aAddClientMenu) {
			intent = addClient;
		} else if (id == R.id.aEditEmpMenu) {
			intent = editWorker;
		} else if (id == R.id.aAddEmpMenu) {
			intent = addWorker;
		} else if (id == R.id.aEditClientMenu) {
			intent = editClient;
		}

		if (intent != null) {
			addExtras(intent);
			startActivity(intent);
		}

		return true;
	}

	public void amenuDidPressLogout (View view) {
		auth.signOut();
		onBackPressed();
	}
	public void amenuDidPressCountHours (View view) {
		addExtras(countHours);
		startActivity(countHours);
	}
	public void amenuDidPressViewCalendar (View view) {
		addExtras(aviewCalendar);
		startActivity(aviewCalendar);
	}
	public void amenuDidPressReviseHours (View view) {
		addExtras(reviseHours);
		startActivity(reviseHours);
	}
	public void amenuDidPressAddJob (View view) {
		addExtras(addJob);
		startActivity(addJob);
	}
	public void amenuDidPressAddEmp (View view) {
		addExtras(addWorker);
		startActivity(addWorker);
	}
	public void amenuDidPressAddClient (View view) {
		addExtras(addClient);
		startActivity(addClient);
	}
	public void amenuDidPressEditEmp(View view) {
		addExtras(editWorker);
		startActivity(editWorker);
	}
	public void amenuDidPressEditClient (View view) {
		addExtras(editClient);
		startActivity(editClient);
	}
}
