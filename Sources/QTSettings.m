#import "QTCore.h"

@interface QTOptionsController : UITableViewController
@property(nonatomic, copy) NSString *group;
@property(nonatomic, strong) NSArray<NSDictionary *> *rows;
@end
@implementation QTOptionsController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.group ?: @"Quiet controls";
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
        @{@"title":@"View diagnostics", @"action":@"diagnostics"},
        @{@"title":@"UI-only test mode", @"action":@"ui"},
        @{@"title":@"Restore chosen defaults", @"action":@"reset"}
    ];
}
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section { return self.rows.count; }
- (NSString *)tableView:(UITableView *)tv titleForFooterInSection:(NSInteger)section {
    return @"Experimental · YouTube 21.38.2\nRestart the guest app after changing flags. A switch is a preference, not proof that its hooks are available. See Advanced → View diagnostics.\n\nNo analytics, account-token access, request rewriting, or automatic error retries are added by this tweak.\n\nShorts-to-regular-player conversion is not implemented in 0.1; its requested default was off.";
}
- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)index {
    NSDictionary *row = self.rows[index.row];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text = row[@"title"];
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = row[@"note"];
    cell.detailTextLabel.numberOfLines = 0;
    if (row[@"key"]) {
        UISwitch *toggle = [UISwitch new];
        toggle.accessibilityLabel = row[@"title"];
        toggle.accessibilityIdentifier = row[@"key"];
        toggle.on = [NSUserDefaults.standardUserDefaults boolForKey:[@"QuietTube.v1." stringByAppendingString:row[@"key"]]];
        [toggle addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = toggle;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)changed:(UISwitch *)sender { QTSet(sender.accessibilityIdentifier, sender.on); }
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)index {
    [tv deselectRowAtIndexPath:index animated:YES];
    NSDictionary *row = self.rows[index.row];
    if (row[@"page"]) {
        QTOptionsController *page = [[QTOptionsController alloc] initWithStyle:UITableViewStyleInsetGrouped];
        page.group = row[@"page"];
        [self.navigationController pushViewController:page animated:YES];
    } else if ([row[@"action"] isEqualToString:@"diagnostics"]) {
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
        text.text = QTDiagnostics();
        page.view = text;
        [self.navigationController pushViewController:page animated:YES];
    } else if (row[@"action"]) {
        BOOL reset = [row[@"action"] isEqualToString:@"reset"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:row[@"title"]
            message:reset ? @"Restore your selected defaults? Restart YouTube afterward." :
                @"Disable player-ad filtering, PiP, background audio, autoplay and preview modifications. UI hiding stays on. Restart YouTube afterward."
            preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Apply" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) {
            QTSet(@"enabled", YES);
            for (NSDictionary *o in QTOptions()) {
                if (reset) QTSet(o[@"key"], [o[@"default"] boolValue]);
                else if ([o[@"group"] isEqualToString:@"Playback"]) QTSet(o[@"key"], NO);
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
        SEL push = NSSelectorFromString(@"pushViewController:");
        if (QTMatches(target,push,@"v@")) {
            ((void (*)(id,SEL,id))objc_msgSend)(target,push,page); return YES;
        }
        if ([target isKindOfClass:UIViewController.class]) {
            UINavigationController *nav = ((UIViewController *)target).navigationController;
            if (nav) { [nav pushViewController:page animated:YES]; return YES; }
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
