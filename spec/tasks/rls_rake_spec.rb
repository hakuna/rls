# frozen_string_literal: true

require "spec_helper"
require "rake"

Rails.application.load_tasks

RSpec.describe "rake tasks" do
  describe "rls:enable" do
    subject { -> { capture_rake_task_output("rls:enable") } }

    specify do
      expect(RLS).to receive(:enable!)
      subject.call
    end
  end

  describe "rls:disable" do
    subject { -> { capture_rake_task_output("rls:disable") } }

    specify do
      expect(RLS).to receive(:disable!)
      subject.call
    end
  end

  describe "rls:create_role" do
    subject { -> { capture_rake_task_output("rls:create_role") } }

    specify do
      expect(RLS).to receive(:disable!).ordered
      expect(RLS.connection).to receive(:execute).with(/CREATE ROLE "app_rls"/).ordered
      expect(RLS).to receive(:enable!).ordered
      subject.call
    end
  end

  describe "rls:drop_role" do
    subject { -> { capture_rake_task_output("rls:drop_role") } }

    specify do
      expect(RLS).to receive(:disable!).ordered
      expect(RLS.connection).to receive(:execute).with(/DROP ROLE "app_rls"/).ordered
      expect(RLS).to receive(:enable!).ordered
      subject.call
    end
  end

  describe "db:* tasks, such as db:migrate" do
    describe do
      subject { -> { capture_rake_task_output("db:migrate") } }

      specify do
        expect(RLS).to receive(:disable!).ordered.and_call_original
        expect(RLS).to receive(:enable!).ordered.and_call_original
        subject.call
      end
    end
  end

  def capture_rake_task_output(task_name)
    stdout = StringIO.new
    $stdout = stdout
    Rake::Task[task_name].invoke
    $stdout = STDOUT
    Rake.application[task_name].reenable
    stdout.string
  end
end
