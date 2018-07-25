<?xml version="1.0" encoding="UTF-8"?>
<unite scripting="02_angie">
  <s3>
		<accesskey>${S3_ACCESS_KEY}</accesskey>
		<secretkey>${S3_SECRET_KEY}</secretkey>
		<signature>v4</signature>
		<bucket>scos-prod-joomla-backups</bucket>
		<region>us-east-1</region>
		<ssl>1</ssl>
		<filename>${S3_FILE_NAME}</filename>
	</s3>

  <siteInfo>
    <package from="s3"></package>
    <deletePackage>0</deletePackage>
    <localLog>test.log</localLog>
    <emailSysop>0</emailSysop>
    <name>Smart Columbus OS</name>
    <email>smartcolumbusos@columbus.gov</email>
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
      <dbname>joomla</dbname>
      <dbprefix>scos_</dbprefix>
    </database>
  </databaseInfo>

</unite>