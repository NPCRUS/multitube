mkdir -p ./build
cp ./src/Assets/index.html ./build/
./node_modules/.bin/elm-live ./src/Main.elm --open --hot --dir=./build -- --output=./build/main.js
