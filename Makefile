FILE_NAME := 448.zip
URLS := http://blog.kislenko.net/archives/448.zip \
        https://web.archive.org/web/20250205080556/http://blog.kislenko.net/archives/448.zip
SHA1SUM := 96ea305717d5b473feb2ee92b5827a93c17aeed3

BC_VERSION := $(word 2,$(shell bc -v))
PYTHON := $(shell compgen -c | egrep 'python3(\.[0-9]+)?$$' | sort -V | tail -1)

.PHONY: all download verify extract process test cleanup clean

all: download extract process test cleanup

download:
	@rm -f $(FILE_NAME)
	@for url in $(URLS); do \
		if curl -fsSL -o $(FILE_NAME) $$url; then \
			if echo "$(SHA1SUM)  $(FILE_NAME)" | sha1sum -c --status; then \
				echo "Downloaded and verified from $$url"; \
				exit 0; \
			else \
				echo "Checksum mismatch for $$url, trying next..."; \
				rm -f $(FILE_NAME); \
			fi; \
		fi; \
	done; \
	echo "Download failed or checksum mismatch on all URLs"; exit 1

extract:
	@echo "Extracting..."
	@unzip -o $(FILE_NAME)
	@echo "Extraction complete."

process:
	@echo "Processing extracted files..."
	@$(PYTHON) convert $(BC_VERSION) < ENRUS.TXT > dict
	@chmod a+x dict
	@echo "Processing complete."

test:
	@echo "Testing dictionary..."
	@printf "cat\n0" | ./dict 2>/dev/null | grep -q "Кошка" && echo "Test passed!" || (echo "Test failed!" && exit 1)

cleanup:
	@rm -f $(FILE_NAME) ENRUS.TXT

clean: cleanup
	@rm -f dict
