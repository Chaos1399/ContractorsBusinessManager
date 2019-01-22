package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.content.Intent;
import android.support.annotation.NonNull;
import android.os.Bundle;
import android.support.design.widget.TextInputEditText;
import android.support.v7.app.AlertDialog;
import android.text.InputType;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.auth.FirebaseAuthUserCollisionException;
import com.google.firebase.database.FirebaseDatabase;

//TODO: Use this page instead to redirect to the webpage
public class AAddUser extends AdminSuperclass {
	TextInputEditText NET;
	TextInputEditText EET;
	TextInputEditText PET;
	TextInputEditText PPHET;
	final FirebaseAuth mAuth = FirebaseAuth.getInstance();
	final String adminEmail = mAuth.getCurrentUser().getEmail();
	String adminPass;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_aadd_user);

		NET = findViewById(R.id.auNET);
		EET = findViewById(R.id.auEET);
		PET = findViewById(R.id.auPET);
		PPHET = findViewById(R.id.auPPHET);

		PPHET.setOnEditorActionListener(new TextView.OnEditorActionListener() {
			@Override
			public boolean onEditorAction(TextView textView, int i, KeyEvent keyEvent) {
				if (i == 6)
					auDidPressSave(textView);

				return false;
			}
		});

		// Make and set up all Intents
		this.makeIntents(AAddUser.this);
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

	public void auDidPressSave(View view) {
		String name = "";
		String email = "";
		String password = "";
		String pph = "";
		String toWorkURL;
		String payURL;
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
		if (PET.getText().toString().isEmpty()) {
			PET.setError(getString(R.string.error_field_required));
			errorSet = true;
		} else if (PET.getText().toString().length() <= 6) {
			PET.setError(getString(R.string.error_short_password));
			errorSet = true;
		} else {
			password = PET.getText().toString();
		}
		if (PPHET.getText().toString().isEmpty()) {
			PPHET.setError(getString(R.string.error_field_required));
			errorSet = true;
		} else {
			pph = PPHET.getText().toString();
		}

		if (errorSet) return;

		toWorkURL = scheduleBase.toString() + "/" + name;
		payURL = FirebaseDatabase.getInstance().getReference().toString() + "/Pay Period Histories/";

		final String n = name, e = email, twurl = toWorkURL, purl = payURL;
		final String fpph = pph;

		User tempU = new User(n, e, twurl, purl, null, Double.valueOf(fpph),
				  0.0, 0.0, false, 0, 0);
		signInDialog(tempU, password);
	}

	public void addUserDidPressCancel (View view) {
		NET.getText().clear();
		EET.getText().clear();
		PET.getText().clear();
		PPHET.getText().clear();

		Intent intent = getIntent();
		addExtras(intent);

		super.onBackPressed();
	}

	public void signInDialog (final User newUser, final String newUserPass) {
		final TextInputEditText passField = new TextInputEditText(this);

		passField.setHint(R.string.password);
		passField.setBackgroundColor(getResources().getColor(R.color.primary));
		passField.setTextColor(getResources().getColor(R.color.secondaryAccent));
		passField.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);

		final AlertDialog dialog = new AlertDialog.Builder(AAddUser.this, R.style.CustomDialogTheme)
				  .setView(passField)
				  .setMessage(R.string.reenterPass)
				  .setPositiveButton(R.string.sign_in, null)
				  .setNegativeButton(R.string.cancel, null)
				  .create();
		dialog.show();

		dialog.getButton(AlertDialog.BUTTON_POSITIVE).setOnClickListener(new View.OnClickListener() {
			@Override
			public void onClick(View view) {
				final String password = passField.getText().toString();

				mAuth.signInWithEmailAndPassword(adminEmail, password).addOnCompleteListener(new OnCompleteListener<AuthResult>() {
					@Override
					public void onComplete(@NonNull Task<AuthResult> task) {
						if (task.isSuccessful()) {
							adminPass = password;

							newUser.history += mAuth.getUid();
							newUser.toWork += mAuth.getUid();
							newUser.uid += mAuth.getUid();

							mAuth.signOut();

							createNewUserAndReturn(newUser, newUserPass);

							dialog.dismiss();
						} else {
							passField.setError(getResources().getString(R.string.error_incorrect_password));
							passField.requestFocus();
						}
					}
				});
			}
		});
	}

	void createNewUserAndReturn (final User newUser, final String newUserPass) {
		mAuth.createUserWithEmailAndPassword(newUser.email, newUserPass).addOnCompleteListener(new OnCompleteListener<AuthResult>() {
			@Override
			public void onComplete(@NonNull Task<AuthResult> task) {
				if (task.isSuccessful()) {
					String uid = mAuth.getUid();

					userBase.child(uid).setValue(newUser.toMap());
					persistenceStartup.child("EIDs").child(employeeList.size() + "").setValue(uid);
					persistenceStartup.child("Employees").child(employeeList.size() + "").setValue(newUser.name);
					AAddUser.this.employeeNameList.add(newUser.name);
					AAddUser.this.employeeList.add(newUser);

					mAuth.signOut();
					mAuth.signInWithEmailAndPassword(adminEmail, adminPass);

					AAddUser.this.addExtras(menu);
					AAddUser.this.navigateUpTo(menu);
				} else {
					Exception e = task.getException();

					if (e instanceof FirebaseAuthInvalidCredentialsException) {
						AAddUser.this.EET.setError(getResources().getString(R.string.error_invalid_email));
						AAddUser.this.EET.requestFocus();
					} else if (e instanceof FirebaseAuthUserCollisionException) {
						AAddUser.this.EET.setError(getResources().getString(R.string.error_user_exists));
						AAddUser.this.EET.requestFocus();
					}
				}
			}
		});
	}
}
