module Mongo
  class Connection
    def server_info
      #self["admin"].command({:buildinfo => 1})
      return {
                      "version" => "2.0.1",
                      "gitVersion" => "3a5cf0e2134a830d38d2d1aae7e88cac31bdd684",
                      "sysInfo" => "Linux bs-linux64.10gen.cc 2.6.21.7-2.ec2.v1.2.fc8xen #1 SMP Fri Nov 20 17:48:28 EST 2009 x86_64 BOOST_LIB_VERSION=1_41",
                      "versionArray" => [
                              2,
                              0,
                              1,
                              0
                      ],
                      "bits" => 64,
                      "debug" => false,
                      "maxBsonObjectSize" => 16777216,
                      "ok" => 1
              }

    end
  end
end