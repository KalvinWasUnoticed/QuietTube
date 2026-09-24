#ifndef QT_FEED_RULES_H
#define QT_FEED_RULES_H
#include <stddef.h>
#include <string.h>

enum { QTFeedShorts = 1, QTFeedAd = 2, QTFeedPlayable = 4, QTFeedPromo = 8, QTFeedTopics = 16, QTFeedEdgeVideo = 32, QTFeedDisplayAd = 64, QTFeedMix = 128, QTFeedInlineShort = 256, QTFeedMixURL = 512, QTFeedWatchAgain = 1024 };
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
/* RD is the YouTube radio/Mix playlist family. Never scan naked RD prefixes
 * in arbitrary payload bytes: use a native playlistId or URL query boundary. */
static int QTPlaylistIDChar(unsigned char c) {
    return (c>='a'&&c<='z') || (c>='A'&&c<='Z') ||
           (c>='0'&&c<='9') || c=='_' || c=='-';
}
static int QTIsRadioPlaylistID(const unsigned char *bytes, size_t length) {
    if (!bytes || length<3 || length>96 || bytes[0]!='R' || bytes[1]!='D') return 0;
    for(size_t i=2;i<length;i++) if (!QTPlaylistIDChar(bytes[i])) return 0;
    return 1;
}
static int QTHasRadioPlaylistQuery(const unsigned char *bytes, size_t length) {
    if (!bytes || length>262144) return 0;
    for(size_t i=0;i<length;i++) {
        if (bytes[i]!='?' && bytes[i]!='&') continue;
        const char *key="list=";
        size_t start=i+1;
        if (length-start<5 || memcmp(bytes+start,key,5)) continue;
        start+=5;
        size_t end=start;
        while(end<length && QTPlaylistIDChar(bytes[end])) end++;
        /* Reject URL-encoded/invalid continuations rather than accept a prefix. */
        if (end<length && bytes[end]>=32 && bytes[end]<127 &&
            bytes[end]!='&' && bytes[end]!='#' && bytes[end]!='"' && bytes[end]!='\'' && bytes[end]!=' ') continue;
        if (QTIsRadioPlaylistID(bytes+start,end-start)) return 1;
    }
    return 0;
}
// BEGIN 0.9.1 WATCH AGAIN
/* A lexical protobuf-style string-field candidate, NOT a root-schema parser.
 * Require a legal bounded field tag and an exact short string length, never a
 * title substring. Nested text can still match inside a horizontal shelf. */
static int QTHasExactWatchAgainText(const unsigned char *bytes, size_t length) {
    static const char *titles[]={"Watch it again", "Watch again"};
    if (!bytes || length>262144) return 0;
    for(size_t i=0;i<length;i++) {
        size_t pos=i;
        unsigned long tag=0;
        unsigned shift=0;
        int complete=0;
        for(unsigned k=0;k<5 && pos<length;k++) {
            unsigned char b=bytes[pos++];
            if(k==4 && (b&0xf0)) break;
            tag|=(unsigned long)(b&127)<<shift;
            if(!(b&128)) { complete=1; break; }
            shift+=7;
        }
        if(!complete || (tag&7)!=2 || (tag>>3)==0 || pos>=length) continue;
        size_t n=bytes[pos++]; /* both supported strings have single-byte lengths */
        if(n>length-pos) continue;
        for(size_t t=0;t<sizeof(titles)/sizeof(titles[0]);t++)
            if(n==strlen(titles[t]) && !memcmp(bytes+pos,titles[t],n)) return 1;
    }
    return 0;
}
// END 0.9.1 WATCH AGAIN
static unsigned QTClassifyElementBytes(const unsigned char *bytes, size_t length) {
    if (!bytes || !length || length > 262144) return 0;
    static const struct { const char *token; unsigned kind; } rules[] = {
        {"shorts_shelf", QTFeedShorts}, {"reel_shelf", QTFeedShorts},
        {"shorts_lockup", QTFeedShorts}, {"shorts_video_cell", QTFeedShorts},
        {"shortslockup", QTFeedShorts}, {"shortslockupviewmodel", QTFeedShorts},
        {"radio_playlist_mix", QTFeedMix},
        {"radioautomixplaylistid", QTFeedMix}, {"radioplaylistmixplaylistid", QTFeedMix},
        {"feed_ad_metadata", QTFeedAd}, {"text_search_ad", QTFeedAd},
        {"playables_shelf", QTFeedPlayable}, {"playable_card", QTFeedPlayable},
        {"horizontal_gaming_shelf", QTFeedPlayable}, {"mini_game_card", QTFeedPlayable},
        {"statement_banner", QTFeedPromo}, {"brand_promo", QTFeedPromo},
        /* Display-ad candidates seen in public iOS filter references. Kept behind
         * a separate switch because matching a nested template is not proof. */
        {"text_image_button_layout", QTFeedDisplayAd},
        {"square_image_layout", QTFeedDisplayAd},
        {"carousel_footered_layout", QTFeedDisplayAd},
        {"product_carousel", QTFeedDisplayAd},
        {"carousel_headered_layout", QTFeedDisplayAd},
        {"landscape_image_wide_button_layout", QTFeedDisplayAd}
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
    /* Co-occurrence observed in user capture group 11; neither signal alone
     * identifies a full-height Short. No generic Home/injection-key matching. */
    if (QTTokenPresent(bytes,length,"video_lockup_overlay") &&
        QTTokenPresent(bytes,length,"yt_fill_youtube_shorts_24pt"))
        result |= QTFeedInlineShort;
    if (QTHasRadioPlaylistQuery(bytes,length)) result |= QTFeedMixURL;
// BEGIN 0.9.1 WATCH AGAIN
    if (QTTokenPresent(bytes,length,"horizontal_shelf") && QTHasExactWatchAgainText(bytes,length))
        result |= QTFeedWatchAgain;
// END 0.9.1 WATCH AGAIN
    return result;
}
#endif
