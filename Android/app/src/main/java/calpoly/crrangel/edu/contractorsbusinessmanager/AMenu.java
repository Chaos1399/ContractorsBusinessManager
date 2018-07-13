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

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

public class AMenu extends AdminSuperclass
        implements NavigationView.OnNavigationItemSelectedListener {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_amenu);
        Toolbar toolbar = (Toolbar) findViewById(R.id.amToolbar);
        setSupportActionBar(toolbar);

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);

        Intent toHere = getIntent();
        if (toHere.getExtras() == null) return;
        this.user = bundleToUser(toHere.getExtras().getBundle("user"));
        this.clientList = toHere.getStringArrayListExtra("cList");
        this.employeeList = toHere.getStringArrayListExtra("eList");

        this.makeIntents(AMenu.this);
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

	@Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        int id = item.getItemId();

        ((DrawerLayout) findViewById(R.id.drawer_layout)).closeDrawer(GravityCompat.START);

        if (id == R.id.logoutmenu) {
            super.onBackPressed();
        } else if (id == R.id.counthoursmenu) {
            startActivity (countHours);
        } else if (id == R.id.viewcalendarmenu) {
            startActivity (aviewCalendar);
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

    public void amenuDidPressLogout (View view) {
    	writeToPersistenceStartup();
    	super.onBackPressed();
    }
    public void amenuDidPressCountHours (View view) { startActivity(countHours); }
    public void amenuDidPressViewCalendar (View view) { startActivity(aviewCalendar); }
    public void amenuDidPressReviseHours (View view) { startActivity(reviseHours); }
    public void amenuDidPressAddJob (View view) { startActivity(addJob); }
    public void amenuDidPressAddEmp (View view) { startActivity(addWorker); }
    public void amenuDidPressAddClient (View view) { startActivity(addClient); }
    public void amenuDidPressEditEmp(View view) { startActivity(editWorker); }
    public void amenuDidPressEditClient (View view) { startActivity(editClient); }

    void writeToPersistenceStartup () {
		ValueEventListener writeBack = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					int i;
					for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
						switch (snapshot.getKey()) {
							case "ClientSize":
								snapshot.getRef().setValue(clientList.size());
								break;
							case "EmployeeSize":
								snapshot.getRef().setValue(employeeList.size());
								break;
							case "Clients":
								i = 0;
								for (DataSnapshot snap : snapshot.getChildren()) {
									snap.getRef().setValue(clientList.get(i++));
								}
								break;
							case "Employees":
								i = 0;
								for (DataSnapshot snap : snapshot.getChildren()) {
									if (employeeList.get(i).equals("Admin"))
										i++;
									snap.getRef().setValue(employeeList.get(i++));
								}
								break;
						}
					}
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		persistenceStartup.addListenerForSingleValueEvent(writeBack);
	}
}
