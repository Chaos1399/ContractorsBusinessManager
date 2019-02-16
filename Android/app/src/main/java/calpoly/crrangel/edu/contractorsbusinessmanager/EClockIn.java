package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.annotation.SuppressLint;
import android.app.PendingIntent;
import android.app.TaskStackBuilder;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.NavigationView;
import android.support.v4.app.NotificationCompat;
import android.support.v4.app.NotificationManagerCompat;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.widget.Toolbar;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Date;

public class EClockIn extends EmpSuperclass
		  implements AdapterView.OnItemSelectedListener,
		  NavigationView.OnNavigationItemSelectedListener{
	ArrayList<Location> locationList;
	ArrayList<String> locNameList;
	ArrayList<String> jobList;

	Button workButton;
	Spinner clntSpin;
	Spinner addrSpin;
	Spinner ctySpin;
	Spinner jSpin;
	ArrayAdapter<String> clntAdapter;
	ArrayAdapter<String> addrAdapter;
	ArrayAdapter<CharSequence> ctyAdapter;
	ArrayAdapter<String> jAdapter;

	TimerTask timer;
	int dropdownItem = android.R.layout.simple_spinner_dropdown_item;
	long startTime = 0;

	//TODO: Change Title and Message in notification
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_eclock_in);
		Toolbar toolbar = findViewById(R.id.ciToolbar);
		setSupportActionBar(toolbar);
		DrawerLayout drawer = findViewById(R.id.drawer_layout);
		ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
				  this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
		drawer.addDrawerListener(toggle);
		toggle.syncState();
		NavigationView navigationView = findViewById(R.id.enav_view);
		navigationView.setNavigationItemSelectedListener(this);

		workButton = findViewById(R.id.eciWorkButton);

		clntSpin = findViewById(R.id.eciClientSpin);
		addrSpin = findViewById(R.id.eciASpin);
		ctySpin = findViewById(R.id.eciCitySpin);
		jSpin = findViewById(R.id.eciJSpin);
		clntSpin.setOnItemSelectedListener(this);
		addrSpin.setOnItemSelectedListener(this);
		ctySpin.setOnItemSelectedListener(this);
		jSpin.setOnItemSelectedListener(this);

		clntAdapter = new ArrayAdapter<>(this, dropdownItem, clientList);
		ctyAdapter = ArrayAdapter.createFromResource(this, R.array.SLOCountyCities, dropdownItem);
		clntSpin.setAdapter(clntAdapter);
		ctySpin.setAdapter(ctyAdapter);

		makeIntents(this);
		setLocJob(0);
	}

	@Override
	protected void onStart() {
		super.onStart();

		try {
			FileInputStream persistentStorage = openFileInput("PersistentStorage");
			int readByte;
			StringBuilder content = new StringBuilder();
			while ((readByte = persistentStorage.read()) != -1)
				content.append((char) readByte);
			// Split file read in on all whitespace
			String[] strs = content.toString().split("\\s+");

			if (strs[0].equals("clockedIn:"))
				isClockedIn = Boolean.valueOf(strs[1]);
		} catch (Exception e) {
			e.printStackTrace();
		}
		if (isClockedIn)
			workButton.setText(R.string.clock_out);
	}

	@Override
	public void onNothingSelected(AdapterView<?> parent) {}


	//Spinner Item Selected
	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
		if (parent.getId() == R.id.eciClientSpin) {
			addrSpin.setSelection(0, false);
			jSpin.setSelection(0, false);
			setLocJob(position);
		} else if (parent.getId() == R.id.eciASpin) {
			jSpin.setSelection(0, false);
			setJob(position);
		}
	}

	@Override
	public void onBackPressed() {
		DrawerLayout drawer = findViewById(R.id.drawer_layout);
		if (drawer.isDrawerOpen(GravityCompat.START)) {
			drawer.closeDrawer(GravityCompat.START);
		} else {
			menu = new Intent(this, EMenu.class);
			addExtras(menu);
			startActivity(menu);
		}
	}

	// Drawer Item Selected
	@Override
	public boolean onNavigationItemSelected(@NonNull MenuItem item) {
		int id = item.getItemId();
		Intent intent = null;

		((DrawerLayout) findViewById(R.id.drawer_layout)).closeDrawer(GravityCompat.START);

		if (id == R.id.eLogoutMenu) {
			auth.signOut();
			intent = signOut;
		} else if (id == R.id.eMenuMenu) {
			intent = menu;
		} else if (id == R.id.editProfileMenu) {
			intent = editProfile;
		} else if (id == R.id.clockInMenu) {
			intent = clockIn;
		} else if (id == R.id.viewScheduleEMenu) {
			intent = viewSchedule;
		} else if (id == R.id.pphMenu) {
			intent = payPeriodHistory;
		} else if (id == R.id.timeBankMenu) {
			intent = timeBank;
		}

		if (intent != null) {
			addExtras(intent);
			startActivity(intent);
		}

		return true;
	}

	private void setLocJob (final int position) {
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

								addrAdapter = new ArrayAdapter<>(EClockIn.this, dropdownItem, locNameList);
								addrSpin.setAdapter(addrAdapter);

								setJob(0);
							}
						}

						@Override
						public void onCancelled(DatabaseError databaseError) { finish(); }
					};

					for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
						Client temp = new Client(snapshot);

						FirebaseDatabase
								  .getInstance()
								  .getReferenceFromUrl(temp.properties)
								  .orderByKey()
								  .addListenerForSingleValueEvent(readLList);
					}
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
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

					jAdapter = new ArrayAdapter<>(EClockIn.this, dropdownItem, jobList);
					jSpin.setAdapter(jAdapter);
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		if (locationList.size() <= position)
			return;

		DatabaseReference locs = FirebaseDatabase.getInstance().getReferenceFromUrl(locationList.get(position).jobs);

		locs.orderByKey().addListenerForSingleValueEvent(readJList);
	}

	public void didPressWorkButton (View view) {
		if (isClockedIn) {
			isClockedIn = false;
			workButton.setText(R.string.clock_in);
			timer.cancel(true);
		} else {
			isClockedIn = true;
			workButton.setText(R.string.clock_out);
			startTime = System.currentTimeMillis();
			sendNotification();
			timer = new TimerTask();
			timer.execute((Void) null);
		}

		String fileContents = "clockedIn: " + isClockedIn;
		FileOutputStream outputStream;

		try {
			outputStream = openFileOutput("PersistentStorage", Context.MODE_PRIVATE);
			outputStream.write(fileContents.getBytes());
			outputStream.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void sendNotification() {
		clockIn = new Intent(this, EClockIn.class);
		clockIn.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
		addExtras(clockIn);

		TaskStackBuilder stackBuilder = TaskStackBuilder.create(this);
		stackBuilder.addNextIntentWithParentStack(clockIn);

		PendingIntent contentIntent = stackBuilder.getPendingIntent(0,
				  PendingIntent.FLAG_CANCEL_CURRENT);

		NotificationCompat.Builder builder =
				  new NotificationCompat.Builder(this, TIMER_CHANNEL)
							 .setSmallIcon(R.mipmap.cbm_launcher_icon_round)
							 .setContentTitle("HEY! LISTEN!")
							 .setContentText("You need to clock out, bud.")
							 .setAutoCancel(true);

		builder.setContentIntent(contentIntent);
		NotificationManagerCompat nManager = NotificationManagerCompat.from(this);
		nManager.notify(NID, builder.build());
	}

	@SuppressLint("StaticFieldLeak")
	public class TimerTask extends AsyncTask<Void, Void, Boolean> {
		private int tenMinutes = 1000 * 60 * 10;
		private int oneHour = 1000 * 60 * 60;
		private double hours;
		private int elapsedTime = 0;
		private int iterations = 0;

		TimerTask() {}

		@Override
		protected Boolean doInBackground(Void... params) {
			// Continue to loop while not cancelled, and while timer doesn't exceed twelve hours
			while (!isCancelled() && elapsedTime < (oneHour * 12)) {
				try {
					Thread.sleep(tenMinutes);
					elapsedTime += tenMinutes;
					if (elapsedTime >= (oneHour * 9)) {
						// At 9 hours, and every 30 min after, remind the employee they're clocked in
						if (iterations % 3 == 0)
							sendNotification();
						iterations++;
					}
				} catch (InterruptedException e) {
					break;
				}
			}
			return true;
		}

		// Doesn't seem like it will be used, but just in case, make it exactly the same as the onCancelled
		@Override
		protected void onPostExecute(Boolean result) {
			hours = (double) (System.currentTimeMillis() - startTime) / 1000 / 60;
			hours = new BigDecimal(hours).setScale(2, RoundingMode.HALF_UP).doubleValue();

			final Workday toSave = new Workday(df.format(new Date()),
					  clntSpin.getSelectedItem().toString(),
					  addrSpin.getSelectedItem().toString(),
					  ctySpin.getSelectedItem().toString(),
					  jSpin.getSelectedItem().toString(),
					  hours);

			workdayBase.child(user.uid).child((user.numPeriods - 1) + "").addListenerForSingleValueEvent(new ValueEventListener() {
				@Override
				public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
					String newDayNum = (dataSnapshot.exists())?
							  (dataSnapshot.getChildrenCount() + "") : "0";
					workdayBase.child(user.uid).child((user.numPeriods - 1) + "").child(newDayNum).setValue(toSave.toMap());
				}

				@Override
				public void onCancelled(@NonNull DatabaseError databaseError) {}
			});

			historyBase.child(user.uid).child((user.numPeriods - 1) + "").addListenerForSingleValueEvent(new ValueEventListener() {
				@Override
				public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
					if (dataSnapshot.exists()) {
						PayPeriod tempPer = new PayPeriod(dataSnapshot);
						tempPer.numDays++;
						tempPer.totalHours += toSave.hours;
						dataSnapshot.getRef().setValue(tempPer.toMap());
					}
				}

				@Override
				public void onCancelled(@NonNull DatabaseError databaseError) {}
			});
		}

		@Override
		protected void onCancelled() {
			hours = (double) (System.currentTimeMillis() - startTime) / 1000 / 60 / 60;
			hours = new BigDecimal(hours).setScale(2, RoundingMode.HALF_UP).doubleValue();

			final Workday toSave = new Workday(df.format(new Date()),
					  clntSpin.getSelectedItem().toString(),
					  addrSpin.getSelectedItem().toString(),
					  ctySpin.getSelectedItem().toString(),
					  jSpin.getSelectedItem().toString(),
					  hours);

			workdayBase.child(user.uid).child((user.numPeriods - 1) + "").addListenerForSingleValueEvent(new ValueEventListener() {
				@Override
				public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
					String newDayNum = (dataSnapshot.exists())?
							  (dataSnapshot.getChildrenCount() + "") : "0";
					workdayBase.child(user.uid).child((user.numPeriods - 1) + "").child(newDayNum).setValue(toSave.toMap());
				}

				@Override
				public void onCancelled(@NonNull DatabaseError databaseError) {}
			});

			historyBase.child(user.uid).child((user.numPeriods - 1) + "").addListenerForSingleValueEvent(new ValueEventListener() {
				@Override
				public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
					if (dataSnapshot.exists()) {
						PayPeriod tempPer = new PayPeriod(dataSnapshot);
						tempPer.numDays++;
						tempPer.totalHours += toSave.hours;
						dataSnapshot.getRef().setValue(tempPer.toMap());
					}
				}

				@Override
				public void onCancelled(@NonNull DatabaseError databaseError) {}
			});
		}
	}
}
