module HoptoadNotifier
  HEADERS.replace({
    "X-Hoptoad-Client-Name"    =>"Hoptoad Notifier", 
    "Content-type"             =>"application/x-yaml", 
    "X-Hoptoad-Client-Version" =>"1.2.4", 
    "Accept"                   =>"text/xml, application/xml"
  })
  
  class Sender
    self.send(:remove_const, "NOTICES_URI")
    NOTICES_URI = '/notices/'
  end
  
  class << self
    
    def notify_or_ignore(exception, opts = {})
      notice = build_notice_for(exception, opts)
      send_notice(notice) if configuration.public?
    end


    private

    def default_notice_options #:nodoc:
      {
        :api_key       => HoptoadNotifier.configuration.api_key,
        :error_message => 'Notification',
        :backtrace     => caller,
        :request       => {},
        :session       => {},
        :environment   => ENV.to_hash
      }
    end

    def send_notice(notice)
      if configuration.public?
        sender.send_to_hoptoad(notice)
      end
    end

    def build_notice_for(exception, opts = {})
      notice = normalize_notice(exception)
      notice = clean_notice(notice)
      notice = yamlize_notice(notice)
    end
    
    def yamlize_notice(notice)
      notice.stringify_keys.to_yaml
    end


    def normalize_notice(notice) #:nodoc:
      case notice
      when Hash
        default_notice_options.merge(notice)
      when Exception
        default_notice_options.merge(exception_to_data(notice))
      end
    end

    def clean_notice(notice) 
      notice[:backtrace] = clean_hoptoad_backtrace(notice[:backtrace])
      if notice[:request].is_a?(Hash) && notice[:request][:params].is_a?(Hash)
        notice[:request][:params] = filter_parameters(notice[:request][:params]) if respond_to?(:filter_parameters)
        notice[:request][:params] = clean_hoptoad_params(notice[:request][:params])
      end
      if notice[:environment].is_a?(Hash)
        notice[:environment] = filter_parameters(notice[:environment]) if respond_to?(:filter_parameters)
        notice[:environment] = clean_hoptoad_environment(notice[:environment])
      end
      {:notice => clean_non_serializable_data(notice)}
    end

    def exception_to_data(exception)
      data = {
        :api_key       => HoptoadNotifier.configuration.api_key,
        :error_class   => exception.class.name,
        :error_message => "#{exception.class.name}: #{exception.message}",
        :backtrace     => exception.backtrace,
        :environment   => ENV.to_hash
      }

      if self.respond_to? :request
        data[:request] = {
          :params      => request.parameters.to_hash,
          :rails_root  => File.expand_path(RAILS_ROOT),
          :url         => "#{request.protocol}#{request.host}#{request.request_uri}"
        }
        data[:environment].merge!(request.env.to_hash)
      end

      if self.respond_to? :session
        data[:session] = {
          :key         => session.instance_variable_get("@session_id"),
          :data        => session.respond_to?(:to_hash) ?
          session.to_hash :
          session.instance_variable_get("@data")
        }
      end

      data
    end

    def clean_hoptoad_backtrace backtrace #:nodoc:
      if backtrace.to_a.size == 1
        backtrace = backtrace.to_a.first.split(/\n\s*/)
      end

      filtered = backtrace.to_a.map do |line|
        HoptoadNotifier.configuration.backtrace_filters.inject(line) do |line, proc|
          proc.call(line)
        end
      end

      filtered.compact
    end

    def clean_hoptoad_params params #:nodoc:
      params.each do |k, v|
        params[k] = "[FILTERED]" if HoptoadNotifier.configuration.params_filters.any? do |filter|
          k.to_s.match(/#{filter}/)
        end
      end
    end

    def clean_hoptoad_environment env #:nodoc:
      env.each do |k, v|
        env[k] = "[FILTERED]" if HoptoadNotifier.configuration.environment_filters.any? do |filter|
          k.to_s.match(/#{filter}/)
        end
      end
    end

    def clean_non_serializable_data(data) #:nodoc:
      case data
      when Hash
        data.inject({}) do |result, (key, value)|
          result.update(key => clean_non_serializable_data(value))
        end
      when Fixnum, Array, String, Bignum
        data
      else
        data.to_s
      end
    end

    def stringify_keys(hash) #:nodoc:
      hash.inject({}) do |h, pair|
        h[pair.first.to_s] = pair.last.is_a?(Hash) ? stringify_keys(pair.last) : pair.last
        h
      end
    end
  end
end

