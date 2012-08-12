openshift-diy-ruby193
=====================

The script will install **ruby 1.9.3**, **bundler** and **unicorn** including the action_hooks scripts to build, start and stop a rails application.

Setup
-----
1. create an app:

   ```bash
   rhc app create -a testruby193 -t diy-0.1
   ```
   
2. ssh to your openshift app

3. execute the following bash command:

   ```bash
   cd $OPENSHIFT_TMP_DIR && curl https://raw.github.com/zekus/openshift-diy-ruby193/master/setup.sh | sh
   ```

4. exit and clone the app following the openshift guideline