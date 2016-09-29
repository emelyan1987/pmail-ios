//
//  PMBoxFileViewController.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMEvernoteNoteViewController.h"
#import "PMMailComposeVC.h"
#import "PMTextManager.h"
#import "PMFileManager.h"

@interface PMEvernoteNoteViewController () <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *lblNoteTitle;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnAction;
@property (nonatomic, strong) ENNote *note;
@property (nonatomic, strong) NSString *filepath;
@end

@implementation PMEvernoteNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lblNoteTitle.text = self.noteTitle;
    [self setNavigationBar:@""];
    
    if(_isSelecting) {
        [_btnAction setImage:[UIImage imageNamed:@"attachIcon"]];
    }
    
    _btnAction.enabled = NO;
    [self performSelector:@selector(loadNote) withObject:nil afterDelay:.1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerForAccountDeleted:) name:NOTIFICATION_EVERNOTE_ACCOUNT_DELETED object:nil];
}

- (void)handlerForAccountDeleted:(NSNotification*)notification
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void) setNavigationBar:(NSString*)title
{
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"MuseoSans-100" size:18.0f]];
    lblTitle.text = title;
    lblTitle.textColor = [UIColor whiteColor];
    
    float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    
    lblTitle.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:lblTitle];
    
    self.navigationItem.titleView = headerview;
}
- (IBAction)btnBackClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadNote
{
    
    [AlertManager showProgressBarWithTitle:nil view:self.webView];
    [[ENSession sharedSession] downloadNote:self.noteRef progress:^(CGFloat progress) {
        self.progressView.progress = progress;
    } completion:^(ENNote *note, NSError *downloadNoteError) {
        if (note) {
            self.note = note;
            EDAMNote *edamNote = note.EDAMNote;;
            NSString *content = edamNote.content;
            //ENNoteContent *content = note.content;
            
            [note generateWebArchiveData:^(NSData *data) {
                [AlertManager hideProgressBar];
                self.progressView.hidden = YES;
                
                
                if(data)
                {
                    [self.webView loadData:data
                              MIMEType:ENWebArchiveDataMIMEType
                      textEncodingName:nil
                               baseURL:nil];
                }
                
            }];
        } else {
            NSLog(@"Error downloading note contents %@", downloadNoteError);
        }
    }];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    /*_filepath = [self getFilePath:_note.title];
    
    NSData *fileData = [NSData dataWithContentsOfURL:self.webView.request.URL];
    [fileData writeToFile:_filepath atomically:YES];*/
    
    _btnAction.enabled = YES;
}
-(NSString*)getFilePath:(NSString*)filename
{
    NSString* notefile = [[PMFileManager DownloadDirectory:@"Evernote"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", filename]];
    
    NSInteger index = 0;
    while (true) {
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:notefile];
        
        if(fileExists)
        {
            index++;
            notefile = [[PMFileManager DownloadDirectory:@"Evernote"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@(%d).html", filename, (int)index]];
        } else {
            break;
        }
        
    }
    
    return notefile;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnActionClicked:(id)sender
{
    ENNote *note = self.note;
    ENNoteContent *content = note.content;
    NSLog(@"%@", content);
    if(self.isSelecting)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            NSMutableArray *filepaths = [NSMutableArray new];
            NSInteger index = 0;
            for(ENResource *resource in self.note.resources)
            {
                
                index++;
                
                NSString *filename = resource.filename?resource.filename:(index>1)?[NSString stringWithFormat:@"%@(%d).%@", note.title, (int)index, [PMFileManager ExtensionForMime:resource.mimeType]]:[NSString stringWithFormat:@"%@.%@", note.title, [PMFileManager ExtensionForMime:resource.mimeType]];
                NSString *filepath = [[PMFileManager DownloadDirectory:@"Evernote"] stringByAppendingPathComponent:filename];
                [resource.data writeToFile:filepath atomically:YES];
                [filepaths addObject:filepath];
            }
            
            ENNoteStoreClient *noteStore = [[ENSession sharedSession] noteStoreForNoteRef:_noteRef];
            
            [noteStore getNoteSearchTextWithGuid:_noteRef.guid noteOnly:YES tokenizeForIndexing:NO success:^(NSString *text) {
                
                NSDictionary *userInfo = @{@"filepaths":filepaths, @"body":text};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DoneSelectFile" object:nil userInfo:userInfo];
                
            } failure:^(NSError *error) {
                NSLog(@"NoteSearchTextWithGuid Error = %@", error);
            }];
            
        }];
        
        
    }
    else
    {
        PMMailComposeVC *mailComposeVC = [MAIL_STORYBOARD instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
        
        NSMutableArray *files = [[NSMutableArray alloc] init];
        NSMutableArray *filepaths = [NSMutableArray new];
        NSInteger index = 0;
        for(ENResource *resource in self.note.resources)
        {
            index ++;
            NSString *filename = resource.filename?resource.filename:(index>1)?[NSString stringWithFormat:@"%@(%d).%@", note.title, (int)index, [PMFileManager ExtensionForMime:resource.mimeType]]:[NSString stringWithFormat:@"%@.%@", note.title, [PMFileManager ExtensionForMime:resource.mimeType]];
            NSString *filepath = [[PMFileManager DownloadDirectory:@"Evernote"] stringByAppendingPathComponent:filename];
            [resource.data writeToFile:filepath atomically:YES];
            [filepaths addObject:filepath];
        }
        [files addObjectsFromArray:filepaths];
        mailComposeVC.files = files;
        PMDraftModel *lDraft = [PMDraftModel new];
        
        ENNoteStoreClient *noteStore = [[ENSession sharedSession] noteStoreForNoteRef:_noteRef];
        
        [noteStore getNoteSearchTextWithGuid:_noteRef.guid noteOnly:YES tokenizeForIndexing:NO success:^(NSString *text) {
            
            //NSString *plainText = self.note.content.enml;//[[PMTextManager shared] convertHTML:self.note.content.enml];
            lDraft.body = text;
            mailComposeVC.draft = lDraft;
            
            [self presentViewController:mailComposeVC animated:YES completion:nil];
        } failure:^(NSError *error) {
            NSLog(@"NoteSearchTextWithGuid Error = %@", error);
        }];
    }
}

@end
