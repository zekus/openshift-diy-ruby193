#!/bin/sh

cd $OPENSHIFT_TMP_DIR

### yaml
# get and compile
wget http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
tar xzf yaml-0.1.4.tar.gz
cd yaml-0.1.4
./configure --prefix=$OPENSHIFT_RUNTIME_DIR
make
make install
# clean up
cd $OPENSHIFT_TMP_DIR
rm -rf yaml*

### ruby
# get the source
wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz
tar xzf ruby-1.9.3-p194.tar.gz
# tell ruby about yaml.h and libyaml
cd ruby-1.9.3-p194/ext/psych
export C_INCLUDE_PATH=$OPENSHIFT_RUNTIME_DIR/include
export LIBYAMLPATH=$OPENSHIFT_RUNTIME_DIR/lib
sed -i '1i $LIBPATH << ENV["LIBYAMLPATH"]' extconf.rb
# compile
cd $OPENSHIFT_TMP_DIR/ruby-1.9.3-p194
./configure --disable-install-doc --prefix=$OPENSHIFT_RUNTIME_DIR
make
make install
# clean up
cd $OPENSHIFT_TMP_DIR
rm -rf ruby*

### export the bin directory
export PATH=$OPENSHIFT_RUNTIME_DIR/bin:$PATH
