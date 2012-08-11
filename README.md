openshift-diy-ruby193
=====================

The script will install ruby 1.9.3, bundler and unicorn including the action_hooks scripts to build, start and stop a rails application.

To setup just ssh to your openshift app and execute the following bash command:

```bash
cd $OPENSHIFT_TMP_DIR && curl https://raw.github.com/zekus/openshift-diy-ruby193/master/setup.sh | sh
```
