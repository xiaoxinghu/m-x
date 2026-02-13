PROJECT = Mx.xcodeproj
SCHEME = Mx
CONFIGURATION = Debug
DERIVED_DATA = $(HOME)/Library/Developer/Xcode/DerivedData

.PHONY: build clean find install

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIGURATION) build

clean:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean

find:
	@find $(DERIVED_DATA) -name "M-x.app" -type d 2>/dev/null

install: build
	@APP_PATH=$$(find $(DERIVED_DATA) -name "M-x.app" -type d -print0 2>/dev/null | xargs -0 ls -td 2>/dev/null | head -n 1); \
	if [ -z "$$APP_PATH" ]; then \
		echo "No built M-x.app found. Run 'make build' first."; \
		exit 1; \
	fi; \
	echo "Installing $$APP_PATH to /Applications/M-x.app"; \
	rm -rf "/Applications/M-x.app"; \
	ditto "$$APP_PATH" "/Applications/M-x.app"; \
	echo "Install complete."
