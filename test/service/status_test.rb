# frozen_string_literal: true

require 'test_helper'

describe ADAM6050::Service::Status do
  subject { ADAM6050::Service::Status }

  let(:handler)       { subject.new }
  let(:initial_state) { ADAM6050::State.initial }

  describe '#validate?' do
    it 'returns true' do
      assert handler.validate?
    end
  end

  describe '#handles?' do
    it 'returns true for the preamble "$01C"' do
      assert handler.handles?('$01C')
    end

    it 'returns false for other preambles' do
      refute handler.handles?('$01PW')
      refute handler.handles?('#01')
      refute handler.handles?('$016')
    end
  end

  describe '#handle' do
    it 'does not alter the state' do
      state, = handler.handle "$01C\r", initial_state, nil, nil
      assert_equal initial_state, state
    end

    it 'replies with a status message' do
      _, reply = handler.handle "$01C\r", initial_state, nil, nil
      assert_equal '!01000000000000000000000000000000000000', reply
    end

    it 'replies with an ok message' do
      _, reply = handler.handle '$01C00', initial_state, nil, nil
      assert_equal '>', reply
    end
  end
end
