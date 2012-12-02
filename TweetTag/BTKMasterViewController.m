//
//  BTKMasterViewController.m
//  TweetTag
//
//  Created by Brandon Krieger on 11/25/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import "BTKMasterViewController.h"
#import "BTKWebViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>



@interface BTKMasterViewController () {
    NSMutableData *_data; //for holding tweets temporarily while getting them
    NSMutableArray *_objects;
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
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:.318 green:.428 blue:.478 alpha:1]];
    
    self.defaultNumTweets = 25;
    self.currentNumTweets = self.defaultNumTweets;
    
    //pull to refresh
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor colorWithRed:.839 green:.949 blue:1 alpha:1];;
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    //sorting
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort: Recent" style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonClicked)];
    self.sortType = 1;
    self.noMore = YES;
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)viewWillAppear:(BOOL)animated {
    self.noTweets = NO;
    self.loading = YES;
    [self getCurrentHashtags];
    [self.tableView reloadData];
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
        _objects = [NSMutableArray new];
        self.currentNumTweets = self.defaultNumTweets;
        [self getTweets:NO];
        //Go to top of table
        [self.tableView setContentOffset:CGPointZero animated:NO];
    }
}

//If useNextPage is false, getTweets will create a query
//Otherwise, it will use the nextPage property as the query
-(void)getTweets: (BOOL)useNextPage {
    //Connect to Twitter
    
    if(_tags.count == 0) {
        
        return;
    }
    
    NSString *url;
    
    if(!useNextPage) {
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
        url = [NSString stringWithFormat:@"http://search.twitter.com/search.json?q=%%23%@&rpp=%d&lang=en&result_type=%@",
                         query, self.currentNumTweets, result_type];

    } else {
        url = [NSString stringWithFormat:@"http://search.twitter.com/search.json%@", self.nextPage];
    }
    
    
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
    //If no tweets, display nothing
    //If there are tweets, display one extra cell for "Loading More..."
    if(_objects.count ==0) {
        return 1;
    } else if(!self.noMore) {
        return _objects.count + 1;
    } else {
        //if there are no more tweets to be loaded, only display what we have
        return _objects.count;
    }

}

//- (void)goToTwitterApp:(id)sender {
//    UIButton *button = (UIButton*)sender;
//    NSString *title = [button currentTitle];
//    
//
//    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://user?screen_name=%@",title]]];
//    } else {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.twitter.com/%@",title]]];
//    }
//
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_objects.count == 0 && indexPath.row==0 && _tags.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoTags" forIndexPath:indexPath];
        return cell;

    } else if (_objects.count == 0 && indexPath.row == 0 && self.noTweets) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoTweets" forIndexPath:indexPath];
        return cell;

    } else if(indexPath.row < _objects.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        NSDictionary *object = _objects[indexPath.row];
        
        UILabel *label;
        
        //User
        UIButton *button = (UIButton*)[cell viewWithTag:7];
        [button setTitle:[NSString stringWithFormat:@"%@%@",@"@",[object objectForKey:@"from_user"]] forState:UIControlStateNormal];
        //[button addTarget:self action:@selector(goToTwitterApp:) forControlEvents:UIControlEventTouchUpInside];
        
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
        
        int time = -1 * (int)[date timeIntervalSinceNow];
        if(time>172800) {
            label.text = [NSString stringWithFormat:@"about %d days ago",time/86400];
        } else if(time>86400) {
            label.text = @"about 1 day ago";
        } else if(time>7200) {
            label.text = [NSString stringWithFormat:@"about %d hours ago",time/3600];
        } else if(time>3600) {
            label.text = @"about 1 hour ago";
        } else if(time>120) {
            label.text = [NSString stringWithFormat:@"about %d minutes ago",time/60];
        } else if(time>60) {
            label.text = @"about 1 minute ago";
        } else {
            label.text = @"less than a minute ago";
        }
        
        //Text
        UITextView *tv = (UITextView*)[cell viewWithTag:5];
        NSString *text = [object objectForKey:@"text"];
        tv.text = text;

        //Image
        UIButton *uib = (UIButton*)[cell viewWithTag:9];
        
        UIImageView *image = (UIImageView*)[cell viewWithTag:4];
        [image.layer setMasksToBounds:YES];
        [image.layer setCornerRadius:10];
        NSString *url = [object objectForKey:@"profile_image_url"];
        url = [url stringByReplacingOccurrencesOfString:@"_normal." withString:@"_bigger."];
        [image setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        [uib setTitle:[object objectForKey:@"from_user"] forState:UIControlStateNormal];
        //[uib addTarget:self action:@selector(goToTwitterApp:) forControlEvents:UIControlEventTouchUpInside];
        [uib.layer setMasksToBounds:YES];
        [uib.layer setCornerRadius:10];
        
        if(indexPath.row%2 == 0) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:.839 green:.949 blue:1 alpha:.5];

        } else {
            cell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        }
                
        return cell;
    } else if(_objects.count == indexPath.row) {
        //We need to load more
        if(!self.loading) {
            self.loading = YES;
            [self loadMore];
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"More" forIndexPath:indexPath];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Blank" forIndexPath:indexPath];
        return cell;
    }



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
            self.sortType = 2;
            self.navigationItem.rightBarButtonItem.title = @"Sort: Mixed";
            break;
        case 1:
            self.sortType = 0;
            self.navigationItem.rightBarButtonItem.title = @"Sort: Popular";
            break;
        case 2:
            self.sortType = 1;
            self.navigationItem.rightBarButtonItem.title = @"Sort: Recent";
            break;
    }

    [self.tableView setContentOffset:CGPointZero animated:NO];

    [self refresh];
}

- (void) refresh {
    self.currentNumTweets = self.defaultNumTweets;
    _objects = [NSMutableArray new];
    self.loading = YES;
    [self getTweets:NO];
    [self.refreshControl endRefreshing];
}

- (void) loadMore {
    [self getTweets:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"web"]) {
        UIButton *button = (UIButton*)sender;
        NSString *title = [button currentTitle];
        BTKWebViewController *vc = [segue destinationViewController];
        vc.url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.twitter.com/%@",title]];
    }
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
    
    [_objects addObjectsFromArray:[results objectForKey:@"results"]];
    self.nextPage = [results objectForKey:@"next_page"];
    
    //if no more to load
    if(self.nextPage) {
        self.noMore = NO;
    } else {
        self.noMore = YES;
    }
    
    self.loading = NO;
    if(_objects.count==0) {
        self.noTweets = YES;
    } else {
        self.noTweets = NO;
    }
      
    [self.tableView reloadData];
}



@end
