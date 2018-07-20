<?xml version="1.0" encoding="UTF-8"?>
<unite scripting="02_angie">
  <siteInfo>
    <package>/tmp/${S3_FILE_NAME}</package>
    <deletePackage>0</deletePackage>
    <localLog>test.log</localLog>
    <emailSysop>0</emailSysop>
    <name>${JOOMLA_SITE_NAME}</name>
    <email>${JOOMLA_ADMIN_EMAIL}</email>
    <absolutepath>/var/www/html</absolutepath>
    <homeurl>${JOOMLA_SITE_URL}</homeurl>
    <livesite>${JOOMLA_SITE_URL}</livesite>
  </siteInfo>

  <databaseInfo>
    <database name="site">
      <changecollation>0</changecollation>
      <dbdriver>mysqli</dbdriver>
      <dbhost>${JOOMLA_DB_HOST}</dbhost>
      <dbuser>${JOOMLA_DB_USER}</dbuser>
      <dbpass>${JOOMLA_DB_PASSWORD}</dbpass>
      <dbname>${JOOMLA_DB_NAME}</dbname>
      <dbprefix>${JOOMLA_DB_PREFIX}</dbprefix>
    </database>
  </databaseInfo>

</unite>