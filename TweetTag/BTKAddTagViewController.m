//
//  BTKAddTagViewController.m
//  TweetTag
//
//  Created by Brandon Krieger on 11/25/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import "BTKAddTagViewController.h"

@implementation BTKAddTagViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    self.navBarItem.rightBarButtonItem = rightButton;
    self.navBarItem.leftBarButtonItem = leftButton;
    
}

- (BOOL) isValidHashtag:(NSString*) tag {
    
    if(tag.length == 0) {
        return NO;
    }
    
    NSCharacterSet *unwantedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    return ([tag rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound);
}

- (void) save {
    
    if([self isValidHashtag:(NSString *) self.tagField.text]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSDictionary *unmutableTags = [defaults dictionaryForKey:@"tags"];
        NSMutableDictionary *tags;
        if (unmutableTags) {
            tags = [NSMutableDictionary dictionaryWithDictionary:unmutableTags];
        } else {
            tags = [NSMutableDictionary new];
        }
        
        [tags setValue:[NSNumber numberWithBool:YES] forKey:self.tagField.text];
        [defaults setObject:tags forKey:@"tags"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self back];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Hashtag." message:@"Hashtags can only contain alphanumeric characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

}

- (void) back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
