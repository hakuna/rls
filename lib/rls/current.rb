module RLS
  class Current < ActiveSupport::CurrentAttributes
    attribute :admin

    resets { self.admin = false }
  end
end
