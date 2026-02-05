#!/usr/bin/env bash
function help {
cat <<EOF
    Usage: $0 [OPTIONS]... [FILE]...

    -h|--help   Display this text
    -crop       Default is 1440x2672+0+96
    -geometry   Default is x1000+2+2
    -output     Default is ssmontage.png

    Creates a montage of FILEs (default is screenshots/*.png)
EOF
}

CROP_ARG="1440x2672+0+0"
GEOMETRY_ARG="x1000+2+2"
OUTPUT_FILE="ssmontage.png"
POSITIONAL_ARGS=""

while (( "$#" )); do
    case "$1" in
    -crop)
        CROP_ARG=$2
        shift 2
    ;;
    -geometry)
        GEOMETRY_ARG=$2
        shift 2
    ;;
    -o|-output)
        OUTPUT_FILE=$2
        shift 2
    ;;
    -?|-h|-help|--help)
        help
        exit 0
    ;;
    --) # end argument parsing
        shift
        break
    ;;
    -*|--*=) # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        help
        exit 1
    ;;
    *) # preserve positional arguments
        POSITIONAL_ARGS="$POSITIONAL_ARGS $1"
        shift
    ;;
    esac
done

if [ -z "$POSITIONAL_ARGS" ]
then
    POSITIONAL_ARGS=screenshots/*.png
fi

montage -crop $CROP_ARG -geometry $GEOMETRY_ARG $POSITIONAL_ARGS $OUTPUT_FILE
