package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.TextInputEditText;
import android.text.InputType;
import android.view.MenuItem;
import android.view.View;

public class AAddClient extends AdminSuperclass {
	TextInputEditText NET;
	TextInputEditText EET;
	TextInputEditText AET;
	TextInputEditText CET;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_add_client);

		NET = findViewById(R.id.acNET);
		EET = findViewById(R.id.acEET);
		AET = findViewById(R.id.acAET);
		CET = findViewById(R.id.acCET);

		NET.setInputType(InputType.TYPE_TEXT_FLAG_CAP_WORDS);
		EET.setInputType(InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
		AET.setInputType(InputType.TYPE_TEXT_FLAG_CAP_WORDS);
		CET.setInputType(InputType.TYPE_TEXT_FLAG_CAP_WORDS);

		menu = new Intent(this, AMenu.class);
	}

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

	public void acDidPressSave (View view) {
		String name = "";
		String email = "";
		String address = "";
		String city = "";
		String propURL;
		Client toRet;
		boolean errorSet = false;

		if (NET.getText().toString().isEmpty()) {
			NET.setError(getString(R.string.error_field_required));
			errorSet = true;
		} else {
			name = NET.getText().toString();
		}
		if (EET.getText().toString().isEmpty()) {
			EET.setError(getString(R.string.error_field_required));
			errorSet = true;
		} else {
			email = EET.getText().toString();
		}
		if (AET.getText().toString().isEmpty()) {
			AET.setError(getString(R.string.error_field_required));
			errorSet = true;
		} else {
			address = AET.getText().toString();
		}
		if (CET.getText().toString().isEmpty()) {
			CET.setError(getString(R.string.error_field_required));
			errorSet = true;
		} else {
			city = CET.getText().toString();
		}

		if (errorSet) return;

		propURL = locationBase + "/" + clientList.size();

		toRet = new Client (name, address, city, email, propURL, 0);

		clientBase.child(clientList.size() + "").setValue(toRet.toMap());
		persistenceStartup.child("Clients").child(clientList.size() + "").setValue((name));
		this.clientList.add(name);
		this.addExtras(menu);
		navigateUpTo(menu);
	}
}
