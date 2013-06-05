#!/bin/bash

set -e

cd build/
rm -rf build/
mkdir build/
cd build/

wget --no-check-certificate -O - $1 | tar --strip-components=1 -xvzf -

npm install .

rm -rf build
cp -R public pre_build_public
cp -RL public build_public
rm -rf public
mv build_public public
echo 'Building application...'
hem build
mv public build
mv pre_build_public public

timestamp=`date -u +%Y-%m-%d_%H-%M-%S`

echo 'Compressing...'

mv build/application.js "build/application-$timestamp.js"

mv build/application.css "build/application-$timestamp.css"
gzip -9 -c "build/application-$timestamp.js" > "build/application-$timestamp.js.gz"
gzip -9 -c "build/application-$timestamp.css" > "build/application-$timestamp.css.gz"

mv build/index.html build/index.old.html
sed "s/application\.\([a-z]*\)/application-$timestamp.\1/g" <build/index.old.html > build/index.html
rm build/index.old.html
echo 'build successful!'

echo "Uploading to S3..."
s3cmd put -c /build/s3cfg --acl-public --mime-type="text/css" "build/application-$timestamp.css" "s3://$2"
rm "build/application-$timestamp.css"
s3cmd put -c /build/s3cfg --recursive --acl-public --guess-mime-type build/ "s3://$2"