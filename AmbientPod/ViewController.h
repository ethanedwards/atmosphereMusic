//
//  ViewController.h
//  AmbientPod
//
//  Created by ethan on 12/12/15.
//  Copyright (c) 2015 Ethan Edwards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTcmixPlayer.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController

@property (nonatomic, strong)	RTcmixPlayer	*rtcmixManager;

@property (nonatomic,strong) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UILabel *CurWeather;

@property (weak, nonatomic) IBOutlet UILabel *TempLabel;

@property (weak, nonatomic) IBOutlet UILabel *WindLabel;

@property (weak, nonatomic) IBOutlet UILabel *HumLabel;

@property (weak, nonatomic) IBOutlet UIButton *StartBut;

@property (weak, nonatomic) IBOutlet UIButton *UpdateButton;

@property (weak, nonatomic) IBOutlet UITextField *cityName;

- (IBAction)StartButton:(id)sender;

- (IBAction)OffButton:(id)sender;

@end

