RSpec::Matchers.define :has_characters do
  match do |actual|
    actual && actual.instance_of?(String) && actual.strip.length > 0
  end
end

RSpec::Matchers.alias_matcher :has_symbols, :has_characters
RSpec::Matchers.alias_matcher :not_blank, :has_characters

RSpec::Matchers.define :be_ordered_by do |attribute|
  match do |actual|
    result = true
    reverse_indicator = "_desc"
    if attribute =~ /#{reverse_indicator}/
      symbol = attribute.gsub(/#{reverse_indicator}/, '').to_sym
      sorted = actual.sort {|a, b| b.send(symbol) <=> a.send(symbol)}
    else
      sorted = actual.sort {|a, b| a.updated_at <=> b.updated_at}
    end
    sorted.each_with_index do |a, i|
      result = false unless actual[i] == a
    end
    result # return true or false for this matcher.
  end

  failure_message do |actual|
    "expected that #{actual} would be sorted by #{attribute}"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not be sorted by #{attribute}"
  end

  description do
    "be a sorted by #{attribute}"
  end
end

RSpec::Matchers.define :has_path do |path|
  match do |url|
    begin
      return path.eql?(URI(url).path)
    rescue URI::InvalidURIError
      return false
    end
  end
end

RSpec::Matchers.define :has_query do |expected|
  match do |url|
    begin
      no_query_expected = expected.nil? || expected == '' || (expected.kind_of?(Hash) && expected.empty?)
      p_url = URI(url)
      return p_url.query.nil? if no_query_expected
      return no_query_expected if p_url.query.nil?

      if expected.kind_of?(Hash)
        expected_params = expected.stringify_keys
      else
        expected_params = URI::decode_www_form(expected).to_h
      end
      actual_params = URI::decode_www_form(p_url.query).to_h
      return expected_params.keys.all? do |exp_key|
        act_value = actual_params[exp_key]
        exp_value = expected_params[exp_key]
        return exp_value.eql?(act_value)
      end
    rescue URI::InvalidURIError
      return false
    end
  end
end