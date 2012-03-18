module Sunspot
  class Server #:nodoc:
    # 
    # Run the sunspot-solr server in the foreground. Boostrap
    # solr_home first, if neccessary.
    #
    # ==== Returns
    #
    # Boolean:: success
    #
    def run
      command = ['java']
      command << "-Xms#{min_memory}" if min_memory
      command << "-Xmx#{max_memory}" if max_memory
      command << "-Djetty.port=#{port}" if port
      command << "-Dsolr.data.dir=\"#{solr_data_dir}\"" if solr_data_dir
      command << "-Dsolr.solr.home=\"#{solr_home}\"" if solr_home
      command << "-Djava.util.logging.config.file=\"#{logging_config_path}\"" if logging_config_path
      command << '-jar' << File.basename(solr_jar)
      FileUtils.cd(File.dirname(solr_jar)) do
        exec(command.join(" "))
      end
    end
  end
end