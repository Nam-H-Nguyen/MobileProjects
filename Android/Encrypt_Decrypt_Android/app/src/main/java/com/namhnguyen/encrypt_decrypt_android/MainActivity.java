package com.namhnguyen.encrypt_decrypt_android;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Base64;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import java.security.MessageDigest;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class MainActivity extends AppCompatActivity {

    Button btnEncrypt = findViewById(R.id.btnEncrypt);
    Button btnDecrypt = findViewById(R.id.btnDecrypt);

    TextView inputText = findViewById(R.id.inputText);
    TextView outputText = findViewById(R.id.outputText);

    String outputString = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        btnEncrypt.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                try {
                    outputString = encrypt(outputString, inputText.getText().toString());
                    outputText.setText(outputString);
                } catch(Exception e) {
                    e.printStackTrace();
                }
            }
        });

        btnDecrypt.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                try {
                    outputString = decrypt(outputString, outputText.getText().toString());
                } catch(Exception e) {
                    Toast.makeText(MainActivity.this, "Wrong Password", Toast.LENGTH_LONG).show();
                    e.printStackTrace();
                }
                outputText.setText(outputString);
            }
        });
    }

    private String encrypt(String Data, String password) throws Exception {
        SecretKeySpec key = generateKey(password);
        Cipher c = Cipher.getInstance("AES");
        c.init(Cipher.ENCRYPT_MODE, key);
        byte[] encVal = c.doFinal(Data.getBytes());

        return Base64.encodeToString(encVal, Base64.DEFAULT);
    }

    private String decrypt(String outputString, String password) throws Exception {
        SecretKeySpec key = generateKey(password);
        Cipher c = Cipher.getInstance("AES");

        c.init(Cipher.DECRYPT_MODE, key);
        byte[] decodedValue = Base64.decode(outputString, Base64.DEFAULT);
        byte[] decValue = c.doFinal(decodedValue);

        return new String(decValue);
    }


    private SecretKeySpec generateKey(String password) throws Exception {
        final MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] bytes = password.getBytes("UTF-8");
        digest.update(bytes, 0, bytes.length);
        byte[] key = digest.digest();

        return new SecretKeySpec(key, "AES");
    }
}
