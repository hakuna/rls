# frozen_string_literal: true

module RLS
  class Current < ActiveSupport::CurrentAttributes
    attribute :tenant
  end
end
