# frozen_string_literal: true

require 'test_helper'

describe ADAM6050::Handler::Login do
  subject             { ADAM6050::Handler::Login }

  let(:handler)       { subject.new 'b6TSkfr6' }
  let(:msg)           { "$01PW0]\tklTYM\t\r" }
  let(:msg_invalid)   { "$01PW0\x0E\x0E\x0E\x0E\x0E\x0E\x0E\x0E\r" }
  let(:addr)          { Addrinfo.ip('localhost') }
  let(:sender)        { Socket::UDPSource.new addr, addr }
  let(:session)       { ADAM6050::Session.new }
  let(:initial_state) { ADAM6050::State.initial }

  describe '#validate?' do
    it 'returns false' do
      refute handler.validate?
    end
  end

  describe '#handles?' do
    it 'returns true for the preamble "$01PW"' do
      assert handler.handles?('$01PW')
    end

    it 'returns false for other preambles' do
      refute handler.handles?('$01C')
      refute handler.handles?('#01')
      refute handler.handles?('$016')
    end
  end

  describe '#handle' do
    it 'does not update the state' do
      state, = handler.handle msg, initial_state, session, sender

      assert_equal state, initial_state
    end

    it 'replies with an ok message' do
      _, reply = handler.handle msg, initial_state, session, sender

      assert_equal '>01', reply
    end

    it 'validates the sender through the session' do
      handler.handle msg, initial_state, session, sender

      assert session.valid?(sender)
    end

    it 'replies with a "?" for an invalid password' do
      _, reply = handler.handle msg_invalid, initial_state, session, sender

      assert_equal '?', reply
    end

    it 'does not validate the sender given an invalid password' do
      handler.handle msg_invalid, initial_state, session, sender
      refute session.valid?(sender)
    end
  end
end
