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

public class CountHours extends AdminSuperclass
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
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
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

        makeIntents(CountHours.this);
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

		ValueEventListener iterateUsers = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
						User tempU = new User(snapshot);

						if (tempU.name.equals("Admin")) continue;

						DatabaseReference histories = FirebaseDatabase.getInstance().getReferenceFromUrl(tempU.history);

						workerList.add(tempU);
						hourList.add(0.0);
						pphList.add(0.0);

						ValueEventListener iterateHistories = new ValueEventListener() {
							@Override
							public void onDataChange(DataSnapshot dataSnapshot) {
								if (dataSnapshot.exists()) {
									for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
										tempPer = new PayPeriod(snapshot);
										if (!pptxt.getText().toString().equals(Integer.toString(tempPer.period)))
											continue;

										ValueEventListener iterateWorkdays = new ValueEventListener() {
											@Override
											public void onDataChange(DataSnapshot dataSnapshot) {
												if (dataSnapshot.exists()) {
													int i = 0;

													for (; i < workerList.size(); i++) {
														if (workerList.get(i).name.equals(dataSnapshot.getKey().replace(pptxt.getText().toString(), "")))
															break;
													}

													for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
														tempDay = new Workday(snapshot);

														if ((tempDay.client.equals(cSpin.getSelectedItem())) &&
																(tempDay.location.equals(lSpin.getSelectedItem())) &&
																(tempDay.job.equals(jSpin.getSelectedItem()))) {
															hourList.set (i, hourList.get(i) + tempDay.hours);
														}
													}
													pphList.set (i, hourList.get(i) * workerList.get(i).pph);

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
							}

							@Override
							public void onCancelled(DatabaseError databaseError) { finish(); }
						};

						histories.orderByKey().equalTo(pptxt.getText().toString()).addListenerForSingleValueEvent(iterateHistories);
					}
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) { finish(); }
		};

		userBase.orderByKey().addListenerForSingleValueEvent(iterateUsers);
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
									locNameList.add(l.address);
								}


								// Had to split it up so that the locationlist and joblist get initiated at the start
								if (isInit) {
									cAdapter = new ArrayAdapter<>(CountHours.this, R.layout.support_simple_spinner_dropdown_item, clientList);
									lAdapter = new ArrayAdapter<>(CountHours.this, R.layout.support_simple_spinner_dropdown_item, locNameList);
									jAdapter = new ArrayAdapter<>(CountHours.this, R.layout.support_simple_spinner_dropdown_item, jobList);
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

        clientBase.orderByKey().equalTo(clientList.get(position)).addListenerForSingleValueEvent(getC);
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
			threeLabelBoxes[i] = new threeLabelBox(employeeList.get(i), 0, 0);
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
