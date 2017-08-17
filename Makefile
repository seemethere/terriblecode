DOCKER_RUN=docker run --rm -p 1313:1313 -v "$(CURDIR)":/v -w /v seemethere/hugo-docker:latest

all: clean public

.PHONY: dev
dev:
	-$(DOCKER_RUN) serve -Dw --bind 0.0.0.0

.PHONY: clean
clean:
	$(RM) -r public

public:
	$(DOCKER_RUN)
