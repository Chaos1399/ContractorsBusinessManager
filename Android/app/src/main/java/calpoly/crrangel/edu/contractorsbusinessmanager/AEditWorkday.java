package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import calpoly.crrangel.edu.contractorsbusinessmanager.AReviseHours.workdayBox;

import java.util.ArrayList;

public class AEditWorkday extends AdminSuperclass implements AdapterView.OnItemSelectedListener {
	Spinner cSpin;
	Spinner lSpin;
	Spinner jSpin;
	Spinner hSpin;
	ArrayAdapter<String> cAdapter;
	ArrayAdapter<String> lAdapter;
	ArrayAdapter<String> jAdapter;
	ArrayList<Location> locationList;
	ArrayList<String> locNameList;
	ArrayList<String> jobList;
	ArrayList<workdayBox> wb;
	String curURL;
	int pos;
	long selectedDate;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_aedit_workday);

		// Load passed User, clientList, and employeeList
		Intent toHere = getIntent();
		if (toHere.getExtras() == null) return;
		this.pos = toHere.getIntExtra("pos", -1);
		this.wb = AReviseHours.bundleToWorkdayBoxArr (toHere.getBundleExtra("wBoxes"));
		this.selectedDate = toHere.getLongExtra("selectedDate", 0);
		this.curURL = toHere.getStringExtra("curURL");

		// Make spinners
		cSpin = findViewById(R.id.ewCSpin);
		lSpin = findViewById(R.id.ewLSpin);
		jSpin = findViewById(R.id.ewJSpin);
		hSpin = findViewById(R.id.ewHSpin);
		cSpin.setOnItemSelectedListener(this);
		lSpin.setOnItemSelectedListener(this);
		jSpin.setOnItemSelectedListener(this);
		hSpin.setOnItemSelectedListener(this);
		setLocJob(0, true);

		ArrayAdapter <CharSequence> hAdapter = ArrayAdapter.createFromResource(this,
				  R.array.hours, android.R.layout.simple_spinner_item);
		hSpin.setAdapter(hAdapter);

		int i;
		String [] hrlist = getResources().getStringArray(R.array.hours);
		for (i = 0; i < hrlist.length; i++)
			if (Double.valueOf(hrlist[i]).equals(wb.get(pos).hrNum))
				break;
		hSpin.setSelection(i, false);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			// Respond to the action bar's Up/Home button
			case android.R.id.home:
				Intent intent = new Intent(this, ASchedule.class);
				addExtras(intent);
				intent.putExtra("pos", pos);
				intent.putExtra("wBoxes", AReviseHours.workdayBoxArrToBundle(wb));
				intent.putExtra("selectedDate", selectedDate);
				intent.putExtra("curURL", curURL);
				navigateUpTo(intent);
				return true;
		}
		return super.onOptionsItemSelected(item);
	}

	//Spinner Item Selected
	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
		if (parent.getId() == R.id.ewCSpin) {
			lSpin.setSelection(0, false);
			jSpin.setSelection(0, false);
			setLocJob(position, false);
		} else if (parent.getId() == R.id.ewLSpin) {
			jSpin.setSelection(0, false);
			setJob(position);
		}
	}

	@Override
	public void onNothingSelected(AdapterView<?> parent) {}

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
									cAdapter = new ArrayAdapter<>(AEditWorkday.this, R.layout.support_simple_spinner_dropdown_item, clientList);
									lAdapter = new ArrayAdapter<>(AEditWorkday.this, R.layout.support_simple_spinner_dropdown_item, locNameList);
									jAdapter = new ArrayAdapter<>(AEditWorkday.this, R.layout.support_simple_spinner_dropdown_item, jobList);
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

	public void ewDidPressSave (View view) {
		String [] lSpinSelection = lSpin.getSelectedItem().toString().split(", ");
		workdayBox temp = new workdayBox (cSpin.getSelectedItem().toString(),
				lSpinSelection[0], lSpinSelection[1], jSpin.getSelectedItem().toString(),
				Double.valueOf(hSpin.getSelectedItem().toString()));

		wb.set(pos, temp);

		Intent intent = new Intent(this, AReviseHours.class);
		addExtras(intent);
		intent.putExtra("wBoxes", AReviseHours.workdayBoxArrToBundle(wb));
		intent.putExtra("selectedDate", selectedDate);
		intent.putExtra("curURL", curURL);
		intent.putExtra("pos", pos);
		navigateUpTo(intent);
	}
}
