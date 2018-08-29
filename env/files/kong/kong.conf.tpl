# -----------------------
# Kong configuration file
# -----------------------
#
# The commented-out settings shown in this file represent the default values.
#
# This file is read when `kong start` or `kong compile` are used. Kong
# generates the Nginx configuration with the settings specified in this file.
#
# All environment variables prefixed with `KONG_` and capitalized will override
# the settings specified in this file.
# Example:
#   `log_level` setting -> `KONG_LOG_LEVEL` env variable
#
# Boolean values can be specified as `on`/`off` or `true`/`false`.
# Lists must be specified as comma-separated strings.
#
# All comments in this file can be removed safely, including the
# commented-out properties.
# You can verify the integrity of your settings with `kong check <conf>`.

#------------------------------------------------------------------------------
# GENERAL
#------------------------------------------------------------------------------

#prefix = /usr/local/kong/       # Working directory. Equivalent to Nginx's
                                 # prefix path, containing temporary files
                                 # and logs.
                                 # Each Kong process must have a separate
                                 # working directory.

#log_level = notice              # Log level of the Nginx server. Logs are
                                 # found at <prefix>/logs/error.log
# Note: See http://nginx.org/en/docs/ngx_core_module.html#error_log for a list
# of accepted values.

#proxy_access_log = logs/access.log       # Path for proxy port request access
                                          # logs. Set this value to `off` to
                                          # disable logging proxy requests.
                                          # If this value is a relative path, it
                                          # will be placed under the `prefix`
                                          # location.

#proxy_error_log = logs/error.log         # Path for proxy port request error
                                          # logs. Granularity of these logs is
                                          # adjusted by the `log_level`
                                          # directive.

#admin_access_log = logs/admin_access.log # Path for Admin API request access
                                          # logs. Set this value to `off` to
                                          # disable logging Admin API requests.
                                          # If this value is a relative path, it
                                          # will be placed under the `prefix`
                                          # location.

#admin_error_log = logs/error.log         # Path for Admin API request error
                                          # logs. Granularity of these logs is
                                          # adjusted by the `log_level`
                                          # directive.

#custom_plugins =                # Comma-separated list of additional plugins
                                 # this node should load.
                                 # Use this property to load custom plugins
                                 # that are not bundled with Kong.
                                 # Plugins will be loaded from the
                                 # `kong.plugins.{name}.*` namespace.

#anonymous_reports = on          # Send anonymous usage data such as error
                                 # stack traces to help improve Kong.

#------------------------------------------------------------------------------
# NGINX
#------------------------------------------------------------------------------

proxy_listen = 0.0.0.0:80     # Address and port on which Kong will accept
                                 # HTTP requests.
                                 # This is the public-facing entrypoint of
                                 # Kong, to which your consumers will make
                                 # requests.
# Note: See http://nginx.org/en/docs/http/ngx_http_core_module.html#listen for
# a description of the accepted formats for this and other *_listen values.

#proxy_listen_ssl = 0.0.0.0:8443 # Address and port on which Kong will accept
                                 # HTTPS requests if `ssl` is enabled.

#admin_listen = 0.0.0.0:8001     # Address and port on which Kong will expose
                                 # an entrypoint to the Admin API.
                                 # This API lets you configure and manage Kong,
                                 # and should be kept private and secured.

#admin_listen_ssl = 0.0.0.0:8444 # Address and port on which Kong will accept
                                 # HTTPS requests to the admin API, if
                                 # `admin_ssl` is enabled.

#nginx_user = nobody nobody      # Defines user and group credentials used by
                                 # worker processes. If group is omitted, a
                                 # group whose name equals that of user is
                                 # used. Ex: [user] [group].

#nginx_worker_processes = auto   # Determines the number of worker processes
                                 # spawned by Nginx.

#nginx_daemon = on               # Determines wether Nginx will run as a daemon
                                 # or as a foreground process. Mainly useful
                                 # for development or when running Kong inside
                                 # a Docker environment.

#mem_cache_size = 128m           # Size of the in-memory cache for database
                                 # entities. The accepted units are `k` and
                                 # `m`, with a minimum recommended value of
                                 # a few MBs.

ssl = off                       # Determines if Nginx should be listening for
                                 # HTTPS traffic on the `proxy_listen_ssl`
                                 # address. If disabled, Nginx will only bind
                                 # itself on `proxy_listen`, and all SSL
                                 # settings will be ignored.

#ssl_cipher_suite = modern       # Defines the TLS ciphers served by Nginx.
                                 # Accepted values are `modern`, `intermediate`,
                                 # `old`, or `custom`.
# Note: See https://wiki.mozilla.org/Security/Server_Side_TLS for detailed
# descriptions of each cipher suite.

#ssl_ciphers =                   # Defines a custom list of TLS ciphers to be
                                 # served by Nginx. This list must conform to
                                 # the pattern defined by `openssl ciphers`.
                                 # This value is ignored if `ssl_cipher_suite`
                                 # is not `custom`.

#ssl_cert =                      # If `ssl` is enabled, the absolute path to
                                 # the SSL certificate for the
                                 # `proxy_listen_ssl` address.

#ssl_cert_key =                  # If `ssl` is enabled, the absolute path to
                                 # the SSL key for the `proxy_listen_ssl`
                                 # address.

#http2 = off                     # Enables HTTP2 support for HTTPS traffic on
                                 # the `proxy_listen_ssl` address.

#client_ssl = off                # Determines if Nginx should send client-side
                                 # SSL certificates when proxying requests.

#client_ssl_cert =               # If `client_ssl` is enabled, the absolute path
                                 # to the client SSL certificate for the
                                 # `proxy_ssl_certificate` directive. Note that
                                 # this value is statically defined on the node,
                                 # and currently cannot be configured on a
                                 # per-API basis.

#client_ssl_cert_key =           # If `client_ssl` is enabled, the absolute path
                                 # to the client SSL key for the
                                 # `proxy_ssl_certificate_key` address. Note
                                 # this value is statically defined on the node,
                                 # and currently cannot be configured on a
                                 # per-API basis.

admin_ssl = off                 # Determines if Nginx should be listening for
                                 # HTTPS traffic on the `admin_listen_ssl`
                                 # address. If disabled, Nginx will only bind
                                 # itself on `admin_listen`, and all SSL
                                 # settings will be ignored.

#admin_ssl_cert =                # If `admin_ssl` is enabled, the absolute path
                                 # to the SSL certificate for the
                                 # `admin_listen_ssl` address.

#admin_ssl_cert_key =            # If `admin_ssl` is enabled, the absolute path
                                 # to the SSL key for the `admin_listen_ssl`
                                 # address.

#admin_http2 = off               # Enables HTTP2 support for HTTPS traffic on
                                 # the `admin_listen_ssl` address.

#upstream_keepalive = 60         # Sets the maximum number of idle keepalive
                                 # connections to upstream servers that are
                                 # preserved in the cache of each worker
                                 # process. When this number is exceeded, the
                                 # least recently used connections are closed.

server_tokens = off              # Enables or disables emitting Kong version on
                                 # error pages and in the "Server" or "Via"
                                 # (in case the request was proxied) response
                                 # header field.

#latency_tokens = on             # Enables or disables emitting Kong latency
                                 # information in the "X-Kong-Proxy-Latency"
                                 # and "X-Kong-Upstream-Latency" response
                                 # header fields.

#trusted_ips =                   # Defines trusted IP addresses blocks that are
                                 # known to send correct X-Forwarded-* headers.
                                 # Requests from trusted IPs make Kong forward
                                 # their X-Forwarded-* headers upstream.
                                 # Non-trusted requests make Kong insert its
                                 # own X-Forwarded-* headers.
                                 #
                                 # This property also sets the `set_real_ip_from`
                                 # directive(s) in the Nginx configuration. It
                                 # accepts the same type of values (CIDR blocks)
                                 # but as a comma-separated list.
                                 #
                                 # To trust *all* /!\ IPs, set this value to
                                 # `0.0.0.0/0,::/0`.
                                 #
                                 # If the special value `unix:` is specified,
                                 # all UNIX-domain sockets will be trusted.
# Note:
#
# See http://nginx.org/en/docs/http/ngx_http_realip_module.html for
# examples of accepted values.

#real_ip_header = X-Real-IP      # Defines the request header field whose value
                                 # will be used to replace the client address.
                                 # This value sets the ngx_http_realip_module
                                 # directive of the same name in the Nginx
                                 # configuration.
                                 #
                                 # If this value receives `proxy_protocol`, the
                                 # `proxy_protocol` parameter will be appended
                                 # to the `listen` directive of the Nginx
                                 # template.
# Note:
#
# See http://nginx.org/en/docs/http/ngx_http_realip_module.html#real_ip_header
# for a description of this directive.
#
# See https://www.nginx.com/resources/admin-guide/proxy-protocol/ for more
# details about the `proxy_protocol` parameter.

#real_ip_recursive = off         # This value sets the ngx_http_realip_module
                                 # directive of the same name in the Nginx
                                 # configuration.
# Note:
#
# See http://nginx.org/en/docs/http/ngx_http_realip_module.html#real_ip_recursive
# for a description of this directive.

#client_max_body_size = 0        # Defines the maximum request body size allowed
                                 # by requests proxied by Kong, specified in the
                                 # Content-Length request header. If a request
                                 # exceeds this limit, Kong will respond with a
                                 # 413 (Request Entity Too Large). Setting this
                                 # value to 0 disables checking the request body
                                 # size.
# Note: See
# http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size
# for further description of this parameter. Numeric values may be suffixed with
# 'k' or 'm' to denote limits in terms of kilobytes or megabytes.

#client_body_buffer_size = 8k    # Defines the buffer size for reading the
                                 # request body. If the client request body is
                                 # larger than this value, the body will be
                                 # buffered to disk. Note that when the body is
                                 # buffered to disk Kong plugins that access or
                                 # manipulate the request body may not work, so
                                 # it is advisable to set this value as high as
                                 # possible (e.g., set it as high as
                                 # `client_max_body_size` to force request
                                 # bodies to be kept in memory). Do note that
                                 # high-concurrency environments will require
                                 # significant memory allocations to process
                                 # many concurrent large request bodies.
# Note: See
# http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_buffer_size
# for further description of this parameter. Numeric values may be suffixed with
# 'k' or 'm' to denote limits in terms of kilobytes or megabytes.

#error_default_type = text/plain  # Default MIME type to use when the request
                                  # `Accept` header is missing and Nginx
                                  # is returning an error for the request.
                                  # Accepted values are `text/plain`,
                                  # `text/html`, `application/json`, and
                                  # `application/xml`.

#------------------------------------------------------------------------------
# DATASTORE
#------------------------------------------------------------------------------

# Kong will store all of its data (such as APIs, consumers and plugins) in
# either Cassandra or PostgreSQL.
#
# All Kong nodes belonging to the same cluster must connect themselves to the
# same database.

database = postgres             # Determines which of PostgreSQL or Cassandra
                                 # this node will use as its datastore.
                                 # Accepted values are `postgres` and
                                 # `cassandra`.

pg_host = ${DB_HOST}
pg_port = ${DB_PORT}            # The port to connect to.
pg_user = kong                  # The username to authenticate if required.
pg_password = ${DB_PASSWORD}    # The password to authenticate if required.
pg_database = kong              # The database name to connect to.

#pg_ssl = off                    # Toggles client-server TLS connections
                                 # between Kong and PostgreSQL.

#pg_ssl_verify = off             # Toggles server certificate verification if
                                 # `pg_ssl` is enabled.
                                 # See the `lua_ssl_trusted_certificate`
                                 # setting to specify a certificate authority.

#cassandra_contact_points = 127.0.0.1  # A comma-separated list of contact
                                       # points to your cluster.

#cassandra_port = 9042           # The port on which your nodes are listening
                                 # on. All your nodes and contact points must
                                 # listen on the same port.

#cassandra_keyspace = kong       # The keyspace to use in your cluster.

#cassandra_timeout = 5000        # Defines the timeout (in ms), for reading
                                 # and writing.

#cassandra_ssl = off             # Toggles client-to-node TLS connections
                                 # between Kong and Cassandra.

#cassandra_ssl_verify = off      # Toggles server certificate verification if
                                 # `cassandra_ssl` is enabled.
                                 # See the `lua_ssl_trusted_certificate`
                                 # setting to specify a certificate authority.

#cassandra_username = kong       # Username when using the
                                 # `PasswordAuthenticator` scheme.

#cassandra_password =            # Password when using the
                                 # `PasswordAuthenticator` scheme.

#cassandra_consistency = ONE     # Consistency setting to use when reading/
                                 # writing to the Cassandra cluster.

#cassandra_lb_policy = RoundRobin  # Load balancing policy to use when
                                   # distributing queries across your Cassandra
                                   # cluster.
                                   # Accepted values are `RoundRobin` and
                                   # `DCAwareRoundRobin`.
                                   # Prefer the later if and only if you are
                                   # using a multi-datacenter cluster.

#cassandra_local_datacenter =    # When using the `DCAwareRoundRobin` load
                                 # balancing policy, you must specify the name
                                 # of the local (closest) datacenter for this
                                 # Kong node.

#cassandra_repl_strategy = SimpleStrategy  # When migrating for the first time,
                                           # Kong will use this setting to
                                           # create your keyspace.
                                           # Accepted values are
                                           # `SimpleStrategy` and
                                           # `NetworkTopologyStrategy`.

#cassandra_repl_factor = 1       # When migrating for the first time, Kong
                                 # will create the keyspace with this
                                 # replication factor when using the
                                 # `SimpleStrategy`.

#cassandra_data_centers = dc1:2,dc2:3  # When migrating for the first time,
                                       # will use this setting when using the
                                       # `NetworkTopologyStrategy`.
                                       # The format is a comma-separated list
                                       # made of <dc_name>:<repl_factor>.

#cassandra_schema_consensus_timeout = 10000  # Defines the timeout (in ms) for
                                             # the waiting period to reach a
                                             # schema consensus between your
                                             # Cassandra nodes.
                                             # This value is only used during
                                             # migrations.

#------------------------------------------------------------------------------
# DATASTORE CACHE
#------------------------------------------------------------------------------

# In order to avoid unecessary communication with the datastore, Kong caches
# entities (such as APIs, Consumers, Credentials...) for a configurable period
# of time. It also handles invalidations if such an entity is updated.
#
# This section allows for configuring the behavior of Kong regarding the
# caching of such configuration entities.

#db_update_frequency = 5         # Frequency (in seconds) at which to check for
                                 # updated entities with the datastore.
                                 # When a node creates, updates, or deletes an
                                 # entity via the Admin API, other nodes need
                                 # to wait for the next poll (configured by
                                 # this value) to eventually purge the old
                                 # cached entity and start using the new one.

#db_update_propagation = 0       # Time (in seconds) taken for an entity in the
                                 # datastore to be propagated to replica nodes
                                 # of another datacenter.
                                 # When in a distributed environment such as
                                 # a multi-datacenter Cassandra cluster, this
                                 # value should be the maximum number of
                                 # seconds taken by Cassandra to propagate a
                                 # row to other datacenters.
                                 # When set, this property will increase the
                                 # time taken by Kong to propagate the change
                                 # of an entity.
                                 # Single-datacenter setups or PostgreSQL
                                 # servers should suffer no such delays, and
                                 # this value can be safely set to 0.

#db_cache_ttl = 3600             # Time-to-live (in seconds) of an entity from
                                 # the datastore when cached by this node.
                                 # Database misses (no entity) are also cached
                                 # according to this setting.
                                 # If set to 0, such cached entities/misses
                                 # never expire.

#------------------------------------------------------------------------------
# DNS RESOLVER
#------------------------------------------------------------------------------

# By default the DNS resolver will use the standard configuration files
# `/etc/hosts` and `/etc/resolv.conf`. The settings in the latter file will be
# overridden by the environment variables `LOCALDOMAIN` and `RES_OPTIONS` if
# they have been set.

#dns_resolver =                  # Comma separated list of nameservers, each
                                 # entry in `ip[:port]` format to be used by
                                 # Kong. If not specified the nameservers in
                                 # the local `resolv.conf` file will be used.
                                 # Port defaults to 53 if omitted. Accepts
                                 # both IPv4 and IPv6 addresses.

#dns_hostsfile = /etc/hosts      # The hosts file to use. This file is read
                                 # once and its content is static in memory.
                                 # To read the file again after modifying it,
                                 # Kong must be reloaded.

#dns_order = LAST,SRV,A,CNAME    # The order in which to resolve different
                                 # record types. The `LAST` type means the
                                 # type of the last successful lookup (for the
                                 # specified name). The format is a (case
                                 # insensitive) comma separated list.

#dns_stale_ttl = 4               # Defines, in seconds, how long a record will
                                 # remain in cache past its TTL. This value
                                 # will be used while the new DNS record is
                                 # fetched in the background.
                                 # Stale data will be used from expiry of a
                                 # record until either the refresh query
                                 # completes, or the `dns_stale_ttl` number of
                                 # seconds have passed.

#dns_not_found_ttl = 30          # TTL in seconds for empty DNS responses and
                                 # "(3) name error" responses.

#dns_error_ttl = 1               # TTL in seconds for error responses.

#dns_no_sync = off               # If enabled, then upon a cache-miss every
                                 # request will trigger its own dns query.
                                 # When disabled multiple requests for the
                                 # same name/type will be synchronised to a
                                 # single query.

#------------------------------------------------------------------------------
# DEVELOPMENT & MISCELLANEOUS
#------------------------------------------------------------------------------

# Additional settings inherited from lua-nginx-module allowing for more
# flexibility and advanced usage.
#
# See the lua-nginx-module documentation for more informations:
# https://github.com/openresty/lua-nginx-module

#lua_ssl_trusted_certificate =   # Absolute path to the certificate
                                 # authority file for Lua cosockets in PEM
                                 # format. This certificate will be the one
                                 # used for verifying Kong's database
                                 # connections, when `pg_ssl_verify` or
                                 # `cassandra_ssl_verify` are enabled.

#lua_ssl_verify_depth = 1        # Sets the verification depth in the server
                                 # certificates chain used by Lua cosockets,
                                 # set by `lua_ssl_trusted_certificate`.
                                 # This includes the certificates configured
                                 # for Kong's database connections.

#lua_package_path =              # Sets the Lua module search path (LUA_PATH).
                                 # Useful when developing or using custom
                                 # plugins not stored in the default search
                                 # path.

#lua_package_cpath =             # Sets the Lua C module search path
                                 # (LUA_CPATH).

#lua_socket_pool_size = 30       # Specifies the size limit for every cosocket
                                 # connection pool associated with every remote
                                 # server