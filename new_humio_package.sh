#!/bin/bash

copy_and_replace() {
    local filename="$1"
    local app="$2"

    local SEARCH_STRING="{mule-app-name}"
    local REPLACEMENT_STRING="$app"

    local WARN_SEARCH_STRING="{_warn_threshold}"
    local WARN_REPLACEMENT_STRING="50"

    local ERROR_SEARCH_STRING="{_error_threshold}"
    local ERROR_REPLACEMENT_STRING="12"

    if [ "$filename" == "manifest.yaml" ]; then
        local REPLACEMENT_STRING="$(echo "$app" | tr '[:upper:]' '[:lower:]')"
    fi
    
    local SOURCE_FILE="$TEMPLATE_PACKAGE/$filename"
    local DEST_FILE="$OUTPUT_PACKAGE/$filename"
    cp "$SOURCE_FILE" "$DEST_FILE"

    if [[ "$(uname -s)" == "Darwin" ]]; then
        sed -i '' "s#${SEARCH_STRING}#${REPLACEMENT_STRING}#g" "$DEST_FILE"
        sed -i '' "s#${WARN_SEARCH_STRING}#${WARN_REPLACEMENT_STRING}#g" "$DEST_FILE"
        sed -i '' "s#${ERROR_SEARCH_STRING}#${ERROR_REPLACEMENT_STRING}#g" "$DEST_FILE"
    else
        sed -i "s#${SEARCH_STRING}#${REPLACEMENT_STRING}#g" "$DEST_FILE"
        sed -i "s#${WARN_SEARCH_STRING}#${WARN_REPLACEMENT_STRING}#g" "$DEST_FILE"
        sed -i "s#${ERROR_SEARCH_STRING}#${ERROR_REPLACEMENT_STRING}#g" "$DEST_FILE"
    fi

    return 0
}

APP="$1"
TEMPLATE_PACKAGE="package_template"
OUTPUT_PACKAGE="mule--$APP--0.1.0"

mkdir -p "$OUTPUT_PACKAGE/actions"
mkdir -p "$OUTPUT_PACKAGE/dashboards"
mkdir -p "$OUTPUT_PACKAGE/aggregate-alerts"

copy_and_replace actions/slack-webhook.yaml "$APP"
copy_and_replace dashboards/app.yaml "$APP"
copy_and_replace aggregate-alerts/app-ERROR-Alert.yaml "$APP"
copy_and_replace aggregate-alerts/app-WARN-Alert.yaml "$APP"
copy_and_replace manifest.yaml "$APP"
copy_and_replace README.md "$APP"

humioctl packages install io_schibsted_icc_mule_pre $OUTPUT_PACKAGE
rm -rf $OUTPUT_PACKAGE