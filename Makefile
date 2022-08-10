# ################ Assets ################

assets: swiftgen format

swiftgen:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftgen config run --config ./swiftgen.yml)

format:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftformat ..)

XCBEAUTIFY:
	@(cd BuildTools; SDKROOT=macosx; echo "" | swift run -c release xcbeautify)

# ################ Web Views ################

VIEWS_LIB_URL=https://github.com/prose-im/prose-core-views
VIEWS_LIB_VERSION=0.11.1
VIEWS_ARCHIVE_NAME=release-${VIEWS_LIB_VERSION}.tar.gz
DESTINATION=Prose/ProseLib/Sources/ConversationFeature/Resources/Views

views: views-build assets

views-build:
	rm -rf "${DESTINATION}"
	mkdir "${DESTINATION}"
	touch "${DESTINATION}/.gitkeep"

	@curl -Ls "${VIEWS_LIB_URL}/releases/download/${VIEWS_LIB_VERSION}/${VIEWS_ARCHIVE_NAME}" | tar -xvz -C ${DESTINATION} --strip=1

# ################ Code Hygiene ################

XCBEAUTIFY = ./BuildTools/.build/release/xcbeautify
XCODEBUILD = set -o pipefail && xcodebuild
XCPROJ = Prose/Prose.xcodeproj
XCSCHEME = Prose
PREVIEW_SCHEMES = ConversationFeaturePreview EditProfileFeaturePreview

preflight: lint test release_build build_preview_apps

lint:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftformat --lint ..)

test: XCBEAUTIFY
	@$(XCODEBUILD) \
		-project $(XCPROJ) \
	    -scheme $(XCSCHEME) \
		-testPlan AllTests \
	  	test | $(XCBEAUTIFY)
		  
test-ci: XCBEAUTIFY
	@$(XCODEBUILD) \
		-project $(XCPROJ) \
		-scheme $(XCSCHEME) \
		-testPlan AllTests \
		-resultBundlePath TestResults \
		test | $(XCBEAUTIFY)

release_build: XCBEAUTIFY
	@(export IS_RELEASE_BUILD=1 && $(XCODEBUILD) \
		-project $(XCPROJ) \
		-scheme $(XCSCHEME) \
		-configuration Release | $(XCBEAUTIFY))

build_preview_apps: XCBEAUTIFY $(PREVIEW_SCHEMES)

$(PREVIEW_SCHEMES): XCBEAUTIFY
	@$(XCODEBUILD) \
		-project $(XCPROJ) \
		-scheme $@ | $(XCBEAUTIFY)
