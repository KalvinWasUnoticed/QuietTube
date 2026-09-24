#import "QTCore.h"

@interface QTOptionsController : UITableViewController
@property(nonatomic, copy) NSString *group;
@property(nonatomic, strong) NSArray<NSDictionary *> *rows;
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
    if (self.group) {
        self.rows = [QTOptions() filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *o, NSDictionary *bindings) {
            return [o[@"group"] isEqualToString:self.group];
        }]];
    } else self.rows = @[
        @{@"title":@"Enable modifications", @"key":@"enabled"},
        @{@"title":@"Distractions", @"page":@"Distractions"},
        @{@"title":@"Playback", @"page":@"Playback"},
        @{@"title":@"Advanced", @"page":@"Advanced"}
    ];
    if ([self.group isEqualToString:@"Advanced"]) self.rows = @[
        @{@"title":@"Inspect unmatched templates", @"key":@"inspectElements",
          @"note":@"Opt-in local capture of identifier-shaped names. Requires Extended feed formats and restart. Review before sharing."},
        @{@"title":@"Clear template capture", @"action":@"clearCapture"},
// BEGIN 0.13 AD PROFILE
        @{@"title":@"Ad test report", @"action":@"adReport"},
        @{@"title":@"Ad test options", @"page":@"Ad test options"},
// END 0.13 AD PROFILE
        @{@"title":@"View diagnostics", @"action":@"diagnostics"},
        @{@"title":@"Disable all for next launch", @"action":@"reset"}
    ];
}
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section { return self.rows.count; }
- (NSString *)tableView:(UITableView *)tv titleForFooterInSection:(NSInteger)section {
    return @"0.13 · Restart the guest app to apply changes. Use YouTube’s own PiP setting. Player-ad blocking remains paused.";
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)index {
    NSDictionary *row = self.rows[index.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text = row[@"title"];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.textLabel.adjustsFontForContentSizeCategory = YES;
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    cell.detailTextLabel.adjustsFontForContentSizeCategory = YES;
    cell.detailTextLabel.text = row[@"note"];
    cell.detailTextLabel.numberOfLines = 0;
    if (row[@"key"]) {
        UISwitch *toggle = [UISwitch new];
        toggle.accessibilityLabel = row[@"title"];
        toggle.accessibilityIdentifier = row[@"key"];
        BOOL needsExtended = [@[@"topicsShelves",@"edgeCards",@"playables",@"eventPromos",@"inspectElements",@"displayAds",@"mixes",@"watchAgain"] containsObject:row[@"key"]];
        BOOL dependencyReady = !needsExtended || [NSUserDefaults.standardUserDefaults boolForKey:@"QuietTube.v1.extendedFeed"];
        BOOL needsFeedAds = [row[@"key"] isEqualToString:@"displayAds"];
        if (needsFeedAds && ![NSUserDefaults.standardUserDefaults boolForKey:@"QuietTube.v1.feedAds"]) dependencyReady = NO;
        toggle.enabled = ![row[@"disabled"] boolValue] && dependencyReady;
        if (!dependencyReady) cell.detailTextLabel.text = needsFeedAds ? @"Enable Extended feed formats and Feed ads first. Restart to apply." : @"Enable Extended feed formats first. Restart to apply.";
        toggle.on = ![row[@"disabled"] boolValue] && [NSUserDefaults.standardUserDefaults boolForKey:[@"QuietTube.v1." stringByAppendingString:row[@"key"]]];
        [toggle addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = toggle;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)closeControls {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)changed:(UISwitch *)sender {
    QTSet(sender.accessibilityIdentifier, sender.on);
    [self.tableView reloadData];
    self.navigationItem.prompt = @"Saved — restart the guest app to apply";
}
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)index {
    [tv deselectRowAtIndexPath:index animated:YES];
    NSDictionary *row = self.rows[index.row];
    if (row[@"page"]) {
        QTOptionsController *page = [[QTOptionsController alloc] initWithStyle:UITableViewStyleInsetGrouped];
        page.group = row[@"page"];
        [self.navigationController pushViewController:page animated:YES];
    } else if (([row[@"action"] isEqualToString:@"diagnostics"] || [row[@"action"] isEqualToString:@"adReport"])) {
        UIViewController *page = [UIViewController new];
        page.title = @"Diagnostics";
        UITextView *text = [UITextView new];
        text.editable = NO;
        text.selectable = YES;
        text.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        text.adjustsFontForContentSizeCategory = YES;
        text.backgroundColor = UIColor.systemBackgroundColor;
        text.textColor = UIColor.labelColor;
        text.textContainerInset = UIEdgeInsetsMake(16,16,24,16);
        text.text = [row[@"action"] isEqualToString:@"adReport"] ? QTAdReport() : QTDiagnostics();
        page.view = text;
        [self.navigationController pushViewController:page animated:YES];
    } else if ([row[@"action"] isEqualToString:@"clearCapture"]) {
        QTResetElementCapture();
        self.navigationItem.prompt = @"Capture cleared — refresh Home to inspect new elements";
    } else if (row[@"action"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Disable all modifications?"
            message:@"This takes effect after a full guest-app restart. It will not change the running feed."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Apply" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            QTSet(@"enabled", NO);
            for (NSDictionary *o in QTOptions()) {
                QTSet(o[@"key"], NO);
            }
            [self.tableView reloadData];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
@end
UIViewController *QTSettingsController(void) {
    return [[QTOptionsController alloc] initWithStyle:UITableViewStyleInsetGrouped];
}

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
