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
    assert(match("chips_shelf.eml") == QTFeedTopics);
    assert(match("chip_cloud.eml") == 0);
    assert(match("video_card.eml") == 0);
    assert(match("video_lockup_with_attachment.eml /hqdefault.jpg") == 0);
    assert(match("video_lockup_with_attachment.eml /oardefault.jpg") == QTFeedEdgeVideo);
    assert(match("video_card.eml /oar1.jpg") == QTFeedEdgeVideo);
    assert(match("/oar1.jpg") == 0);
    assert(match("inline_shorts.eml") == QTFeedEdgeVideo);
    assert(match("Explore more topics") == 0); /* title alone in arbitrary bytes is not a rule */
    assert(match("not_chips_shelf") == 0);
    assert(match("video_card.eml /frame0.jpg") == 0); /* common thumbnail excluded */
    assert(match("chips_shelf.eml shorts_shelf.eml") == (QTFeedTopics|QTFeedShorts));
    assert(match("text_image_button_layout.eml") == QTFeedDisplayAd);
    assert(match("product_carousel") == QTFeedDisplayAd);
    assert(match("ordinary_video_layout") == 0);
    assert(match("not_text_image_button_layout") == 0);
    assert(match("text_image_button_layout_extra") == 0);
    assert(match("shorts_shelf.eml square_image_layout") == (QTFeedShorts|QTFeedDisplayAd));
    assert(match("video_lockup_overlay.eml-fe yt_fill_youtube_shorts_24pt") == QTFeedInlineShort);
    assert(match("video_lockup_overlay.eml-fe") == 0);
    assert(match("yt_fill_youtube_shorts_24pt") == 0);
    assert(match("home_vertical_feed_prominence_group_key inline_injection_teaser_1790215880042_0") == 0);
    assert(match("post_lockup posts_lockup ic_video_youtube") == 0);
    assert(match("not_video_lockup_overlay yt_fill_youtube_shorts_24pt") == 0);
    assert(match("video_lockup_overlay yt_fill_youtube_shorts_24pt_extra") == 0);
    assert(match("radio_playlist_mix.eml") == QTFeedMix);
    assert(match("radioautomixplaylistid") == QTFeedMix);
    assert(match("radioplaylistmixplaylistid") == QTFeedMix);
    assert(match("Mix - Phantogram - Black Out Days") == 0);
    assert(match("playlist_lockup feed_nudge_view remix video_card") == 0);
    assert(match("not_radio_playlist_mix radio_playlist_mix_extra") == 0);
    assert(match("https://www.youtube.com/watch?v=abcdefghijk&list=RDabcdefghijk") == QTFeedMixURL);
    assert(match("/playlist?list=RDMMabcdefghijk&playnext=1") == QTFeedMixURL);
    assert(match("?list=RDCLAK5uy_ABC-def#next") == QTFeedMixURL);
    assert(match("?list=PLabcdefghijk") == 0);
    assert(match("?list=WL") == 0);
    assert(match("?list=LL") == 0);
    assert(match("RDabcdefghijk Mix - title list=RDabcdefghijk") == 0);
    assert(match("?notlist=RDabcdefghijk") == 0);
    assert(match("?list=RD") == 0);
    assert(match("?list=rdabcdefghijk") == 0);
    assert(match("?list=RDabc%2Fbad") == 0);
    assert(match("?list=RDabc/bad") == 0);
    assert(QTIsRadioPlaylistID((const unsigned char *)"RDabcdefghijk",13));
    assert(!QTIsRadioPlaylistID((const unsigned char *)"PLabcdefghijk",13));
    assert(!QTIsRadioPlaylistID(NULL,3));
    unsigned char largeID[100]; memset(largeID,'a',sizeof(largeID)); largeID[0]='R'; largeID[1]='D';
    assert(!QTIsRadioPlaylistID(largeID,sizeof(largeID)));
    const unsigned char rdBinary[]={0,255,'?', 'l','i','s','t','=','R','D','x',0};
    assert(QTClassifyElementBytes(rdBinary,sizeof(rdBinary))==QTFeedMixURL);
    assert(match("?list=RDabc shorts_shelf.eml") == (QTFeedMixURL|QTFeedShorts));
    assert(match("horizontal_shelf.eml-fe \x0a\x0eWatch it again") == QTFeedWatchAgain);
    assert(match("horizontal_shelf.eml-fe \x12\x0bWatch again") == QTFeedWatchAgain);
    assert(match("horizontal_shelf.eml-fe \x82\x01\x0eWatch it again") == QTFeedWatchAgain);
    assert(match("horizontal_shelf.eml-fe") == 0);
    assert(match("shelf_header.eml-fe \x0a\x0eWatch it again") == 0);
    assert(match("video_card \x0a\x0eWatch it again") == 0);
    assert(match("horizontal_shelf.eml-fe Watch it again") == 0);
    assert(match("horizontal_shelf.eml-fe \x0a\x13Watch it again soon") == 0);
    assert(match("not_horizontal_shelf \x0a\x0eWatch it again") == 0);
    assert(match("horizontal_shelf_extra \x0a\x0eWatch it again") == 0);
    assert(match("horizontal_shelf \x0a\x0eWatch it") == 0);
    assert(match("horizontal_shelf \x0a\x7fWatch it again") == 0);
    assert(match("horizontal_shelf \x09\x0eWatch it again") == 0);
    assert(match("chip_cloud \x0a\x0eWatch it again") == 0);
    assert(match("home_vertical_feed_prominence_group_key inline_injection_teaser") == 0);
    assert(match("horizontal_shelf \x0a\x0eWatch it again ?list=RDabc") == (QTFeedWatchAgain|QTFeedMixURL));
    assert(match("full_width_portrait_image_layout.eml-fe") == QTFeedCompanionAd);
    assert(match("full_width_square_image_layout") == QTFeedCompanionAd);
    assert(match("video_display_full_layout") == QTFeedCompanionAd);
    assert(match("video_display_full_buttoned_layout") == QTFeedCompanionAd);
    assert(match("not_video_display_full_layout") == 0);
    assert(match("video_display_full_layout_extra") == 0);
    assert(match("video_metadata.eml-fe video_metadata_carousel_collection") == 0);
    assert(match("inline_injection_teaser ic_video_youtube id.video.add_to.button") == 0);
    assert(match("Sponsored MIVI MadMuscles Visit site") == 0);
    assert(match("full_width_portrait_image_layout shorts_shelf") == (QTFeedCompanionAd|QTFeedShorts));
    /* Deterministic malformed-byte smoke test under ASan/UBSan. */
    unsigned state=1234567;
    unsigned char noise[257];
    for (unsigned round=0;round<5000;round++) {
        size_t n=round%sizeof(noise);
        for (size_t k=0;k<n;k++) { state=state*1664525u+1013904223u; noise[k]=(unsigned char)(state>>24); }
        unsigned value=QTClassifyElementBytes(noise,n);
        assert((value & ~4095u)==0);
    }
    puts("89 classifier fixtures + 5000 bounded random-byte iterations passed");
    return 0;
}
