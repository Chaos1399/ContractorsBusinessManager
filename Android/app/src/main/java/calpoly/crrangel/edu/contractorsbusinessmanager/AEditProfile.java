package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.TextInputEditText;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.ToggleButton;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

public class AEditProfile extends AdminSuperclass {
	TextInputEditText NET;
	TextInputEditText EET;
	EditText PPHET;
	EditText STET;
	EditText VTET;
	ToggleButton AB;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_aedit_profile);

		// Make and set up all Intents
		this.makeIntents(AEditProfile.this);

		NET = findViewById(R.id.aepNET);
		EET = findViewById(R.id.aepEET);
		PPHET = findViewById(R.id.aepPPHET);
		STET = findViewById(R.id.aepSTET);
		VTET = findViewById(R.id.aepVTET);
		AB = findViewById(R.id.aepAdminButton);
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

    public void aepDidPressSave (View view) {
		String ncheck = "";
		final String email = EET.getText().toString();
		final String pph = PPHET.getText().toString();
		final String stet = STET.getText().toString();
		final String vtet = VTET.getText().toString();

		if (NET.getText().toString().isEmpty()) {
			NET.setError(getString(R.string.error_field_required));
			return;
		} else {
			ncheck = NET.getText().toString();
		}

		final String name = ncheck;

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
						userBase.child(name).setValue(toRet.toMap());
					}
				} else {
					NET.setError(getString(R.string.error_invalid_name));
				}
			}

			@Override
			public void onCancelled(DatabaseError databaseError) {}
		};

		userBase.child(name).addListenerForSingleValueEvent(getU);
	}
}
