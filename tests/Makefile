test-cases = vdma

test-cases += example 
#test-cases += interrupt


test-cases-clean = $(foreach  i, $(test-cases), $(i)_clean)

PWD = $(shell pwd)

all : $(test-cases)

clean : $(test-cases-clean)

$(test-cases) : 
	make -C $@

$(test-cases-clean) :
	make -C $(subst _clean,,$@) clean

.PHONY : $(test-cases) $(test-cases-clean) clean