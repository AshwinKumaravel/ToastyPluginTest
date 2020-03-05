package com.stanleyidesis.cordova.plugin;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.NonNull;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import com.scandit.datacapture.barcode.capture.BarcodeCapture;
import com.scandit.datacapture.barcode.capture.BarcodeCaptureListener;
import com.scandit.datacapture.barcode.capture.BarcodeCaptureSession;
import com.scandit.datacapture.barcode.capture.BarcodeCaptureSettings;
import com.scandit.datacapture.barcode.capture.SymbologySettings;
import com.scandit.datacapture.barcode.data.Barcode;
import com.scandit.datacapture.barcode.data.Symbology;
import com.scandit.datacapture.barcode.data.SymbologyDescription;
import com.scandit.datacapture.barcode.ui.overlay.BarcodeCaptureOverlay;
import com.scandit.datacapture.core.capture.DataCaptureContext;
import com.scandit.datacapture.core.data.FrameData;
import com.scandit.datacapture.core.source.Camera;
import com.scandit.datacapture.core.source.FrameSourceState;
import com.scandit.datacapture.core.ui.DataCaptureView;
import com.scandit.datacapture.core.ui.viewfinder.RectangularViewfinder;

import java.util.Arrays;
import java.util.HashSet;

public class NewActivity extends CameraPermissionActivity implements BarcodeCaptureListener {

    public static final String SCANDIT_LICENSE_KEY = "AcwuTyW6OyCfAw/oXRAg/7w/zNFaMBqI/XXo8hZcKMWydVYgu0dYgktRqT72eZOoPX6vMTg7KxyjQRt78nZJXmJ7wf/sc2tvcmgdi+xugYNeL1NbHlbu5jhlSTEyR1jTb2M0f6BY26tVL4G1hzvXOdoxCg/iDwcrNt9dwzfiBs7HAR5mLKgxmsap6WBqG3OS/vob53Z5dr1dYtmCV4aKmuvU19tYB/9Hr4hFJi8lMji/0f/WJKaFlWcoqsFlQqD8gRONQNWcSiM4wUZiIQrz8Kz+dH1wGh43pHrqGJjklZfoEANoqEoNe+Oyyq9TVKDaRQAjFlZ4bLIBFIExqPn+xQAP3EDNeuYJdTcaOpllxA8QLHKb04tSZg2st0XEQ/WkbD551a8DwfeM4nJt5hHKcpTbREC9ZE4jCBZFndKMfOmQf/l7qhzU9nQSvHQcuYMGNBEVG5UMpCCyotp2m6lG9nSGP/yH5sz8DwMDlHSfbkdarrQKR01f1P4hbVnqIjN5QQ/v4Pvbz/Jj/0ae/aDIMng3aljRzxWWhLEoXEKiGU40LTR3mLR9EezkYYpC+/oOAbBwhjZudNwaUerRsM8h2ys03l0TvPZPvqDbC2njAIHSZxHF5AIKRzfPgzyrC1A0XA4aZ8bAFRQ68QEbEfF16qL6A76mpaZsGVN28cPOt1zEey9KzmiY8ZmJ9YQ+76YipnCVFz4zQcMohgwXhwGaUZQGQTo5ESUpwzodkAhkBG7gakf8D1XEr2SVNmDUERh9TSYrG7Z8TIWIWUToy8P8G6jM+50t+dKS+wnbcmzIwfFpuWI1XrQOd1oyQlV94LdChZjRN8iL";
    private static final String DURATION_LONG = "long";
    private DataCaptureContext dataCaptureContext;
    private BarcodeCapture barcodeCapture;
    private Camera camera;
    private DataCaptureView dataCaptureView;

    private AlertDialog dialog;

    FrameLayout frameLayout;
    Button button ;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        frameLayout = new FrameLayout(this);
        frameLayout.setLayoutParams(new ViewGroup.LayoutParams(500,500));
        frameLayout.setBackgroundColor(Color.GREEN);

        initializeAndStartBarcodeScanning();


    }

    private void initializeAndStartBarcodeScanning() {
        // Create data capture context using your license key.
        dataCaptureContext = DataCaptureContext.forLicenseKey(SCANDIT_LICENSE_KEY);

        // Use the default camera and set it as the frame source of the context.
        // The camera is off by default and must be turned on to start streaming frames to the data
        // capture context for recognition.
        // See resumeFrameSource and pauseFrameSource below.
        camera = Camera.getDefaultCamera();
        if (camera != null) {
            // Use the recommended camera settings for the BarcodeCapture mode.
            camera.applySettings(BarcodeCapture.createRecommendedCameraSettings());
            dataCaptureContext.setFrameSource(camera);
        } else {
            throw new IllegalStateException("Sample depends on a camera, which failed to initialize.");
        }

        // The barcode capturing process is configured through barcode capture settings
        // which are then applied to the barcode capture instance that manages barcode recognition.
        BarcodeCaptureSettings barcodeCaptureSettings = new BarcodeCaptureSettings();

        // The settings instance initially has all types of barcodes (symbologies) disabled.
        // For the purpose of this sample we enable a very generous set of symbologies.
        // In your own app ensure that you only enable the symbologies that your app requires as
        // every additional enabled symbology has an impact on processing times.
        HashSet<Symbology> symbologies = new HashSet<>();
        symbologies.add(Symbology.EAN13_UPCA);
        symbologies.add(Symbology.EAN8);
        symbologies.add(Symbology.UPCE);
        symbologies.add(Symbology.QR);
        symbologies.add(Symbology.DATA_MATRIX);
        symbologies.add(Symbology.CODE39);
        symbologies.add(Symbology.CODE128);
        symbologies.add(Symbology.INTERLEAVED_TWO_OF_FIVE);

        barcodeCaptureSettings.enableSymbologies(symbologies);

        // Some linear/1d barcode symbologies allow you to encode variable-length data.
        // By default, the Scandit Data Capture SDK only scans barcodes in a certain length range.
        // If your application requires scanning of one of these symbologies, and the length is
        // falling outside the default range, you may need to adjust the "active symbol counts"
        // for this symbology. This is shown in the following few lines of code for one of the
        // variable-length symbologies.
        SymbologySettings symbologySettings =
                barcodeCaptureSettings.getSymbologySettings(Symbology.CODE39);

        HashSet<Short> activeSymbolCounts = new HashSet<>(
                Arrays.asList(new Short[] { 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 }));

        symbologySettings.setActiveSymbolCounts(activeSymbolCounts);

        // Create new barcode capture mode with the settings from above.
        barcodeCapture = BarcodeCapture.forDataCaptureContext(dataCaptureContext, barcodeCaptureSettings);

        // Register self as a listener to get informed whenever a new barcode got recognized.
        barcodeCapture.addListener(this);

        // To visualize the on-going barcode capturing process on screen, setup a data capture view
        // that renders the camera preview. The view must be connected to the data capture context.
        dataCaptureView = DataCaptureView.newInstance(this, dataCaptureContext);

        // Add a barcode capture overlay to the data capture view to render the location of captured
        // barcodes on top of the video preview.
        // This is optional, but recommended for better visual feedback.
        BarcodeCaptureOverlay overlay = BarcodeCaptureOverlay.newInstance(barcodeCapture, dataCaptureView);
        overlay.setViewfinder(new RectangularViewfinder());




        button = new Button(this);
        button.setPadding(100,0,0,20);
        button.setGravity(Gravity.BOTTOM);

       // button.setLayoutParams(new ViewGroup.LayoutParams(500,300));
        button.setBackgroundColor(Color.TRANSPARENT);
        button.setTextColor(Color.RED);
        frameLayout.addView(dataCaptureView);
        frameLayout.addView(button);

        setContentView(frameLayout);


    }


    @Override
    protected void onPause() {
        pauseFrameSource();
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        barcodeCapture.removeListener(this);
        dataCaptureContext.removeMode(barcodeCapture);
        super.onDestroy();
    }

    private void pauseFrameSource() {
        // Switch camera off to stop streaming frames.
        // The camera is stopped asynchronously and will take some time to completely turn off.
        // Until it is completely stopped, it is still possible to receive further results, hence
        // it's a good idea to first disable barcode capture as well.
        barcodeCapture.setEnabled(false);
        camera.switchToDesiredState(FrameSourceState.OFF, null);
    }

    @Override
    protected void onResume() {
        super.onResume();

        // Check for camera permission and request it, if it hasn't yet been granted.
        // Once we have the permission the onCameraPermissionGranted() method will be called.
        requestCameraPermission();
    }

    @Override
    public void onCameraPermissionGranted() {
        resumeFrameSource();
    }

    private void resumeFrameSource() {
        dismissScannedCodesDialog();

        // Switch camera on to start streaming frames.
        // The camera is started asynchronously and will take some time to completely turn on.


        barcodeCapture.setEnabled(true);
        camera.switchToDesiredState(FrameSourceState.ON, null);
    }

    private void dismissScannedCodesDialog() {
        if (dialog != null) {
            dialog.dismiss();
            dialog = null;
        }
    }

    private void showResult(String result) {

        if(button!=null)
        {

            button.setText(result);

        }

        barcodeCapture.setEnabled(true);
    }

    @Override
    public void onBarcodeScanned(
            @NonNull BarcodeCapture barcodeCapture,
            @NonNull BarcodeCaptureSession session,
            @NonNull FrameData frameData
    ) {
        if (session.getNewlyRecognizedBarcodes().isEmpty()) return;

        Barcode barcode = session.getNewlyRecognizedBarcodes().get(0);

        // Stop recognizing barcodes for as long as we are displaying the result. There won't be any
        // new results until the capture mode is enabled again. Note that disabling the capture mode
        // does not stop the camera, the camera continues to stream frames until it is turned off.
        barcodeCapture.setEnabled(false);

        // If you are not disabling barcode capture here and want to continue scanning, consider
        // setting the codeDuplicateFilter when creating the barcode capture settings to around 500
        // or even -1 if you do not want codes to be scanned more than once.

        // Get the human readable name of the symbology and assemble the result to be shown.
        String symbology = SymbologyDescription.create(barcode.getSymbology()).getReadableName();
        final String result = "Scanned: " + barcode.getData() + " (" + symbology + ")";

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                showResult(result);
            }
        });
    }

    @Override
    public void onSessionUpdated(@NonNull BarcodeCapture barcodeCapture,
                                 @NonNull BarcodeCaptureSession session, @NonNull FrameData data) {

    }

    @Override
    public void onObservationStarted(@NonNull BarcodeCapture barcodeCapture) {

    }

    @Override
    public void onObservationStopped(@NonNull BarcodeCapture barcodeCapture) {

    }
}
