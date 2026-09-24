#include "../Sources/QTFeedRules.h"
#include <assert.h>
#include <stdio.h>
static unsigned match(const char *s) { return QTClassifyElementBytes((const unsigned char *)s,strlen(s)); }
int main(void) {
    assert(match("shorts_shelf.eml") == QTFeedShorts);
    assert(match("\x01shorts_video_cell\x00") == QTFeedShorts);
    assert(match("ordinary video about shorts and games") == 0);
    assert(match("not_shorts_shelf") == 0);
    assert(match("shorts_shelf_extra") == 0);
    assert(match("feed_ad_metadata") == QTFeedAd);
    assert(match("playables_shelf.eml") == QTFeedPlayable);
    assert(match("statement_banner.eml") == QTFeedPromo);
    assert(match("My Featured Video") == 0);
    assert(match("A video with a vertical aspect ratio") == 0);
    assert(match("shorts_shelf.eml feed_ad_metadata") == (QTFeedShorts|QTFeedAd));
    const unsigned char binary[] = {0,1,'x',0,'s','h','o','r','t','s','_','s','h','e','l','f',0,255};
    assert(QTClassifyElementBytes(binary,sizeof(binary)) == QTFeedShorts);
    assert(QTClassifyElementBytes(NULL,0) == 0);
    assert(QTClassifyElementBytes((const unsigned char *)"shorts_shelf",262145) == 0);
    puts("14 classifier assertions passed (not live feed coverage tests)");
    return 0;
}
