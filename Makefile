all:
	yarn

.PHONY:compile
compile: clean
	yarn compile

.PHONY:test
test:
	yarn test

.PHONY:clean
clean:
	yarn clean
	rm -rf cache