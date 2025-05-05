set -e

COMMON_FLAGS=(
  "archive"
  "-configuration release"
  "-project GRDBCustom.xcodeproj"
  "-scheme GRDBCustom"
)

SDKS=(
  "iphoneos"
  "iphonesimulator"
)

rm -rf GRDB.xcframework.zip GRDB.xcframework *.xcarchive

make SQLiteCustom

FRAMEWORKS=()
for SDK in "${SDKS[@]}"; do
  echo "Running xcodebuild -sdk ${SDK} ${COMMON_FLAGS[@]} -archivePath GRDB-${SDK}.xcarchive"

  xcodebuild \
    -sdk ${SDK} \
    ${COMMON_FLAGS[@]} \
    -archivePath GRDB-${SDK}.xcarchive \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO

  FRAMEWORKS+=(
    "-framework" "GRDB-${SDK}.xcarchive/Products/Library/Frameworks/GRDB.framework"
    "-debug-symbols" "$(pwd)/GRDB-${SDK}.xcarchive/dSYMs/GRDB.framework.dSYM"
  )
done

xcodebuild -create-xcframework -output GRDB.xcframework ${FRAMEWORKS[@]}

zip -r GRDB.xcframework.zip GRDB.xcframework
rm -rf ${ARCHIVES[@]} GRDB.xcframework

sha256sum GRDB.xcframework.zip