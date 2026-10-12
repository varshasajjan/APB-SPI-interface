help:
        -@echo "######################################################################"
        -@echo "FROM EACH test_<name> DIRECTORY...."
        -@echo "make lint       => Run VC Static on current testcase"
        -@echo "make clean      => Clean up current testcase directory"
        -@echo "FROM examples DIRECTORY...."
        -@echo "make help       => Generate this help menu      "
        -@echo "NOTE: Refer to README file for more details on the testcase"
        -@echo "######################################################################"

lint:
        $(VC_STATIC_HOME)/bin/vc_static_shell -mode64 -f vc_lint.tcl

clean:
         rm -rf novas* vcst* *.txt
