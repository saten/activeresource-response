module ActiveresourceResponse   

  module ResponseMethod
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def add_response_method(method_name = :http_response)

        remove_response_method  if methods.map(&:to_sym).include?(:find_without_http_response)
        [:find, :get].each do |method| 
	  instance_eval  <<-EOS
          alias #{method}_without_http_response #{method}
          def #{method}(*arguments)
            result = #{method}_without_http_response(*arguments)
	    begin
              result.instance_variable_set(:@http_response, connection.http_response)
	    def result.#{method_name} 
              @http_response
            end
            rescue Exception => e
		#this should happen if the response is of a class that does not allow the definition of the http_response method
	    end
            result
          end
          EOS
        end
      end

      def remove_response_method
        [:find, :get].each do |method| 
          instance_eval   <<-EOS
            undef :#{method}
            alias :#{method} :#{method}_without_http_response 
            undef :#{method}_without_http_response
          EOS
                     
        end 
      end   

    end
  end   
end
