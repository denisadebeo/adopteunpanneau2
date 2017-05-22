module FormHelper

  class ActionView::Helpers::FormBuilder
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::FormOptionsHelper

    def switch(name, options = {})
      @switch_id = "#{@object_name}_#{name}"
      lbl(name,options) + container(name,options)
    end

    protected

      def lbl(name, options)
        label_tag(name, options[:label])
      end

      def check(name, options)
        check_box name, options.merge({label: false, class: "switch-input"})
      end

      def container(name, options)
        content_tag :div, check(name,options) + paddle, class: "switch"
      end

      def paddle
        label_tag(@switch_id, "", class: "switch-paddle")
      end

  end

end
