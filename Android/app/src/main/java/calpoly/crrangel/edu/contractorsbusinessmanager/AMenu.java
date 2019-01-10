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

        this.makeIntents(AMenu.this);
    }

	@Override
	public void onBackPressed() {
		DrawerLayout drawer = findViewById(R.id.drawer_layout);
		if (drawer.isDrawerOpen(GravityCompat.START)) {
			drawer.closeDrawer(GravityCompat.START);
		} else {
			Intent intent = getIntent();
			addExtras(intent);
			super.onBackPressed();
		}
	}

	@Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        int id = item.getItemId();
        Intent intent = null;

        ((DrawerLayout) findViewById(R.id.drawer_layout)).closeDrawer(GravityCompat.START);

        if (id == R.id.logoutmenu) {
            super.onBackPressed();
        } else if (id == R.id.counthoursmenu) {
            intent = countHours;
        } else if (id == R.id.viewcalendarmenu) {
			intent = aviewCalendar;
        } else if (id == R.id.revisehoursmenu) {
			intent = reviseHours;
        } else if (id == R.id.addjobmenu) {
			intent = addJob;
        } else if (id == R.id.addclientmenu) {
			intent = addClient;
        } else if (id == R.id.editempmenu) {
			intent = editWorker;
        } else if (id == R.id.addempmenu) {
			intent = addWorker;
        } else if (id == R.id.editclientmenu) {
			intent = editClient;
		}

		if (intent != null) {
        	addExtras(intent);
        	startActivity(intent);
		}

        return true;
    }

    public void amenuDidPressLogout (View view) {
    	writeToPersistenceStartup();
    	super.onBackPressed();
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
