{%- if data is defined and 'id' in data %}
apply_rhsa_state:
  local.state.apply:
    - tgt: {{ data['id'] }}
      arg:
      - rhsa
      kwarg:
        queue: True
        pillar:
          rhsa:
            {%- if data['tag'] == 'rhsa/run' %}
            run: next
            {%- else %}
            run: init
            {%- endif %}
{%- else %}
  {%- set rhsa_enabled = salt['pillar.get']('rhsa:enabled', False) %}
  {%- if rhsa_enabled %}
    {%- set run = salt['pillar.get']('rhsa:run', 'apply') %}
    {%- set job_req = true %}
    {%- if run == 'next' %}
apply_highstate:
  module.run:
    - name: state.highstate
      kwarg:
        queue: True
    {%- elif run != 'init' %}
      {%- set job_req = not salt['schedule.is_enabled']('job_rhsa').enabled | default(false, true) %}
    {%- endif %}
    {%- if job_req %}
job_rhsa:
  schedule.present:
    - enabled: True
      function: event.send
    {%- set job_delay = salt['pillar.get']('rhsa:next_delay', 10800) %}
    {%- set delay_drift = salt['pillar.get']('rhsa:next_delay_drift', 3600) %}
    {%- if delay_drift > 0 %}{%- set job_delay = range(job_delay, job_delay+delay_drift) | random %}{%- endif %}
    {%- if run == 'init' %}
      {%- set job_delay = salt['pillar.get']('rhsa:init_delay', 240) %}
      {%- set max_delay = salt['pillar.get']('rhsa:init_delay_drift', 3600) %}
      {%- if delay_drift > 0 %}{%- set job_delay = range(job_delay, job_delay+delay_drift) | random %}{%- endif %}
    {%- endif %}
      seconds: {{ job_delay }}
      job_args:
      - rhsa/run
    {%- else %}
rhsa_nop:
  test.nop
    {%- endif %}
  {%- else %}
job_rhsa:
  schedule.absent: []
  {%- endif %}
{%- endif %}
