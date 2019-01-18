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
	ArrayList<Integer> yearList;

	Spinner clntSpin;
	Spinner addrSpin;
	Spinner ctySpin;
	Spinner jSpin;
	Spinner smSpin;
	Spinner sdSpin;
	Spinner sySpin;
	Spinner emSpin;
	Spinner edSpin;
	Spinner eySpin;

	ArrayAdapter<String> clntAdapter;
	ArrayAdapter<String> addrAdapter;
	ArrayAdapter<CharSequence> ctyAdapter;
	ArrayAdapter<String> jAdapter;
	ArrayAdapter<CharSequence> smAdapter;
	ArrayAdapter<CharSequence> emAdapter;
	ArrayAdapter<CharSequence> sdAdapter;
	ArrayAdapter<CharSequence> edAdapter;
	ArrayAdapter<Integer> syAdapter;
	ArrayAdapter<Integer> eyAdapter;
	String toSched;
	long selectedDate;
	int dropdownItem = android.R.layout.simple_spinner_dropdown_item;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_aadd_to_schedule);

		Intent toHere = getIntent();
		if (toHere.getExtras() == null) return;
		this.toSched = toHere.getStringExtra("toSched");
		selectedDate = toHere.getLongExtra("date", 0);

		// Make spinners
		clntSpin = findViewById(R.id.aasClientSpin);
		addrSpin = findViewById(R.id.aasAddrSpin);
		ctySpin = findViewById(R.id.aasCitySpin);
		jSpin = findViewById(R.id.aasJobSpin);
		smSpin = findViewById(R.id.aasStartMonth);
		emSpin = findViewById(R.id.aasEndMonth);
		sdSpin = findViewById(R.id.aasStartDay);
		edSpin = findViewById(R.id.aasEndDay);
		sySpin = findViewById(R.id.aasStartYear);
		eySpin = findViewById(R.id.aasEndYear);

		clntSpin.setOnItemSelectedListener(this);
		addrSpin.setOnItemSelectedListener(this);
		ctySpin.setOnItemSelectedListener(this);
		jSpin.setOnItemSelectedListener(this);
		smSpin.setOnItemSelectedListener(this);
		emSpin.setOnItemSelectedListener(this);
		sdSpin.setOnItemSelectedListener(this);
		edSpin.setOnItemSelectedListener(this);
		sySpin.setOnItemSelectedListener(this);
		eySpin.setOnItemSelectedListener(this);

		Date d = (selectedDate > 0)? new Date(selectedDate) : new Date();
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

		smSpin.setAdapter(smAdapter);
		emSpin.setAdapter(emAdapter);
		sdSpin.setAdapter(sdAdapter);
		edSpin.setAdapter(edAdapter);
		sySpin.setAdapter(syAdapter);
		eySpin.setAdapter(eyAdapter);
		ctySpin.setAdapter(ctyAdapter);
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
		if (parent.getId() == R.id.aasClientSpin) {
			addrSpin.setSelection(0, false);
			jSpin.setSelection(0, false);
			setLocJob(position, false);
		} else if (parent.getId() == R.id.aasAddrSpin) {
			jSpin.setSelection(0, false);
			setJob(position);
		} else if (parent.getId() == R.id.aasStartMonth) {
			Date d = new Date();
			d.setYear(Integer.parseInt(sySpin.getSelectedItem().toString()));
			d.setMonth(position);
			int prevpos = sdSpin.getSelectedItemPosition();
			sdAdapter = ArrayAdapter.createFromResource(this, getArrayFromTime(d.getTime()), dropdownItem);
			sdSpin.setAdapter(sdAdapter);
			prevpos = (prevpos >= sdSpin.getCount())? (sdSpin.getCount() - 1) : prevpos;
			sdSpin.setSelection(prevpos, false);
		} else if (parent.getId() == R.id.aasEndMonth) {
			Date d = new Date();
			d.setYear(Integer.parseInt(sySpin.getSelectedItem().toString()));
			d.setMonth(position);
			int prevpos = edSpin.getSelectedItemPosition();
			edAdapter = ArrayAdapter.createFromResource(this, getArrayFromTime(d.getTime()), dropdownItem);
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
									clntAdapter = new ArrayAdapter<>(AAddToSchedule.this, dropdownItem, clientList);
									addrAdapter = new ArrayAdapter<>(AAddToSchedule.this, dropdownItem, locNameList);
									jAdapter = new ArrayAdapter<>(AAddToSchedule.this, dropdownItem, jobList);
									clntAdapter.setDropDownViewResource(dropdownItem);
									addrAdapter.setDropDownViewResource(dropdownItem);
									jAdapter.setDropDownViewResource(dropdownItem);
									clntSpin.setAdapter(clntAdapter);
									addrSpin.setAdapter(addrAdapter);
									jSpin.setAdapter(jAdapter);
								}

								addrAdapter.clear();
								addrAdapter.addAll(locNameList);
								addrAdapter.notifyDataSetChanged();

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

	public void aasDidPressSave (View view) {
		ScheduledWorkday temp = null;
		final ScheduledWorkday toRet;

		try {
			temp = new ScheduledWorkday(clntSpin.getSelectedItem().toString(),
					  addrSpin.getSelectedItem().toString(),
					  ctySpin.getSelectedItem().toString(),
					  jSpin.getSelectedItem().toString(),
					  df.parse((smSpin.getSelectedItemPosition() + 1) + "/" +
								 (sdSpin.getSelectedItemPosition() + 1) + "/" +
								 sySpin.getSelectedItem().toString().substring(2)),
					  df.parse((emSpin.getSelectedItemPosition() + 1) + "/" +
								 (edSpin.getSelectedItemPosition() + 1) + "/" +
								 eySpin.getSelectedItem().toString().substring(2)));

		} catch (ParseException e) {
			e.printStackTrace();
		}

		toRet = temp;
		if (toRet == null) {
			System.out.println("Something went wrong. Try again");
			return;
		}

		final ValueEventListener setNumDays = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				//noinspection ConstantConditions
				int numdays = dataSnapshot.getValue(Integer.class);

				FirebaseDatabase.getInstance().getReferenceFromUrl(dataSnapshot.getRef().toString()).setValue(numdays + 1);
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		ValueEventListener getAndSet = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {

				scheduleBase.child(toSched).child(Long.toString(dataSnapshot.getChildrenCount())).setValue(toRet.toMap());
				userBase.child(toSched).child("numDays").addListenerForSingleValueEvent(setNumDays);
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		scheduleBase.child(toSched).orderByKey().addListenerForSingleValueEvent(getAndSet);

		Intent intent = new Intent(this, ASchedule.class);
		addExtras(intent);
		intent.putExtra("date", selectedDate);

		navigateUpTo(intent);
	}
}
