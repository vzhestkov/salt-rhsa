# salt-rhsa
## SALT state and formula for recurrent highstate apply by a minion

**salt-rhsa** is a set of state and formula to make minion apply the highstate in recurrent manner.

### Installation

Put **salt/rhsa** directory content to the salt-master server. For example to /srv/salt/rhsa
The example file structure should be like this:
```
/srv/salt/rhsa/
/srv/salt/rhsa/init.sls
```

Put **formulas** directory content to the salt-master server. For example to /usr/share/susemanager/formulas/
The example file structure should be like this:
```
/usr/share/susemanager/formulas/metadata/frhsa
/usr/share/susemanager/formulas/metadata/frhsa/form.yml
/usr/share/susemanager/formulas/metadata/frhsa/metadata.yml
/usr/share/susemanager/formulas/states/frhsa
/usr/share/susemanager/formulas/states/frhsa/init.sls
```

Put the reactor to salt master configuration for the events *salt/minion/*/start* and *rhsa/run*.
The example configuration:
```
reactor:
  - 'salt/minion/*/start':
    - /srv/salt/rhsa/init.sls
  - 'rhsa/run':
    - /srv/salt/rhsa/init.sls

```

***WARNING: please note, that reactor for salt/minion/*/start could be already set, for example in SUSE Manager configuration
Use the following example as a reference for such case:***
```
reactor:
  - 'salt/minion/*/start':
    - /usr/share/susemanager/reactor/resume_action_chain.sls
    - /srv/salt/rhsa/init.sls
  - 'rhsa/run':
    - /srv/salt/rhsa/init.sls
```
