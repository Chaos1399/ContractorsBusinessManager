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
import com.google.firebase.database.ValueEventListener;

public class AEditClient extends AdminSuperclass
		  implements AdapterView.OnItemSelectedListener {
	Spinner oNSpin;
	TextInputEditText NNET;
	TextInputEditText AET;
	TextInputEditText EET;
	TextInputEditText CET;

	ArrayAdapter<String> oNAdapter;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_aedit_client);

		oNSpin = findViewById(R.id.aecONSpin);
		NNET = findViewById(R.id.aecNNET);
		AET = findViewById(R.id.aecAET);
		CET = findViewById(R.id.aecCET);
		EET = findViewById(R.id.aecEET);

		oNSpin.setOnItemSelectedListener(this);
		oNAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, clientList);
		oNSpin.setAdapter(oNAdapter);

		oNSpin.setSelection(0);

		menu = new Intent(AEditClient.this, AMenu.class);
	}

	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int i, long l) {
		if (parent.getId() == R.id.aecONSpin) {
			clientBase.child(i + "").orderByKey().addListenerForSingleValueEvent(new ValueEventListener() {
				@Override
				public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
					if (dataSnapshot.exists()) {
						Client temp = new Client (dataSnapshot);

						AET.setText(temp.address);
						CET.setText(temp.city);
						EET.setText(temp.email);
					}
				}

				@Override
				public void onCancelled(@NonNull DatabaseError databaseError) {}
			});
		}
	}

	@Override
	public void onNothingSelected(AdapterView<?> adapterView) {}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			// Respond to the action bar's Up/Home button
			case android.R.id.home:
				addExtras(menu);
				navigateUpTo(menu);
				return true;
		}
		return super.onOptionsItemSelected(item);
	}

	public void aecDidPressSave(View view) {
		final int oname = oNSpin.getSelectedItemPosition();
		final String nname = NNET.getText().toString();
		final String address = AET.getText().toString();
		final String city = CET.getText().toString();
		final String email = EET.getText().toString();

		ValueEventListener getAndSet = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					Client temp = new Client(dataSnapshot);
					boolean changed = false;

					if (!nname.equals(temp.name)) {
						temp.name = nname;
						changed = true;
					}
					if (!email.equals(temp.email)) {
						temp.email = email;
						changed = true;
					}
					if (!address.equals(temp.address)) {
						temp.address = address;
						changed = true;
					}
					if (!city.equals(temp.city)) {
						temp.city = city;
						changed = true;
					}

					if (changed) {
						if (!nname.isEmpty()) {
							AEditClient.this.clientList.remove(oname);
							AEditClient.this.clientList.add(oname, nname);
							persistenceStartup.child("Clients").child(oname + "").setValue(nname);
						}
						clientBase.child(oname + "").setValue(temp.toMap());
						AEditClient.this.addExtras(menu);
						AEditClient.this.navigateUpTo(menu);
					}
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		clientBase.child(oname + "").addListenerForSingleValueEvent(getAndSet);
	}
}
