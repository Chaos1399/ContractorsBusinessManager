package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.os.Bundle;
import android.support.design.widget.TextInputEditText;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;

import com.google.firebase.database.FirebaseDatabase;

public class AddUser extends AdminSuperclass
        implements NavigationView.OnNavigationItemSelectedListener {
	TextInputEditText NET;
	TextInputEditText EET;
	TextInputEditText PET;
	TextInputEditText PPHET;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_user);
        Toolbar toolbar = findViewById(R.id.auToolbar);
        setSupportActionBar(toolbar);

        NET = findViewById(R.id.auNET);
        EET = findViewById(R.id.auEET);
        PET = findViewById(R.id.auPET);
        PPHET = findViewById(R.id.auPPHET);

        // Drawer stuff
        DrawerLayout drawer = findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.addDrawerListener(toggle);
        toggle.syncState();
        NavigationView navigationView = findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);

        // Make and set up all Intents
        this.makeIntents(AddUser.this);
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

		if (id == R.id.logoutmenu) {
			intent = signOut;
			navOrStart = false;
		} else if (id == R.id.amenumenu) {
			intent = menu;
			navOrStart = false;
		} else if (id == R.id.counthoursmenu)
			intent = countHours;
		else if (id == R.id.viewcalendarmenu)
			intent = aviewCalendar;
		else if (id == R.id.revisehoursmenu)
			intent = reviseHours;
		else if (id == R.id.addjobmenu)
			intent = addJob;
		else if (id == R.id.addclientmenu)
			intent = addClient;
		else if (id == R.id.editempmenu)
			intent = editWorker;
		else if (id == R.id.editclientmenu)
			intent = editClient;

		addExtras(intent);

		if (navOrStart)
			startActivity(intent);
		else
			navigateUpTo(intent);

		return true;
	}

	public void auDidPressSave(View view) {
    	String name = "";
    	String uid;
    	String email = "";
    	String password = "";
    	String pph = "";
    	String toWorkURL;
    	String payURL;
    	User tempU;
    	boolean errorSet = false;

    	if (NET.getText().toString().isEmpty()) {
    		NET.setError(getString(R.string.error_field_required));
    		errorSet = true;
		} else {
    		name = NET.getText().toString();
		}
		if (EET.getText().toString().isEmpty()) {
			EET.setError(getString(R.string.error_field_required));
			errorSet = true;
		} else {
    		email = EET.getText().toString();
		}
		if (PET.getText().toString().isEmpty()) {
			PET.setError(getString(R.string.error_field_required));
			errorSet = true;
		} else {
    		password = PET.getText().toString();
		}
		if (PPHET.getText().toString().isEmpty()) {
			PPHET.setError(getString(R.string.error_field_required));
			errorSet = true;
		} else {
    		pph = PPHET.getText().toString();
		}

		if (errorSet) return;

    	toWorkURL = scheduleBase.toString() + "/" + name;
    	payURL = FirebaseDatabase.getInstance().getReference().toString() + "/Pay Period Histories/" + name;

    	//TODO: Add auth user creation

		uid = "HASH" + name.hashCode();

    	tempU = new User(name, password, email, toWorkURL, payURL, uid, Double.valueOf(pph),
				0.0, 0.0, false, 0, 0);

    	this.employeeList.add(name);
    	userBase.child(name).setValue(tempU.toMap());

    	addExtras(menu);

    	navigateUpTo(menu);
	}

	public void addUserDidPressCancel (View view) {
    	NET.getText().clear();
    	EET.getText().clear();
    	PET.getText().clear();
    	PPHET.getText().clear();

    	Intent intent = getIntent();
    	addExtras(intent);

    	super.onBackPressed();
	}
}
