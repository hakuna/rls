# frozen_string_literal: true

require "spec_helper"
require "rake"

RSpec.describe "rake tasks" do
  describe "rls:enable" do
    subject { -> { run_and_capture_rake("rls:enable") } }

    specify do
      expect(RLS).to receive(:enable!)
      subject.call
    end
  end

  describe "rls:disable" do
    subject { -> { run_and_capture_rake("rls:disable") } }

    specify do
      expect(RLS).to receive(:disable!)
      subject.call
    end
  end

  describe "rls:create_role" do
    subject { -> { run_and_capture_rake("rls:create_role") } }

    specify do
      expect(RLS).to receive(:disable!).ordered
      expect(RLS.connection).to receive(:execute).with(/CREATE ROLE "dummy_rls_test"/).ordered
      expect(RLS).to receive(:enable!).ordered
      subject.call
    end
  end

  describe "rls:drop_role" do
    subject { -> { run_and_capture_rake("rls:drop_role") } }

    specify do
      expect(RLS).to receive(:disable!).ordered
      expect(RLS.connection).to receive(:execute).with(/DROP ROLE "dummy_rls_test"/).ordered
      expect(RLS).to receive(:enable!).ordered
      subject.call
    end
  end

  describe "db:* tasks, such as db:migrate" do
    before { allow(Rake.application).to receive(:top_level_tasks).and_return(top_level_tasks) }
    before do
      Rake::Task.clear
      Rails.application.load_tasks
    end

    before do
      @rls_enabled = nil
      allow(RLS).to receive(:disable!).and_wrap_original do |method, *args|
        @rls_enabled = false
        method.call(*args)
      end
      allow(RLS).to receive(:enable!).and_wrap_original do |method, *args|
        @rls_enabled = true
        method.call(*args)
      end
    end

    context "single task" do
      let(:top_level_tasks) { ["db:migrate:status"] }

      subject { -> { run_and_capture_rake("db:migrate:status") } }

      # at the end of the task chain, RLS should still be enabled
      specify do
        subject.call
        expect(@rls_enabled).to be true
      end
    end

    context "multiple tasks" do
      let(:top_level_tasks) { ["db:migrate", "db:version"] }

      subject { -> { run_and_capture_rake("db:migrate", "db:version") } }

      # at the end of the task chain, RLS should still be enabled
      specify do
        subject.call
        expect(@rls_enabled).to be true
      end
    end
  end

  def run_and_capture_rake(*task_names)
    stdout = StringIO.new
    $stdout = stdout
    task_names.each do |task_name|
      Rake::Task[task_name].invoke
      Rake.application[task_name].reenable
    end
    $stdout = STDOUT
    stdout.string
  end
end
