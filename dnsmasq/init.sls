# Include :download:`map file <map.jinja>` of OS-specific package names and
# file paths. Values can be overridden using Pillar.
{%- from "dnsmasq/map.jinja" import dnsmasq with context %}

dnsmasq_conf:
  file.managed:
    - name: {{ dnsmasq.dnsmasq_conf }}
    - source: salt://dnsmasq/files/dnsmasq.conf
    - user: root
    - group: {{ dnsmasq.group }}
    - mode: "0644"
    - template: jinja
    - require:
      - pkg: dnsmasq
    - context:
        addn_hosts: {{ dnsmasq.dnsmasq_hosts }}

dnsmasq_conf_dir:
  file.recurse:
    - name: {{ dnsmasq.dnsmasq_conf_dir }}
    - source: salt://dnsmasq/files/dnsmasq.d
    - template: jinja
    - require:
      - pkg: dnsmasq

dnsmasq_hosts:
  file.managed:
    - name: {{ dnsmasq.dnsmasq_hosts }}
    - source: salt://dnsmasq/files/dnsmasq.hosts
    - user: root
    - group: {{ dnsmasq.group }}
    - mode: "0644"
    - template: jinja
    - require:
      - pkg: dnsmasq
    - watch_in:
      - service: dnsmasq

dnsmasq_cnames:
  file.managed:
    - name: {{ dnsmasq.dnsmasq_cnames }}
    - source: salt://dnsmasq/files/dnsmasq.cnames
    - user: root
    - group: {{ dnsmasq.group }}
    - mode: "0644"
    - template: jinja
    - require:
      - pkg: dnsmasq
    - watch_in:
      - service: dnsmasq

dnsmasq_addresses:
  file.managed:
    - name: {{ dnsmasq.dnsmasq_addresses }}
    - source: salt://dnsmasq/files/dnsmasq.addresses
    - user: root
    - group: {{ dnsmasq.group }}
    - mode: "0644"
    - template: jinja
    - require:
      - pkg: dnsmasq
    - watch_in:
      - service: dnsmasq

dnsmasq_systemd_config:
  file.managed:
  - name: /usr/lib/systemd/system/dnsmasq.service
  - source: salt://dnsmasq/files/dnsmasq.service
  - user: root
  - group: {{ dnsmasq.group }}
  - mode: "0644"
  - template: jinja
  - require:
    - pkg: dnsmasq
  - watch_in:
    - service: dnsmasq_systemd_config

dnsmasq_systemd_reload:
  cmd.run:
   - name: systemctl --system daemon-reload
   - onchanges:
     - file: dnsmasq_systemd_config


{% if dnsmasq.upstreams != [] %}
dnsmasq_upstream:
  file.managed:
    - name: {{ dnsmasq.dnsmasq_upstream }}
    - source: salt://dnsmasq/files/dnsmasq.upstreams
    - user: root
    - group: {{ dnsmasq.group }}
    - mode: "0644"
    - template: jinja
    - require:
      - pkg: dnsmasq
    - watch_in:
      - service: dnsmasq
{% endif %}

dnsmasq:
  pkg.installed: []
  service.running:
    - name: {{ dnsmasq.service }}
    - enable: True
    - require:
      - pkg: dnsmasq
    - watch:
      - file: dnsmasq_conf
      - file: dnsmasq_conf_dir
