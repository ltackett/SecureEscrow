require "action_dispatch"
require "action_pack"

module SecureEscrow
  module Railtie
    module Routing
      def escrow options, &block
        defaults = options[:defaults] || {}
        defaults[:escrow] = true
        post options.merge(defaults), &block
      end
    end

    module ActionViewHelper
      DATA_ESCROW = 'data-escrow'

      def escrow_form_for record, options = {}, &proc
        options[:html] ||= {}

        stringy_record = String === record || Symbol === record
        apply_form_for_options!(record, options) unless stringy_record


        form_for record, escrow_options(options), &proc
      end

      def escrow_form_tag url_for_options = {}, options = {}, &block
        form_tag url_for_options, escrow_options(options), &block
      end

      private
      def escrow_options options
        # Add data-escrow attribute to the form element
        html_options = options[:html] || {}
        options.merge(html: html_options.merge(DATA_ESCROW => true))

        # Rewrite URL to point to secure domain
        app = Rails.application
        config = app.config

        submission_url = controller.url_for(
          app.routes.recognize_path(options[:url]).
            merge(
              host:     config.secure_domain_name,
              protocol: config.secure_domain_protocol,
              port:     config.secure_domain_port
            ))

        options[:url] = submission_url
        options
      end
    end
  end
end

