# ################ Assets ################

assets: swiftgen format

swiftgen:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftgen config run --config ./swiftgen.yml)

format:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftformat ..)

XCBEAUTIFY:
	@(cd BuildTools; SDKROOT=macosx; echo "" | swift run -c release xcbeautify)

# ################ Web Views ################

VIEWS_LIB_PATH = ../prose-core-views
DESTINATION = Prose/ProseLib/Sources/ConversationFeature/Resources/Views

views: views-build assets

views-build:
	rm -rf "${VIEWS_LIB_PATH}/dist"
	(cd "${VIEWS_LIB_PATH}"; npm run build)
	rm -rf "${DESTINATION}"
	mkdir "${DESTINATION}"
	touch "${DESTINATION}/.gitkeep"

	cp -Rp "${VIEWS_LIB_PATH}/dist/" "${DESTINATION}"

# ################ Code Hygiene ################

XCBEAUTIFY = ./BuildTools/.build/release/xcbeautify
XCODEBUILD = set -o pipefail && xcodebuild
XCPROJ = Prose/Prose.xcodeproj
XCSCHEME = Prose

preflight: lint test release_build build_preview_apps

lint:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftformat --lint ..)

test: XCBEAUTIFY
	@$(XCODEBUILD) \
		-project $(XCPROJ) \
	    -scheme $(XCSCHEME) \
	  	test | $(XCBEAUTIFY)

release_build: XCBEAUTIFY
	@(export IS_RELEASE_BUILD=1 && $(XCODEBUILD) \
		-project $(XCPROJ) \
		-scheme $(XCSCHEME) \
		-configuration Release | $(XCBEAUTIFY))

build_preview_apps: XCBEAUTIFY
	@$(XCODEBUILD) \
		-project $(XCPROJ) \
		-scheme ConversationFeaturePreview | $(XCBEAUTIFY)