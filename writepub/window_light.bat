start /D script /SEPARATE /B mongo > log/mongo.log 2>&1
start /D script /SEPARATE /B redis-server > log/redis.log 2>&1
rails server
