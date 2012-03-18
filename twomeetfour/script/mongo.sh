rm -f /mongo/data/mongod.lock
rm -f /mongo/data/db/mongod.lock
/mongo/bin/mongod --repair
/mongo/bin/mongod -v --dbpath "/mongo/data/db"