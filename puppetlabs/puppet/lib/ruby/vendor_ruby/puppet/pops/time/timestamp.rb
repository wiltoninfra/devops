module Puppet::Pops
module Time
class Timestamp < TimeData
  DEFAULT_FORMATS_WO_TZ = ['%FT%T.L', '%FT%T', '%F']
  DEFAULT_FORMATS = ['%FT%T.%L %Z', '%FT%T %Z', '%F %Z'] + DEFAULT_FORMATS_WO_TZ

  CURRENT_TIMEZONE = 'current'.freeze
  KEY_TIMEZONE = 'timezone'.freeze

  # Converts a timezone that strptime can parse using '%z' into '-HH:MM' or '+HH:MM'
  # @param [String] tz the timezone to convert
  # @return [String] the converted timezone
  #
  # @api private
  def self.convert_timezone(tz)
    if tz =~ /\A[+-]\d\d:\d\d\z/
      tz
    else
      offset = utc_offset(tz) / 60
      if offset < 0
        offset = offset.abs
        sprintf('-%2.2d:%2.2d', offset / 60, offset % 60)
      else
        sprintf('+%2.2d:%2.2d', offset / 60, offset % 60)
      end
    end
  end

  # Returns the zone offset from utc for the given `timezone`
  # @param [String] timezone the timezone to get the offset for
  # @return [Integer] the timezone offset, in seconds
  #
  # @api private
  def self.utc_offset(timezone)
    if CURRENT_TIMEZONE.casecmp(timezone) == 0
      ::Time.now.utc_offset
    else
      hash = DateTime._strptime(timezone, '%z')
      offset = hash.nil? ? nil : hash[:offset]
      raise ArgumentError, "Illegal timezone '#{timezone}'" if offset.nil?
      offset
    end
  end

  # Formats a ruby Time object using the given timezone
  def self.format_time(format, time, timezone)
    unless timezone.nil? || timezone.empty?
      time = time.localtime(convert_timezone(timezone))
    end
    time.strftime(format)
  end

  def self.now
    from_time(::Time.now)
  end

  def self.from_time(t)
    new(t.tv_sec * NSECS_PER_SEC + t.tv_nsec)
  end

  def self.from_hash(args_hash)
    parse(args_hash[KEY_STRING], args_hash[KEY_FORMAT], args_hash[KEY_TIMEZONE])
  end

  def self.parse(str, format = :default, timezone = nil)
    has_timezone = !(timezone.nil? || timezone.empty? || timezone == :default)
    if format.nil? || format == :default
      format = has_timezone ? DEFAULT_FORMATS_WO_TZ : DEFAULT_FORMATS
    end

    parsed = nil
    if format.is_a?(Array)
      format.each do |fmt|
        assert_no_tz_extractor(fmt) if has_timezone
        begin
          parsed = DateTime.strptime(str, fmt)
          break
        rescue ArgumentError
        end
      end
      raise ArgumentError, "Unable to parse '#{str}' using any of the formats #{format.join(', ')}" if parsed.nil?
    else
      assert_no_tz_extractor(format) if has_timezone
      begin
        parsed = DateTime.strptime(str, format)
      rescue ArgumentError
        raise ArgumentError, "Unable to parse '#{str}' using format '#{format}'"
      end
    end
    parsed_time = parsed.to_time
    parsed_time -= utc_offset(timezone) if has_timezone
    from_time(parsed_time)
  end

  def self.assert_no_tz_extractor(format)
    if format =~ /[^%]%[zZ]/
      raise ArgumentError, 'Using a Timezone designator in format specification is mutually exclusive to providing an explicit timezone argument'
    end
  end

  undef_method :-@, :+@, :div, :fdiv, :abs, :abs2, :magnitude # does not make sense on a Timestamp
  if method_defined?(:negative?)
    undef_method :negative?, :positive?
  end
  if method_defined?(:%)
    undef_method :%, :modulo, :divmod
  end

  def +(o)
    case o
    when Timespan
      Timestamp.new(@nsecs + o.nsecs)
    when Integer, Float
      Timestamp.new(@nsecs + (o * NSECS_PER_SEC).to_i)
    else
      raise ArgumentError, "#{a_an_uc(o)} cannot be added to a Timestamp"
    end
  end

  def -(o)
    case o
    when Timestamp
      # Diff between two timestamps is a timespan
      Timespan.new(@nsecs - o.nsecs)
    when Timespan
      Timestamp.new(@nsecs - o.nsecs)
    when Integer, Float
      # Subtract seconds
      Timestamp.new(@nsecs - (o * NSECS_PER_SEC).to_i)
    else
      raise ArgumentError, "#{a_an_uc(o)} cannot be subtracted from a Timestamp"
    end
  end

  def format(format, timezone = nil)
    self.class.format_time(format, to_time, timezone)
  end

  def to_s
    format(DEFAULT_FORMATS[0])
  end

  def to_time
    ::Time.at(to_r).utc
  end
end
end
end
