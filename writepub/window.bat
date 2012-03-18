start /D script /SEPARATE /B mongo > log/mongo.log 2>&1
start /D script /SEPARATE /B redis-server_test > log/redis_test.log 2>&1
start /D script /SEPARATE /B redis-server > log/redis.log 2>&1
sleep 2
start /SEPARATE /B bundle exec sunspot-solr run -p 8390 -d solr/data -s solr > log/sunspot.log 2>&1
start /SEPARATE /B bundle exec rake environment resque:work QUEUE="member_action" > log/resque_member_action.log 2>&1
start /SEPARATE /B bundle exec rake environment resque:work QUEUE="notification" > log/resque_notification.log 2>&1
start /SEPARATE /B bundle exec rake environment resque:work QUEUE="normal" > log/resque_normal.log 2>&1
start /SEPARATE /B bundle exec rake resque:scheduler > log/resque_scheduler.log 2>&1
rails server
