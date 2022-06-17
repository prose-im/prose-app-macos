# ################ Assets ################

assets: strings xcassets format

xcassets:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftgen config run --config ./swiftgen-xcassets.yml)
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftgen config run --config ./swiftgen-preview.yml)

strings:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftgen config run --config ./swiftgen-strings.yml)

format:
	@(cd BuildTools; SDKROOT=macosx; swift run -c release swiftformat ..)

# ################ FFIs ################

RUST_LIB_PATH = ../uniffi_test
RUST_LIB_NAME = uniffi_test
SWIFT_LIB_NAME = ProseCore
BUILD_FOLDER = Build

ffi: interface framework

interface:
	uniffi-bindgen generate $(RUST_LIB_PATH)/src/$(RUST_LIB_NAME).udl -o ./$(BUILD_FOLDER)/interface --language swift
	sed -i '' 's/import uniffi_testFFI/@_implementationOnly import uniffi_testFFI/g' ./$(BUILD_FOLDER)/interface/$(RUST_LIB_NAME).swift

framework:
	rm -f $(BUILD_FOLDER)/lib$(SWIFT_LIB_NAME).a
	rm -f $(BUILD_FOLDER)/$(SWIFT_LIB_NAME).a
	rm -f $(BUILD_FOLDER)/$(SWIFT_LIB_NAME).swiftmodule
	
	(cd $(BUILD_FOLDER); swiftc \
		-module-name $(SWIFT_LIB_NAME) \
		-emit-library -o lib$(SWIFT_LIB_NAME).a \
		-emit-module -emit-module-path . \
		-parse-as-library \
		-L $(RUST_LIB_PATH)/target/aarch64-apple-darwin/release \
		-l$(RUST_LIB_NAME) \
		-Xcc -fmodule-map-file=./interface/$(RUST_LIB_NAME)FFI.modulemap \
		-static \
		-enable-library-evolution \
		./interface/$(RUST_LIB_NAME).swift)
	
	libtool -static -o $(BUILD_FOLDER)/$(SWIFT_LIB_NAME).a $(BUILD_FOLDER)/lib$(SWIFT_LIB_NAME).a $(RUST_LIB_PATH)/target/aarch64-apple-darwin/release/lib$(RUST_LIB_NAME).a
	
	rm -rf ProseCore/ProseCore/$(SWIFT_LIB_NAME).xcframework
	
	xcodebuild -create-xcframework \
		-library ./Build/$(SWIFT_LIB_NAME).a \
		-output ProseCore/ProseCore/$(SWIFT_LIB_NAME).xcframework
	
	cp Build/$(SWIFT_LIB_NAME).swiftmodule ProseCore/ProseCore/$(SWIFT_LIB_NAME).xcframework/macos-arm64
