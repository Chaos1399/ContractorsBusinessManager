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

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;

public class AAddToSchedule extends AdminSuperclass
		implements AdapterView.OnItemSelectedListener {
	ArrayList<Location> locationList;
	ArrayList<String> locNameList;
	ArrayList<String> jobList;
	Spinner cSpin;
	Spinner lSpin;
	Spinner jSpin;
	Spinner smSpin;
	Spinner sdSpin;
	Spinner emSpin;
	Spinner edSpin;
	//TODO: Add multi-year scheduling ability
	ArrayAdapter<String> cAdapter;
	ArrayAdapter<String> lAdapter;
	ArrayAdapter<String> jAdapter;
	ArrayAdapter<CharSequence> smAdapter;
	ArrayAdapter<CharSequence> sdAdapter;
	ArrayAdapter<CharSequence> emAdapter;
	ArrayAdapter<CharSequence> edAdapter;
	String toSched;
	long selectedDate;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_aadd_to_schedule);

        Intent toHere = getIntent();
        if (toHere.getExtras() == null) return;
		this.toSched = toHere.getStringExtra("toSched");
		selectedDate = toHere.getLongExtra("date", 0);


		// Make spinners
		cSpin = findViewById(R.id.aasClientSpinner);
		lSpin = findViewById(R.id.aasLocSpinner);
		jSpin = findViewById(R.id.aasJobSpinner);
		smSpin = findViewById(R.id.aasStartMonth);
		sdSpin = findViewById(R.id.aasStartDay);
		emSpin = findViewById(R.id.aasEndMonth);
		edSpin = findViewById(R.id.aasEndDay);
		cSpin.setOnItemSelectedListener(this);
		lSpin.setOnItemSelectedListener(this);
		jSpin.setOnItemSelectedListener(this);
		smSpin.setOnItemSelectedListener(this);
		sdSpin.setOnItemSelectedListener(this);
		emSpin.setOnItemSelectedListener(this);
		edSpin.setOnItemSelectedListener(this);

		Date d = new Date();

		smAdapter = ArrayAdapter.createFromResource(this, R.array.monthNames, android.R.layout.simple_spinner_dropdown_item);
		emAdapter = ArrayAdapter.createFromResource(this, R.array.monthNames, android.R.layout.simple_spinner_dropdown_item);
		sdAdapter = ArrayAdapter.createFromResource(this, getArrayFromTime(d.getTime()), android.R.layout.simple_spinner_dropdown_item);
		edAdapter = ArrayAdapter.createFromResource(this, getArrayFromTime(d.getTime()), android.R.layout.simple_spinner_dropdown_item);

		smSpin.setAdapter(smAdapter);
		emSpin.setAdapter(emAdapter);
		sdSpin.setAdapter(sdAdapter);
		edSpin.setAdapter(edAdapter);
		smSpin.setSelection(d.getMonth(), false);
		emSpin.setSelection(d.getMonth(), false);
		sdSpin.setSelection(d.getDate() - 1, false);
		edSpin.setSelection(d.getDate() - 1, false);

		setLocJob(0, true);
    }

	@Override
	public void onNothingSelected(AdapterView<?> parent) {}


	//Spinner Item Selected
	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
		if (parent.getId() == R.id.aasClientSpinner) {
			lSpin.setSelection(0, false);
			jSpin.setSelection(0, false);
			setLocJob(position, false);
		} else if (parent.getId() == R.id.aasLocSpinner) {
			jSpin.setSelection(0, false);
			setJob(position);
		} else if (parent.getId() == R.id.aasStartMonth) {
			Date d = new Date();
			d.setMonth(position);
			int prevpos = sdSpin.getSelectedItemPosition();
			sdAdapter = ArrayAdapter.createFromResource(this, getArrayFromTime(d.getTime()), android.R.layout.simple_spinner_dropdown_item);
			sdSpin.setAdapter(sdAdapter);
			prevpos = (prevpos >= sdSpin.getCount())? (sdSpin.getCount() - 1) : prevpos;
			sdSpin.setSelection(prevpos, false);
		} else if (parent.getId() == R.id.aasEndMonth) {
			Date d = new Date();
			d.setMonth(position);
			int prevpos = edSpin.getSelectedItemPosition();
			edAdapter = ArrayAdapter.createFromResource(this, getArrayFromTime(d.getTime()), android.R.layout.simple_spinner_dropdown_item);
			edSpin.setAdapter(edAdapter);
			prevpos = (prevpos >= edSpin.getCount())? (edSpin.getCount() - 1) : prevpos;
			edSpin.setSelection(prevpos, false);
		}
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			// Respond to the action bar's Up/Home button
			case android.R.id.home:
				Intent intent = new Intent(this, ASchedule.class);
				this.addExtras(intent);
				intent.putExtra("date", selectedDate);
				navigateUpTo(intent);
				return true;
		}
		return super.onOptionsItemSelected(item);
	}

	public static int getArrayFromTime (long time) {
    	Date d = new Date(time);
    	int y = d.getYear(), m = d.getMonth();

    	switch (m) {
			case 1:
				if (y % 4 == 0)
					return R.array.monthDays29;
				else
					return R.array.monthDays28;
			case 0:
			case 2:
			case 4:
			case 6:
			case 7:
			case 9:
			case 11:
				return R.array.monthDays31;

			default:
				return R.array.monthDays30;

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
									locNameList.add(l.address);
								}


								if (isInit) {
									cAdapter = new ArrayAdapter<>(AAddToSchedule.this, R.layout.support_simple_spinner_dropdown_item, clientList);
									lAdapter = new ArrayAdapter<>(AAddToSchedule.this, R.layout.support_simple_spinner_dropdown_item, locNameList);
									jAdapter = new ArrayAdapter<>(AAddToSchedule.this, R.layout.support_simple_spinner_dropdown_item, jobList);
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

	public void aasDidPressSave (View view) {
    	ScheduledWorkday temp = null;
    	final ScheduledWorkday toRet;

		try {
			temp = new ScheduledWorkday((String) cSpin.getSelectedItem(), (String) lSpin.getSelectedItem(),
					(String) jSpin.getSelectedItem(),
					df.parse((smSpin.getSelectedItemPosition() + 1) + "/" + (sdSpin.getSelectedItemPosition() + 1) + "/18"),
					df.parse((emSpin.getSelectedItemPosition() + 1) + "/" + (edSpin.getSelectedItemPosition() + 1) + "/18"));

		} catch (ParseException e) {
			e.printStackTrace();
		}

		toRet = temp;
		if (toRet == null)
			System.exit(1);

		ValueEventListener getAndSet = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				ValueEventListener setNumDays = new ValueEventListener() {
					@Override
					public void onDataChange(DataSnapshot dataSnapshot) {
						//noinspection ConstantConditions
						int numdays = dataSnapshot.getValue(Integer.class);

						userBase.child(toSched).child("numDays").setValue(numdays + 1);
					}

					@Override
					public void onCancelled(DatabaseError databaseError) {}
				};

				scheduleBase.child(toSched).child(Long.toString(dataSnapshot.getChildrenCount())).setValue(toRet.toMap());
				userBase.child(toSched).child("numDays").addListenerForSingleValueEvent(setNumDays);
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		scheduleBase.child(toSched).orderByKey().addListenerForSingleValueEvent(getAndSet);

		Intent intent = new Intent(AAddToSchedule.this, ASchedule.class);
		addExtras(intent);
		intent.putExtra("date", selectedDate);

		navigateUpTo(intent);
	}
}
