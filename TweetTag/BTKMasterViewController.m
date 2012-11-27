//
//  BTKMasterViewController.m
//  TweetTag
//
//  Created by Brandon Krieger on 11/25/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import "BTKMasterViewController.h"


@interface BTKMasterViewController () {
    NSMutableData *_data; //for holding tweets temporarily while getting them
    NSArray *_objects;
    NSMutableSet *_tags;
}
@end

@implementation BTKMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.defaultNumTweets = 25;
    self.currentNumTweets = self.defaultNumTweets;
    
    //pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor redColor];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    //sorting
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort: Recent" style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonClicked)];
    self.sortType = 1;
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)viewWillAppear:(BOOL)animated {
    [self getCurrentHashtags];
}

-(void)getCurrentHashtags {
    NSMutableSet *newTags = [[NSMutableSet alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *allTags = [defaults dictionaryForKey:@"tags"];
    
    //go through all tags in NSUserDefaults
    for (NSString *tag in [allTags allKeys]) {
        //if the tag is checked off
        if ([[NSNumber numberWithBool:YES] isEqualToNumber:[allTags valueForKey:tag]]) {
            [newTags addObject:tag];
        }
    }
    
    //if tags have changed
    if(_tags == nil || ![newTags isEqualToSet:_tags]) {
        _tags = newTags;
        self.currentNumTweets = self.defaultNumTweets;
        [self getTweets:self.currentNumTweets];
        //Go to top of table
        [self.tableView setContentOffset:CGPointZero animated:NO];
    }
}

-(void)getTweets:(int)numTweets {
    //Connect to Twitter
    
    NSString *result_type;
    
    switch(self.sortType) {
        case 0:
            result_type = @"popular";
            break;
        case 1:
            result_type = @"recent";
            break;
        case 2:
            result_type = @"mixed";
            break;
        //default should never occur, but just in case
        default:
            result_type = @"popular";
            break;
    }
    
    
    //Query is all tags joined together by " OR #", so we have tags OR'd together and they all get the necessary #
    NSString *query = [[_tags allObjects] componentsJoinedByString:@"%20OR%20%23"];
    
    

    
    //URL format is search.twitter.com/search.json?q=%23"tag"&rpp="numTweetsPerTag"&lang=en&result_type="result_type"
    NSString *url = [NSString stringWithFormat:@"http://search.twitter.com/search.json?q=%%23%@&rpp=%d&lang=en&result_type=%@",
                     query, numTweets, result_type];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *object = _objects[indexPath.row];
    
    UILabel *label;
        
    //User
    label = (UILabel*)[cell viewWithTag:1];
    label.text = [object objectForKey:@"from_user"];
    
    //Date
    label = (UILabel*)[cell viewWithTag:2];
    NSString *timestamp = [object objectForKey:@"created_at"];
    //Fix time for time zone
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"EEE', 'dd' 'MMM' 'yyyy' 'HH':'mm':'ss' +0000'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    // Convert the RFC 3339 date time string to an NSDate.
    NSDate *date = [rfc3339DateFormatter dateFromString:timestamp];
    
    NSString *userVisibleDateTimeString;
    if (date != nil) {
        // Convert the date object to a user-visible date string.
        NSDateFormatter *userVisibleDateFormatter = [[NSDateFormatter alloc] init];
        assert(userVisibleDateFormatter != nil);
        
        [userVisibleDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        
        userVisibleDateTimeString = [userVisibleDateFormatter stringFromDate:date];
    }
        
    label.text = userVisibleDateTimeString;
        
    //Text
    label = (UILabel*)[cell viewWithTag:3];
    label.text = [object objectForKey:@"text"];

    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


//Changes the sorting value
//0=popular
//1=recent
//2=mixed
- (void) sortButtonClicked {
    switch (self.sortType) {
        case 0:
            self.sortType = 1;
            self.navigationItem.rightBarButtonItem.title = @"Sort: Recent";
            break;
        case 1:
            self.sortType = 2;
            self.navigationItem.rightBarButtonItem.title = @"Sort: Mixed";
            break;
        case 2:
            self.sortType = 0;
            self.navigationItem.rightBarButtonItem.title = @"Sort: Popular";
            break;
    }
    
    [self refresh];
}

- (void) refresh {
    self.currentNumTweets = self.defaultNumTweets;
    [self getTweets:self.currentNumTweets];
    [self.refreshControl endRefreshing];
}

#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with server. Please check your internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:_data options:0 error:nil];
    
    _objects = [results objectForKey:@"results"];
      
    [self.tableView reloadData];
}



@end
