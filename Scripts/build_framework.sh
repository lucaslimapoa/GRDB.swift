set -e

COMMON_FLAGS=(
  archive
  -configuration
  release
  -project
  GRDBCustom.xcodeproj
  -scheme
  GRDBCustom
)

DESTINATIONS=(
  "generic/platform=iOS"
  "generic/platform=iOS Simulator"
)

rm -rf GRDB.xcframework.zip GRDB.xcframework *.xcarchive

make SQLiteCustom

FRAMEWORKS=()
INDEX=0
for DEST in "${DESTINATIONS[@]}"; do
  ARCHIVE_NAME="GRDB-${INDEX}.xcarchive"
  echo "Running xcodebuild ${COMMON_FLAGS[*]} -destination '${DEST}' -archivePath ${ARCHIVE_NAME}"

  xcodebuild \
    "${COMMON_FLAGS[@]}" \
    -destination "${DEST}" \
    -archivePath "${ARCHIVE_NAME}" \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO

  FRAMEWORKS+=(
    "-framework" "${ARCHIVE_NAME}/Products/Library/Frameworks/GRDB.framework"
    "-debug-symbols" "$(pwd)/${ARCHIVE_NAME}/dSYMs/GRDB.framework.dSYM"
  )
  ((INDEX++))
done

xcodebuild -create-xcframework -output GRDB.xcframework "${FRAMEWORKS[@]}"

zip -r GRDB.xcframework.zip GRDB.xcframework
rm -rf GRDB.xcframework *.xcarchive

shasum -a 256 GRDB.xcframework.zip > GRDB.xcframework.zip.sha256