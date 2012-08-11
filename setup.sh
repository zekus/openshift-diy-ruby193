#!/bin/sh

OPENSHIFT_ACTION_HOOKS_DIR=$OPENSHIFT_REPO_DIR/.openshift/action_hooks
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
cd $OPENSHIFT_REPO_DIR

### bundler
gem install bundler
# setup the pre-build script
echo > $OPENSHIFT_ACTION_HOOKS_DIR/pre-build
$OPENSHIFT_ACTION_HOOKS_DIR/pre-build << 'EOF'
data="${OPENSHIFT_DATA_DIR}/assets"
assets="${OPENSHIFT_REPO_DIR}/public"
# Make the data directory if it doesn't exist
if [ ! -d "$data" ]; then
  mkdir $data;
fi
# Remove the assets directory if it's empty
find $assets/assets -maxdepth 0 -type d -empty -delete 2> /dev/null
# Try to make the symlink
ln -s $data $assets 2> /dev/null
if [ $? -gt 0 ]; then
  echo "Unable to create symlink to assets directory, using existing directory in repository"
fi
EOF
# setup the build script
echo > $OPENSHIFT_ACTION_HOOKS_DIR/build
$OPENSHIFT_ACTION_HOOKS_DIR/build << 'EOF'
pushd ${OPENSHIFT_REPO_DIR} > /dev/null
bundle install --deployment
popd > /dev/null
EOF
# setup the deploy script
echo > $OPENSHIFT_ACTION_HOOKS_DIR/deploy
$OPENSHIFT_ACTION_HOOKS_DIR/deploy << 'EOF'
pushd ${OPENSHIFT_REPO_DIR} > /dev/null
# Run db:migrate
#bundle exec rake db:migrate RAILS_ENV="production"
# Precompile the assets
bundle exec rake assets:precompile RAILS_ENV="production"
popd > /dev/null
EOF

### unicorn
gem install unicorn
# setup the start script
echo > $OPENSHIFT_ACTION_HOOKS_DIR/start
$OPENSHIFT_ACTION_HOOKS_DIR/start << 'EOF'
#!/bin/bash
export PATH=$OPENSHIFT_RUNTIME_DIR/bin:$PATH
unicorn -l $OPENSHIFT_INTERNAL_IP:$OPENSHIFT_INTERNAL_PORT -E "production" -D
EOF
# setup the stop script
echo > $OPENSHIFT_ACTION_HOOKS_DIR/stop
$OPENSHIFT_ACTION_HOOKS_DIR/stop << 'EOF'
#!/bin/bash
export PATH=$OPENSHIFT_RUNTIME_DIR/bin:$PATH
kill -s QUIT `ps -ef | grep "unicorn master" | grep -v grep | awk "{ print $2 }"`
EOF
