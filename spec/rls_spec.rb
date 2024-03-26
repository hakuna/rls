# frozen_string_literal: true

RSpec.describe RLS do
  it "has a version number" do
    expect(RLS::VERSION).not_to be nil
  end

  describe "#connection" do
    subject { described_class.connection }

    it { is_expected.to eq ActiveRecord::Base.connection }
  end

  describe "#enable!" do
    subject { -> { described_class.enable! } }

    before { RLS::Current.admin = true }

    specify { expect { subject.call }.to change(RLS::Current, :admin).from(true).to(false) }
    specify { expect(ActiveRecord::Base.connection_pool).to receive(:disconnect!); subject.call }
  end

  describe "#disable!" do
    subject { -> { described_class.disable! } }

    specify { expect { subject.call }.to change(RLS::Current, :admin).from(false).to(true) }
    specify { expect(ActiveRecord::Base.connection_pool).to receive(:disconnect!); subject.call }
  end

  describe "#process" do
    subject { -> { described_class.process(tenant_id, &block) } }

    let(:tenant_id) { 42 }

    let(:block) do
      lambda do
        1234
      end
    end

    it "returns returned value of block" do
      expect(subject.call).to eq 1234
    end

    it "sets tenant, then resets" do
      expect(described_class.connection).to receive(:execute).with("SET rls.tenant_id = 42").ordered.and_call_original
      expect(block).to receive(:call).ordered.and_call_original
      expect(described_class.connection).to receive(:execute).with("RESET rls.tenant_id").ordered.and_call_original

      subject.call
    end

    context "tenant id blank" do
      let(:tenant_id) { nil }

      it "resets, then resets" do
        expect(described_class.connection).to receive(:execute).with("RESET rls.tenant_id").ordered.and_call_original
        expect(block).to receive(:call).ordered.and_call_original
        expect(described_class.connection).to receive(:execute).with("RESET rls.tenant_id").ordered.and_call_original

        subject.call
      end
    end

    context "encountering exception in block" do
      let(:block) do
        lambda do
          raise "error"
        end
      end

      it "still resets" do
        expect(described_class.connection).to receive(:execute).with("SET rls.tenant_id = 42").ordered.and_call_original
        expect(block).to receive(:call).ordered.and_call_original
        expect(described_class.connection).to receive(:execute).with("RESET rls.tenant_id").ordered.and_call_original

        expect { subject.call }.to raise_error("error")
      end
    end
  end

  describe "#set!" do
    subject { -> { described_class.set!(55) } }

    specify do
      expect(described_class.connection).to receive(:execute).with("SET rls.tenant_id = 55")
      subject.call
    end
  end

  describe "#reset!" do
    subject { -> { described_class.reset! } }

    specify do
      expect(described_class.connection).to receive(:execute).with("RESET rls.tenant_id")
      subject.call
    end
  end
end
