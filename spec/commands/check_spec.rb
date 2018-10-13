require 'spec_helper'

describe "commands:check" do

  let(:check_file) { '/opt/resource/check' }

  it('should exist') do
    expect(File).to exist(check_file)
    expect(File.stat(check_file).mode.to_s(8)[3..5]).to eq("755")
  end

  it('should return an empty array') do
    expect(`#{check_file}`).to eq("[]")
  end

end
