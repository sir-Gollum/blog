.PHONY: help
## Show this help message
help:
	@awk 'BEGIN { \
		FS = ":.*##"; \
		printf "Usage:\n  make \033[36m<target>\033[0m\n\nTargets:\n" \
	} \
	/^[a-zA-Z_0-9-]+:.*##/ { \
		printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 \
	} \
	/^##[^@]/ { \
		getline target; \
		if (target ~ /^[a-zA-Z_0-9-]+:/) { \
			gsub(/^## */, "", $$0); \
			gsub(/:.*/, "", target); \
			printf "  \033[36m%-15s\033[0m %s\n", target, $$0 \
		} \
	} \
	/^##@/ { \
		printf "\n\033[1m%s\033[0m\n", substr($$0, 5) \
	}' $(MAKEFILE_LIST)


.PHONY: serve
## Serve locally with live reload
serve:
	hugo serve --cleanDestinationDir --forceSyncStatic --noHTTPCache --disableFastRender --renderToMemory --buildDrafts

.PHONY: new-post
## Create a new blog post
new-post:
	@echo "Creating a new blog post..."
	@read -p "Enter year (default: $$(date +%Y)): " year; \
	year=$${year:-$$(date +%Y)}; \
	read -p "Enter month (default: $$(date +%m)): " month; \
	month=$${month:-$$(date +%m)}; \
	read -p "Enter day (default: $$(date +%d)): " day; \
	day=$${day:-$$(date +%d)}; \
	read -p "Enter post slug: " slug; \
	if [ -z "$$slug" ]; then \
		echo "Error: Post slug is required"; \
		exit 1; \
	fi; \
	dir="content/blog/$$year/$$month"; \
	mkdir -p "$$dir"; \
	filepath="$$dir/$$slug.en.md"; \
	if [ -f "$$filepath" ]; then \
		echo "Error: Post already exists at $$filepath"; \
		exit 1; \
	fi; \
	hugo new "$$filepath" --clock "$${year}-$${month}-$${day}T$$(date +%H:%M:%S%z)"; \
	echo "Created new post at $$filepath"

.PHONY: deploy-tower
## Deploy to Tower home server
deploy-tower:
	hugo && rsync -avz --delete public/ root@tower.local:/mnt/user/CIOutput/blog/
