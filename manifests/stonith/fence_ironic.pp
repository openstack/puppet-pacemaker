# == Define: pacemaker::stonith::fence_ironic
#
# Module for managing Stonith for fence_ironic.
#
# WARNING: Generated by "rake generate_stonith", manual changes will
# be lost.
#
# === Parameters
#
# [*debug*]
#   Specify (stdin) or increment (command line) debug level
#
# [*auth_url*]
#   Keystone URL to authenticate against
#
# [*login*]
#   Keystone username to use for authentication
#
# [*password*]
#   Keystone password to use for authentication
#
# [*tenant_name*]
#   Keystone tenant name to use for authentication
#
# [*pcmk_host_map*]
#   A mapping of UUIDs to node names
#
# [*action*]
#   Fencing action (null, off, on, [reboot], status, list, monitor, metadata)
#
# [*timeout*]
#   Fencing timeout (in seconds; default=30)
#
# [*delay*]
#   Fencing delay (in seconds; default=0)
#
# [*domain*]
#   Virtual Machine (domain name) to fence (deprecated; use port)
#
#  [*interval*]
#   Interval between tries.
#
# [*ensure*]
#   The desired state of the resource.
#
# [*tries*]
#   The number of tries.
#
# [*try_sleep*]
#   Time to sleep between tries.
#
# [*pcmk_host_list*]
#   List of Pacemaker hosts.
#
# [*meta_attr*]
#   (optional) String of meta attributes
#   Defaults to undef
#
# === Dependencies
#  None
#
# === Authors
#
# Generated by rake generate_stonith task.
#
# === Copyright
#
# Copyright (C) 2016 Red Hat Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
define pacemaker::stonith::fence_ironic (
  $debug          = undef,
  $auth_url       = undef,
  $login          = undef,
  $password       = undef,
  $tenant_name    = undef,
  $pcmk_host_map  = undef,
  $action         = undef,
  $timeout        = undef,
  $delay          = undef,
  $domain         = undef,

  $meta_attr      = undef,
  $interval       = '60s',
  $ensure         = present,
  $pcmk_host_list = undef,

  $tries          = undef,
  $try_sleep      = undef,

) {
  $debug_chunk = $debug ? {
    undef   => '',
    default => "debug=\"${debug}\"",
  }
  $auth_url_chunk = $auth_url ? {
    undef   => '',
    default => "auth_url=\"${auth_url}\"",
  }
  $login_chunk = $login ? {
    undef   => '',
    default => "login=\"${login}\"",
  }
  $password_chunk = $password ? {
    undef   => '',
    default => "password=\"${password}\"",
  }
  $tenant_name_chunk = $tenant_name ? {
    undef   => '',
    default => "tenant_name=\"${tenant_name}\"",
  }
  $pcmk_host_map_chunk = $pcmk_host_map ? {
    undef   => '',
    default => "pcmk_host_map=\"${pcmk_host_map}\"",
  }
  $action_chunk = $action ? {
    undef   => '',
    default => "action=\"${action}\"",
  }
  $timeout_chunk = $timeout ? {
    undef   => '',
    default => "timeout=\"${timeout}\"",
  }
  $delay_chunk = $delay ? {
    undef   => '',
    default => "delay=\"${delay}\"",
  }
  $domain_chunk = $domain ? {
    undef   => '',
    default => "domain=\"${domain}\"",
  }

  $pcmk_host_value_chunk = $pcmk_host_list ? {
    undef   => '$(/usr/sbin/crm_node -n)',
    default => $pcmk_host_list,
  }

  $meta_attr_value_chunk = $meta_attr ? {
    undef   => '',
    default => "meta ${meta_attr}",
  }

  # $title can be a mac address, remove the colons for pcmk resource name
  $safe_title = regsubst($title, ':', '', 'G')

  Exec<| title == 'wait-for-settle' |> -> Pcmk_stonith<||>

  $param_string = "${debug_chunk} ${auth_url_chunk} ${login_chunk} ${password_chunk} ${tenant_name_chunk} ${pcmk_host_map_chunk} ${action_chunk} ${timeout_chunk} ${delay_chunk} ${domain_chunk}  op monitor interval=${interval} ${meta_attr_value_chunk}"


  pcmk_stonith { "stonith-fence_ironic-${safe_title}":
    ensure           => $ensure,
    stonith_type     => 'fence_ironic',
    pcmk_host_list   => $pcmk_host_value_chunk,
    pcs_param_string => $param_string,
    tries            => $tries,
    try_sleep        => $try_sleep,
  }
}
