#!/bin/bash

npm install zlib
npm install is-gzip

rm main.zip
zip -r main.zip *
