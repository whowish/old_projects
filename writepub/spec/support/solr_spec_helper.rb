# encoding: utf-8
$original_sunspot_session = Sunspot.session
Sunspot.session = Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)

module SolrSpecHelper

  def solr_setup
    unless $sunspot
      $sunspot = Sunspot::Rails::Server.new

      pid = fork do
        $sunspot.run
      end
      # shut down the Solr server
      at_exit { Process.kill(9, pid) }
      # wait for solr to start
      sleep 10
    end

    Sunspot.session = $original_sunspot_session
  end
end