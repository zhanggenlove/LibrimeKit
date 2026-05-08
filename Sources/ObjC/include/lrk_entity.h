#import <Foundation/Foundation.h>

/**
 ObjC mirror of librime's `rime_traits_t` struct.

 Should be initialized by calling `RIME_STRUCT_INIT(Type, var)` on
 the C side; from ObjC just allocate and fill in the properties.
 */
@interface LRKTraits : NSObject {
  NSString *sharedDataDir;
  NSString *userDataDir;
  NSString *distributionName;
  NSString *distributionCodeName;
  NSString *distributionVersion;

  // Pass a C-string of the form `"rime.<x>"` where `<x>` is your
  // app name. The `rime.` prefix is what lets librime auto-clean
  // its own old log files.
  NSString *appName;

  // Modules to load before `initialize`. When empty, librime uses
  // its built-in defaults (typically `core`, `dict`, `gears`, `lua`).
  NSArray<NSString *> *modules;

  // v1.6+
  /*! Minimal level of logged messages.
   *  Value is passed to Glog library using FLAGS_minloglevel variable.
   *  0 = INFO (default), 1 = WARNING, 2 = ERROR, 3 = FATAL
   */
  int minLogLevel;
  // Directory for log files. Forwarded to Glog as `FLAGS_log_dir`.
  NSString *logDir;
  // Pre-built data directory. Defaults to `${shared_data_dir}/build`.
  NSString *prebuiltDataDir;
  // Staging directory. Defaults to `${user_data_dir}/build`.
  NSString *stagingDir;
}

@property NSString *sharedDataDir;
@property NSString *userDataDir;
@property NSString *distributionName;
@property NSString *distributionCodeName;
@property NSString *distributionVersion;
@property NSString *appName;
@property NSArray<NSString *> *modules;
@property int minLogLevel;
@property NSString *logDir;
@property NSString *prebuiltDataDir;
@property NSString *stagingDir;

@end

/**
 One entry from the rime schema list — id + display name pair.
 */
@interface LRKSchema : NSObject {
  NSString *schemaId;
  NSString *schemaName;
}

@property NSString *schemaId;
@property NSString *schemaName;

- (id)initWithSchemaId:(NSString *)schemaId andSchemaName:(NSString *)name;

@end

/**
 Status snapshot returned by `LRKAPI -getStatus:`. Mirrors
 librime's `RIME_STRUCT(RimeStatus, ...)` fields.
 */
@interface LRKStatus : NSObject {
  NSString *schemaId;
  NSString *schemaName;
  BOOL isASCIIMode;
  BOOL isASCIIPunct;
  BOOL isComposing;
  BOOL isDisabled;
  BOOL isFullShape;
  BOOL isSimplified;
  BOOL isTraditional;
}

@property NSString *schemaId;
@property NSString *schemaName;
@property BOOL isASCIIMode;
@property BOOL isASCIIPunct;
@property BOOL isComposing;
@property BOOL isDisabled;
@property BOOL isFullShape;
@property BOOL isSimplified;
@property BOOL isTraditional;

@end

/**
 One candidate produced by librime — `text` is what gets committed,
 `comment` is the schema-supplied annotation (typically pinyin).
 */
@interface LRKCandidate : NSObject {
  NSString *text;
  NSString *comment;
}

@property NSString *text;
@property NSString *comment;

@end

/**
 The current candidate menu — page metadata plus the page's
 candidates. `highlightedCandidateIndex` is page-local.
 */
@interface LRKMenu : NSObject {
  int pageSize;
  int pageNo;
  BOOL isLastPage;
  int highlightedCandidateIndex;
  int numCandidates;
  NSString *selectKeys;
  NSArray<LRKCandidate *> *candidates;
}

@property int pageSize;
@property int pageNo;
@property BOOL isLastPage;
@property int highlightedCandidateIndex;
@property int numCandidates;
@property NSString *selectKeys;
@property NSArray<LRKCandidate *> *candidates;

@end

/**
 In-progress composition state — the raw input, cursor position,
 and the preedit string actually rendered to the user.
 */
@interface LRKComposition : NSObject {
  int length;
  int cursorPos;
  int selStart;
  int selEnd;
  NSString *preedit;
}

@property int length, cursorPos, selStart, selEnd;
@property NSString *preedit;

@end

/**
 Full session context — composition, menu, and any extra labels
 (e.g. shift-mode indicators) the schema wants to surface.
 */
@interface LRKContext : NSObject {
  NSString *commitTextPreview;
  LRKMenu *menu;
  LRKComposition *composition;
  NSArray<NSString *> *labels;
}

@property NSString *commitTextPreview;
@property LRKMenu *menu;
@property LRKComposition *composition;
@property NSArray<NSString *> *labels;

@end

/**
 One entry from a config-iterator walk over a list/map node.
 */
@interface LRKConfigIteratorItem : NSObject {
  int index;
  NSString *key;
  NSString *path;
}

@property int index;
@property NSString *key;
@property NSString *path;

@end


/**
 Open handle to a rime YAML config file (schema, default, user).
 Always pair an open with a `closeConfig` to release the underlying
 librime resources.
 */
@interface LRKConfig : NSObject

- (NSString *)getString:(NSString *)key;
- (BOOL)getBool:(NSString *)key;
- (int)getInt:(NSString *)key;
- (BOOL)setInt:(NSString *)key value:(int) value;
- (double)getDouble:(NSString *)key;

- (NSArray<LRKConfigIteratorItem *> *)getItems:(NSString *)key;
- (NSArray<LRKConfigIteratorItem *> *)getMapValues:(NSString *)key;
- (void) closeConfig;
@end
