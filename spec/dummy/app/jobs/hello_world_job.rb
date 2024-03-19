# frozen_string_literal: true

class HelloWorldJob < ApplicationJob
  rescue_from RLS::SchemaNotFound do 
    Rails.logger.error "World not found!"
  end

  def perform
    Rails.logger.info "Hello World"
  end
end
