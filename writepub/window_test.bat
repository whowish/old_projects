start /D script /SEPARATE /B mongo > log/mongo.log 2>&1
start /D script /SEPARATE /B redis-server_test > log/redis.log 2>&1
