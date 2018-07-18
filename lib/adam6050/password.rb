# frozen_string_literal: true

module ADAM6050
  # == Usage
  # The following example creates a password and uses it to validate an encoded
  # string.
  #
  #   password = Password.new 'b6TSkfr6'
  #
  #   password == 'b6TSkfr6' # => false
  #   password == "]\tklTYM\t" # => true
  #
  # The next example creates a password that will match any string.
  #
  #   password = Password.new
  #
  #   password == 'anything' # => true
  class Password
    # Format errors should be raised whenever a plain text password longer than
    # 8 characters is passed. Note that only ascii characters are supported.
    class FormatError < Error
      def initialize
        super 'Only ascii passwords of length 8 or less are supported'
      end
    end

    # @raise [FormatError] if the plain text password is longer than 8
    #   characters.
    #
    # @param  plain [String] the plain text version of the password.
    def initialize(plain = nil)
      if plain
        password = obfuscate plain
        define_singleton_method(:==) { |text| password == text }
      else
        define_singleton_method(:==) { |_| true }
      end

      freeze
    end

    private

    def obfuscate(plain)
      codepoints = plain.codepoints

      raise FormatError if codepoints.length > 8

      password = Array.new(8, 0x0E)
      codepoints.each_with_index do |c, i|
        password[i] = (c & 0x40) | (~c & 0x3F)
      end
      password.pack 'c*'
    end
  end
end
