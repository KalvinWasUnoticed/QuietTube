#ifndef QT_FEED_RULES_H
#define QT_FEED_RULES_H
#include <stddef.h>
#include <string.h>

enum { QTFeedShorts = 1, QTFeedAd = 2, QTFeedPlayable = 4, QTFeedPromo = 8, QTFeedTopics = 16, QTFeedEdgeVideo = 32 };
/* Bounded, case-sensitive template-token heuristics, NOT a protobuf decoder.
 * Never match generic words such as "shorts", "game", "featured" or "ad". */
static int QTTokenChar(unsigned char c) {
    return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
           (c >= '0' && c <= '9') || c == '_';
}
static int QTTokenPresent(const unsigned char *bytes, size_t length, const char *token) {
    size_t n = strlen(token);
    if (!bytes || !n || length < n) return 0;
    for (size_t i = 0; i <= length - n; i++) {
        if (i && QTTokenChar(bytes[i-1])) continue;
        if (memcmp(bytes+i, token, n)) continue;
        if (i+n < length && QTTokenChar(bytes[i+n])) continue;
        return 1;
    }
    return 0;
}
static unsigned QTClassifyElementBytes(const unsigned char *bytes, size_t length) {
    if (!bytes || !length || length > 262144) return 0;
    static const struct { const char *token; unsigned kind; } rules[] = {
        {"shorts_shelf", QTFeedShorts}, {"reel_shelf", QTFeedShorts},
        {"shorts_lockup", QTFeedShorts}, {"shorts_video_cell", QTFeedShorts},
        {"shortslockup", QTFeedShorts}, {"shortslockupviewmodel", QTFeedShorts},
        {"feed_ad_metadata", QTFeedAd}, {"text_search_ad", QTFeedAd},
        {"playables_shelf", QTFeedPlayable}, {"playable_card", QTFeedPlayable},
        {"horizontal_gaming_shelf", QTFeedPlayable}, {"mini_game_card", QTFeedPlayable},
        {"statement_banner", QTFeedPromo}, {"brand_promo", QTFeedPromo}
    };
    unsigned result = 0;
    for (size_t i=0; i<sizeof(rules)/sizeof(rules[0]); i++)
        if (QTTokenPresent(bytes,length,rules[i].token)) result |= rules[i].kind;
    /* Cross-client component names: candidates, not iOS screenshot validation.
     * Do not hide the generic chip_cloud (top topic bar) or every video_card. */
    if (QTTokenPresent(bytes,length,"chips_shelf")) result |= QTFeedTopics;
    int videoLockup = QTTokenPresent(bytes,length,"video_lockup_with_attachment") ||
                      QTTokenPresent(bytes,length,"video_card");
    int portraitThumb = QTTokenPresent(bytes,length,"oardefault.jpg") ||
                        QTTokenPresent(bytes,length,"oar1.jpg") ||
                        QTTokenPresent(bytes,length,"oar2.jpg") ||
                        QTTokenPresent(bytes,length,"oar3.jpg");
    if (QTTokenPresent(bytes,length,"inline_shorts") || (videoLockup && portraitThumb))
        result |= QTFeedEdgeVideo;
    return result;
}
#endif
