package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.TextInputEditText;
import android.view.MenuItem;
import android.view.View;

public class AddClient extends AdminSuperclass {
	TextInputEditText NET;
	TextInputEditText EET;
	TextInputEditText AET;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add_client);

		NET = findViewById(R.id.acNET);
		EET = findViewById(R.id.acEET);
		AET = findViewById(R.id.acAET);
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

	public void acDidPressSave (View view) {
		String name = "";
		String email = "";
		String address = "";
		String propURL = "";
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

		if (errorSet) return;

		propURL = locationBase + "/" + name;

		toRet = new Client (name, address, email, propURL, 0);

		this.clientList.add(name);
		clientBase.child(name).setValue(toRet.toMap());
		addExtras(menu);
		navigateUpTo(menu);
	}
}
