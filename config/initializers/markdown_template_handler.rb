# frozen_string_literal: true

# https://gist.github.com/mattlenz/3185536

module MarkdownHandler
  def self.call(_template, source)
    "#{Kramdown::Document.new(source, auto_ids: false).to_html.inspect}.html_safe"
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler
ActionView::Template.register_template_handler :markdown, MarkdownHandler
