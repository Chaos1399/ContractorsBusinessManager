package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.TextInputEditText;
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

import java.util.ArrayList;
import java.util.Date;

import static calpoly.crrangel.edu.contractorsbusinessmanager.AAddToSchedule.getArrayFromTime;

public class AddJob extends AdminSuperclass
		implements AdapterView.OnItemSelectedListener {
	Spinner cSpin;
	Spinner lSpin;
	Spinner smSpin;
	Spinner sdSpin;
	Spinner emSpin;
	Spinner edSpin;
	ArrayList <Location> locationList;
	ArrayList <String> locNameList;
	ArrayAdapter <String> cAdapter;
	ArrayAdapter <String> lAdapter;
	ArrayAdapter<CharSequence> smAdapter;
	ArrayAdapter<CharSequence> sdAdapter;
	ArrayAdapter<CharSequence> emAdapter;
	ArrayAdapter<CharSequence> edAdapter;
	TextInputEditText typeField;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_job);

		typeField = findViewById(R.id.ajJobET);

		// Make spinners
		cSpin = findViewById(R.id.ajClientSpinner);
		lSpin = findViewById(R.id.ajLocSpinner);
		smSpin = findViewById(R.id.ajStartMonth);
		sdSpin = findViewById(R.id.ajStartDay);
		emSpin = findViewById(R.id.ajEndMonth);
		edSpin = findViewById(R.id.ajEndDay);
		cSpin.setOnItemSelectedListener(this);
		lSpin.setOnItemSelectedListener(this);
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

		setLoc(true);
    }

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			// Respond to the action bar's Up/Home button
			case android.R.id.home:
				Intent intent = new Intent(this, AMenu.class);
				addExtras(intent);
				navigateUpTo(intent);
				return true;
		}
		return super.onOptionsItemSelected(item);
	}

	//Spinner Item Selected
	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
		if (parent.getId() == R.id.ajClientSpinner) {
			setLoc(false);
			lSpin.setSelection(0, false);
		} else if (parent.getId() == R.id.ajStartMonth) {
			Date d = new Date();
			d.setMonth(position);
			int prevpos = sdSpin.getSelectedItemPosition();
			sdAdapter = ArrayAdapter.createFromResource(this, getArrayFromTime(d.getTime()), android.R.layout.simple_spinner_dropdown_item);
			sdSpin.setAdapter(sdAdapter);
			prevpos = (prevpos >= sdSpin.getCount())? (sdSpin.getCount() - 1) : prevpos;
			sdSpin.setSelection(prevpos, false);
		} else if (parent.getId() == R.id.ajEndMonth) {
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
	public void onNothingSelected(AdapterView<?> parent) {}

	private void setLoc (final boolean isInit) {
		locationList = new ArrayList<>();
		locNameList = new ArrayList<>();

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
									cAdapter = new ArrayAdapter<>(AddJob.this, R.layout.support_simple_spinner_dropdown_item, clientList);
									lAdapter = new ArrayAdapter<>(AddJob.this, R.layout.support_simple_spinner_dropdown_item, locNameList);
									cAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
									lAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
									cSpin.setAdapter(cAdapter);
									lSpin.setAdapter(lAdapter);
								}

								lAdapter.clear();
								lAdapter.addAll(locNameList);
								lAdapter.notifyDataSetChanged();
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

		clientBase.orderByKey().equalTo(clientList.get(0)).addListenerForSingleValueEvent(getC);
	}

	public void ajDidPressSave (View view) {
    	final String type = typeField.getText().toString();
		final Job toCreate = new Job(type, null, new Date(), new Date());
		final String client = (String) cSpin.getSelectedItem();
		final int locnum = lSpin.getSelectedItemPosition();

		if (type.isEmpty()) {
			typeField.setError(getString(R.string.error_field_required));
			return;
		}

		ValueEventListener getJobURL = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					final Location tempLoc = new Location(dataSnapshot);

					DatabaseReference jobs = FirebaseDatabase.getInstance().getReferenceFromUrl(tempLoc.jobs);

					ValueEventListener checkForJob = new ValueEventListener() {
						@Override
						public void onDataChange(DataSnapshot dataSnapshot) {
							if (dataSnapshot.exists()) {
								for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
									Job temp = new Job(snapshot);
									if (temp.type.equals(toCreate.type)) {
										typeField.setError("Job already exists. To change, use Edit Job page.");
										return;
									}
								}

								tempLoc.numJobs++;
								jobBase.child(client + locNameList.get(locnum)).child(Long.toString(dataSnapshot.getChildrenCount())).setValue(toCreate.toMap());
								locationBase.child(client).child(Integer.toString(locnum)).setValue(tempLoc.toMap());
							}
						}

						@Override
						public void onCancelled(DatabaseError databaseError) {}
					};

					jobs.addListenerForSingleValueEvent(checkForJob);
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		locationBase.child(client).child(Integer.toString(locnum)).addListenerForSingleValueEvent(getJobURL);
	}
}
