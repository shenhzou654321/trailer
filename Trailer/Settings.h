
@interface Settings : NSObject

+ (Settings *)shared;

- (NSString *)sortField;

@property (nonatomic) NSInteger sortMethod, statusFilteringMode,
								closeHandlingPolicy, mergeHandlingPolicy, statusItemRefreshInterval;

@property (nonatomic) NSArray *statusFilteringTerms;

@property (nonatomic) NSString *authToken, *localUser, *localUserId,
							*apiFrontEnd, *apiBackEnd, *apiPath,
							*hotkeyLetter;

@property (nonatomic) float refreshPeriod, backgroundRefreshPeriod, newRepoCheckPeriod;

@property (nonatomic) BOOL shouldHideUncommentedRequests, showCommentsEverywhere,
							sortDescending, showCreatedInsteadOfUpdated,
							dontKeepPrsMergedByMe, hideAvatars, autoParticipateInMentions,
							dontAskBeforeWipingMerged, dontAskBeforeWipingClosed,
							includeReposInFilter, showReposInName,
							dontReportRefreshFailures, groupByRepo, hideAllPrsSection,
							showStatusItems, makeStatusItemsSelectable, moveAssignedPrsToMySection,
							markUnmergeableOnUserSectionsOnly, countOnlyListedPrs;

@property (nonatomic) BOOL hotkeyEnable, hotkeyCommandModifier, hotkeyOptionModifier, hotkeyShiftModifier, hotkeyControlModifier;

// auto updates in OSX
@property (nonatomic) BOOL checkForUpdatesAutomatically;
@property (nonatomic) NSInteger checkForUpdatesInterval;

@end
