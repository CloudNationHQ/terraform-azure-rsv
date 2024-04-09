.PHONY: test

export TF_PATH

test:
	cd tests && go test -v -timeout 60m -run TestApplyNoError/$(TF_PATH) ./rsv_test.go

#test_extended:
	#cd tests && env go test -v -timeout 60m -run TestCosmosDbAccount ./rsv_extended_test.go

