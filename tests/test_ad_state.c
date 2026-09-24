#include "../Sources/QTAdState.h"
#include <assert.h>
#include <stdio.h>
#include <string.h>
int main(void) {
    unsigned count=0;
    for(int master=0;master<2;master++) for(int requested=0;requested<2;requested++)
    for(int stopped=0;stopped<2;stopped++) for(int player=0;player<2;player++) for(int feed=0;feed<2;feed++) {
        QTAdInstallState expected=(!master||!requested)?QTAdOff:stopped?QTAdStopped:
            (player&&feed)?QTAdInstalled:(player||feed)?QTAdPartial:QTAdPending;
        assert(QTAdState(master,requested,stopped,player,feed)==expected);
        assert(strlen(QTAdStateName(expected))>0);
        count++;
    }
    assert(QTAdState(1,1,0,0,0)==QTAdPending); /* exact reported empty 0.13 session */
    printf("%u ad-state combinations + inactive-session regression passed\n",count);
    return 0;
}
