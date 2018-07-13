package calpoly.crrangel.edu.contractorsbusinessmanager;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.content.Intent;

import android.os.AsyncTask;

import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.text.DateFormat;
import java.text.FieldPosition;
import java.text.ParsePosition;
import java.util.ArrayList;
import java.util.Date;

/**
 * A login screen that offers login via email/password.
 */
public class Login extends AppCompatActivity {
    Intent intent;
	ArrayList<String> clientList;
	ArrayList<String> employeeList;
	User user = null;
	DatabaseReference clientBase = FirebaseDatabase.getInstance().getReference("Clients");
	DatabaseReference userBase = FirebaseDatabase.getInstance().getReference("Users");

	private static final String TAG = "MyActivity";

    /**
     * Keep track of the login task to ensure we can cancel it if requested.
     */
    private UserLoginTask mAuthTask = null;
    private FirebaseAuth mAuth;

    // UI references.
    private TextView mUserView;
    private EditText mPasswordView;
    private View mProgressView;
    private View mLoginFormView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        // Set up the login form.
        mUserView = findViewById(R.id.uname);

        mPasswordView = findViewById(R.id.password);
        mPasswordView.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView textView, int id, KeyEvent keyEvent) {
                if (id == EditorInfo.IME_ACTION_DONE || id == EditorInfo.IME_NULL) {
                    attemptLogin();
                    return true;
                }
                return false;
            }
        });

        Button mEmailSignInButton = findViewById(R.id.email_sign_in_button);
        mEmailSignInButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                attemptLogin();
            }
        });

        mLoginFormView = findViewById(R.id.login_form);
        mProgressView = findViewById(R.id.login_progress);

        DateFormat format = new DateFormat() {
            @Override
            public StringBuffer format(Date date, StringBuffer toAppendTo, FieldPosition fieldPosition) {
                return null;
            }

            @Override
            public Date parse(String source, ParsePosition pos) {
                return null;
            }
        };

        clientList = new ArrayList<>();
        employeeList = new ArrayList<>();

        mAuth = FirebaseAuth.getInstance();
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        mPasswordView.setText("");
        mUserView.setText("");
        mAuthTask = null;
    }

    public void onStart() {
    	super.onStart();

		FirebaseUser currentUser = mAuth.getCurrentUser();

		if (currentUser == null) {
			Log.d(TAG, "currentuser is null");
		} else {
			Log.d(TAG, "currentuser is not null: " + currentUser);
		}
	}

    /**
     * Attempts to sign in the account specified by the login form.
     * If there are form errors (invalid username, missing fields, etc.), the
     * errors are presented and no actual login attempt is made.
     */
    private void attemptLogin() {
        if (mAuthTask != null) {
            return;
        }

        // Reset errors.
        mUserView.setError(null);
        mPasswordView.setError(null);

        // Store values at the time of the login attempt.
        String uname = mUserView.getText().toString();
        String password = mPasswordView.getText().toString();

        showProgress(true);
        mAuthTask = new UserLoginTask(uname, password);
        mAuthTask.doInBackground((Void) null);
    }

    /**
     * Shows the progress UI and hides the login form.
     */
    @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR2)
    private void showProgress(final boolean show) {
        int shortAnimTime = getResources().getInteger(android.R.integer.config_shortAnimTime);

        mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
        mLoginFormView.animate().setDuration(shortAnimTime).alpha(
                show ? 0 : 1).setListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                mLoginFormView.setVisibility(show ? View.GONE : View.VISIBLE);
            }
        });

        mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
        mProgressView.animate().setDuration(shortAnimTime).alpha(
                show ? 1 : 0).setListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                mProgressView.setVisibility(show ? View.VISIBLE : View.GONE);
            }
        });
    }
	public Bundle userToBundle (User u) {
		Bundle b = new Bundle();

		b.putString("name", u.name);
		b.putString("password", u.password);
		b.putString("email", u.email);
		b.putString("toWork", u.toWork);
		b.putString("history", u.history);
		b.putBoolean("admin", u.admin);
		b.putDouble("pph", u.pph);
		b.putDouble("sickTime", u.sickTime);
		b.putDouble("vacaTime", u.vacaTime);
		b.putInt("numDaysScheduled", u.numDaysScheduled);
		b.putInt("numPeriods", u.numPeriods);

		return b;
	}

    /**
     * Represents an asynchronous login/registration task used to authenticate
     * the user.
     */
    @SuppressLint("StaticFieldLeak")
    public class UserLoginTask extends AsyncTask<Void, Void, Boolean> {

        private final String mName;
        private final String mPassword;

        UserLoginTask(String name, String password) {
            mName = name;
            mPassword = password;
        }

        @Override
        protected Boolean doInBackground(Void... params) {

        	ValueEventListener startClist = new ValueEventListener() {
				@Override
				public void onDataChange(DataSnapshot dataSnapshot) {
					if (dataSnapshot.exists()) {
						for (DataSnapshot snapshot : dataSnapshot.getChildren()) {
							for (DataSnapshot snap : snapshot.getChildren()) {
								if (snapshot.getKey().equals("Clients")) {
									if (!clientList.contains(snap.getValue(String.class)))
										clientList.add(snap.getValue(String.class));
								} else {
									if (!employeeList.contains(snap.getValue(String.class)))
										employeeList.add(snap.getValue(String.class));
								}
							}
						}
					}
				}

				@Override
				public void onCancelled(DatabaseError databaseError) {}
			};

        	FirebaseDatabase.getInstance().getReference().child("PersistenceStartup").addListenerForSingleValueEvent(startClist);

			ValueEventListener read = new ValueEventListener() {
				@Override
				public void onDataChange(DataSnapshot snapshot) {
					if (snapshot.exists()) {
						user = new User (snapshot);

						if (mPassword.equals(user.password)) {
							if (user.admin) {
								showProgress(false);
								intent = new Intent (Login.this, AMenu.class);
								intent.putExtra("user", userToBundle(user));
								intent.putExtra("cList", clientList);
								intent.putExtra("eList", employeeList);
								startActivity (intent);
							} else {
								showProgress(false);
								intent = new Intent (Login.this, EMenu.class);
								startActivity (intent);
							}
						} else {
							UserLoginTask.this.onPostExecute(false);
						}
					} else {
						mUserView.setError(getString (R.string.error_invalid_name));
						mUserView.requestFocus();
					}
				}

				@Override
				public void onCancelled(DatabaseError databaseError) {}
			};

			userBase.child(mName).orderByKey().addListenerForSingleValueEvent(read);

            return true;
        }

        @Override
        protected void onPostExecute(final Boolean success) {
            mAuthTask = null;
            showProgress(false);

            if (success) {
                finish();
            } else {
                mPasswordView.setError(getString(R.string.error_incorrect_password));
                if (!mPasswordView.hasFocus()) {
                    findViewById(mPasswordView.getId()).requestFocus();
                }
            }
        }

        @Override
        protected void onCancelled() {
            mAuthTask = null;
            showProgress(false);
        }
    }
}

