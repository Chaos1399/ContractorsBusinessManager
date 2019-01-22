package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
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

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;

import static calpoly.crrangel.edu.contractorsbusinessmanager.AAddToSchedule.getArrayFromTime;

public class AAddJob extends AdminSuperclass
		  implements AdapterView.OnItemSelectedListener {
	ArrayList <Location> locationList;
	ArrayList <String> locNameList;
	ArrayList<Integer> yearList;

	Spinner clntSpin;
	Spinner addrSpin;
	Spinner ctySpin;
	Spinner smSpin;
	Spinner sdSpin;
	Spinner sySpin;
	Spinner emSpin;
	Spinner edSpin;
	Spinner eySpin;

	ArrayAdapter <String> clntAdapter;
	ArrayAdapter <String> addrAdapter;
	ArrayAdapter <CharSequence> ctyAdapter;
	ArrayAdapter<CharSequence> smAdapter;
	ArrayAdapter<CharSequence> emAdapter;
	ArrayAdapter<CharSequence> sdAdapter;
	ArrayAdapter<CharSequence> edAdapter;
	ArrayAdapter<Integer> syAdapter;
	ArrayAdapter<Integer> eyAdapter;
	TextInputEditText typeField;
	TextInputEditText desField;
	int dropdownItem = android.R.layout.simple_spinner_dropdown_item;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_aadd_job);

		typeField = findViewById(R.id.ajJNET);
		desField = findViewById(R.id.ajJDET);

		// Make spinners
		clntSpin = findViewById(R.id.ajClntSpin);
		addrSpin = findViewById(R.id.ajASpin);
		ctySpin = findViewById(R.id.ajCtySpin);
		smSpin = findViewById(R.id.ajStartMonth);
		sdSpin = findViewById(R.id.ajStartDay);
		sySpin = findViewById(R.id.ajStartYear);
		emSpin = findViewById(R.id.ajEndMonth);
		edSpin = findViewById(R.id.ajEndDay);
		eySpin = findViewById(R.id.ajEndYear);
		clntSpin.setOnItemSelectedListener(this);
		addrSpin.setOnItemSelectedListener(this);
		ctySpin.setOnItemSelectedListener(this);
		smSpin.setOnItemSelectedListener(this);
		emSpin.setOnItemSelectedListener(this);
		sdSpin.setOnItemSelectedListener(this);
		edSpin.setOnItemSelectedListener(this);
		sySpin.setOnItemSelectedListener(this);
		eySpin.setOnItemSelectedListener(this);

		Date d = new Date();
		yearList = new ArrayList<>();

		for (int i = 0; i < 10; i++)
			yearList.add(2019 + i);

		smAdapter = ArrayAdapter.createFromResource(this, R.array.monthNames, dropdownItem);
		emAdapter = ArrayAdapter.createFromResource(this, R.array.monthNames, dropdownItem);
		sdAdapter = ArrayAdapter.createFromResource(this, getArrayFromTime(d.getTime()), dropdownItem);
		edAdapter = ArrayAdapter.createFromResource(this, getArrayFromTime(d.getTime()), dropdownItem);
		syAdapter = new ArrayAdapter<>(this, dropdownItem, yearList);
		eyAdapter = new ArrayAdapter<>(this, dropdownItem, yearList);
		ctyAdapter = ArrayAdapter.createFromResource(this, R.array.SLOCountyCities, dropdownItem);

		ctySpin.setAdapter(ctyAdapter);
		smSpin.setAdapter(smAdapter);
		emSpin.setAdapter(emAdapter);
		sdSpin.setAdapter(sdAdapter);
		edSpin.setAdapter(edAdapter);
		sySpin.setAdapter(syAdapter);
		eySpin.setAdapter(eyAdapter);
		smSpin.setSelection(d.getMonth(), false);
		emSpin.setSelection(d.getMonth(), false);
		sdSpin.setSelection(d.getDate() - 1, false);
		edSpin.setSelection(d.getDate() - 1, false);


		setLoc(0, true);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			// Respond to the action bar's Up/Home button
			case android.R.id.home:
				menu = new Intent(this, AMenu.class);
				addExtras(menu);
				navigateUpTo(menu);
				return true;
		}
		return super.onOptionsItemSelected(item);
	}

	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
		if (parent.getId() == R.id.ajClntSpin) {
			setLoc(position, false);
			addrSpin.setSelection(0, false);
		} else if (parent.getId() == R.id.ajStartMonth) {
			Date d = new Date();
			d.setMonth(position);
			int prevpos = sdSpin.getSelectedItemPosition();
			sdAdapter = ArrayAdapter.createFromResource(this, getArrayFromTime(d.getTime()), dropdownItem);
			sdSpin.setAdapter(sdAdapter);
			prevpos = (prevpos >= sdSpin.getCount())? (sdSpin.getCount() - 1) : prevpos;
			sdSpin.setSelection(prevpos, false);
		} else if (parent.getId() == R.id.ajEndMonth) {
			Date d = new Date();
			d.setMonth(position);
			int prevpos = edSpin.getSelectedItemPosition();
			edAdapter = ArrayAdapter.createFromResource(this, getArrayFromTime(d.getTime()), dropdownItem);
			edSpin.setAdapter(edAdapter);
			prevpos = (prevpos >= edSpin.getCount())? (edSpin.getCount() - 1) : prevpos;
			edSpin.setSelection(prevpos, false);
		}
	}

	@Override
	public void onNothingSelected(AdapterView<?> parent) {}

	private void setLoc (final int position, final boolean isInit) {
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

									if (locationList.contains(l))
										continue;

									locationList.add(l);
									locNameList.add(l.address);
								}


								if (isInit) {
									clntAdapter = new ArrayAdapter<>(AAddJob.this, dropdownItem, clientList);
									addrAdapter = new ArrayAdapter<>(AAddJob.this, dropdownItem, locNameList);
									clntAdapter.setDropDownViewResource(dropdownItem);
									addrAdapter.setDropDownViewResource(dropdownItem);
									clntSpin.setAdapter(clntAdapter);
									addrSpin.setAdapter(addrAdapter);
								}

								addrAdapter.clear();
								addrAdapter.addAll(locNameList);
								addrAdapter.notifyDataSetChanged();
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

	public void ajDidPressSave (View view) {
		final String type = typeField.getText().toString();
		final String des = desField.getText().toString();
		final String startString = (smSpin.getSelectedItemPosition() + 1) + "/" +
				  (sdSpin.getSelectedItemPosition() + 1) + "/" +
				  sySpin.getSelectedItem().toString().substring(2);
		final String endString = (emSpin.getSelectedItemPosition() + 1) + "/" +
				  (edSpin.getSelectedItemPosition() + 1) + "/" +
				  eySpin.getSelectedItem().toString().substring(2);
		final int client = clntSpin.getSelectedItemPosition();
		final int locnum = addrSpin.getSelectedItemPosition();
		Job tempJob;

		if (type.isEmpty()) {
			typeField.setError(getString(R.string.error_field_required));
			return;
		}

		try {
			tempJob = new Job(type, des, df.parse(startString), df.parse(endString));
		} catch (ParseException e) {
			System.out.println (e.getMessage());
			return;
		}

		final Job toCreate = tempJob;

		ValueEventListener getJobURL = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					final Location tempLoc = new Location(dataSnapshot);

					final DatabaseReference jobs = FirebaseDatabase.getInstance().getReferenceFromUrl(tempLoc.jobs);

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
							}

							tempLoc.numJobs++;
							dataSnapshot.getRef().child(Long.toString(dataSnapshot.getChildrenCount())).setValue(toCreate.toMap());
							locationBase.child(client + "").child(Integer.toString(locnum)).setValue(tempLoc.toMap());
						}

						@Override
						public void onCancelled(@NonNull DatabaseError databaseError) {}
					};

					jobs.addListenerForSingleValueEvent(checkForJob);
				} else {
					System.out.println ("locationBase/" + client + "/" + locnum + " DNE");
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		locationBase.child(client + "").child(Integer.toString(locnum)).addListenerForSingleValueEvent(getJobURL);
	}
}
