RELEASE_NAME=MiniBatteryLogger
TARGET_NAME=MiniBatteryLogger
BUILD_DIR=build/Release

.PHONY: all release debug clean l10n lstemperatures i18n missing-strings langpacks docs

all: release

langpacks:
	./scripts/generate_langpacks.sh

docs:
	headerdoc2html -o Docs/ Source/*.h Widget\ Plugin/*.h

i18n:
	./scripts/generate_strings.sh

l10n:
	./scripts/generate_nib.sh
	
missing-strings: l10n
	./generate_missing_strings.sh

debug:
	xcodebuild -target $(TARGET_NAME) -configuration Debug build

release:
	xcodebuild -target $(TARGET_NAME) -configuration Release build

lstemperatures:
	gcc -Wall -o bin/lstemperatures -framework IOKit -framework CoreFoundation bin/lstemperatures.c

next-version:
	/usr/bin/agvtool next-version
	
clean:
	xcodebuild -alltargets clean
	rm bin/lstemperatures