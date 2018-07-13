package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.widget.DividerItemDecoration;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.CalendarView;
import android.widget.Spinner;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;

public class ReviseHours extends AdminSuperclass
		implements NavigationView.OnNavigationItemSelectedListener,
		AdapterView.OnItemSelectedListener{
	RecyclerView wList;
	workdayBoxAdapter wListAdapter;
	RecyclerView.LayoutManager wListLayoutManager;
	ArrayList <workdayBox> wBoxes;
	Spinner selectedEmp;
	CalendarView calendar;
	String curURL;
	long selectedDate;
	int pos;
	private boolean spinnerWasInitialized;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_revise_hours);
		Toolbar toolbar = findViewById(R.id.rhToolbar);
		setSupportActionBar(toolbar);

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
		this.user = bundleToUser(toHere.getBundleExtra("user"));
		this.clientList = toHere.getStringArrayListExtra("cList");
		this.employeeList = toHere.getStringArrayListExtra("eList");
		this.selectedDate = toHere.getLongExtra("selectedDate", 0);
		this.pos = toHere.getIntExtra("pos", -1);
		this.curURL = toHere.getStringExtra("curURL");
		if (toHere.getBundleExtra("wBoxes") != null) {
			wBoxes = bundleToWorkdayBoxArr(toHere.getBundleExtra("wBoxes"));
		} else {
			wBoxes = new ArrayList<>();
			wBoxes.add(new workdayBox("None", "None", "None", 0, false));
		}

		// Set up employee Spinner
		selectedEmp = findViewById(R.id.rhE);
		String [] eList = new String[employeeList.size()];
		for (int i = 0; i < employeeList.size(); i++) {
			eList [i] = employeeList.get(i);
		}
		ArrayAdapter<String> selectedEmpAdapter = new ArrayAdapter<>(ReviseHours.this, R.layout.support_simple_spinner_dropdown_item, eList);
		selectedEmpAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
		selectedEmp.setAdapter(selectedEmpAdapter);
		selectedEmp.setOnItemSelectedListener(this);

		// Set up workday list
		wList = findViewById(R.id.rhWL);
		wList.setHasFixedSize(true);
		wListLayoutManager = new LinearLayoutManager(this, LinearLayoutManager.HORIZONTAL, false);
		DividerItemDecoration divider = new DividerItemDecoration(wList.getContext(),
				LinearLayoutManager.HORIZONTAL);
		wList.addItemDecoration(divider);
		wList.setLayoutManager(wListLayoutManager);
		workdayBoxAdapter.OnItemClickListener listener = new workdayBoxAdapter.OnItemClickListener() {
			@Override
			public void onItemClick (int position) {
				workdayBox box = wBoxes.get(position);
				if (box.client.equals("None"))
					return;

				Intent intent = new Intent(ReviseHours.this, EditWorkday.class);
				intent.putExtra("selectedDate", selectedDate);
				intent.putExtra("user", userToBundle(user));
				intent.putExtra("cList", clientList);
				intent.putExtra("eList", employeeList);
				intent.putExtra("wBoxes", workdayBoxArrToBundle(wBoxes));
				intent.putExtra("pos", position);
				intent.putExtra("curURL", curURL);
				startActivity(intent);
			}
		};
		wListAdapter = new workdayBoxAdapter(wBoxes, listener);
		wList.setAdapter(wListAdapter);

		// Set up calendar
		calendar = findViewById(R.id.rhCalendar);
		calendar.setMaxDate(new Date().getTime());
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
		if (selectedDate > 0 && pos >= 0)
			calendar.setDate(selectedDate);

		spinnerWasInitialized = false;

		// Make and set up all Intents
		this.makeIntents(ReviseHours.this);
		this.addExtras();
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
		} else if (id == R.id.viewcalendarmenu) {
			startActivity (aviewCalendar);
		} else if (id == R.id.counthoursmenu) {
			startActivity (countHours);
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

	//Spinner Item Selected
	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
    	if (spinnerWasInitialized)
			workListZero();
    	else
    		spinnerWasInitialized = true;
	}

	@Override
	public void onNothingSelected(AdapterView<?> parent) {}

	public void rhGetWorkList (View view) {
		wBoxes = new ArrayList<>();

		ValueEventListener readSList = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
						if (!snapshot.getKey().contains((String) selectedEmp.getSelectedItem()))
							continue;

						curURL = snapshot.getRef().toString();

						for (DataSnapshot snap : snapshot.getChildren()) {
							Workday tempW = new Workday(snap);

							Date sd = new Date(selectedDate);

							if (sd.getYear() == tempW.date.getYear() &&
									sd.getMonth() == tempW.date.getMonth() &&
									sd.getDate() == tempW.date.getDate())
								wBoxes.add(new workdayBox(tempW.client, tempW.location, tempW.job, tempW.hours, tempW.clockedOut));
						}
					}

					if (wBoxes.size() != 0) {
						wListAdapter.updateData(wBoxes);
					} else
						workListZero();
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		workdayBase.orderByKey().addListenerForSingleValueEvent(readSList);
	}

	public void rhDidPressSave (View view) {
    	ValueEventListener searchWorkdays = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				int i = 0;
				Workday tempW;
				workdayBox tempwb;
				Date tempd = new Date(selectedDate);

				for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
					tempW = new Workday(snapshot);
					if (tempW.date.after(tempd) || tempW.date.before(tempd))
						continue;

					tempwb = wBoxes.get(i++);
					tempW = new Workday(df.format(tempd), tempwb.client,
							tempwb.loc, tempwb.job, tempwb.hrNum, tempwb.done);
					snapshot.getRef().setValue(tempW.toMap());
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		FirebaseDatabase.getInstance().getReferenceFromUrl(curURL.replace("%20", " ")).addListenerForSingleValueEvent(searchWorkdays);
	}

	private void workListZero () {
		wBoxes = new ArrayList<>();
		wBoxes.add(new workdayBox("None", "None", "None", 0, false));

		wListAdapter.updateData(wBoxes);
	}

	public static Bundle workdayBoxArrToBundle (ArrayList <workdayBox> wbs) {
    	Bundle b = new Bundle();
    	int i = 0;

    	for (; i < wbs.size(); i++)
    		b.putBundle(Integer.toString(i), workdayBoxToBundle(wbs.get(i)));
    	b.putInt("length", i);

    	return b;
	}

	public static ArrayList <workdayBox> bundleToWorkdayBoxArr (Bundle b) {
    	ArrayList <workdayBox> wbs = new ArrayList<>();
    	int j = b.getInt("length");

    	for (int i = 0; i < j; i++)
			wbs.add(bundleToWorkdayBox(b.getBundle(Integer.toString(i))));

    	return wbs;
	}

	public static Bundle workdayBoxToBundle (workdayBox wb) {
    	Bundle b = new Bundle();

    	b.putString("client", wb.client);
    	b.putString("loc", wb.loc);
    	b.putString("job", wb.job);
    	b.putString("hours", wb.hours);
    	b.putDouble("hrnum", wb.hrNum);
    	b.putBoolean("done", wb.done);

    	return b;
	}

	public static workdayBox bundleToWorkdayBox (Bundle b) {
    	workdayBox wb;

    	wb = new workdayBox(b.getString("client"),
				b.getString("loc"),
				b.getString("job"),
				b.getDouble("hrnum"),
				b.getBoolean("done"));

    	return wb;
	}

	static class workdayBox {
		String client;
		String loc;
		String job;
		String hours;
		double hrNum;
		boolean done;

		workdayBox (String client, String loc, String job, double hours, boolean done) {
			this.client = client;
			this.loc = loc;
			this.job = job;
			this.hours = String.format("%2.2f", hours) + " Hours";
			this.hrNum = hours;
			this.done = done;
		}
	}
}
