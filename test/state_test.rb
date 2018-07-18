# frozen_string_literal: true

require 'test_helper'

describe ADAM6050::State do
  subject { ADAM6050::State }
  let(:initial) { subject.initial }

  describe '.update' do
    it 'sets the given output channel' do
      state = subject.update initial, 4, 1
      assert_equal((1 << 16), state)
    end

    it 'clears the given output channel' do
      state = subject.update initial, 4, 1
      state = subject.update state, 4, 0
      assert_equal(0, state)
    end

    it 'raises an error for invalid channel numbers' do
      assert_raises(RangeError) { subject.update initial, 6, 1 }
    end
  end

  describe '.update_all' do
    it 'updates the given output channels' do
      state = subject.update_all initial, 0b001010
      assert_equal((0b001010 << 12), state)
    end
  end

  describe '.input_set?' do
    it 'returns true if the given input channel is set' do
      assert subject.input_set?((1 << 4), 4)
    end

    it 'returns false if the given input channel is not set' do
      refute subject.input_set?(initial, 4)
    end
  end

  describe '.output_set?' do
    it 'returns true if the given output channel is set' do
      state = subject.update initial, 4, 1
      assert subject.output_set?(state, 4)
    end

    it 'returns false if the given output channel is not set' do
      refute subject.output_set?(initial, 4)
    end
  end

  describe '.to_bin' do
    it 'converts the state to binary form' do
      state = subject.update initial, 4, 1
      assert_equal '2FFFF', subject.to_bin(state)
    end
  end

  describe '.inspect' do
    it 'returns a string representation' do
      str = subject.inspect 0b101010101010101010
      assert_equal '101010 101010101010', str
    end
  end
end
