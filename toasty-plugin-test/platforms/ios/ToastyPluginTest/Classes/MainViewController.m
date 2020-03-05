/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  MainViewController.h
//  Workshop
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

@import ScanditBarcodeCapture;
#import "MainViewController.h"

static NSString *const _Nonnull licenseKey = @"AcwuTyW6OyCfAw/oXRAg/7w/zNFaMBqI/XXo8hZcKMWydVYgu0dYgktRqT72eZOoPX6vMTg7KxyjQRt78nZJXmJ7wf/sc2tvcmgdi+xugYNeL1NbHlbu5jhlSTEyR1jTb2M0f6BY26tVL4G1hzvXOdoxCg/iDwcrNt9dwzfiBs7HAR5mLKgxmsap6WBqG3OS/vob53Z5dr1dYtmCV4aKmuvU19tYB/9Hr4hFJi8lMji/0f/WJKaFlWcoqsFlQqD8gRONQNWcSiM4wUZiIQrz8Kz+dH1wGh43pHrqGJjklZfoEANoqEoNe+Oyyq9TVKDaRQAjFlZ4bLIBFIExqPn+xQAP3EDNeuYJdTcaOpllxA8QLHKb04tSZg2st0XEQ/WkbD551a8DwfeM4nJt5hHKcpTbREC9ZE4jCBZFndKMfOmQf/l7qhzU9nQSvHQcuYMGNBEVG5UMpCCyotp2m6lG9nSGP/yH5sz8DwMDlHSfbkdarrQKR01f1P4hbVnqIjN5QQ/v4Pvbz/Jj/0ae/aDIMng3aljRzxWWhLEoXEKiGU40LTR3mLR9EezkYYpC+/oOAbBwhjZudNwaUerRsM8h2ys03l0TvPZPvqDbC2njAIHSZxHF5AIKRzfPgzyrC1A0XA4aZ8bAFRQ68QEbEfF16qL6A76mpaZsGVN28cPOt1zEey9KzmiY8ZmJ9YQ+76YipnCVFz4zQcMohgwXhwGaUZQGQTo5ESUpwzodkAhkBG7gakf8D1XEr2SVNmDUERh9TSYrG7Z8TIWIWUToy8P8G6jM+50t+dKS+wnbcmzIwfFpuWI1XrQOd1oyQlV94LdChZjRN8iL";


@implementation SDCDataCaptureContext (Licensed)

// Get a licensed DataCaptureContext.
+ (SDCDataCaptureContext *)licensedDataCaptureContext {
    return [self contextForLicenseKey:licenseKey];
}

@end

@interface MainViewController () <SDCBarcodeCaptureListener>

@property (strong, nonatomic) SDCDataCaptureContext *context;
@property (strong, nonatomic, nullable) SDCCamera *camera;
@property (strong, nonatomic) SDCBarcodeCapture *barcodeCapture;
@property (strong, nonatomic) SDCDataCaptureView *captureView;
@property (strong, nonatomic) SDCBarcodeCaptureOverlay *overlay;

@end



@implementation MainViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
         _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
         //Uncomment to override the CDVCommandQueue used
         _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
      
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.

    [super viewWillAppear:animated];
    self.barcodeCapture.enabled = YES;
      [self.camera switchToDesiredState:SDCFrameSourceStateOn];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   [self setupRecognition];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.barcodeCapture.enabled = NO;
       [self.camera switchToDesiredState:SDCFrameSourceStateOff];
}


- (void)setupRecognition {
    // Create data capture context using your license key.
    self.context = [SDCDataCaptureContext licensedDataCaptureContext];

    // Use the world-facing (back) camera and set it as the frame source of the context. The camera
    // is off by default and must be turned on to start streaming frames to the data capture context
    // for recognition. See viewWillAppear and viewDidDisappear above.
    self.camera = SDCCamera.defaultCamera;

    // Use the recommended camera settings for the BarcodeCapture mode.
    SDCCameraSettings *recommendedCameraSettings = [SDCBarcodeCapture recommendedCameraSettings];
    [self.camera applySettings:recommendedCameraSettings completionHandler:nil];

    [self.context setFrameSource:self.camera completionHandler:nil];

    // The barcode capturing process is configured through barcode capture settings that first need
    // to be configured and are then applied to the barcode capture instance that manages barcode
    // recognition.
    SDCBarcodeCaptureSettings *settings = [SDCBarcodeCaptureSettings settings];

    // The settings instance initially has all types of barcodes (symbologies) disabled. For the
    // purpose of this sample we enable a very generous set of symbologies. In your own app ensure
    // that you only enable the symbologies that your app requires as every additional symbology
    // enabled has an impact on processing times.
    [settings setSymbology:SDCSymbologyEAN13UPCA enabled:YES];
    [settings setSymbology:SDCSymbologyEAN8 enabled:YES];
    [settings setSymbology:SDCSymbologyUPCE enabled:YES];
    [settings setSymbology:SDCSymbologyQR enabled:YES];
    [settings setSymbology:SDCSymbologyDataMatrix enabled:YES];
    [settings setSymbology:SDCSymbologyCode39 enabled:YES];
    [settings setSymbology:SDCSymbologyCode128 enabled:YES];
    [settings setSymbology:SDCSymbologyInterleavedTwoOfFive enabled:YES];

    // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the
    // Scandit Data Capture SDK only scans barcodes in a certain length range. If your application
    // requires scanning of one of these symbologies, and the length is falling outside the default
    // range, you may need to adjust the "active symbol counts" for this symbology. This is shown in
    // the following few lines of code for one of the variable-length symbologies.
    SDCSymbologySettings *symbologySettings = [settings settingsForSymbology:SDCSymbologyCode39];
    symbologySettings.activeSymbolCounts = [NSSet
        setWithObjects:@7, @8, @9, @10, @11, @12, @13, @14, @15, @16, @17, @18, @19, @20, nil];

    // Create new barcode capture mode with the settings from above.
    self.barcodeCapture = [SDCBarcodeCapture barcodeCaptureWithContext:self.context
                                                              settings:settings];

    // Register self as a listener to get informed whenever a new barcode got recognized.
    [self.barcodeCapture addListener:self];

    // To visualize the on-going barcode capturing process on screen, setup a data capture view that
    // renders the camera preview. The view must be connected to the data capture context.
    self.captureView = [[SDCDataCaptureView alloc] initWithFrame:self.view.bounds];
    self.captureView.context = self.context;
    self.captureView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                        UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.captureView];

    // Add a barcode capture overlay to the data capture view to render the location of captured
    // barcodes on top of the video preview. This is optional, but recommended for better visual
    // feedback.
    self.overlay = [SDCBarcodeCaptureOverlay overlayWithBarcodeCapture:self.barcodeCapture];
    self.overlay.viewfinder = [SDCRectangularViewfinder viewfinder];
    [self.captureView addOverlay:self.overlay];
}

- (void)showResult:(nonnull NSString *)result completion:(nonnull void (^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController
            alertControllerWithTitle:result
                             message:nil
                      preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *_Nonnull action) {
                                                    completion();
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}


- (void)barcodeCapture:(SDCBarcodeCapture *)barcodeCapture
      didScanInSession:(SDCBarcodeCaptureSession *)session
             frameData:(id<SDCFrameData>)frameData {
    SDCBarcode *barcode = [session.newlyRecognizedBarcodes firstObject];
    if (barcode == nil || barcode.data == nil) {
        return;
    }

    // Stop recognizing barcodes for as long as we are displaying the result. There won't be any new
    // results until the capture mode is enabled again. Note that disabling the capture mode does
    // not stop the camera, the camera continues to stream frames until it is turned off.
    self.barcodeCapture.enabled = NO;

    // If you are not disabling barcode capture here and want to continue scanning, consider
    // setting the codeDuplicateFilter when creating the barcode capture settings to around 500
    // or even -1 if you do not want codes to be scanned more than once.

    // Get the human readable name of the symbology and assemble the result to be shown.
    NSString *symbology =
        [[SDCSymbologyDescription alloc] initWithSymbology:barcode.symbology].readableName;
    NSString *result = [NSString stringWithFormat:@"Scanned %@ (%@)", barcode.data, symbology];

    __weak MainViewController *weakSelf = self;
    [self showResult:result
          completion:^{
              // Enable recognizing barcodes when the result is not shown anymore.
              weakSelf.barcodeCapture.enabled = YES;
          }];
}





@end

@implementation MainCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
   in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}

@end

@implementation MainCommandQueue

/* To override, uncomment the line in the init function(s)
   in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end
