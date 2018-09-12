#
# CKAN - Pylons configuration
#
# These are some of the configuration options available for your CKAN
# instance. Check the documentation in 'doc/configuration.rst' or at the
# following URL for a description of what they do and the full list of
# available options:
#
# http://docs.ckan.org/en/latest/maintaining/configuration.html
#
# The %(here)s variable will be replaced with the parent directory of this file
#

[DEFAULT]

# WARNING: *THIS SETTING MUST BE SET TO FALSE ON A PRODUCTION ENVIRONMENT*
debug = false

[server:main]
use = egg:Paste#http
host = 0.0.0.0
port = 5000

[app:main]
use = egg:ckan
full_stack = true
cache_dir = /tmp/%(ckan.site_id)s/
beaker.session.key = ckan

# This is the secret token that the beaker library uses to hash the cookie sent
# to the client. `paster make-config` generates a unique value for this each
# time it generates a config file.
beaker.session.secret = 8i2wtxaWmpGOMfVsZLf9rXmPt

# `paster make-config` generates a unique value for this each time it generates
# a config file.
app_instance_uuid = 607f72d5-8255-44aa-99a9-2f113d73d99a

# repoze.who config
who.config_file = %(here)s/who.ini
who.log_level = warning
who.log_file = %(cache_dir)s/who_log.ini
# Session timeout (user logged out after period of inactivity, in seconds).
# Inactive by default, so the session doesn't expire.
# who.timeout = 86400

## Database Settings
sqlalchemy.url = postgresql://ckan_default:${DB_CKAN_PASSWORD}@${DB_HOST}:${DB_PORT}/ckan_default

ckan.datastore.write_url = postgresql://ckan_default:${DB_CKAN_PASSWORD}@${DB_HOST}:${DB_PORT}/datastore_default
ckan.datastore.read_url = postgresql://datastore_default:${DB_DATASTORE_PASSWORD}@${DB_HOST}:${DB_PORT}/datastore_default

# PostgreSQL' full-text search parameters
ckan.datastore.default_fts_lang = english
ckan.datastore.default_fts_index_method = gist

## Site Settings

ckan.site_url = https://ckan.${DNS_ZONE}
#ckan.use_pylons_response_cleanup_middleware = true

## Authorization Settings

ckan.auth.anon_create_dataset = false
ckan.auth.create_unowned_dataset = false
ckan.auth.create_dataset_if_not_in_organization = false
ckan.auth.user_create_groups = false
ckan.auth.user_create_organizations = false
ckan.auth.user_delete_groups = true
ckan.auth.user_delete_organizations = true
ckan.auth.create_user_via_api = false
ckan.auth.create_user_via_web = true
ckan.auth.roles_that_cascade_to_sub_groups = admin


## Search Settings

ckan.site_id = default
solr_url = http://${SOLR_HOST}:8983/solr

#ckan.simple_search = 1

## CORS Settings

# If cors.origin_allow_all is true, all origins are allowed.
# If false, the cors.origin_whitelist is used.
ckan.cors.origin_allow_all = False
# cors.origin_whitelist is a space separated list of allowed domains.
#ckan.cors.origin_whitelist = http://discourse.sandbox.smartcolumbusos.com https://discourse.sandbox.smartcolumbusos.com


## Plugins Settings

# Note: Add ``datastore`` to enable the CKAN DataStore
#       Add ``datapusher`` to enable DataPusher
#		Add ``resource_proxy`` to enable resorce proxying and get around the
#		same origin policy
ckan.plugins = stats text_view image_view recline_view datastore datapusher cloudstorage harvest ckan_harvester dcat dcat_rdf_harvester dcat_json_harvester dcat_json_interface odata hidegroups ags_fs_view ags_ms_view officedocs_view SCOSMetadata scos_pod_harvester ${EXTRA_PLUGINS}

ckan.base_public_folder = public-bs2
ckan.base_templates_folder = templates-bs2

# Define which views should be created by default
# (plugins must be loaded in ckan.plugins)
ckan.views.default_views = image_view text_view recline_view

##ESRI Leaflet Viewer Settings
ckanext.agsview.default_basemap_url = Topographic
#ckanext.agsview.default_basemap_url = http://example.com/MapServer/tile//{z}/{x}/{y}

##Cloudstorage Settings
ckanext.cloudstorage.driver = #{S3_BUCKET_REGION}
ckanext.cloudstorage.container_name = ${S3_BUCKET}
ckanext.cloudstorage.use_secure_urls = 0
ckanext.cloudstorage.driver_options = {"key":'${AWS_ACCESS_KEY_ID}',"secret":'${AWS_SECRET_ACCESS_KEY}'}
#ckanext.cloudstorage.driver_options = {"key":"AWS_ACCESS_KEY","secret":"AWS_SECRET_KEY"}

##Discourse Settings
#discourse.url = https://discourse.sandbox.smartcolumbusos.com
#discourse.username = ckanbot
#discourse.ckan_category = c/open-data-talk
#discourse_count_cache_age = 0
#discourse.debug = false

##CKAN Harvester Settings
ckan.harvest.mq.type = redis
ckan.harvest.mq.hostname = ${REDIS_HOST}
ckan.harvest.mq.port = 6379
ckan.harvest.mq.redis_db = 0

## Front-End Settings
ckan.site_title = CKAN
ckan.site_logo = /base/images/ckan-logo.png
ckan.site_description =
ckan.favicon = /base/images/ckan.ico
ckan.gravatar_default = identicon
ckan.preview.direct = png jpg gif
ckan.preview.loadable = html htm rdf+xml owl+xml xml n3 n-triples turtle plain atom csv tsv rss txt json
ckan.display_timezone = server

# package_hide_extras = for_search_index_only
#package_edit_return_url = http://another.frontend/dataset/<NAME>
#package_new_return_url = http://another.frontend/dataset/<NAME>
#ckan.recaptcha.version = 1
#ckan.recaptcha.publickey =
#ckan.recaptcha.privatekey =
#licenses_group_url = http://licenses.opendefinition.org/licenses/groups/ckan.json
# ckan.template_footer_end =


## Internationalisation Settings
ckan.locale_default = en
ckan.locale_order = en pt_BR ja it cs_CZ ca es fr el sv sr sr@latin no sk fi ru de pl nl bg ko_KR hu sa sl lv
ckan.locales_offered =
ckan.locales_filtered_out = en_GB

## Feeds Settings

ckan.feeds.authority_name =
ckan.feeds.date =
ckan.feeds.author_name =
ckan.feeds.author_link =

## Storage Settings

ckan.storage_path = /var/lib/ckan
ckan.max_resource_size = 500
ckan.max_image_size = 2

## Datapusher settings

# Make sure you have set up the DataStore

ckan.datapusher.formats = none
ckan.datapusher.url = http://127.0.0.1:8800/

# Resource Proxy settings
# Preview size limit, default: 1MB
ckan.resource_proxy.max_file_size = 1048576
# Size of chunks to read/write.
ckan.resource_proxy.chunk_size = 4096

## Activity Streams Settings

#ckan.activity_streams_enabled = true
#ckan.activity_list_limit = 31
#ckan.activity_streams_email_notifications = true
#ckan.email_notifications_since = 2 days
ckan.hide_activity_from_users = %(ckan.site_id)s

## Email settings

#email_to = errors@example.com
#error_email_from = ckan-errors@example.com
#smtp.server = email-smtp.us-east-1.amazonaws.com
#smtp.starttls = True
#smtp.user =
#smtp.password =
#smtp.mail_from = scideadmin@hntb.com


## Logging configuration
[loggers]
keys = root, ckan, ckanext

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARNING
handlers = console

[logger_ckan]
level = INFO
handlers = console
qualname = ckan
propagate = 0

[logger_ckanext]
level = DEBUG
handlers = console
qualname = ckanext
propagate = 0

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(asctime)s %(levelname)-5.5s [%(name)s] %(message)s