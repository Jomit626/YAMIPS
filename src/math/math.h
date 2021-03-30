#ifndef MATH_H
#define MATH_H


static unsigned mulu(register unsigned a,register unsigned b){
    register unsigned result = 0;
    if (a < b){
        register unsigned tmp = b;
        b = a;
        a = tmp;
    }

    while(b){
        if(b & 0x1)
            result += a;
        b >>= 1;
        a <<= 1;
    }
    return result;
}

struct divu_result
{
    unsigned quotient;
    unsigned reminder;
};


static struct divu_result divu(register unsigned a,register  unsigned b){
    struct divu_result result = {0, 0};
    register int i = 31;
    if(b == 0)
        return result;
        
    while(i >=0 ){
        if((a >> i) >= b){
            result.quotient += 1 << i;
            a -= b << i;
        }
        i -= 1;
    }
    result.reminder = a;
    return result;
}

#endif