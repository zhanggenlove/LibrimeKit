#import "lrk_entity.h"
#import <Foundation/Foundation.h>

typedef uintptr_t RimeSessionId;

/**
 ObjC wrapper around `rime_api.h`'s notification callback. Implement
 these to be informed of deploy progress and schema/mode changes.
 */
@protocol LRKNotificationDelegate

// message_type="deploy", message_value="start"
- (void)onDeployStart;

// message_type="deploy", message_value="success"
- (void)onDeploySuccess;

// message_type="deploy", message_value="failure"
- (void)onDeployFailure;

// on changing mode
- (void)onChangeMode:(NSString *)mode;

// on loading schema
- (void)onLoadingSchema:(NSString *)schema;

@end

/**
 ObjC wrapper around librime's C API. Exposes the function-pointer
 table behind `rime_get_api()` as Cocoa-friendly methods so Swift
 callers don't have to deal with C strings or struct lifetimes.
 */
@interface LRKAPI : NSObject

- (void)setNotificationDelegate:(id<LRKNotificationDelegate>)delegate;

// MARK: start and shutdown
- (void)setup:(LRKTraits *)traits;
- (void)initialize:(LRKTraits *)traits;
- (void)finalize;

- (void)startMaintenance:(BOOL)fullCheck;

- (BOOL)preBuildAllSchemas;
- (void)deployerInitialize:(LRKTraits *)traits;
- (BOOL)deploy;

- (BOOL)runTask:(NSString *)taskName;
- (BOOL)syncUserData;

// Session management
- (RimeSessionId)createSession;
- (BOOL)findSession:(RimeSessionId)session;
- (BOOL)destroySession:(RimeSessionId)session;
- (void)cleanAllSession;

// MARK: input and output
- (BOOL)processKey:(NSString *)keyCode andSession:(RimeSessionId)session;
- (BOOL)processKeyCode:(int)code modifier:(int)modifier andSession:(RimeSessionId)session;
- (NSArray<LRKCandidate *> *)getCandidateList:(RimeSessionId)session;
- (NSArray<LRKCandidate *> *)getCandidateWithIndex:(int)index
                                            andCount:(int)limit
                                          andSession:(RimeSessionId)session;
- (BOOL)selectCandidate:(RimeSessionId)session andIndex:(int)index;
/// Select a candidate from the **current page** by its page-local
/// index. Use this in preference to `selectCandidate:andIndex:`,
/// whose underlying `rime_api->select_candidate` is deprecated and
/// has been observed to silently no-op for some schemas (rime_ice
/// 2026-04 etc.) — `select_candidate_on_current_page` is the
/// modern path and works reliably. To target a candidate beyond
/// the current page, navigate first via `processKeyCode:` with
/// `XK_Page_Down` (`0xff56`) / `XK_Page_Up` (`0xff55`).
- (BOOL)selectCandidateOnCurrentPage:(RimeSessionId)session andIndex:(int)index;
/// Highlight a candidate WITHOUT committing. Useful when the menu
/// needs the highlight to land on a specific row before a separate
/// commit step. Added in librime 1.16.x. Page-local index.
- (BOOL)highlightCandidateOnCurrentPage:(RimeSessionId)session andIndex:(int)index;
/// Modern page-navigation API. Pass `backward = NO` for next page,
/// `YES` for previous. Returns `YES` if the page actually changed
/// (e.g. won't change at the last page when going forward).
/// Replaces the old "send `XK_Page_Down`/`XK_Page_Up` keycodes"
/// trick — that trick relied on the schema having those keys
/// bound, which `rime_ice` doesn't (the keycodes were silently
/// dropped, and `selectCandidateOnCurrentPage` then operated on
/// the wrong page).
- (BOOL)changePage:(RimeSessionId)session backward:(BOOL)backward;
- (BOOL)deleteCandidate:(RimeSessionId)session andIndex:(int)index;

- (NSString *)getInput:(RimeSessionId)session;
- (NSString *)getCommit:(RimeSessionId)session;
- (BOOL)commitComposition:(RimeSessionId)session;
- (void)cleanComposition:(RimeSessionId)session;
- (LRKStatus *)getStatus:(RimeSessionId)session;
- (LRKContext *)getContext:(RimeSessionId)session;

- (int) getCaretPosition:(RimeSessionId)session;
- (BOOL) setCaret:(RimeSessionId)session withPosition:(int)position;

// MARK: schema
- (NSArray<LRKSchema *> *)schemaList;
- (LRKSchema *)currentSchema:(RimeSessionId)session;
- (BOOL)selectSchema:(RimeSessionId)session andSchemaId:(NSString *)schemaId;

// MARK: Configuration
- (BOOL)getOption:(RimeSessionId)session andOption:(NSString *)option;
- (BOOL)setOption:(RimeSessionId)session andOption:(NSString *)option andValue:(BOOL)value;
// open <schema_id>.schema.yaml
- (LRKConfig *)openSchema:(NSString *)schemaId;
// open <config_id>.yaml
- (LRKConfig *)openConfig:(NSString *)configId;
// access config files in user data directory, eg. user.yaml and installation.yaml
- (LRKConfig *)openUserConfig:(NSString *)configId;
// MARK: Debug
- (void)simulateKeySequence:(NSString *)keys andSession:(RimeSessionId)session;

// MARK: customer settings
// NOTE: requires `default.custom.yaml` to exist in the user data
// directory; otherwise rime returns an empty list.
- (NSArray<LRKSchema *> *)getAvailableRimeSchemaList;
// NOTE: after `selectRimeSchemas:` the rime engine MUST be restarted
// for the change to take effect — i.e. call
// `[rimeAPI startMaintenance:YES]` (full-check must be YES).
- (NSArray<LRKSchema *> *)getSelectedRimeSchemaList;
- (BOOL)selectRimeSchemas:(NSArray<NSString *> *)schemas;
- (NSString *) getHotkeys;
- (BOOL) isFirstRun;
- (BOOL) customize:(NSString *)key boolValue:(BOOL) value;
- (BOOL) customize:(NSString *)key stringValue:(NSString *) value;
- (NSString *) getCustomize:(NSString *)key;
@end
