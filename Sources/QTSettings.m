#import "QTSettingsModel.h"

@interface QTOptionsController : UITableViewController
@property(nonatomic, copy) NSString *group;
@property(nonatomic, strong) NSArray<NSDictionary *> *rows;
@property(nonatomic, copy) NSDictionary<NSString *,NSNumber *> *preview;
@property(nonatomic) NSUInteger noticeGeneration;
@end
@implementation QTOptionsController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.group ?: @"Quiet controls";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.navigationItem.backButtonDisplayMode = UINavigationItemBackButtonDisplayModeMinimal;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeControls)];
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    self.tableView.cellLayoutMarginsFollowReadableWidth = YES;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 74;
    if (self.preview) {
        NSMutableArray *rows=[NSMutableArray array];
        for (NSString *key in [[self.preview allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
            BOOL before=QTSavedSetting(key), after=[self.preview[key] boolValue];
            [rows addObject:@{@"title":QTSettingTitle(key),@"note":[NSString stringWithFormat:@"%@ → %@%@",before?@"On":@"Off",after?@"On":@"Off",before==after?@" (unchanged)":@""],@"readOnly":@YES}];
        }
        self.rows=rows;
        self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(applyPreset)];
    } else if (!self.group) self.rows=@[
        @{@"title":@"Enable QuietTube",@"key":@"enabled",@"note":@"Master switch. Your individual preferences are kept when this is off."},
        @{@"title":@"Presets",@"page":@"Presets",@"icon":@"slider.horizontal.3",@"note":@"Preview a setup before applying it."},
        @{@"title":@"Ads",@"page":@"Ads",@"icon":@"hand.raised"},
        @{@"title":@"Feed",@"page":@"Feed",@"icon":@"rectangle.grid.1x2"},
        @{@"title":@"Playback",@"page":@"Playback",@"icon":@"play.circle"},
        @{@"title":@"Appearance",@"page":@"Appearance",@"icon":@"paintbrush"},
        @{@"title":@"Advanced",@"page":@"Advanced",@"icon":@"gearshape"}];
    else if ([self.group isEqualToString:@"Presets"]) self.rows=@[
        @{@"title":@"Ads & essentials",@"preset":@"Ads & essentials",@"note":@"Enable ad protection and the classic logo; turn off detailed logging. Other preferences stay as they are."},
        @{@"title":@"Focused feed",@"preset":@"Focused feed",@"note":@"Ads & essentials plus all available feed cleanup. Playback preferences stay as they are."}];
    else {
        NSMutableArray *rows=[QTSettingsRows(self.group) mutableCopy];
        if ([self.group isEqualToString:@"Advanced"]) [rows addObjectsFromArray:@[
            @{@"title":@"Troubleshooting",@"page":@"Troubleshooting",@"note":@"Optional local diagnostics for reporting a problem."},
            @{@"title":@"About QuietTube",@"action":@"about"},
            @{@"title":@"Disable all options",@"action":@"reset",@"note":@"Clears QuietTube toggle selections, not your YouTube account or history."}]];
        if ([self.group isEqualToString:@"Troubleshooting"]) [rows addObjectsFromArray:@[
            @{@"title":@"Prepare a support test",@"action":@"prepareAdTest",@"note":@"Enable ad protection, extended matching and local diagnostic capture. Your other preferences stay unchanged."},
            @{@"title":@"View support report",@"action":@"adReport",@"note":@"Short player and feed report. Review before sharing."},
            @{@"title":@"View full diagnostics",@"action":@"diagnostics"},
            @{@"title":@"Clear template capture",@"action":@"clearCapture"}]];
        self.rows=rows;
    }
}
- (void)viewWillAppear:(BOOL)animated { [super viewWillAppear:animated]; [self.tableView reloadData]; }
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section { return self.rows.count; }
- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    return self.preview ? @"Review settings" : self.group ?: @"Make YouTube quieter";
}
- (NSString *)tableView:(UITableView *)tv titleForFooterInSection:(NSInteger)section {
    if (self.preview) return @"Only the settings listed above will be saved. No change is made until you tap Apply. All other preferences are preserved. Fully close and reopen the app afterward.";
    NSString *state=QTSettingsPendingRestart()?@"Restart required — fully close and reopen the app to apply saved changes.":@"Changes take effect after fully closing and reopening the app.";
    return [NSString stringWithFormat:@"%@\n%@\n1.0.0 · Unofficial, not affiliated with YouTube. Use YouTube’s own Picture in Picture setting.",state,QTSavedSetting(@"enabled")?@"":@"QuietTube is disabled for the next launch. Enable the master switch to use these options."];
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)index {
    NSDictionary *row=self.rows[index.row];
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text=row[@"title"]; cell.textLabel.numberOfLines=0;
    cell.textLabel.font=[UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.textLabel.adjustsFontForContentSizeCategory=YES;
    cell.detailTextLabel.font=[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    cell.detailTextLabel.adjustsFontForContentSizeCategory=YES;
    cell.detailTextLabel.numberOfLines=0; cell.detailTextLabel.text=row[@"note"];
    if (row[@"icon"]) cell.imageView.image=[UIImage systemImageNamed:row[@"icon"]];
    if (row[@"key"]) {
        NSString *key=row[@"key"];
        UISwitch *toggle=[UISwitch new]; toggle.accessibilityIdentifier=key;
        toggle.accessibilityLabel=row[@"title"]; toggle.accessibilityHint=row[@"note"];
        toggle.on=QTSavedSetting(key);
        // Keep controls usable: enabling an option saves its prerequisites too.
        NSDictionary *required=QTSettingChanges(key,YES);
        BOOL missing=NO;
        for (NSString *dependency in required) if (![dependency isEqualToString:key] && !QTSavedSetting(dependency)) missing=YES;
        if (missing) cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ %@",row[@"note"] ?: @"",toggle.on?@"Paused: a required option is off. Toggle off and on to restore it.":@"Required matching options will also be enabled."];
        [toggle addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView=toggle; cell.selectionStyle=UITableViewCellSelectionStyleNone;
    } else if (![row[@"readOnly"] boolValue]) cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    else cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)closeControls { [self.navigationController dismissViewControllerAnimated:YES completion:nil]; }
- (void)showNotice:(NSString *)message {
    self.navigationItem.prompt=message;
    NSUInteger generation=++self.noticeGeneration;
    __weak QTOptionsController *weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(3*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
        QTOptionsController *strongSelf=weakSelf;
        if (strongSelf && strongSelf.noticeGeneration==generation) strongSelf.navigationItem.prompt=nil;
    });
    // Footer persists if changes still differ from the launch snapshot.
}
- (void)changed:(UISwitch *)sender {
    QTSaveSettings(QTSettingChanges(sender.accessibilityIdentifier,sender.on));
    [self.tableView reloadData];
    [self showNotice:QTSettingsPendingRestart()?@"Saved · Restart to apply":@"Saved · No restart pending"];
}
- (void)applyPreset {
    QTSaveSettings(self.preview);
    UINavigationController *navigation=self.navigationController;
    [navigation popViewControllerAnimated:YES];
    QTOptionsController *parent=(QTOptionsController *)navigation.topViewController;
    if ([parent isKindOfClass:QTOptionsController.class]) { [parent.tableView reloadData]; [parent showNotice:QTSettingsPendingRestart()?@"Preset saved · Restart to apply":@"Preset saved · No restart pending"]; }
}
- (void)showText:(NSString *)content title:(NSString *)title {
    UIViewController *page=[UIViewController new]; page.title=title;
    UITextView *text=[UITextView new]; text.editable=NO; text.selectable=YES;
    text.font=[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote]; text.adjustsFontForContentSizeCategory=YES;
    text.backgroundColor=UIColor.systemBackgroundColor; text.textColor=UIColor.labelColor;
    text.textContainerInset=UIEdgeInsetsMake(16,16,24,16); text.text=content; page.view=text;
    [self.navigationController pushViewController:page animated:YES];
}
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)index {
    [tv deselectRowAtIndexPath:index animated:YES]; NSDictionary *row=self.rows[index.row];
    if (row[@"key"] || [row[@"readOnly"] boolValue]) return;
    if (row[@"page"] || row[@"preset"]) {
        QTOptionsController *page=[[QTOptionsController alloc] initWithStyle:UITableViewStyleInsetGrouped];
        page.group=row[@"page"] ?: row[@"preset"];
        if (row[@"preset"]) page.preview=QTPresetChanges(row[@"preset"]);
        [self.navigationController pushViewController:page animated:YES];
    } else if ([row[@"action"] isEqualToString:@"adReport"]) [self showText:QTAdReport() title:@"Support report"];
    else if ([row[@"action"] isEqualToString:@"diagnostics"]) [self showText:QTDiagnostics() title:@"Diagnostics"];
    else if ([row[@"action"] isEqualToString:@"about"]) [self showText:@"QuietTube 1.0.0\n\nAn unofficial customization for YouTube 21.38.2 on iOS. Not affiliated with or endorsed by YouTube or Google.\n\nAd protection was tested in limited sessions on one device. It is not guaranteed across all videos or future app updates. The runtime and settings were tested on iPhone 14, iOS 26.5 and LiveContainer 3.8.0. Other environments may behave differently.\n\nQuietTube adds no automatic diagnostic upload. Reports can contain internal class/template identifiers; review before sharing. YouTube and your installation tools have their own data practices.\n\nThe QuietTube source is MIT licensed; see LICENSE and Notices in the source distribution. That license does not grant rights to redistribute YouTube or its trademarks.\n\nTo pause modifications, turn off Enable QuietTube and fully close and reopen the app. Your preferences are retained. Restore your previous IPA if needed." title:@"About QuietTube"];
    else if ([row[@"action"] isEqualToString:@"prepareAdTest"]) {
        QTPrepareAdTest(); [self.tableView reloadData]; [self showNotice:@"Support test saved · Restart to apply"];
    } else if ([row[@"action"] isEqualToString:@"clearCapture"]) {
        QTResetElementCapture(); [self showNotice:@"Template capture cleared"];
    } else if ([row[@"action"] isEqualToString:@"reset"]) {
        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"Disable all options?" message:@"This clears QuietTube toggle selections for the next launch. Your YouTube account and history are not changed." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Disable all" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
            NSMutableDictionary *changes=[NSMutableDictionary dictionaryWithObject:@NO forKey:@"enabled"];
            for (NSDictionary *o in QTOptions()) changes[o[@"key"]]=@NO;
            QTSaveSettings(changes); [self.tableView reloadData]; [self showNotice:@"Options disabled · Restart to apply"];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
@end
UIViewController *QTSettingsController(void) { return [[QTOptionsController alloc] initWithStyle:UITableViewStyleInsetGrouped]; }

static const void *QTRowMarker = &QTRowMarker;
static NSArray *QTAppendEntry(id controller, NSArray *items, NSUInteger category) {
    // General is category 1 in the reviewed settings integration. No new top-level category.
    if (category != 1 || ![items isKindOfClass:NSArray.class]) return items;
    for (id item in items) if (objc_getAssociatedObject(item,QTRowMarker)) return items;
    Class cls = NSClassFromString(@"YTSettingsSectionItem");
    SEL factory = NSSelectorFromString(@"itemWithTitle:titleDescription:accessibilityIdentifier:detailTextBlock:selectBlock:");
    if (!QTMatches(cls,factory,@"@@@@@@")) { QTCount(@"settings factory unavailable"); return items; }
    __weak id weakController = controller;
    BOOL (^select)(id,NSUInteger) = ^BOOL(id cell, NSUInteger index) {
        id target = weakController;
        UIViewController *page = QTSettingsController();
        // Isolate our UIKit navigation from YouTube's private bar/layout rules.
        // The native General entry remains unchanged; Done returns to it.
        if ([target isKindOfClass:UIViewController.class]) {
            UIViewController *presenter = (UIViewController *)target;
            if (!presenter.viewIfLoaded.window || presenter.presentedViewController) return NO;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:page];
            nav.navigationBar.prefersLargeTitles = NO;
            UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
            [appearance configureWithDefaultBackground];
            nav.navigationBar.standardAppearance = appearance;
            nav.navigationBar.scrollEdgeAppearance = appearance;
            nav.navigationBar.compactAppearance = appearance;
            nav.modalPresentationStyle = UIModalPresentationPageSheet;
            UISheetPresentationController *sheet = nav.sheetPresentationController;
            sheet.detents = @[[UISheetPresentationControllerDetent largeDetent]];
            sheet.prefersGrabberVisible = YES;
            [presenter presentViewController:nav animated:YES completion:nil];
            return YES;
        }
        QTCount(@"settings navigation unavailable");
        return NO;
    };
    id row = ((id (*)(id,SEL,id,id,id,id,id))objc_msgSend)(cls,factory,
        @"Quiet controls", nil, @"quiettube.settings", nil, select);
    if (!row) return items;
    objc_setAssociatedObject(row,QTRowMarker,@YES,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    QTCount(@"settings entry appended");
    return [items arrayByAddingObject:row];
}
void QTInstallSettings(void) {
    QTHook(@"YTSettingsViewController",
        @"setSectionItems:forCategory:title:icon:titleDescription:headerHidden:", @"v@Q@@@B",
        ^id(IMP old, SEL sel) {
            return ^(id obj, NSArray *items, NSUInteger cat, id title, id icon, id desc, BOOL hidden) {
                ((void (*)(id,SEL,id,NSUInteger,id,id,id,BOOL))old)(obj,sel,QTAppendEntry(obj,items,cat),cat,title,icon,desc,hidden);
            };
        });
    QTHook(@"YTSettingsViewController",
        @"setSectionItems:forCategory:title:titleDescription:headerHidden:", @"v@Q@@B",
        ^id(IMP old, SEL sel) {
            return ^(id obj, NSArray *items, NSUInteger cat, id title, id desc, BOOL hidden) {
                ((void (*)(id,SEL,id,NSUInteger,id,id,BOOL))old)(obj,sel,QTAppendEntry(obj,items,cat),cat,title,desc,hidden);
            };
        });
}
