mkdir -p ./build
cp -a ./assets/. ./build/
./node_modules/.bin/elm-live ./src/Main.elm --open --hot --dir=./build -- --output=./build/main.js
