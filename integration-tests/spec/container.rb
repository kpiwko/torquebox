require 'jruby/core_ext'

module Spec
  module Example
    module ExampleGroupMethods

=begin
      def deploy( path, options = {} )
        @run_mode = options.fetch(:run_mode, :client)
        @deployment = path
      end

      attr_reader :deployment
      
      def run_mode
        case @run_mode
        when :client
          org.jboss.arquillian.api.RunModeType::AS_CLIENT
        when :container
          org.jboss.arquillian.api.RunModeType::IN_CONTAINER
        else
          raise "Unknown :run_mode -- acceptable values are :client or :container"
        end 
      end

      def create_deployment 
        tail = @deployment.split('/')[-1]
        base = /(.*)\./.match(tail)[1]
        archive = org.jboss.shrinkwrap.api.ShrinkWrap.create( org.jboss.shrinkwrap.api.spec.JavaArchive.java_class, "#{base}.jar" )
        deploymentDescriptorUrl = JRuby.runtime.jruby_class_loader.getResource( name )
        archive.addResource( deploymentDescriptorUrl, "/META-INF/#{tail}" )
        archive
      end
=end

    end
  end
end

Spec::Runner.configure do |config|

  config.before(:suite) do
    puts "JC: before(:suite)"
    configuration = org.jboss.arquillian.impl.XmlConfigurationBuilder.new.build()
    Thread.current[:test_runner_adaptor] = org.jboss.arquillian.impl.DeployableTestBuilder.build(configuration)
    Thread.current[:test_runner_adaptor].beforeSuite
  end
    
  config.before(:all) do
    puts "JC: before(:all)"
    @real_java_class = self.class.become_java!('.')
    Thread.current[:test_runner_adaptor].beforeClass(@real_java_class)
  end

  config.after(:all) do
    puts "JC: after(:all)"
    Thread.current[:test_runner_adaptor].afterClass(@real_java_class)
  end

  config.after(:suite) do
    puts "JC: after(:suite)"
    Thread.current[:test_runner_adaptor].afterSuite if Thread.current[:test_runner_adapter].respond_to?( :afterSuite )
  end

end

