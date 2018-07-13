package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.TextInputEditText;
import android.view.MenuItem;
import android.view.View;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

public class EditClient extends AdminSuperclass {
	TextInputEditText ONET;
	TextInputEditText NNET;
	TextInputEditText AET;
	TextInputEditText EET;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_edit_client);

		// Load passed User, clientList, and employeeList
		Intent toHere = getIntent();
		if (toHere.getExtras() == null) return;
		this.user = bundleToUser(toHere.getExtras().getBundle("user"));
		this.clientList = toHere.getStringArrayListExtra("cList");
		this.employeeList = toHere.getStringArrayListExtra("eList");

		ONET = findViewById(R.id.ecONET);
		NNET = findViewById(R.id.ecNNET);
		AET = findViewById(R.id.ecAET);
		EET = findViewById(R.id.ecEET);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			// Respond to the action bar's Up/Home button
			case android.R.id.home:
				menu = new Intent(this, AMenu.class);
				menu.putExtra("user", userToBundle(user));
				menu.putExtra("cList", clientList);
				menu.putExtra("eList", employeeList);
				navigateUpTo(menu);
				return true;
		}
		return super.onOptionsItemSelected(item);
	}

	public void ecDidPressSave(View view) {
		final String oname = ONET.getText().toString();
		final String nname = NNET.getText().toString();
		final String address = AET.getText().toString();
		final String email = EET.getText().toString();

		if (oname.isEmpty()) {
			ONET.setError(getString(R.string.error_field_required));
			return;
		}

		ValueEventListener getAndSet = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					Client temp = new Client(dataSnapshot);
					Client toRet = new Client(temp);

					//TODO: Restructure Firebase to ensure no deletion has to occur, and that everything will be based off the name value, not name key
					if (!nname.isEmpty()) {
						toRet.name = nname;
						//toRet.properties = toRet.properties.replace(oname, nname);
					}
					if (!address.isEmpty())
						toRet.address = address;
					if (!email.isEmpty())
						toRet.email = email;

					if (!toRet.toString().equals(temp.toString())) {
						menu = new Intent(EditClient.this, AMenu.class);

						if (!nname.isEmpty()) {
							EditClient.this.clientList.add(nname);
							EditClient.this.clientList.remove(oname);
							clientBase.child(nname).setValue(toRet.toMap());
							//clientBase.child(oname).removeValue();
						} else {
							clientBase.child(oname).setValue(toRet.toMap());
						}

						menu.putExtra("user", userToBundle(user));
						menu.putExtra("cList", clientList);
						menu.putExtra("eList", employeeList);

						navigateUpTo(menu);
					}
				} else {
					ONET.setError(getString(R.string.error_invalid_name));
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		clientBase.child(oname).addListenerForSingleValueEvent(getAndSet);
	}
}
