fuser -k -n tcp 8080
dart2js web/client.dart -o web/client.dart.js
dart web/webapp/main.dart &
echo "Done."

