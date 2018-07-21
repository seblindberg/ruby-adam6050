# frozen_string_literal: true

require 'test_helper'

describe ADAM6050::Service::Read do
  subject { ADAM6050::Service::Read }

  let(:handler)       { subject.new }
  let(:initial_state) { ADAM6050::State.initial }
  let(:msg)           { "$016\r" }

  describe '#validate?' do
    it 'returns true' do
      assert handler.validate?
    end
  end

  describe '#handles?' do
    it 'returns true for the preamble "$016"' do
      assert handler.handles?('$016')
    end

    it 'returns false for other preambles' do
      refute handler.handles?('$01C')
      refute handler.handles?('#01')
      refute handler.handles?('$01PW')
    end
  end

  describe '#handle' do
    it 'does not alter the state' do
      state, = handler.handle msg, initial_state, nil, nil
      assert_equal initial_state, state
    end

    it 'replies with the initial state' do
      _, reply = handler.handle msg, initial_state, nil, nil
      assert_equal '!01003FFFF', reply
    end

    it 'replies with the modified state' do
      _, reply = handler.handle msg, 0x20000, nil, nil
      assert_equal '!01001FFFF', reply
    end
  end
end
