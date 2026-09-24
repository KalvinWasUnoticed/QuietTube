#include "../Sources/QTInsertionPolicy.h"
#include <assert.h>
#include <stdio.h>
int main(void) {
    unsigned n=0;
    for (int active=0;active<2;active++) for(int feed=0;feed<2;feed++)
        for(size_t depth=0;depth<4;depth++) {
            assert(QTInsertionMayFilter(active,feed,depth)==(active==1 && feed==1 && depth!=0)); n++;
        }
    for(int exact=0;exact<2;exact++) for(int marker=0;marker<2;marker++) {
        assert(QTInsertionRejectEntry(exact,marker)==(exact==1 && marker==1)); n++;
    }
    assert(!QTInsertionBatchWithinLimit(0));
    assert(QTInsertionBatchWithinLimit(1));
    assert(QTInsertionBatchWithinLimit(512));
    assert(!QTInsertionBatchWithinLimit(513));
    assert(!QTInsertionBatchWithinLimit((size_t)-1)); n+=5;
    // The predicate retains unmarked/unknown entries even in mixed input.
    int exact[]={1,1,0,1,1},marked[]={0,1,1,0,1},kept[5],count=0;
    for(int i=0;i<5;i++) if(!QTInsertionRejectEntry(exact[i],marked[i]))kept[count++]=i;
    assert(count==3 && kept[0]==0 && kept[1]==2 && kept[2]==3); n++;
    printf("%u insertion-policy checks passed; native hook execution untested\n",n);
    return 0;
}
