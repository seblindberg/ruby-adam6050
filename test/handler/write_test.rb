# frozen_string_literal: true

require 'test_helper'

describe ADAM6050::Handler::Write do
  subject { ADAM6050::Handler::Write }

  let(:handler)       { subject.new }
  let(:initial_state) { ADAM6050::State.initial }

  describe '#validate?' do
    it 'returns true' do
      assert handler.validate?
    end
  end

  describe '#handles?' do
    it 'returns true for the preamble "#01"' do
      assert handler.handles?('#01')
    end

    it 'returns false for other preambles' do
      refute handler.handles?('$01C')
      refute handler.handles?('$016')
      refute handler.handles?('$01PW')
    end
  end

  describe '#handle' do
    it 'updates the state for a single channel' do
      state, = handler.handle '#011201', initial_state, nil, nil
      assert ADAM6050::State.output_set?(state, 2)
    end

    it 'updates the state for all channels' do
      state, = handler.handle '#010012', initial_state, nil, nil

      assert ADAM6050::State.output_set?(state, 1)
      assert ADAM6050::State.output_set?(state, 4)

      refute ADAM6050::State.output_set?(state, 0)
      refute ADAM6050::State.output_set?(state, 2)
      refute ADAM6050::State.output_set?(state, 3)
      refute ADAM6050::State.output_set?(state, 5)
    end

    it 'replies with a ">"' do
      _, reply = handler.handle '#011201', initial_state, nil, nil
      assert_equal '>', reply
    end
  end
end
