#include "../Sources/QTDiagnosticPolicy.h"
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
int main(void) {
    for(size_t pending=0;pending<100;pending++) for(size_t rate=0;rate<100;rate++) for(int critical=0;critical<2;critical++) {
        int expected=pending<(size_t)(critical?64:56) && rate<(size_t)(critical?30:24);
        assert(QTDPAdmission(pending,rate,critical)==expected);
    }
    assert(QTDPFits(0,262144)); assert(QTDPFits(262144,0));
    assert(!QTDPFits(262144,1)); assert(!QTDPFits(SIZE_MAX,1)); assert(!QTDPFits(1,SIZE_MAX));
    for(size_t n=0;n<300000;n++) assert(QTDPFits(n,128)==(n<=262016));
    double now=1000000;
    assert(QTDPRecent(now,now)); assert(QTDPRecent(now-604800,now));
    assert(!QTDPRecent(now-604801,now)); assert(QTDPRecent(now+60,now));
    assert(!QTDPRecent(now+61,now)); assert(!QTDPRecent(NAN,now));
    assert(!QTDPRecent(INFINITY,now)); assert(!QTDPRecent(now,NAN));
    puts("Diagnostic policy: 20000 admission combinations + 300000 size checks + expiry/overflow boundaries passed.");
    return 0;
}
