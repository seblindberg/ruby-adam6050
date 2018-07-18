# frozen_string_literal: true

require 'test_helper'

describe ADAM6050::Session do
  subject { ADAM6050::Session }
  let(:session) { subject.new }

  let(:addr)   { Addrinfo.ip('localhost') }
  let(:sender) { Socket::UDPSource.new addr, addr }

  describe '.new' do
    it 'accepts an optional timeout' do
      session = subject.new timeout: 10.0

      session.register sender, time: 0
      refute session.valid?(sender, time: 11.0)
    end
  end

  describe '#size' do
    it 'returns the number of senders tracked by the session' do
      assert_equal 0, session.size
      session.register sender
      assert_equal 1, session.size
    end
  end

  describe '#register' do
    it 'makes a sender valid' do
      refute session.valid?(sender)
      session.register sender
      assert session.valid?(sender)
    end

    it 'can register the same sender twice' do
      session.register sender, time: 0.0

      refute session.valid?(sender, time: subject::DEFAULT_TIMEOUT + 1)
      session.register sender, time: 1.0
      assert session.valid?(sender, time: subject::DEFAULT_TIMEOUT + 1)
    end
  end

  describe 'validate!' do
    it 'raises an error for unknown senders' do
      assert_raises(subject::UnknownSender) do
        session.validate! sender
      end
    end

    it 'raises an error for expired senders' do
      session.register sender, time: 0.0
      assert_raises(subject::InvalidSender) do
        session.validate! sender, time: subject::DEFAULT_TIMEOUT + 1
      end
    end

    it 'is silent for valid senders' do
      session.register sender, time: 0.0
      assert_silent do
        session.validate! sender, time: subject::DEFAULT_TIMEOUT - 1
      end
    end
  end

  describe '#cleanup!' do
    it 'removes invalid senders after an interval' do
      session.register sender, time: 0.0
      session.cleanup! time: subject::DEFAULT_CLEANUP_INTERVALL
      assert_equal 0, session.size
    end

    it 'does nothing within the next interval' do
      session.cleanup! time: 0.0
      session.register sender, time: 0.0
      session.cleanup! time: subject::DEFAULT_CLEANUP_INTERVALL - 1
      assert_equal 1, session.size
    end
  end
end
