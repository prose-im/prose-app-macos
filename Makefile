assets: swiftgen format

swiftgen:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftgen config run --config ./swiftgen.yml)

format:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftformat ..)