// Loads a .saver bundle into a regular window for development and
// memory profiling. Build: clang -fobjc-arc -framework Cocoa
// -framework ScreenSaver -o harness harness.m
// Usage: harness <path-to-.saver> single [preview]
//        harness <path-to-.saver> churn <cycle-seconds>
//        harness <path-to-.saver> pileup <cycle-seconds>
// churn mode tears down the view and creates a fresh one every cycle,
// simulating repeated screensaver activations in one process.
// pileup mode keeps old views alive and animating, modeling the
// legacyScreenSaver host bug where instances are never destroyed.
// "preview" instantiates the view with isPreview:YES.
#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>
#import <objc/runtime.h>

@interface HarnessDelegate : NSObject <NSApplicationDelegate>
@property (strong) NSWindow *window;
@property (strong) ScreenSaverView *saverView;
@property (assign) Class saverClass;
@property (assign) NSTimeInterval cycleSeconds; // 0 = single mode
@property (assign) BOOL retainOldViews;         // pileup mode
@property (assign) BOOL preview;                // isPreview:YES
@property (strong) NSMutableArray *pile;
@property (assign) NSUInteger cycleCount;
@end

@implementation HarnessDelegate

- (void)attachFreshView {
    if (self.saverView) {
        if (self.retainOldViews) {
            [self.pile addObject:self.saverView];
        } else {
            if (self.saverView.isAnimating) [self.saverView stopAnimation];
            [self.saverView removeFromSuperview];
        }
        self.saverView = nil;
    }
    NSRect frame = NSMakeRect(0, 0, 800, 600);
    ScreenSaverView *v = [[self.saverClass alloc] initWithFrame:frame isPreview:self.preview];
    if (!v) {
        fprintf(stderr, "failed to instantiate saver view\n");
        exit(2);
    }
    [self.window.contentView addSubview:v];
    [v startAnimation];
    self.saverView = v;
    self.cycleCount++;
    fprintf(stdout, "cycle %lu: view attached\n", (unsigned long)self.cycleCount);
    fflush(stdout);
}

- (void)applicationDidFinishLaunching:(NSNotification *)note {
    NSRect frame = NSMakeRect(200, 200, 800, 600);
    self.window = [[NSWindow alloc] initWithContentRect:frame
                                              styleMask:NSWindowStyleMaskTitled
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    self.window.title = @"saver harness";
    [self.window orderFront:nil]; // no makeKey: don't steal focus
    [self attachFreshView];
    if (self.cycleSeconds > 0) {
        [NSTimer scheduledTimerWithTimeInterval:self.cycleSeconds
                                        repeats:YES
                                          block:^(NSTimer *t) { [self attachFreshView]; }];
    }
}

@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        if (argc < 3) {
            fprintf(stderr, "usage: %s <saver-path> single|churn|pileup [cycle-seconds] [preview]\n", argv[0]);
            return 1;
        }
        NSBundle *bundle = [NSBundle bundleWithPath:@(argv[1])];
        NSError *err = nil;
        if (![bundle loadAndReturnError:&err]) {
            fprintf(stderr, "bundle load failed: %s\n", err.description.UTF8String);
            return 2;
        }
        Class saverClass = bundle.principalClass;
        fprintf(stdout, "loaded principal class: %s (pid %d)\n",
                class_getName(saverClass), getpid());
        fflush(stdout);

        NSApplication *app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        HarnessDelegate *delegate = [HarnessDelegate new];
        delegate.saverClass = saverClass;
        BOOL cycling = strcmp(argv[2], "churn") == 0 || strcmp(argv[2], "pileup") == 0;
        delegate.cycleSeconds = (cycling && argc > 3) ? atof(argv[3]) : 0;
        delegate.retainOldViews = strcmp(argv[2], "pileup") == 0;
        delegate.preview = strcmp(argv[argc - 1], "preview") == 0;
        delegate.pile = [NSMutableArray array];
        app.delegate = delegate;
        [app run];
    }
    return 0;
}
