#
# Shortcuts to common Gitbook commands
#

# Change to the name you'd like to use for your book output files
BOOK_NAME := test-book-01

# Container meta-info
BIN := gitbook
REGISTRY ?= spohnan
IMAGE := $(REGISTRY)/$(BIN)
CONTAINER := $(REGISTRY)-$(BIN)

# The base command to run the Gitbook container
RUN_CMD := @docker run --rm -v $$(pwd):/srv/gitbook $(IMAGE)

GITBOOK_CMD := $(RUN_CMD) $(BIN)

# Slightly different options and a name so we can kill easily
SERVE_CMD := @docker run               \
               -p 4000:4000 --rm       \
               -v $$(pwd):/srv/gitbook \
               --name "$(CONTAINER)"   \
               $(IMAGE) $(BIN)

all: html pdf mobi

# Rebuild the docker container
# Must be run from the directory containing the Dockerfile
buildimage:
	@docker build -t $(IMAGE) .

# Gitbook Actions

bookdir:
	@mkdir -p _book

clean:
	@rm -fr _book

init: stop
	$(GITBOOK_CMD) init

html:
	$(GITBOOK_CMD) build

mobi: bookdir
	$(GITBOOK_CMD) mobi . ./_book/$(BOOK_NAME).mobi

pdf: bookdir
	$(GITBOOK_CMD) pdf . ./_book/$(BOOK_NAME).pdf

serve:
	$(SERVE_CMD) serve > /dev/null 2>&1 &

status:
	@docker ps --filter="name=$(CONTAINER)"

stop:
	@docker kill $(shell docker ps --filter=\"name=$(CONTAINER)\" -q) > /dev/null 2>&1 || true

# Gitbook Theme Actions
# For use with themes such as https://github.com/GitbookIO/theme-default

themeinit:
	$(RUN_CMD) npm update

themebuild:
	$(RUN_CMD) ./src/build.sh
   