# frozen_string_literal: true

# BEFORE = %w[db:drop].freeze
# AFTER = %w[db:migrate db:create db:seed db:rollback db:migrate:up db:migrate:down].freeze

# namespace

# def rls_task_name(task_name)
#   sub_task_name = task_name.split(":", 2).last
#   "rls:#{sub_task_name}"
# end

# BEFORE.each do |task_name|
#   task = Rake::Task[task_name]
#   task.enhance([rls_task_name(task_name)])
# end

# AFTER.each do |task_name|
#   task = Rake::Task[task_name]
#   task.enhance do
#     Rake::Task[rls_task_name(task_name)].invoke
#   end
# end

# def each_tenant(&block)
#   # TENANT=tenant1,tenant2 bundle exec rake db:migrate
#   # can override default tenants
#   tenants = if ENV["TENANT"]
#               ENV["TENANT"].split(",").map(&:strip)
#             else
#               begin
#                 RLS.tenants
#               rescue ActiveRecord::StatementInvalid => e
#                 warn "Could not retrieve tenants. Maybe default schema was not initialized yet."
#                 []
#               end
#             end

#   tenants.each(&block)
# end

# namespace :rls do
#   desc "Create all tenant schemas"
#   task create: :environment do
#     each_tenant do |tenant|
#       if RLS.exists?(tenant)
#         puts "Schema for tenant '#{tenant}' does already exist, cannot create"
#       else
#         puts "Create schema for tenant '#{tenant}"
#         RLS.create(tenant)
#       end
#     end
#   end

#   desc "Drop all tenant schemas"
#   task drop: :environment do
#     each_tenant do |tenant|
#       if RLS.exists?(tenant)
#         puts "Drop schema for trenant '#{tenant}'"
#         RLS.drop(tenant)
#       else
#         puts "Schema for tenant '#{tenant}' does not exist, cannot drop"
#       end
#     end
#   end

#   desc "Migrate all tenant schemas"
#   task migrate: :environment do
#     each_tenant do |tenant|
#       if RLS.exists?(tenant)
#         puts "Migrate schema for '#{tenant}'"
#         RLS.process(tenant) do
#           ActiveRecord::Tasks::DatabaseTasks.migrate
#         end
#       else
#         puts "Schema for tenant '#{tenant}' does not exist, cannot migrate"
#       end
#     end
#   end

#   desc "Seed all tenant schemas"
#   task seed: :environment do
#     each_tenant do |tenant|
#       if RLS.exists?(tenant)
#         puts "Seed schema for tenant '#{tenant}'"
#         RLS.seed(tenant)
#       else
#         puts "Schema for tenant '#{tenant}' does not exist, cannot seed"
#       end
#     end
#   end

#   desc "Rolls tenant schemas back to the previous version (specify steps w/ STEP=n)"
#   task rollback: :environment do
#     step = ENV["STEP"]&.to_i || 1

#     each_tenant do |tenant|
#       if RLS.exists?(tenant)
#         puts "Rolling back schema of tenant '#{tenant}'"
#         RLS.process(tenant) do
#           ActiveRecord::Base.connection.migration_context.rollback(step)
#         end
#       else
#         puts "Schema for tenant '#{tenant}' does not exist, cannot rollback"
#       end
#     end
#   end

#   namespace :migrate do
#     desc 'Runs the "up" for a given migration VERSION across all tenant schemas'
#     task up: :environment do
#       version = ActiveRecord::Tasks::DatabaseTasks.target_version

#       each_tenant do |tenant|
#         if RLS.exists?(tenant)
#           puts "Migrate schema for tenant '#{tenant}' up to #{version}"
#           RLS.process(tenant) do
#             ActiveRecord::Base.connection.migration_context.run(:up, version)
#           end
#         else
#           puts "Schema for tenant '#{tenant}' does not exist, cannot migrate up"
#         end
#       end
#     end

#     desc 'Runs the "down" for a given migration VERSION across all tenant schemas'
#     task down: :environment do
#       version = ActiveRecord::Tasks::DatabaseTasks.target_version

#       each_tenant do |tenant|
#         if RLS.exists?(tenant)
#           puts "Migrate schema for tenant '#{tenant}' down to #{version}"
#           RLS.process(tenant) do
#             ActiveRecord::Base.connection.migration_context.run(:down, version)
#           end
#         else
#           puts "Schema for tenant '#{tenant}' does not exist, cannot migrate down"
#         end
#       end
#     end
#   end
# end
