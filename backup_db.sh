FILE_NAME="app/etc/env.php"
echo "Starting Migration..."

db_name=$((grep -Po "(?<='dbname' => ).*(?=,)" $FILE_NAME) | cut -d "'" -f 2)

project_name=''
if [-z "$project_name"]; then
    $project_name="$(pwd | cut -d "/" -f 4)"
fi

# The host name of the MySQL database server; usually 'localhost'

#db_host=$((grep -Po "(?<='host' => ).*(?=,)" $FILE_NAME) | cut -d "'" -f 2)
db_host='localhost'

# The MySQL user to use when performing the database backup.
db_user=$((grep -Po "(?<='username' => ).*(?=,)" $FILE_NAME) | cut -d "'" -f 2)

# The password for the above MySQL user.
db_pass=$((grep -Po "(?<='password' => ).*(?=,)" $FILE_NAME) | cut -d "'" -f 2)

# Directory to which backup files will be written. Should end with slash ("/").

backups_dir="/home/$USER/backups/"
if [ ! -d $backups_dir ]; then
   mkdir $backups_dir;
   echo  "Directory $backups_dir created";
fi 

# Date/time included in the file names of the database backup files.
datetime=$(date +'%Y-%m-%dT%H:%M')

# Create database backup and compress using gzip.
mysqldump -u $db_user -h $db_host --password=$db_pass $db_name | gzip -9 > $backups_dir$project_name--$datetime.sql.gz

# Set appropriate file permissions/owner.
chown $USER:$USER $backups_dir*--$datetime.sql.gz
chmod 0400 $backups_dir*--$datetime.sql.gz

#TODO remove old db_backups automaticaly 
#find $backups_dir -type f -mtime +7 -name '*.gz' -execdir rm -- '{}' \;

echo "Backup DB saved: $backups_dir$project_name--$datetime.sql.gz"