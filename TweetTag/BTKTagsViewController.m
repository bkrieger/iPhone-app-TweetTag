//
//  BTKTagsViewController.m
//  TweetTag
//
//  Created by Brandon Krieger on 11/25/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import "BTKTagsViewController.h"

@interface BTKTagsViewController () {
    NSMutableArray *_objects;
    NSMutableDictionary *_dictObjects;
}
@end

@implementation BTKTagsViewController

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _dictObjects = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"tags"]];
    _objects = [NSMutableArray arrayWithArray:[_dictObjects allKeys]];
    [_objects sortUsingSelector:@selector(compare:)];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTag)];
    
    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    self.saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    
    self.navBarItem.leftBarButtonItem = self.doneButton;
    self.navBarItem.rightBarButtonItem = self.addButton;
    self.isAdding = NO;
}

- (void) done {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    if(indexPath.row > 0 || !self.isAdding) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        NSDate *object = _objects[indexPath.row];
        NSMutableString *title = [NSMutableString stringWithString:@"#"];
        [title appendString:(NSString *)object];
        cell.textLabel.text = title;
        if([[_dictObjects valueForKey:(NSString*) object] boolValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"New" forIndexPath:indexPath];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    //return YES;
    return !self.isAdding;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!self.isAdding) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            NSDate *object = _objects[indexPath.row];
            [_dictObjects removeObjectForKey:object];
            [_objects removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:_dictObjects forKey:@"tags"];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if(!self.isAdding) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSDate *object = _objects[indexPath.row];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [_dictObjects setValue:[NSNumber numberWithBool:YES] forKey:(NSString *)object];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [_dictObjects setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)object];

        }
        
        [defaults setObject:_dictObjects forKey:@"tags"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.tableView reloadData];
   // } else {
   //     [tableView deselectRowAtIndexPath:indexPath animated:YES];
   // }
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)addTag {
    //can only add one thing at a time
    if(!self.isAdding) {
        self.isAdding = YES;
        self.navBarItem.leftBarButtonItem = self.cancelButton;
        self.navBarItem.rightBarButtonItem = self.saveButton;
        if (!_objects) {
            _objects = [[NSMutableArray alloc] init];
        }
        [_objects insertObject:[NSDate date] atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) cancel {
    [_objects removeObjectAtIndex:0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField *field = (UITextField *) [cell viewWithTag:1];
    field.text = @"";
    
        
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.isAdding = NO;
    
    self.navBarItem.leftBarButtonItem = self.doneButton;
    self.navBarItem.rightBarButtonItem = self.addButton;
}

- (BOOL) isValidHashtag:(NSString*) tag {
    
    if(tag.length == 0) {
        return NO;
    }
    
    NSCharacterSet *nonAlphanumeric = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    NSCharacterSet *nonLetters = [[NSCharacterSet letterCharacterSet] invertedSet];
    
    if([nonLetters characterIsMember:[tag characterAtIndex:0]]) {
        return false;
    }
    
    return ([tag rangeOfCharacterFromSet:nonAlphanumeric].location == NSNotFound);
}

- (void) save {

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField *field = (UITextField *) [cell viewWithTag:1];
    NSString *tag = field.text;
    
        
    if([self isValidHashtag:tag]) {
        field.text = @"";
        [_objects removeObjectAtIndex:0];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        NSDictionary *unmutableTags = [defaults dictionaryForKey:@"tags"];
        NSMutableDictionary *tags;
        if (unmutableTags) {
            tags = [NSMutableDictionary dictionaryWithDictionary:unmutableTags];
        } else {
            tags = [NSMutableDictionary new];
        }
        
        [tags setValue:[NSNumber numberWithBool:YES] forKey:tag];
        [defaults setObject:tags forKey:@"tags"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.isAdding = NO;
        self.navBarItem.leftBarButtonItem = self.doneButton;
        self.navBarItem.rightBarButtonItem = self.addButton;

        [self viewWillAppear:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Hashtag." message:@"Hashtags can only contain alphanumeric characters and must begin with a letter." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

}
@end

