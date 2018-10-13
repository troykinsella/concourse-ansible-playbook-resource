require 'json'
require 'ostruct'

class InputError < StandardError
  def initialize(msg)
    super(msg)
  end
end

class Input

  def self.instance(payload: nil)
    @instance = new(payload: payload) if payload
    @instance ||= begin
      payload = JSON.parse(ARGF.read)
      new(payload: payload)
    end
  end

  def self.reset
    @instance = nil
  end

  def initialize(payload:)
    @payload = payload
  end

  def source
    @source ||= OpenStruct.new @payload.fetch('source', {})
  end

  def version
    @version ||= OpenStruct.new @payload.fetch('version', {})
  end

  def params
    @params ||= OpenStruct.new @payload.fetch('params', {})
  end
end
