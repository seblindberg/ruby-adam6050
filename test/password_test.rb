# frozen_string_literal: true

require 'test_helper'

describe ADAM6050::Password do
  subject { ADAM6050::Password }
  let(:plain)  { 'b6TSkfr6' }
  let(:target) { "]\tklTYM\t" }
  let(:password) { subject.new plain }

  describe '#==' do
    it 'returns true when there is a match' do
      assert_operator password, :==, target
    end

    it 'returns false when there is no match' do
      refute_operator password, :==, 'other'
    end
  end

  describe '.new' do
    it 'raises an error when the password is more than 8 characters' do
      assert_raises(subject::FormatError) { subject.new ' ' * 9 }
    end

    it 'accepts passwords shorter than 8 characters' do
      password = subject.new plain[0..-2]
      assert_operator password, :==, (target[0..-2] + "\x0E")
    end

    it 'accepts no password' do
      password = subject.new
      assert_operator password, :==, 'anything'
    end
  end
end
