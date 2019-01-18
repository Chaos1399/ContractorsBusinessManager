package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.Spinner;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;

public class ACountHours extends AdminSuperclass
		  implements NavigationView.OnNavigationItemSelectedListener,
		  AdapterView.OnItemSelectedListener {
	RecyclerView hourTotals;
	RecyclerView.Adapter hourTotalsAdapter;
	RecyclerView.LayoutManager hourTotalsLayoutManager;
	threeLabelBox[] threeLabelBoxes;
	PayPeriod tempPer;
	Workday tempDay;
	ArrayList<User> workerList;
	ArrayList<Double> hourList;
	ArrayList<Double> pphList;
	ArrayList<Location> locationList;
	ArrayList<String> locNameList;
	ArrayList<String> jobList;
	Spinner cSpin;
	Spinner lSpin;
	Spinner jSpin;
	ArrayAdapter<String> cAdapter;
	ArrayAdapter<String> lAdapter;
	ArrayAdapter<String> jAdapter;
	EditText pptxt;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_count_hours);
		Toolbar toolbar = findViewById(R.id.chToolbar);
		setSupportActionBar(toolbar);

		// Drawer stuff
		DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
		ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawer, toolbar,
				  R.string.navigation_drawer_open, R.string.navigation_drawer_close);
		drawer.addDrawerListener(toggle);
		toggle.syncState();
		NavigationView navigationView = findViewById(R.id.nav_view);
		navigationView.setNavigationItemSelectedListener(this);

		// Make RecyclerView
		hourTotals = findViewById(R.id.hourTotalList);
		hourTotals.setHasFixedSize(true);
		hourTotalsLayoutManager = new LinearLayoutManager(this);
		DividerItemDecoration dividerItemDecoration = new DividerItemDecoration(hourTotals.getContext(),
				  LinearLayoutManager.VERTICAL);
		hourTotals.addItemDecoration(dividerItemDecoration);
		hourTotals.setLayoutManager(hourTotalsLayoutManager);
		hourTotalBoxesZero ();

		// Make spinners
		cSpin = findViewById(R.id.chClientSpinner);
		lSpin = findViewById(R.id.chLocSpinner);
		jSpin = findViewById(R.id.chJobSpinner);
		cSpin.setOnItemSelectedListener(this);
		lSpin.setOnItemSelectedListener(this);
		jSpin.setOnItemSelectedListener(this);

		// First time initialize location and job spinners
		setLocJob(0, true);

		// Make PayPeriod EditText
		pptxt = findViewById(R.id.chPeriodNum);

		makeIntents(ACountHours.this);
	}

	@Override
	public void onBackPressed() {
		DrawerLayout drawer = findViewById(R.id.drawer_layout);
		if (drawer.isDrawerOpen(GravityCompat.START)) {
			drawer.closeDrawer(GravityCompat.START);
		} else {
			addExtras(menu);
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

	//Spinner Item Selected
	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
		hourTotalBoxesZero ();
		if (parent.getId() == R.id.chClientSpinner) {
			lSpin.setSelection(0, false);
			jSpin.setSelection(0, false);
			setLocJob(position, false);
		} else if (parent.getId() == R.id.chLocSpinner) {
			jSpin.setSelection(0, false);
			setJob(position);
		}
	}

	@Override
	public void onNothingSelected(AdapterView<?> parent) {}


	public void chDidPressCalculate(View view) {
		workerList = new ArrayList<>();
		hourList = new ArrayList<>();
		pphList = new ArrayList<>();

		InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
		imm.hideSoftInputFromWindow(pptxt.getWindowToken(), 0);

		System.out.println ("didPressCalculate");

		if (pptxt.getText().toString().equals("")) {
			pptxt.setError(getString(R.string.error_field_required));
			if (!pptxt.hasFocus()) {
				findViewById(pptxt.getId()).requestFocus();
			}
			return;
		}

		final ValueEventListener iterateHistories = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					tempPer = new PayPeriod(dataSnapshot.child(pptxt.getText().toString()));
					int i = 0;
					for (; i < employeeList.size(); i++)
						if (employeeList.get(i).uid.equals(dataSnapshot.getKey()))
							break;

					final int toAddTo = i;

					ValueEventListener iterateWorkdays = new ValueEventListener() {
						@Override
						public void onDataChange(DataSnapshot dataSnapshot) {
							if (dataSnapshot.exists()) {
								for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
									System.out.println ("snapshot: " + snapshot.getValue());
									tempDay = new Workday(snapshot);

									if ((tempDay.client.equals(cSpin.getSelectedItem())) &&
											  ((tempDay.location + ", " + tempDay.city).equals(lSpin.getSelectedItem())) &&
											  (tempDay.job.equals(jSpin.getSelectedItem()))) {
										hourList.set (toAddTo, hourList.get(toAddTo) + tempDay.hours);
										pphList.set (toAddTo, hourList.get(toAddTo) * workerList.get(toAddTo).pph);
									}
								}

								listSet ();
							}
						}

						@Override
						public void onCancelled(DatabaseError databaseError) { finish(); }
					};

					DatabaseReference days = FirebaseDatabase.getInstance().getReferenceFromUrl(tempPer.days);

					days.orderByKey().addListenerForSingleValueEvent(iterateWorkdays);
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) { finish(); }
		};

		for (User tempU : employeeList) {
			workerList.add(tempU);
			hourList.add(0.0);
			pphList.add(0.0);

			DatabaseReference histories = FirebaseDatabase.getInstance().getReferenceFromUrl(tempU.history);

			histories.orderByKey().equalTo(pptxt.getText().toString()).addListenerForSingleValueEvent(iterateHistories);
		}
	}

	private void setLocJob (final int position, final boolean isInit) {
		locationList = new ArrayList<>();
		locNameList = new ArrayList<>();
		jobList = new ArrayList<>();

		ValueEventListener getC = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					ValueEventListener readLList = new ValueEventListener() {
						@Override
						public void onDataChange(DataSnapshot dataSnapshot) {
							if (dataSnapshot.exists()) {
								for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
									Location l = new Location(snapshot);

									if (locationList.contains(l)) {
										continue;
									}

									locationList.add(l);
									locNameList.add(l.address + ", " + l.city);
								}


								// Had to split it up so that the locationlist and joblist get initiated at the start
								if (isInit) {
									cAdapter = new ArrayAdapter<>(ACountHours.this, R.layout.support_simple_spinner_dropdown_item, clientList);
									lAdapter = new ArrayAdapter<>(ACountHours.this, R.layout.support_simple_spinner_dropdown_item, locNameList);
									jAdapter = new ArrayAdapter<>(ACountHours.this, R.layout.support_simple_spinner_dropdown_item, jobList);
									cAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
									lAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
									jAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
									cSpin.setAdapter(cAdapter);
									lSpin.setAdapter(lAdapter);
									jSpin.setAdapter(jAdapter);
								}

								lAdapter.clear();
								lAdapter.addAll(locNameList);
								lAdapter.notifyDataSetChanged();

								setJob(0);
							}
						}

						@Override
						public void onCancelled(DatabaseError databaseError) { finish(); }
					};

					for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
						Client temp = new Client(snapshot);

						DatabaseReference locs = FirebaseDatabase.getInstance().getReferenceFromUrl(temp.properties);

						locs.orderByKey().addListenerForSingleValueEvent(readLList);
					}
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) { finish(); }
		};

		clientBase.orderByKey().equalTo(position + "").addListenerForSingleValueEvent(getC);
	}

	private void setJob (final int position) {
		jobList = new ArrayList<>();

		ValueEventListener readJList = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
						Job j = new Job(snapshot);

						if (jobList.contains(j.type))
							continue;
						jobList.add(j.type);
					}

					jAdapter.clear();
					jAdapter.addAll(jobList);
					jAdapter.notifyDataSetChanged();
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) { finish(); }
		};

		if (locationList.size() <= position)
			return;

		DatabaseReference locs = FirebaseDatabase.getInstance().getReferenceFromUrl(locationList.get(position).jobs);

		locs.orderByKey().addListenerForSingleValueEvent(readJList);
	}

	private void hourTotalBoxesZero () {
		threeLabelBoxes = new threeLabelBox[employeeList.size()];
		for (int i = 0; i < employeeList.size(); i++) {
			threeLabelBoxes[i] = new threeLabelBox(employeeNameList.get(i), 0, 0);
		}
		hourTotalsAdapter = new hourTotalListAdapter(threeLabelBoxes);
		hourTotals.setAdapter(hourTotalsAdapter);
	}

	private void listSet () {
		threeLabelBoxes = new threeLabelBox[workerList.size()];

		for (int i = 0; i < workerList.size(); i++) {
			threeLabelBoxes[i] = new threeLabelBox(workerList.get(i).name, hourList.get(i), pphList.get (i));
		}

		hourTotalsAdapter = new hourTotalListAdapter(threeLabelBoxes);
		hourTotals.setAdapter(hourTotalsAdapter);
	}
}
