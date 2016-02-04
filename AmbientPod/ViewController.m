//
//  ViewController.m
//  WeatherMusic
//
//  Created by ethan on 11/15/15.
//  Copyright (c) 2015 Ethan Edwards. All rights reserved.
//

//Currently this app does not work in the Gulf of Guinea


//Scheduling too many events appears to lead to crashes even after flush

//Relevant variables are

//Type of weather

//Sunrise
//Sunset to determine time of day, length of day

//Temp

//Humidity

//Wind spped

//Clouds

//Date (Season)

//1am 6am 9am 12pm 4pm 7pm 10pm


#import "ViewController.h"
#import "OWMWeatherAPI.h"

@interface ViewController ()

@end

@implementation ViewController

OWMWeatherAPI *weatherAPI;
NSString *currentCity;
bool stop;
bool receiving;
bool active;
NSTimer *currentTimer;
int repeater;
CLLocation *loc;
int curTime;
int loop;
int maxLoop = 6;
bool authorized;

static int midnightLow = 60;
static int midnightHigh = 25*60;
static int dawn = 6*60;
static int morning = 9*60;
static int noon = 12*60;
static int afternoon = 16*60;
static int evening = 19*60;
static int night = 22*60;
int timeStamps[8];
float droneInts[7];
float droneGaps[7];

CLLocationCoordinate2D curCoord;

- (void)viewDidLoad {
        [super viewDidLoad];
    [self.UpdateButton removeFromSuperview];
    [self.cityName removeFromSuperview];

    
    active = false;
    receiving = true;
    NSLog(@"hey");
    repeater = 0;
    loop = 0;

    // Do any additional setup after loading the view, typically from a nib.
    // Setup weather api
    self.rtcmixManager = [RTcmixPlayer sharedManager];
    //[self.rtcmixManager startAudio];
    currentCity = @"Tokyo";
    
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    //[NSDateFormatter localizedStringFromDate:today dateStyle: NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
    NSLog(@"User's current time in their preference format:%@",currentTime);
    
    [self setVals];
    
    
    //NSString *scorePath = [[NSBundle mainBundle] pathForResource:@"loop" ofType:@"sco"];
    //[self.rtcmixManager parseScoreWithFilePath:scorePath];
    
    weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"4014964bf2aa8437aa122358be7a8bcb"];
    [weatherAPI setTemperatureFormat:kOWMTempCelcius];
    
    
    if ([CLLocationManager locationServicesEnabled]&&[CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
            NSLog(@"Location services enabled");
        authorized = true;
    } else {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

        NSLog(@"Location services are not enabled");
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
        
        authorized = false;
            curCoord = CLLocationCoordinate2DMake(35, 139);
    }
    


    //[self play:@"Tokyo" withAPI: weatherAPI];
    //[self getAndPrint:@"Tokyo" withAPI: weatherAPI];
    //[self getAndPrint:@"Boston" withAPI: weatherAPI];
    //[self getAndPrint:@"Kyoto" withAPI: weatherAPI];
    //[self getAndPrint:@"London" withAPI: weatherAPI];
    //[self getAndPrint:@"Miami" withAPI: weatherAPI];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

- (IBAction)updateCity:(id)sender {
    //[self.rtcmixManager flushAllScores];
    //[self.rtcmixManager pauseRTcmix];
    //NSLog(self.cityName.text);
    [self.rtcmixManager destroyRTcmix];
    [self.rtcmixManager startAudio];
    //currentCity = self.cityName.text;
    //[currentTimer invalidate];
    //[self mainLoop];
    //[self.rtcmixManager pauseRTcmix];
    //[self.rtcmixManager resumeRTcmix];
    [self play:currentCity withAPI: weatherAPI];

}
- (IBAction)StartAudio:(id)sender {
    if(!active){
        [self.rtcmixManager startAudio];
        loop = 0;
        [self mainLoop];
        [self.StartBut setTitle:@"Stop" forState:UIControlStateNormal];
        active = true;
    } else{
        [currentTimer invalidate];
        currentTimer = nil;
        [self.rtcmixManager destroyRTcmix];
        [self.StartBut setTitle:@"Start" forState:UIControlStateNormal];
        active = false;
    }

}

-(void) setVals{
    
    timeStamps[0] = midnightLow;
    timeStamps[1] = dawn;
    timeStamps[2] = morning;
    timeStamps[3] = noon;
    timeStamps[4] = afternoon;
    timeStamps[5] = evening;
    timeStamps[6] = night;
    timeStamps[7] = midnightHigh;
    
    droneInts[0] = 18;
    droneGaps[0] = 25;
    droneInts[1] = 12;
    droneGaps[1] = 17;
    droneInts[2] = 10;
    droneGaps[2] = 15;
    droneInts[3] = 8;
    droneGaps[3] = 13;
    droneInts[4] = 7;
    droneGaps[4] = 10;
    droneInts[5] = 8;
    droneGaps[5] = 12;
    droneInts[6] = 10;
    droneGaps[6] = 15;
    
}

- (void) play: (NSString*) city withAPI:(OWMWeatherAPI*) weatherAPI{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if(!authorized){
    if(status == kCLAuthorizationStatusAuthorizedAlways){
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
        authorized = true;
    }
    }
    
    
    
    //[self.locationManager requestLocation];
    CLLocation *hey = [self.locationManager location];
    CLLocationCoordinate2D coord = [hey coordinate];
    if(receiving){
        curCoord = coord;
    }
    NSLog(@"%f", curCoord.latitude);
    
    
    float multiplier;
    int index;
    
    //Date stuff
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    NSLog(@"User's current time in their preference format:%@",currentTime);
    int hours = [[currentTime substringToIndex:2] integerValue];
    int minutes = [[currentTime substringWithRange: NSMakeRange(3, 2)] integerValue];
    NSLog(@"%d\n", hours);
    NSLog(@"%d\n", minutes);
    curTime = hours*60+minutes;
    for(int i = 0; i < (sizeof(timeStamps)/sizeof(int)); i++){
        if(curTime<timeStamps[i]){
            float numer = (timeStamps[i]-curTime);
            float denom = (timeStamps[i]-timeStamps[i-1]);
            multiplier = numer/denom;
            index = i;
            break;
        }
    }
    
    float dim;
    float dgm;
    
    NSLog(@"multiplier is %f", multiplier);
    dim = droneInts[index-1] + (droneInts[index]-droneInts[index-1])*multiplier;
    dgm = droneGaps[index-1] + (droneInts[index]-droneGaps[index-1])*multiplier;
    
    if(loop!=0){
        NSString *times = [NSString stringWithFormat: @"droneGap = %f\ndroneInt = %f\n", dgm, dim];
        [self.rtcmixManager parseScoreWithNSString:times];
        NSString *scorePath = [[NSBundle mainBundle] pathForResource:@"loop" ofType:@"sco"];
        [self.rtcmixManager parseScoreWithFilePath:scorePath];
        loop++;
        if(loop>=maxLoop){
            loop = 0;
        }
    } else{
    if(curCoord.latitude==0&&curCoord.longitude==0){
            curCoord = CLLocationCoordinate2DMake(35, 139);
    }
        loop++;
        NSLog(@"New Loop!");
    [weatherAPI currentWeatherByCoordinate: curCoord withCallback:^(NSError *error, NSDictionary *result) {
        if (error) {
            // handle the error
            NSLog(@"Error");
            return;
        }
        // The data is ready
        
        //Type of weather
        NSNumber *currentID = result[@"weather"][0][@"id"];
        self.CurWeather.text = result[@"weather"][0][@"main"];
        int i = [[[currentID stringValue] substringToIndex: 1] intValue];
        NSLog(@"ID is %d", i);
        
        float chNum;
        float cg;
        float ci;
        float cr;
        float cf;
        float cu;
        float cm;
        float cd;
        float dg;
        float di;
        float dd;
        float d1;
        float d2;
        float dvar;
        float dspace;
        float v;
        
        
        chNum = 4;
        dvar = 2;
        dspace = .2;
        v = 1;
        cd = 7.0;
        
        //normal
        if(i == 8){
            int k = [currentID intValue];
            if(k == 800){
                cg = 10;
                ci = 6;
                cr = 3;
                cf = 600;
                cu = 70;
                cm = 5;
                cd = 0;
                dg = 8;
                di = 6;
                dd = 3;
                d1 = 70;
                d2 = 100;
                v = 1;
                chNum = 4;
                dvar = 3;
                dspace = .05;
                
            }
            else if (k > 802){
                cg = 10;
                ci = 6;
                cr = 6;
                cf = 600;
                cu = 80;
                cm = 5;
                cd = 3;
                dg = 7;
                di = 6;
                dd = 4.5;
                d1 = 30;
                d2 = 40;
                v = 1;
                chNum = 6;
                dvar = 4;
                dspace = .1;
                
            } else{
                cg = 4;
                ci = 6;
                cr = 3;
                cf = 450;
                cu = 70;
                cm = 3;
                cd = 10;
                dg = 7;
                di = 5;
                dd = 8;
                d1 = 60;
                d2 = 80;
                v = 2;
                chNum = 6;
                dvar = 4;
                dspace = .15;
            }
        } else if(i == 5){
            cg = 1;
            ci = .7;
            cr = 10;
            cf = 600;
            cu = 50;
            cm = .6;
            dg = 9;
            di = 6;
            dd = 8;
            d1 = 10;
            d2 = 20;
            v = 3;
            chNum = 4;
            dvar = 2;
            dspace = .2;
            
        } else if(i == 2){
            cg = .6;
            ci = .4;
            cr = 10;
            cf = 600;
            cu = 50;
            cm = .3;
            cd = 4;
            dg = 10;
            di = 7;
            dd = 4;
            d1 = 10;
            d2 = 20;
            v = 4;
            chNum = 2;
            dvar = 2;
            dspace = .2;
        } else if(i == 3){
            cg = 2;
            ci = 1;
            cr = 10;
            cf = 600;
            cu = 50;
            cm = .5;
            cd = 5;
            dg = 9;
            di = 6;
            dd = 8;
            d1 = 10;
            d2 = 20;
            v = 2;
            chNum = 2;
            dvar = 5;
            dspace = .1;
            
        }
        else if(i == 6){
            cg = 8;
            ci = 6;
            cr = 5;
            cf = 300;
            cu = 40;
            cm = 4;
            dg = 7;
            di = 5;
            dd = 4;
            d1 = 50;
            d2 = 70;
            v = 1;
            chNum = 5;
            dvar = 4;
            dspace = .2;
            
        }
        //this currently includes both "extreme" and "other" due to not checking the second digit, must be changed
        else if(i == 9){
            cg = 10;
            ci = 6;
            cr = 20;
            cf = 500;
            cu = 70;
            cm = 5;
            dg = 7;
            di = 5;
            dd = 4;
            d1 = 10;
            d2 = 20;
            chNum = 7;
            dvar = 5;
            dspace = .2;
            
        } else{
            cg = 10;
            ci = 6;
            cr = 20;
            cf = 500;
            cu = 70;
            cm = 5;
            dg = 7;
            di = 5;
            dd = 4;
            d1 = 10;
            d2 = 20;
        }
        //chimeGap = 5
        //chimeInt = .5
        //chimeRange = 10
        //chimeFreq = 600
        //chimeUp = 50
        
        //droneGap = 7
        //droneInt = 5
        //droneDur = 4
        //drone1 = 10
        //drone2 = 20
        
        di = dim;
        dg = dgm;
        
        NSLog(@"int %f", dim);
        NSLog(@"gap %f", dgm);
        
        NSString *starts = [NSString stringWithFormat: @"chimes=%f\nchimeGap = %f\nchimeInt = %f\nchimeRange = %f\nchimeFreq = %f\nchimeUp = %f\nchimeMin = %f\nchimeDur = %f\ndroneGap = %f\ndroneInt = %f\ndroneDur = %f\ndrone1 = %f\ndrone2 = %f\ndroneSub=%f\ndroneSpace=%f\nvoices = %f", chNum, cg, ci, cr, cf, cu, cm, cd, dg, di, dd, d1, d2, dvar, dspace, v];
        
        
        NSNumber *currentTemp = result[@"main"][@"temp"];
        float k = [currentTemp floatValue];
        k = 250-k*8;
        NSString *variable = [NSString stringWithFormat: @"droneFreq = %f", k];
        NSLog(variable);
        self.TempLabel.text = [NSString stringWithFormat: @"%d%@", [currentTemp intValue], @"°C"];
        
        NSNumber *win = result[@"wind"][@"speed"];
        float w = [win floatValue]*25;
        NSString *wind = [NSString stringWithFormat: @"windamp = %f", w];
        NSLog(wind);
        self.WindLabel.text = [NSString stringWithFormat: @"%@%.1f%@", @"Wind: ", [win floatValue], @" km/h"];
        
        NSNumber *currentHum = result[@"main"][@"humidity"];
        float h = [currentHum floatValue]/10;
        NSString *range = [NSString stringWithFormat: @"droneRange = %f", h];
        self.HumLabel.text = [NSString stringWithFormat: @"%@%@%@", @"Hum: ", [currentHum stringValue], @"%"];
        
        
        [self.rtcmixManager parseScoreWithNSString:starts];
        [self.rtcmixManager parseScoreWithNSString:variable];
        [self.rtcmixManager parseScoreWithNSString:wind];
        [self.rtcmixManager parseScoreWithNSString:range];
        NSString *scorePath = [[NSBundle mainBundle] pathForResource:@"loop" ofType:@"sco"];
        [self.rtcmixManager parseScoreWithFilePath:scorePath];
    }];
    } //end else
    /*
    [weatherAPI currentWeatherByCityName:city withCallback:^(NSError *error, NSDictionary *result) {
        if (error) {
            // handle the error
            NSLog(@"Error");
            return;
        }
        // The data is ready
        
        //Type of weather
        NSNumber *currentID = result[@"weather"][0][@"id"];
        int i = [[[currentID stringValue] substringToIndex: 1] intValue];
        NSLog(@"ID is %d", i);
        
        float chNum;
        float cg;
        float ci;
        float cr;
        float cf;
        float cu;
        float cm;
        float cd;
        float dg;
        float di;
        float dd;
        float d1;
        float d2;
        float dvar;
        float dspace;
        float v;
        
        
        chNum = 4;
        dvar = 2;
        dspace = .5;
        v = 1;
        cd = 7.0;
        
        //normal
        if(i == 8){
            int k = [currentID intValue];
            if(k == 800){
                cg = 10;
                ci = 6;
                cr = 3;
                cf = 600;
                cu = 70;
                cm = 5;
                cd = 0;
                dg = 8;
                di = 6;
                dd = 3;
                d1 = 70;
                d2 = 100;
                v = 1;
                
            }
            else if (k > 802){
                cg = 10;
                ci = 6;
                cr = 6;
                cf = 600;
                cu = 80;
                cm = 5;
                cd = 3;
                dg = 7;
                di = 6;
                dd = 4.5;
                d1 = 30;
                d2 = 40;
                v = 1;
                
            } else{
                cg = 4;
                ci = 6;
                cr = 3;
                cf = 450;
                cu = 70;
                cm = 3;
                cd = 10;
                dg = 7;
                di = 5;
                dd = 8;
                d1 = 60;
                d2 = 80;
                v = 2;
                
            }
        } else if(i == 5){
            cg = 1;
            ci = .7;
            cr = 10;
            cf = 600;
            cu = 50;
            cm = .6;
            dg = 9;
            di = 6;
            dd = 8;
            d1 = 10;
            d2 = 20;
            v = 3;
            
        } else if(i == 2){
            cg = .6;
            ci = .4;
            cr = 10;
            cf = 600;
            cu = 50;
            cm = .3;
            cd = 4;
            dg = 10;
            di = 7;
            dd = 4;
            d1 = 10;
            d2 = 20;
            v = 4;
            
        } else if(i == 3){
            cg = 2;
            ci = 1;
            cr = 10;
            cf = 600;
            cu = 50;
            cm = .5;
            cd = 5;
            dg = 9;
            di = 6;
            dd = 8;
            d1 = 10;
            d2 = 20;
            v = 2;
            
        }
        else if(i == 6){
            cg = 8;
            ci = 6;
            cr = 5;
            cf = 300;
            cu = 40;
            cm = 4;
            dg = 7;
            di = 5;
            dd = 4;
            d1 = 50;
            d2 = 70;
            v = 1;
            
        }
        //this currently includes both "extreme" and "other" due to not checking the second digit, must be changed
        else if(i == 9){
            cg = 10;
            ci = 6;
            cr = 20;
            cf = 500;
            cu = 70;
            cm = 5;
            dg = 7;
            di = 5;
            dd = 4;
            d1 = 10;
            d2 = 20;
            
        } else{
            cg = 10;
            ci = 6;
            cr = 20;
            cf = 500;
            cu = 70;
            cm = 5;
            dg = 7;
            di = 5;
            dd = 4;
            d1 = 10;
            d2 = 20;
        }
        //chimeGap = 5
        //chimeInt = .5
        //chimeRange = 10
        //chimeFreq = 600
        //chimeUp = 50
        
        //droneGap = 7
        //droneInt = 5
        //droneDur = 4
        //drone1 = 10
        //drone2 = 20
        
        di = dim;
        dg = dgm;
        
        NSLog(@"int %f", dim);
        NSLog(@"gap %f", dgm);
        
        NSString *starts = [NSString stringWithFormat: @"chimes=%f\nchimeGap = %f\nchimeInt = %f\nchimeRange = %f\nchimeFreq = %f\nchimeUp = %f\nchimeMin = %f\nchimeDur = %f\ndroneGap = %f\ndroneInt = %f\ndroneDur = %f\ndrone1 = %f\ndrone2 = %f\ndroneSub=%f\ndroneSpace=%f\nvoices = %f", chNum, cg, ci, cr, cf, cu, cm, cd, dg, di, dd, d1, d2, dvar, dspace, v];
        
        
        NSNumber *currentTemp = result[@"main"][@"temp"];
        float k = [currentTemp floatValue];
        k = 250-k*8;
        NSString *variable = [NSString stringWithFormat: @"droneFreq = %f", k];
        NSLog(variable);
        
        NSNumber *win = result[@"wind"][@"speed"];
        float w = [win floatValue]*25;
        NSString *wind = [NSString stringWithFormat: @"windamp = %f", w];
        NSLog(wind);
        
        NSNumber *currentHum = result[@"main"][@"humidity"];
        float h = [currentHum floatValue]/10;
        NSString *range = [NSString stringWithFormat: @"droneRange = %f", h];
        
        
        [self.rtcmixManager parseScoreWithNSString:starts];
        [self.rtcmixManager parseScoreWithNSString:variable];
        [self.rtcmixManager parseScoreWithNSString:wind];
        [self.rtcmixManager parseScoreWithNSString:range];
        NSString *scorePath = [[NSBundle mainBundle] pathForResource:@"loop" ofType:@"sco"];
        [self.rtcmixManager parseScoreWithFilePath:scorePath];
    }];
     */
    
}

- (void) getAndPrint: (NSString*) city withAPI:(OWMWeatherAPI*) weatherAPI{
    [weatherAPI currentWeatherByCityName:city withCallback:^(NSError *error, NSDictionary *result) {
        if (error) {
            // handle the error
            NSLog(@"Error");
            return;
        }
        
        // The data is ready
        NSLog(@"ho");
        
        NSString *cityName = result[@"name"];
        NSLog(@"hhum");
        NSNumber *currentID = result[@"weather"][0][@"id"];
        NSNumber *currentTemp = result[@"main"][@"temp"];
        NSNumber *currentHum = result[@"main"][@"humidity"];
        NSDate *dat = result[@"sys"][@"sunrise"];
        NSDate *dat2 = result[@"sys"][@"sunset"];
        NSNumber *clo = result[@"clouds"][@"all"];
        
        NSNumber *win = result[@"wind"][@"speed"];
        
        int i = [currentID intValue];
        float k = [currentTemp floatValue];
        float c = [clo floatValue];
        float w = [win floatValue];
        float h = [currentHum floatValue];
        NSLog([dat2 description]);
        NSLog([dat description]);
        NSLog(@"ID is %d", i);
        NSLog(@"Temp is %f", k);
        NSLog(@"Clouds is %f", c);
        NSLog(@"Wind is %f", w);
        NSLog(@"Humidity is %f", h);
        
    }];
}

- (void)mainLoop{
    //[self play:currentCity withAPI: weatherAPI];
    currentTimer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(runOnCurrentLoc: ) userInfo: nil repeats:YES];
    [currentTimer fire];
}

- (void)runOnCurrentLoc: (NSTimer *) timer{
    //currentTimer = timer;
    [self play:currentCity withAPI: weatherAPI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    loc = [locations objectAtIndex:0];
    
    NSLog(@"ran");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    receiving = false;
    curCoord = CLLocationCoordinate2DMake(35, 139);
}



//Times of day
//1am 6am 9am 12pm 4pm 7pm 10pm

/*
 - (void)getCurrent:(NSString *)query
 {
 NSString *const BASE_URL_STRING = @"http://api.openweathermap.org/data/2.5/weather";
 
 NSString *weatherURLText = [NSString stringWithFormat:@&quot;%@?q=%@&quot;,
 BASE_URL_STRING, query];
 NSURL *weatherURL = [NSURL URLWithString:weatherURLText];
 NSURLRequest *weatherRequest = [NSURLRequest requestWithURL:weatherURL];
 
 AFJSONRequestOperation *operation =
 [AFJSONRequestOperation JSONRequestOperationWithRequest:weatherRequest
 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
 weatherServiceResponse = (NSDictionary *)JSON;
 [self parseWeatherServiceResponse];
 }
 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
 weatherServiceResponse = @{};
 }
 ];
 
 [operation start];
 }
 */
- (IBAction)StartButton:(id)sender {
}

- (IBAction)OffButton:(id)sender {
}
@end
