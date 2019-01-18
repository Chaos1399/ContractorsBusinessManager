package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.TextInputEditText;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.ToggleButton;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

//TODO: Use this page instead to redirect to the webpage
public class AEditUser extends AdminSuperclass
		  implements AdapterView.OnItemSelectedListener {
	Spinner nSpin;
	TextInputEditText EET;
	EditText PPHET;
	EditText STET;
	EditText VTET;
	ToggleButton AB;

	ArrayAdapter<String> nAdapter;
	User toEdit;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_aedit_profile);

		// Make and set up all Intents
		this.makeIntents(AEditUser.this);

		nSpin = findViewById(R.id.aepNameSpin);
		EET = findViewById(R.id.aepEET);
		PPHET = findViewById(R.id.aepPPHET);
		STET = findViewById(R.id.aepSTET);
		VTET = findViewById(R.id.aepVTET);
		AB = findViewById(R.id.aepAdminButton);

		nSpin.setOnItemSelectedListener(this);

		nAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_dropdown_item, employeeNameList);
		nSpin.setAdapter(nAdapter);
		toEdit = new User();

		nSpin.setSelection(0);
		menu = new Intent (this, AMenu.class);
	}

	@Override
	public void onNothingSelected(AdapterView<?> parent) {}

	@Override
	public void onItemSelected (AdapterView<?> parent, View view, int position, long id) {
		if (parent.getId() == R.id.aepNameSpin) {
			userBase.child(employeeList.get(nSpin.getSelectedItemPosition()).uid).orderByKey()
					  .addListenerForSingleValueEvent(new ValueEventListener() {
						  @Override
						  public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
							  if (dataSnapshot.exists()) {
								  toEdit = new User(dataSnapshot);
								  EET.setText(toEdit.email);
								  PPHET.setText(toEdit.pph + "");
								  STET.setText(toEdit.sickTime + "");
								  VTET.setText(toEdit.vacaTime + "");
								  AB.setChecked(toEdit.admin);
							  }
						  }

						  @Override
						  public void onCancelled(@NonNull DatabaseError databaseError) {}
					  });
		}
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
			// Respond to the action bar's Up/Home button
			case android.R.id.home:
				Intent menu = new Intent(this, AMenu.class);
				addExtras(menu);
				navigateUpTo(menu);
				return true;
		}
		return super.onOptionsItemSelected(item);
	}

	public void aepDidPressSave (View view) {
		final String uid = employeeList.get(nSpin.getSelectedItemPosition()).uid;
		final String email = EET.getText().toString();
		final String pph = PPHET.getText().toString();
		final String stet = STET.getText().toString();
		final String vtet = VTET.getText().toString();

		ValueEventListener getU = new ValueEventListener() {
			@Override
			public void onDataChange(DataSnapshot dataSnapshot) {
				if (dataSnapshot.exists()) {
					User tempU = new User(dataSnapshot);
					User toRet = new User(dataSnapshot);

					if (!email.isEmpty())
						toRet.email = email;
					if (!pph.isEmpty())
						toRet.pph = Double.parseDouble(pph);
					if (!stet.isEmpty())
						toRet.sickTime = Double.parseDouble(stet);
					if (!vtet.isEmpty())
						toRet.vacaTime = Double.parseDouble(vtet);
					toRet.admin = AB.isChecked();

					if (!toRet.toString().equals(tempU.toString())) {
						userBase.child(uid).setValue(toRet.toMap());
					}

					AEditUser.this.addExtras(menu);
					AEditUser.this.navigateUpTo(menu);
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		userBase.child(uid).addListenerForSingleValueEvent(getU);
	}
}
