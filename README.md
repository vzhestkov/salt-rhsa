# salt-rhsa
## SALT state and formula for recurrent highstate apply by a minion

**salt-rhsa** is a set of state and formula to make minion apply the highstate in recurrent manner.

## Objectives

This approach should be very helpful in case of large scaled deployment with the minions have no permanent availability online.
The random drift time of applying highstate should improve performance in large scales environments.

## Installation

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

Put the reactor to salt master configuration for the events `salt/minion/*/start` and `rhsa/run`.
The example configuration:
```
reactor:
  - 'salt/minion/*/start':
    - /srv/salt/rhsa/init.sls
  - 'rhsa/run':
    - /srv/salt/rhsa/init.sls
```

***WARNING: please note, that reactor for `salt/minion/*/start` could be already set, for example in SUSE Manager configuration
Use the following example as a reference for such case:***
```
reactor:
  - 'salt/minion/*/start':
    - /usr/share/susemanager/reactor/resume_action_chain.sls
    - /srv/salt/rhsa/init.sls
  - 'rhsa/run':
    - /srv/salt/rhsa/init.sls
```

## Configuration

The state can be applied with top.sls or using salt formulas applied to systems group or an individual minion.
Pillar data is used for state configuration:
```
rhsa:
    enabled:
        True
    init_delay:
        240
    init_delay_drift:
        3600
    next_delay:
        10800
    next_delay_drift:
        3600
```
The configuration can be applied with forms and formulas also.
Attach formula to a group or a system:
### Formulas
![](https://github.com/vzhestkov/salt-rhsa/raw/master/screenshots/formulas.png)

### Configuring formula
![](https://github.com/vzhestkov/salt-rhsa/raw/master/screenshots/formula-config.png)

### Configuration variables
*enabled* - turns the state ON or OFF. If set to ON, the highstate will be applied according the time configured.

*init_delay* - sets the initial delay on starting minion event. The value defines the delay after start the highstate will be applied for the first time.
This time of the delay is also depends on *init_delay_drift*.

*init_delay_drift* - sets the maximum time in seconds of random addition to the *init_delay_time*

*next_delay* - sets the delay for the each next highstate apply. The value defines the delay to the next highstate apply.
This time of the delay is also depends on *next_delay_drift*.

*next_delay_drift* - sets the maximum time in seconds of random addition to the *next_delay_time*

In general it means that the highstate will be applied in `init_delay+random(init_delay_drift)` after minion starts.
The next highstate apply will be scheduled after `next_delay+random(next_delay_drift)` seconds.
***WARNING: Please refrain of using low init_delay and next_delay values. Such configuration values are your own risk and could influence on whole of the environment.***
