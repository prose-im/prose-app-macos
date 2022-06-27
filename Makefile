# ################ Assets ################

assets: swiftgen format

swiftgen:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftgen config run --config ./swiftgen.yml)

format:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftformat ..)

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
