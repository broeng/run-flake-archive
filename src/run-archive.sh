set -e

ARCHIVE_URL=${1}
FLAKE_TARGET=${2:-}

if [ -z "$ARCHIVE_URL" ]; then
  echo "USAGE: ${0} <ARCHIVE_URL> [<flake-target>]"
  exit 1
fi

DEST_REPO=$(mktemp -d)
DEST_ARCHIVE=$(mktemp)

UNPACK_CMD=""
case "${ARCHIVE_URL}" in
  *.tar.gz)
    UNPACK_CMD="tar xvzf $DEST_ARCHIVE" ;;
  *.tgz)
    UNPACK_CMD="tar xvzf $DEST_ARCHIVE" ;;
  *.tar)
    UNPACK_CMD="tar xvf $DEST_ARCHIVE" ;;
  *.tar.bz2)
    UNPACK_CMD="tar xvjf $DEST_ARCHIVE" ;;
  *.zip)
    UNPACK_CMD="unzip $DEST_ARCHIVE" ;;
  *)
    echo "Unrecognized archive format"
    exit 1 ;;
esac

# Prepare config snippet with username and password if provided
CURL_CONFIG=""
if [ ! -z "$CURL_USERNAME" ] && [ ! -z "$CURL_PASSWORD" ]; then
  echo "Username and password provided"
  CURL_CONFIG="user = \"$CURL_USERNAME:$CURL_PASSWORD\""
fi

# Download archive
echo "Downloading: $ARCHIVE_URL"
curl --config - -D- --fail -o $DEST_ARCHIVE "${ARCHIVE_URL}" <<< $CURL_CONFIG
# Unpack the archive
cd $DEST_REPO
$UNPACK_CMD
# Create a repository with the contents
git init .
git config user.email "nix@example.com"
git config user.name "run-flake-archive"
git config push.autoSetupRemote true
git add .
git commit -m "import from ${ARCHIVE_URL}"

# run the default app from the downloaded flake
nix run .#${FLAKE_TARGET}
