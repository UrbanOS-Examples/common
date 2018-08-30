<?xml version="1.0" encoding="UTF-8"?>
<unite scripting="02_angie">
  <siteInfo>
    <package>/tmp/backup.zip</package>
    <deletePackage>0</deletePackage>
    <localLog>test.log</localLog>
    <emailSysop>0</emailSysop>
    <name>Smart Columbus OS</name>
    <email>smartcolumbusos@columbus.gov</email>
    <absolutepath>/home/admin/web/public_html</absolutepath>
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
      <dbname>joomla</dbname>
      <dbprefix>scos_</dbprefix>
    </database>
  </databaseInfo>

</unite>