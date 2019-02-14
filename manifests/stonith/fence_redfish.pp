# == Define: pacemaker::stonith::fence_redfish
#
# Module for managing Stonith for fence_redfish.
#
# WARNING: Generated by "rake generate_stonith", manual changes will
# be lost.
#
# === Parameters
#
# [*action*]
#   Fencing action
#
# [*inet4_only*]
#   Forces agent to use IPv4 addresses only
#
# [*inet6_only*]
#   Forces agent to use IPv6 addresses only
#
# [*ip*]
#   IP address or hostname of fencing device
#
# [*ipaddr*]
#   IP address or hostname of fencing device
#
# [*ipport*]
#   TCP/UDP port to use for connection with device
#
# [*login*]
#   Login name
#
# [*passwd*]
#   Login password or passphrase
#
# [*passwd_script*]
#   Script to run to retrieve password
#
# [*password*]
#   Login password or passphrase
#
# [*password_script*]
#   Script to run to retrieve password
#
# [*plug*]
#   IP address or hostname of fencing device (together with --port-as-ip)
#
# [*port*]
#   IP address or hostname of fencing device (together with --port-as-ip)
#
# [*redfish_uri*]
#   Base or starting Redfish URI
#
# [*ssl*]
#   Use SSL connection with verifying certificate
#
# [*ssl_insecure*]
#   Use SSL connection without verifying certificate
#
# [*ssl_secure*]
#   Use SSL connection with verifying certificate
#
# [*systems_uri*]
#   Redfish Systems resource URI, i.e. /redfish/v1/Systems/System.Embedded.1
#
# [*username*]
#   Login name
#
# [*quiet*]
#   Disable logging to stderr. Does not affect --verbose or --debug-file or logging to syslog.
#
# [*verbose*]
#   Verbose mode
#
# [*debug*]
#   Write debug information to given file
#
# [*debug_file*]
#   Write debug information to given file
#
# [*delay*]
#   Wait X seconds before fencing is started
#
# [*login_timeout*]
#   Wait X seconds for cmd prompt after login
#
# [*port_as_ip*]
#   Make "port/plug" to be an alias to IP address
#
# [*power_timeout*]
#   Test X seconds for status change after ON/OFF
#
# [*power_wait*]
#   Wait X seconds after issuing ON/OFF
#
# [*shell_timeout*]
#   Wait X seconds for cmd prompt after issuing command
#
# [*retry_on*]
#   Count of attempts to retry power on
#
# [*gnutlscli_path*]
#   Path to gnutls-cli binary
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
define pacemaker::stonith::fence_redfish (
  $action          = undef,
  $inet4_only      = undef,
  $inet6_only      = undef,
  $ip              = undef,
  $ipaddr          = undef,
  $ipport          = undef,
  $login           = undef,
  $passwd          = undef,
  $passwd_script   = undef,
  $password        = undef,
  $password_script = undef,
  $plug            = undef,
  $port            = undef,
  $redfish_uri     = undef,
  $ssl             = undef,
  $ssl_insecure    = undef,
  $ssl_secure      = undef,
  $systems_uri     = undef,
  $username        = undef,
  $quiet           = undef,
  $verbose         = undef,
  $debug           = undef,
  $debug_file      = undef,
  $delay           = undef,
  $login_timeout   = undef,
  $port_as_ip      = undef,
  $power_timeout   = undef,
  $power_wait      = undef,
  $shell_timeout   = undef,
  $retry_on        = undef,
  $gnutlscli_path  = undef,

  $meta_attr       = undef,
  $interval        = '60s',
  $ensure          = present,
  $pcmk_host_list  = undef,

  $tries           = undef,
  $try_sleep       = undef,

) {
  $action_chunk = $action ? {
    undef   => '',
    default => "action=\"${action}\"",
  }
  $inet4_only_chunk = $inet4_only ? {
    undef   => '',
    default => "inet4_only=\"${inet4_only}\"",
  }
  $inet6_only_chunk = $inet6_only ? {
    undef   => '',
    default => "inet6_only=\"${inet6_only}\"",
  }
  $ip_chunk = $ip ? {
    undef   => '',
    default => "ip=\"${ip}\"",
  }
  $ipaddr_chunk = $ipaddr ? {
    undef   => '',
    default => "ipaddr=\"${ipaddr}\"",
  }
  $ipport_chunk = $ipport ? {
    undef   => '',
    default => "ipport=\"${ipport}\"",
  }
  $login_chunk = $login ? {
    undef   => '',
    default => "login=\"${login}\"",
  }
  $passwd_chunk = $passwd ? {
    undef   => '',
    default => "passwd=\"${passwd}\"",
  }
  $passwd_script_chunk = $passwd_script ? {
    undef   => '',
    default => "passwd_script=\"${passwd_script}\"",
  }
  $password_chunk = $password ? {
    undef   => '',
    default => "password=\"${password}\"",
  }
  $password_script_chunk = $password_script ? {
    undef   => '',
    default => "password_script=\"${password_script}\"",
  }
  $plug_chunk = $plug ? {
    undef   => '',
    default => "plug=\"${plug}\"",
  }
  $port_chunk = $port ? {
    undef   => '',
    default => "port=\"${port}\"",
  }
  # Manual workaround s/_/-/ needed due to https://bugzilla.redhat.com/show_bug.cgi?id=1677020
  $redfish_uri_chunk = $redfish_uri ? {
    undef   => '',
    default => "redfish-uri=\"${redfish_uri}\"",
  }
  $ssl_chunk = $ssl ? {
    undef   => '',
    default => "ssl=\"${ssl}\"",
  }
  $ssl_insecure_chunk = $ssl_insecure ? {
    undef   => '',
    default => "ssl_insecure=\"${ssl_insecure}\"",
  }
  $ssl_secure_chunk = $ssl_secure ? {
    undef   => '',
    default => "ssl_secure=\"${ssl_secure}\"",
  }
  # Manual workaround s/_/-/ needed due to https://bugzilla.redhat.com/show_bug.cgi?id=1677020
  $systems_uri_chunk = $systems_uri ? {
    undef   => '',
    default => "systems-uri=\"${systems_uri}\"",
  }
  $username_chunk = $username ? {
    undef   => '',
    default => "username=\"${username}\"",
  }
  $quiet_chunk = $quiet ? {
    undef   => '',
    default => "quiet=\"${quiet}\"",
  }
  $verbose_chunk = $verbose ? {
    undef   => '',
    default => "verbose=\"${verbose}\"",
  }
  $debug_chunk = $debug ? {
    undef   => '',
    default => "debug=\"${debug}\"",
  }
  $debug_file_chunk = $debug_file ? {
    undef   => '',
    default => "debug_file=\"${debug_file}\"",
  }
  $delay_chunk = $delay ? {
    undef   => '',
    default => "delay=\"${delay}\"",
  }
  $login_timeout_chunk = $login_timeout ? {
    undef   => '',
    default => "login_timeout=\"${login_timeout}\"",
  }
  $port_as_ip_chunk = $port_as_ip ? {
    undef   => '',
    default => "port_as_ip=\"${port_as_ip}\"",
  }
  $power_timeout_chunk = $power_timeout ? {
    undef   => '',
    default => "power_timeout=\"${power_timeout}\"",
  }
  $power_wait_chunk = $power_wait ? {
    undef   => '',
    default => "power_wait=\"${power_wait}\"",
  }
  $shell_timeout_chunk = $shell_timeout ? {
    undef   => '',
    default => "shell_timeout=\"${shell_timeout}\"",
  }
  $retry_on_chunk = $retry_on ? {
    undef   => '',
    default => "retry_on=\"${retry_on}\"",
  }
  $gnutlscli_path_chunk = $gnutlscli_path ? {
    undef   => '',
    default => "gnutlscli_path=\"${gnutlscli_path}\"",
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

  $param_string = "${action_chunk} ${inet4_only_chunk} ${inet6_only_chunk} ${ip_chunk} ${ipaddr_chunk} ${ipport_chunk} ${login_chunk} ${passwd_chunk} ${passwd_script_chunk} ${password_chunk} ${password_script_chunk} ${plug_chunk} ${port_chunk} ${redfish_uri_chunk} ${ssl_chunk} ${ssl_insecure_chunk} ${ssl_secure_chunk} ${systems_uri_chunk} ${username_chunk} ${quiet_chunk} ${verbose_chunk} ${debug_chunk} ${debug_file_chunk} ${delay_chunk} ${login_timeout_chunk} ${port_as_ip_chunk} ${power_timeout_chunk} ${power_wait_chunk} ${shell_timeout_chunk} ${retry_on_chunk} ${gnutlscli_path_chunk}  op monitor interval=${interval} ${meta_attr_value_chunk}"

  if $ensure != 'absent' {
    ensure_resource('package', 'fence-agents-redfish', { ensure => 'installed' })
    Package['fence-agents-redfish'] -> Pcmk_stonith["stonith-fence_redfish-${safe_title}"]
  }
  pcmk_stonith { "stonith-fence_redfish-${safe_title}":
    ensure           => $ensure,
    stonith_type     => 'fence_redfish',
    pcmk_host_list   => $pcmk_host_value_chunk,
    pcs_param_string => $param_string,
    tries            => $tries,
    try_sleep        => $try_sleep,
  }
}
